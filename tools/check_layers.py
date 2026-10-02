"""Check the layer dependency rules of docs/05-technical/01-architecture.md §2 (NFR-MT-02):

  shared/  must not reference runner/, app/, or content/
  runner/  must not reference app/, or a specific content pack by path (content/common/ is pack-neutral)
  content/ must not contain gameplay scripts (.gd files)

GDScript classes are global (no imports), so a "reference" is either a whole-word use of another file's
class_name, or a literal res://... path. This is a heuristic: a local variable that happens to share a
class's name would also match. In practice project class names are specific enough that this does not
occur; `--verbose` prints every match found so a false positive can be checked by hand.

Usage: python tools/check_layers.py [--game-dir game] [--verbose]
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

CLASS_NAME_RE = re.compile(r"^class_name\s+(\w+)", re.MULTILINE)
RES_PATH_RE = re.compile(r'res://([\w./]+)')
IDENTIFIER_RE = re.compile(r"\b[A-Za-z_]\w*\b")
LINE_COMMENT_RE = re.compile(r"#.*")

LAYER_ROOTS = ("shared", "runner", "app", "content")


def strip_comments(source: str) -> str:
    return "\n".join(LINE_COMMENT_RE.sub("", line) for line in source.splitlines())


def layer_of(path: Path, game_dir: Path) -> str | None:
    relative = path.relative_to(game_dir).parts
    return relative[0] if relative and relative[0] in LAYER_ROOTS else None


def build_class_map(game_dir: Path) -> dict[str, Path]:
    classes: dict[str, Path] = {}
    for path in game_dir.rglob("*.gd"):
        if layer_of(path, game_dir) is None or "addons" in path.parts:
            continue
        match = CLASS_NAME_RE.search(path.read_text(encoding="utf-8"))
        if match:
            classes[match.group(1)] = path
    return classes


def forbidden_roots(source_layer: str) -> set[str]:
    if source_layer == "shared":
        return {"runner", "app", "content"}
    if source_layer == "runner":
        return {"app"}
    return set()


def content_pack_of(res_path: str) -> str | None:
    parts = res_path.split("/")
    return parts[1] if len(parts) > 1 and parts[0] == "content" and parts[1] != "common" else None


def check_file(path: Path, game_dir: Path, classes: dict[str, Path], verbose: bool) -> list[str]:
    source_layer = layer_of(path, game_dir)
    if source_layer not in ("shared", "runner"):
        return []
    forbidden = forbidden_roots(source_layer)
    code = strip_comments(path.read_text(encoding="utf-8"))
    rel = path.relative_to(game_dir)
    violations = []

    for res_path in RES_PATH_RE.findall(code):
        root = res_path.split("/")[0]
        pack = content_pack_of(res_path)
        if root in forbidden or (source_layer == "runner" and pack):
            violations.append(f"{rel}: literal path res://{res_path}")

    identifiers = set(IDENTIFIER_RE.findall(code))
    for name in identifiers & classes.keys():
        target = classes[name]
        if target == path:
            continue
        target_layer = layer_of(target, game_dir)
        if target_layer in forbidden:
            violations.append(f"{rel}: uses {name} ({target.relative_to(game_dir)})")
            if verbose:
                print(f"  match: {name!r} found in {rel}")

    return violations


def check_content_scripts(game_dir: Path) -> list[str]:
    content_dir = game_dir / "content"
    if not content_dir.exists():
        return []
    return [f"content/{p.relative_to(content_dir)}: gameplay script not allowed in content/"
            for p in content_dir.rglob("*.gd")]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--game-dir", type=Path, default=Path(__file__).resolve().parent.parent / "game")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    classes = build_class_map(args.game_dir)
    violations: list[str] = []
    for layer in ("shared", "runner"):
        for path in (args.game_dir / layer).rglob("*.gd"):
            violations.extend(check_file(path, args.game_dir, classes, args.verbose))
    violations.extend(check_content_scripts(args.game_dir))

    for line in violations:
        print(f"FAIL {line}")
    print(f"{len(violations)} violation(s) found")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
