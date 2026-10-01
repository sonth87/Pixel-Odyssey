"""Build the master palette and per-character palettes from single-character reference sprites.

Group sheets are skipped: their non-integer grids produce blended edge colors.

Usage: python tools/extract_palette.py [--input assets/charactors] [--out art-source/palettes]
"""

from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
import pixel_art as pa  # noqa: E402

REPO = Path(__file__).resolve().parent.parent
CHARACTERS = ("luffy", "zoro", "nami", "sanji", "usopp", "chopper", "robin", "franky")
# The reference sheets draw a light dashed ground line close to the paper color; it is not part of any sprite.
GROUND_TOLERANCE = 44.0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract .gpl palettes from reference sprites")
    parser.add_argument("--input", type=Path, default=REPO / "assets" / "charactors")
    parser.add_argument("--out", type=Path, default=REPO / "art-source" / "palettes")
    parser.add_argument("--merge", type=float, default=6.0, help="merge colors closer than this delta E")
    parser.add_argument("--min-count", type=int, default=3, help="drop colors used by fewer pixels")
    return parser.parse_args()


def sprite_colors(path: Path) -> Counter:
    rgb = pa.load_rgb(path)
    native = pa.downscale(rgb, pa.detect_grid(rgb))
    return pa.opaque_colors(pa.remove_background(native, pa.border_key(native), GROUND_TOLERANCE))


def owner(path: Path) -> str | None:
    found = [name for name in CHARACTERS if name in path.stem.lower()]
    return found[0] if len(found) == 1 else None


def sort_key(color: tuple[int, int, int]) -> tuple[int, float, float]:
    lightness, a, b = pa.rgb_to_lab(np.array([color], dtype=np.uint8))[0]
    if np.hypot(a, b) < 10:
        return (0, 0.0, -lightness)
    return (1, round(float(np.degrees(np.arctan2(b, a))) % 360 / 30), -lightness)


def finalize(counts: Counter, args: argparse.Namespace) -> list[tuple[int, int, int]]:
    merged = pa.merge_similar(counts, args.merge)
    return sorted((color for color, count in merged if count >= args.min_count), key=sort_key)


def main() -> int:
    args = parse_args()
    master: Counter = Counter()
    per_character: dict[str, Counter] = {name: Counter() for name in CHARACTERS}
    for path in sorted(p for p in args.input.iterdir() if p.suffix.lower() in {".png", ".jpg"}):
        name = owner(path)
        if name is None:
            continue
        colors = sprite_colors(path)
        master.update(colors)
        per_character[name].update(colors)
    master_colors = finalize(master, args)
    pa.write_gpl(args.out / "master.gpl", "master", master_colors)
    print(f"master: {len(master_colors)} colors")
    for name, counts in per_character.items():
        if not counts:
            continue
        colors = pa.snap_palette_to(finalize(counts, args), master_colors)
        pa.write_gpl(args.out / "characters" / f"{name}.gpl", name, colors)
        print(f"{name}: {len(colors)} colors")
    return 0


if __name__ == "__main__":
    sys.exit(main())
