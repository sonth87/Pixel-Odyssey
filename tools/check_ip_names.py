"""Check that game/shared/ and game/runner/ stay neutral with respect to any content pack's IP
(docs/05-technical/03-coding-standards.md rule 10, D-006): no character, location or move names from
the One Piece pack may appear in engine code. Content packs (game/content/<pack>/) are exempt — that is
exactly where those names belong.

The word list below is the One Piece pack's vocabulary; add future packs' vocabularies the same way.
Usage: python tools/check_ip_names.py [--game-dir game]
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ONE_PIECE_WORDS = [
    "luffy", "zoro", "nami", "sanji", "usopp", "chopper", "robin", "franky", "strawhat", "straw_hat",
    "onepiece", "one_piece", "gomu", "mera", "hie", "pika", "nikyu", "bari", "gear4", "gear_4",
    "marine", "baroque", "billions", "crocodile", "alabasta", "rainbase", "alubarna", "sandora",
    "going_merry", "thousand_sunny", "berries", "devil_fruit", "sabaody", "wano", "kaido",
]
CHECKED_LAYERS = ("shared", "runner")
LINE_COMMENT_RE = re.compile(r"#.*")


def build_pattern(words: list[str]) -> re.Pattern:
    return re.compile(r"\b(" + "|".join(re.escape(w) for w in words) + r")\b", re.IGNORECASE)


def scan_file(path: Path, pattern: re.Pattern) -> list[str]:
    hits = []
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        code = LINE_COMMENT_RE.sub("", line)
        for match in pattern.finditer(code):
            hits.append(f"{path}:{lineno}: {match.group(1)!r} in: {code.strip()}")
    return hits


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--game-dir", type=Path, default=Path(__file__).resolve().parent.parent / "game")
    parser.add_argument("--words", nargs="*", default=ONE_PIECE_WORDS)
    args = parser.parse_args()

    pattern = build_pattern(args.words)
    violations: list[str] = []
    for layer in CHECKED_LAYERS:
        layer_dir = args.game_dir / layer
        if not layer_dir.exists():
            continue
        for path in layer_dir.rglob("*.gd"):
            violations.extend(scan_file(path, pattern))

    for line in violations:
        print(f"FAIL {line}")
    print(f"{len(violations)} violation(s) found")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
