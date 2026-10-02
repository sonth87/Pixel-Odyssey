"""Slice the Runa sample sprite sheet (sample/image copy 2.png) into per-animation PNG strips.

One-off conversion for viewing the pose sample in Godot; not part of the production pipeline.
Usage: python art-source/drafts/samples/runa/slice_sheet.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image

REPO = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(REPO / "tools"))
import pixel_art as pa  # noqa: E402

SHEET = REPO / "sample" / "image copy 2.png"
OUT = REPO / "game" / "content" / "samples" / "runa" / "sprites" / "base"
BG = (227, 230, 236)
CELL = 3.0                  # source pixels per art pixel, measured by eye on the sheet
FRAME = 96
COLS = [0, 128, 256, 384, 513, 638, 768, 893, 1022]
ROW_LINES = [83, 257, 448, 639, 830, 1022]
LABEL_BOX = (0, 140, 30)    # label text sits in the first column's top-left corner of each row
ROWS = {                    # tag: (row index, first cell, last cell)
    "idle": (0, 2, 5),
    "walk": (1, 0, 7),
    "run": (2, 0, 7),
    "jump": (3, 2, 5),
}
FALL_ROW = 4
FALL_WINDOW = 216
FALL_SPANS = [(92, 300), (318, 512), (578, 690), (760, 900)]   # the sprites overlap the cell grid here


def clean_sheet(rgb: np.ndarray) -> np.ndarray:
    out = rgb.copy()
    rgb_i = out.astype(int)
    mean, spread = rgb_i.mean(axis=2), rgb_i.max(axis=2) - rgb_i.min(axis=2)
    lines = (spread < 25) & (mean > 150) & (mean < 215)
    for x in COLS:
        out[:, max(x - 3, 0):x + 4][lines[:, max(x - 3, 0):x + 4]] = BG
    for y in ROW_LINES:
        out[max(y - 3, 0):y + 4][lines[max(y - 3, 0):y + 4]] = BG
        x0, x1, h = LABEL_BOX
        out[y:y + h, x0:x1] = BG
    return out


def native(window: np.ndarray) -> np.ndarray:
    grid = pa.GridFit(CELL, 0.0, 0.0, 0.0)
    small = pa.downscale(window, grid)
    return pa.remove_background(small, BG, 40.0)


def place(cells: list[np.ndarray]) -> list[np.ndarray]:
    bottoms = [np.nonzero(c[:, :, 3])[0].max() for c in cells]
    baseline = max(bottoms)
    frames = []
    for cell in cells:
        frame = np.zeros((FRAME, FRAME, 4), dtype=np.uint8)
        h, w, _ = cell.shape
        top = FRAME - 1 - baseline
        left = (FRAME - w) // 2
        ys, xs = np.nonzero(cell[:, :, 3])
        for y, x in zip(ys, xs):
            if 0 <= top + y < FRAME and 0 <= left + x < FRAME:
                frame[top + y, left + x] = cell[y, x]
        frames.append(frame)
    return frames


def row_cells(rgb: np.ndarray, row: int, first: int, last: int) -> list[np.ndarray]:
    y0, y1 = ROW_LINES[row] + 3, ROW_LINES[row + 1] - 3
    return [native(rgb[y0:y1, COLS[c] + 3:COLS[c + 1] - 3]) for c in range(first, last + 1)]


def fall_cells(rgb: np.ndarray) -> list[np.ndarray]:
    y0, y1 = ROW_LINES[FALL_ROW] + 3, ROW_LINES[FALL_ROW + 1] - 3
    cells = []
    for x0, x1 in FALL_SPANS:
        window = np.full((y1 - y0, FALL_WINDOW, 3), BG, dtype=np.uint8)
        left = (FALL_WINDOW - (x1 - x0)) // 2
        window[:, left:left + x1 - x0] = rgb[y0:y1, x0:x1]
        cells.append(native(window))
    return cells


def save_strip(tag: str, frames: list[np.ndarray]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.concatenate(frames, axis=1), "RGBA").save(OUT / f"{tag}.png")
    print(f"{tag}: {len(frames)} frames")


def main() -> None:
    rgb = clean_sheet(np.array(Image.open(SHEET).convert("RGB")))
    for tag, (row, first, last) in ROWS.items():
        save_strip(tag, place(row_cells(rgb, row, first, last)))
    save_strip("fall", place(fall_cells(rgb)))


if __name__ == "__main__":
    main()
