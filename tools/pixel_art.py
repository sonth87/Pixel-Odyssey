"""Shared helpers for turning upscaled or AI-generated pixel art into native-resolution sprites."""

from __future__ import annotations

from collections import Counter, deque
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

MAGENTA = (255, 0, 255)


@dataclass
class AxisFit:
    period: float
    offset: float
    score: float


@dataclass
class GridFit:
    cell: float
    offset_x: float
    offset_y: float
    score: float
    error: float = 0.0


def load_rgb(path: Path) -> np.ndarray:
    image = Image.open(path)
    if image.mode in ("RGBA", "LA", "P"):
        rgba = np.array(image.convert("RGBA"))
        rgb = rgba[:, :, :3].copy()
        rgb[rgba[:, :, 3] < 128] = MAGENTA
        return rgb
    return np.array(image.convert("RGB"))


def edge_profile(rgb: np.ndarray, axis: int) -> np.ndarray:
    diff = np.abs(np.diff(rgb.astype(np.int32), axis=axis)).sum(axis=2)
    profile = diff.sum(axis=0 if axis == 1 else 1).astype(np.float64)
    # Edges in AI images are often smeared over 2-3 px; blurring keeps the comb from missing them.
    return np.convolve(profile, [0.25, 0.5, 0.25], mode="same")


def _comb_score(profile: np.ndarray, period: float, offset: float, mean: float) -> float:
    n = len(profile)
    first = int(np.ceil((1 - offset) / period))
    last = int(np.floor((n - offset) / period))
    if last - first < 2:
        return 0.0
    idx = np.rint(offset + np.arange(first, last + 1) * period).astype(int) - 1
    idx = idx[(idx >= 0) & (idx < n)]
    return float(profile[idx].mean() / mean)


def best_offset(profile: np.ndarray, period: float, step: float = 0.5) -> AxisFit:
    mean = profile.mean() + 1e-9
    return max((AxisFit(period, offset, _comb_score(profile, period, offset, mean))
                for offset in np.arange(0, period, step)), key=lambda fit: fit.score)


def content_box(rgb: np.ndarray, margin: int = 8) -> tuple[slice, slice]:
    corners = np.array([rgb[0, 0], rgb[0, -1], rgb[-1, 0], rgb[-1, -1]], dtype=np.int32)
    background = np.median(corners, axis=0)
    ys, xs = np.nonzero(np.abs(rgb.astype(np.int32) - background).sum(axis=2) > 40)
    if len(ys) == 0:
        return slice(None), slice(None)
    return (slice(max(ys.min() - margin, 0), ys.max() + margin + 1),
            slice(max(xs.min() - margin, 0), xs.max() + margin + 1))


def _sample_error(rgb: np.ndarray, box: tuple[slice, slice], cell: float, ox: float, oy: float) -> float:
    ys = np.arange(rgb.shape[0])[box[0]][::2]
    xs = np.arange(rgb.shape[1])[box[1]][::2]
    cy = np.clip(np.rint(oy + (np.floor((ys - oy) / cell) + 0.5) * cell), 0, rgb.shape[0] - 1).astype(int)
    cx = np.clip(np.rint(ox + (np.floor((xs - ox) / cell) + 0.5) * cell), 0, rgb.shape[1] - 1).astype(int)
    rebuilt = rgb[cy][:, cx].astype(np.int32)
    return float(np.abs(rebuilt - rgb[ys][:, xs].astype(np.int32)).mean())


def _fit(rgb: np.ndarray, box: tuple[slice, slice], profiles: tuple[np.ndarray, np.ndarray],
         cell: float, step: float) -> GridFit:
    fx = best_offset(profiles[0], cell, step)
    fy = best_offset(profiles[1], cell, step)
    return GridFit(cell, fx.offset, fy.offset, min(fx.score, fy.score),
                   _sample_error(rgb, box, cell, fx.offset, fy.offset))


def detect_grid(rgb: np.ndarray, forced_cell: float | None = None,
                min_cell: float = 3.0, max_cell: float = 64.0) -> GridFit:
    box = content_box(rgb)
    profiles = (edge_profile(rgb, axis=1), edge_profile(rgb, axis=0))
    if forced_cell:
        grid = _fit(rgb, box, profiles, forced_cell, 0.25)
    else:
        coarse = [_fit(rgb, box, profiles, cell, 0.5) for cell in np.arange(min_cell, max_cell, 0.25)]
        floor_error = min(fit.error for fit in coarse)
        # Divisors of the true cell rebuild the image just as well, multiples do not:
        # the largest cell that still rebuilds well is the real one.
        candidate = max((fit for fit in coarse if fit.error <= floor_error * 1.25 + 1.0), key=lambda f: f.cell)
        fine = [_fit(rgb, box, profiles, cell, 0.25)
                for cell in np.arange(candidate.cell - 0.3, candidate.cell + 0.3, 0.02)]
        grid = min(fine, key=lambda fit: fit.error)
    grid.offset_x %= grid.cell
    grid.offset_y %= grid.cell
    grid.error = reconstruction_error(rgb, downscale(rgb, grid), grid)
    return grid


def _cell_ranges(length: int, cell: float, offset: float) -> list[tuple[int, int]]:
    ranges = []
    k = 0
    while offset + (k + 1) * cell <= length + 0.5:
        start = offset + k * cell
        lo = int(round(start + cell * 0.25))
        hi = max(lo + 1, int(round(start + cell * 0.75)))
        ranges.append((lo, min(hi, length)))
        k += 1
    return ranges


