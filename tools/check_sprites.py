"""Check exported animation strips (one horizontal PNG strip per animation tag).

Usage: python tools/check_sprites.py <strip.png|folder> [--frame 64x64] [--palette file.gpl] [--max-colors 16]
Errors (exit 1): wrong strip size, semi-transparent pixels, empty frames.
Warnings: too many colors, colors outside the palette, feet not on the bottom row, odd file names.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
import pixel_art as pa  # noqa: E402

TAG_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")
FEET_EVERY_FRAME = {"idle", "land", "hurt", "eat", "taunt", "sit", "sit_idle", "form_idle", "form_land", "block"}
AIRBORNE = {"jump_rise", "jump_apex", "fall", "double_jump", "death_fall", "form_jump_rise", "form_fall"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate animation strips")
    parser.add_argument("input", type=Path)
    parser.add_argument("--frame", default="64x64")
    parser.add_argument("--palette", type=Path, default=None)
    parser.add_argument("--max-colors", type=int, default=16)
    return parser.parse_args()


def frames_of(rgba: np.ndarray, width: int) -> list[np.ndarray]:
    return [rgba[:, x:x + width] for x in range(0, rgba.shape[1], width)]


def check_shape(rgba: np.ndarray, width: int, height: int) -> list[str]:
    errors = []
    if rgba.shape[0] != height:
        errors.append(f"height {rgba.shape[0]} != frame height {height}")
    if rgba.shape[1] % width:
        errors.append(f"width {rgba.shape[1]} is not a multiple of frame width {width}")
    alpha = rgba[:, :, 3]
    partial = int(((alpha > 0) & (alpha < 255)).sum())
    if partial:
        errors.append(f"{partial} semi-transparent pixels (alpha must be 0 or 255)")
    return errors


def check_frames(tag: str, frames: list[np.ndarray]) -> tuple[list[str], list[str]]:
    errors, warnings = [], []
    grounded = [bool(frame[-1, :, 3].any()) for frame in frames]
    for index, frame in enumerate(frames):
        if not frame[:, :, 3].any():
            errors.append(f"frame {index + 1} is empty")
    if tag in FEET_EVERY_FRAME and not all(grounded):
        missing = [i + 1 for i, g in enumerate(grounded) if not g]
        warnings.append(f"feet not on the bottom row in frames {missing}")
    elif tag not in AIRBORNE and not any(grounded):
        warnings.append("no frame touches the bottom row (pivot is bottom-center)")
    return errors, warnings


def check_colors(rgba: np.ndarray, palette: list[tuple[int, int, int]] | None, max_colors: int) -> list[str]:
    colors = set(pa.opaque_colors(rgba))
    warnings = []
    if len(colors) > max_colors:
        warnings.append(f"{len(colors)} colors (target <= {max_colors})")
    if palette:
        outside = sorted(colors - set(palette))
        if outside:
            sample = ", ".join(f"#{r:02X}{g:02X}{b:02X}" for r, g, b in outside[:5])
            warnings.append(f"{len(outside)} colors outside the palette: {sample}")
    return warnings


def check_strip(path: Path, width: int, height: int, palette: list | None, max_colors: int) -> tuple[list, list]:
    rgba = np.array(Image.open(path).convert("RGBA"))
    errors = check_shape(rgba, width, height)
    warnings = [] if TAG_PATTERN.match(path.stem) else [f"file name '{path.stem}' is not a valid tag name"]
    if not errors:
        frame_errors, frame_warnings = check_frames(path.stem, frames_of(rgba, width))
        errors += frame_errors
        warnings += frame_warnings
    warnings += check_colors(rgba, palette, max_colors)
    count = rgba.shape[1] // width if rgba.shape[1] % width == 0 else "?"
    print(f"{'FAIL' if errors else 'ok  '} {path.name}: {count} frame(s)")
    for message in errors:
        print(f"     x {message}")
    for message in warnings:
        print(f"     ! {message}")
    return errors, warnings


def main() -> int:
    args = parse_args()
    width, height = (int(v) for v in args.frame.lower().split("x"))
    palette = pa.read_gpl(args.palette) if args.palette else None
    paths = sorted(args.input.glob("*.png")) if args.input.is_dir() else [args.input]
    failed = sum(bool(check_strip(p, width, height, palette, args.max_colors)[0]) for p in paths)
    print(f"\n{len(paths)} strip(s), {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
