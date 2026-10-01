"""Convert AI-generated or upscaled "pixel art" into native-resolution sprites.

Usage: python tools/pixelize.py <image|folder> [--frame 64x64] [--palette file.gpl] [--strip N] ...
See docs/02-art/05-ai-image-pipeline.md.
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
import pixel_art as pa  # noqa: E402
import sprite_frame as sf  # noqa: E402

REPO = Path(__file__).resolve().parent.parent
IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp"}
UNCERTAIN_ERROR = 12.0
UNCERTAIN_SCORE = 3.0


@dataclass
class Report:
    source: Path
    lines: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def print(self) -> None:
        print(f"\n== {self.source}")
        for line in self.lines:
            print(f"   {line}")
        for warning in self.warnings:
            print(f"   ! {warning}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="AI image -> real pixel art sprite")
    parser.add_argument("input", type=Path)
    parser.add_argument("--frame", default="64x64", help="WxH frame, or 'none' to keep the trimmed size")
    parser.add_argument("--grid", type=float, default=None, help="force the source pixel cell size")
    parser.add_argument("--key", default="auto", help="background color as #RRGGBB, or auto")
    parser.add_argument("--tolerance", type=float, default=40.0, help="background match distance (RGB)")
    parser.add_argument("--palette", type=Path, default=None, help=".gpl palette to snap colors to")
    parser.add_argument("--max-colors", type=int, default=16, help="used when no palette is given")
    parser.add_argument("--strip", type=int, default=1, help="number of frames in a horizontal strip")
    parser.add_argument("--despeckle", type=int, default=0, help="remove isolated islands up to N pixels")
    parser.add_argument("--preview", type=int, default=8, help="scale of the preview image, 0 to skip")
    parser.add_argument("--out", type=Path, default=None)
    return parser.parse_args()


def output_dir(source: Path, out: Path | None) -> Path:
    if out:
        return out
    raw = REPO / "art-source" / "raw"
    resolved = source.resolve().parent
    if resolved.is_relative_to(raw):
        return REPO / "art-source" / "processed" / resolved.relative_to(raw)
    return REPO / "art-source" / "processed" / resolved.name


def parse_key(value: str, native: np.ndarray) -> tuple[int, int, int]:
    if value == "auto":
        return pa.border_key(native)
    hex_value = value.lstrip("#")
    return tuple(int(hex_value[i:i + 2], 16) for i in (0, 2, 4))


def recolor(rgba: np.ndarray, args: argparse.Namespace) -> np.ndarray:
    if args.palette:
        return pa.snap_to_palette(rgba, pa.read_gpl(args.palette))
    return pa.quantize(rgba, args.max_colors)


def to_frames(rgba: np.ndarray, args: argparse.Namespace, report: Report) -> list[np.ndarray]:
    cells = sf.split_strip(rgba, args.strip) if args.strip > 1 else [rgba]
    if args.frame == "none":
        return [sf.trim(cell) for cell in cells]
    width, height = (int(v) for v in args.frame.lower().split("x"))
    anchor = sf.find_anchor(cells[0])
    if anchor is None:
        report.warnings.append("first frame is empty after background removal")
        return cells
    frames = []
    for index, cell in enumerate(cells):
        framed, clipped = sf.place_in_frame(cell, width, height, anchor)
        if clipped:
            report.warnings.append(f"frame {index + 1}: {clipped} pixels fall outside {args.frame}")
        frames.append(framed)
    return frames


def save(frames: list[np.ndarray], source: Path, args: argparse.Namespace, report: Report) -> None:
    folder = output_dir(source, args.out)
    folder.mkdir(parents=True, exist_ok=True)
    names = [f"{source.stem}.png"] if len(frames) == 1 else [f"{source.stem}_f{i + 1}.png" for i in range(len(frames))]
    for frame, name in zip(frames, names):
        Image.fromarray(frame, "RGBA").save(folder / name)
    if args.preview:
        sheet = np.concatenate([np.pad(f, ((0, 0), (0, 1), (0, 0))) for f in frames], axis=1)
        preview = Image.fromarray(sheet, "RGBA").resize(
            (sheet.shape[1] * args.preview, sheet.shape[0] * args.preview), Image.NEAREST)
        preview.save(folder / f"{source.stem}_preview.png")
    report.lines.append(f"saved {len(frames)} frame(s) to {folder.relative_to(REPO) if folder.is_relative_to(REPO) else folder}")


def process(source: Path, args: argparse.Namespace) -> Report:
    report = Report(source)
    rgb = pa.load_rgb(source)
    grid = pa.detect_grid(rgb, args.grid)
    native = pa.downscale(rgb, grid)
    report.lines.append(f"source {rgb.shape[1]}x{rgb.shape[0]} -> cell {grid.cell:.2f}px "
                        f"(offset {grid.offset_x:.1f},{grid.offset_y:.1f}) -> native {native.shape[1]}x{native.shape[0]}")
    report.lines.append(f"grid score {grid.score:.1f}, rebuild error {grid.error:.1f}")
    if grid.error > UNCERTAIN_ERROR or grid.score < UNCERTAIN_SCORE:
        report.warnings.append("grid detection uncertain - check the preview or retry with --grid <cell>")
    rgba = pa.remove_background(native, parse_key(args.key, native), args.tolerance)
    before = len(pa.opaque_colors(rgba))
    rgba = recolor(rgba, args)
    if args.despeckle:
        rgba, removed = sf.despeckle(rgba, args.despeckle)
        report.lines.append(f"despeckle removed {removed} px")
    report.lines.append(f"colors {before} -> {len(pa.opaque_colors(rgba))}")
    save(to_frames(rgba, args, report), source, args, report)
    return report


def main() -> int:
    args = parse_args()
    sources = sorted(p for p in args.input.iterdir() if p.suffix.lower() in IMAGE_SUFFIXES) \
        if args.input.is_dir() else [args.input]
    reports = [process(source, args) for source in sources]
    for report in reports:
        report.print()
    return 1 if any(report.warnings for report in reports) else 0


if __name__ == "__main__":
    sys.exit(main())