def downscale(rgb: np.ndarray, grid: GridFit) -> np.ndarray:
    rows = _cell_ranges(rgb.shape[0], grid.cell, grid.offset_y)
    cols = _cell_ranges(rgb.shape[1], grid.cell, grid.offset_x)
    native = np.zeros((len(rows), len(cols), 3), dtype=np.uint8)
    for r, (y0, y1) in enumerate(rows):
        for c, (x0, x1) in enumerate(cols):
            native[r, c] = np.median(rgb[y0:y1, x0:x1].reshape(-1, 3), axis=0)
    return native


def reconstruction_error(rgb: np.ndarray, native: np.ndarray, grid: GridFit) -> float:
    ys = np.clip(((np.arange(rgb.shape[0]) - grid.offset_y) // grid.cell).astype(int), 0, native.shape[0] - 1)
    xs = np.clip(((np.arange(rgb.shape[1]) - grid.offset_x) // grid.cell).astype(int), 0, native.shape[1] - 1)
    rebuilt = native[ys][:, xs]
    return float(np.abs(rebuilt.astype(np.int32) - rgb.astype(np.int32)).mean())


def border_key(native: np.ndarray) -> tuple[int, int, int]:
    border = np.concatenate([native[0], native[-1], native[:, 0], native[:, -1]])
    return Counter(map(tuple, border.tolist())).most_common(1)[0][0]


def remove_background(native: np.ndarray, key: tuple[int, int, int], tolerance: float = 40.0,
                      hole_tolerance: float = 12.0) -> np.ndarray:
    h, w, _ = native.shape
    distance = np.linalg.norm(native.astype(np.float64) - np.array(key), axis=2)
    close = distance <= tolerance
    background = np.zeros((h, w), dtype=bool)
    queue = deque((y, x) for y in range(h) for x in (0, w - 1)) + deque((y, x) for x in range(w) for y in (0, h - 1))
    while queue:
        y, x = queue.popleft()
        if background[y, x] or not close[y, x]:
            continue
        background[y, x] = True
        queue.extend((ny, nx) for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1))
                     if 0 <= ny < h and 0 <= nx < w)
    # Pockets enclosed by the sprite are unreachable from the border; only near-exact key matches are
    # removed there so light sprite colors (skin, white cloth) close to the key survive.
    background |= distance <= hole_tolerance
    alpha = np.where(background, 0, 255).astype(np.uint8)
    return np.dstack([native, alpha])


def rgb_to_lab(rgb: np.ndarray) -> np.ndarray:
    c = rgb.astype(np.float64) / 255.0
    linear = np.where(c > 0.04045, ((c + 0.055) / 1.055) ** 2.4, c / 12.92)
    xyz = linear @ np.array([[0.4124, 0.2126, 0.0193], [0.3576, 0.7152, 0.1192], [0.1805, 0.0722, 0.9505]])
    xyz /= np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], axis=-1)


def snap_to_palette(rgba: np.ndarray, palette: list[tuple[int, int, int]]) -> np.ndarray:
    result = rgba.copy()
    opaque = rgba[:, :, 3] > 0
    pixels_lab = rgb_to_lab(rgba[opaque][:, :3])
    palette_arr = np.array(palette, dtype=np.uint8)
    distances = np.linalg.norm(pixels_lab[:, None, :] - rgb_to_lab(palette_arr)[None, :, :], axis=2)
    result[opaque, :3] = palette_arr[distances.argmin(axis=1)]
    return result


def snap_palette_to(colors: list[tuple[int, int, int]],
                    palette: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    palette_lab = rgb_to_lab(np.array(palette, dtype=np.uint8))
    snapped = []
    for lab in rgb_to_lab(np.array(colors, dtype=np.uint8)):
        nearest = palette[int(np.linalg.norm(palette_lab - lab, axis=1).argmin())]
        if nearest not in snapped:
            snapped.append(nearest)
    return snapped


def quantize(rgba: np.ndarray, max_colors: int) -> np.ndarray:
    opaque = rgba[:, :, 3] > 0
    strip = Image.fromarray(rgba[opaque][:, :3].reshape(1, -1, 3))
    reduced = strip.quantize(colors=max_colors, method=Image.Quantize.MEDIANCUT).getpalette()
    palette = [tuple(reduced[i:i + 3]) for i in range(0, max_colors * 3, 3)]
    return snap_to_palette(rgba, palette)


def opaque_colors(rgba: np.ndarray) -> Counter:
    return Counter(map(tuple, rgba[rgba[:, :, 3] > 0][:, :3].tolist()))


def merge_similar(counts: Counter, threshold: float) -> list[tuple[tuple[int, int, int], int]]:
    kept: list[list] = []
    for color, count in counts.most_common():
        lab = rgb_to_lab(np.array([color], dtype=np.uint8))[0]
        match = next((entry for entry in kept if np.linalg.norm(entry[2] - lab) < threshold), None)
        if match:
            match[1] += count
        else:
            kept.append([color, count, lab])
    return [(tuple(entry[0]), entry[1]) for entry in kept]


def read_gpl(path: Path) -> list[tuple[int, int, int]]:
    colors = []
    for line in path.read_text().splitlines():
        parts = line.split()
        if len(parts) >= 3 and all(p.isdigit() for p in parts[:3]):
            colors.append((int(parts[0]), int(parts[1]), int(parts[2])))
    return colors


def write_gpl(path: Path, name: str, colors: list[tuple[int, int, int]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = ["GIMP Palette", f"Name: {name}", "Columns: 8", "#"]
    lines += [f"{r:3d} {g:3d} {b:3d}\t#{r:02X}{g:02X}{b:02X}" for r, g, b in colors]
    path.write_text("\n".join(lines) + "\n")
