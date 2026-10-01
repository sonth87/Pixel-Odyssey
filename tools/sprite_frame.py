"""Positioning native sprites inside fixed-size animation frames."""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass

import numpy as np


@dataclass
class Anchor:
    feet_y: int
    center_x: int


def split_strip(rgba: np.ndarray, count: int) -> list[np.ndarray]:
    edges = np.rint(np.linspace(0, rgba.shape[1], count + 1)).astype(int)
    return [rgba[:, edges[i]:edges[i + 1]] for i in range(count)]


def find_anchor(rgba: np.ndarray) -> Anchor | None:
    ys, xs = np.nonzero(rgba[:, :, 3])
    if len(ys) == 0:
        return None
    feet_y = int(ys.max())
    # The lowest rows hold the feet; centering on them keeps the pivot stable when arms or weapons stick out.
    bottom = ys >= feet_y - 3
    return Anchor(feet_y, int(round(xs[bottom].mean())))


def place_in_frame(rgba: np.ndarray, width: int, height: int, anchor: Anchor) -> tuple[np.ndarray, int]:
    frame = np.zeros((height, width, 4), dtype=np.uint8)
    dy = (height - 1) - anchor.feet_y
    dx = width // 2 - anchor.center_x
    ys, xs = np.nonzero(rgba[:, :, 3])
    ty, tx = ys + dy, xs + dx
    inside = (ty >= 0) & (ty < height) & (tx >= 0) & (tx < width)
    frame[ty[inside], tx[inside]] = rgba[ys[inside], xs[inside]]
    return frame, int((~inside).sum())


def trim(rgba: np.ndarray) -> np.ndarray:
    ys, xs = np.nonzero(rgba[:, :, 3])
    if len(ys) == 0:
        return rgba
    return rgba[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def despeckle(rgba: np.ndarray, max_island: int) -> tuple[np.ndarray, int]:
    opaque = rgba[:, :, 3] > 0
    seen = np.zeros_like(opaque)
    result = rgba.copy()
    removed = 0
    h, w = opaque.shape
    for y, x in zip(*np.nonzero(opaque)):
        if seen[y, x]:
            continue
        island = _flood(opaque, seen, y, x, h, w)
        if len(island) <= max_island:
            for iy, ix in island:
                result[iy, ix, 3] = 0
            removed += len(island)
    return result, removed


def _flood(opaque: np.ndarray, seen: np.ndarray, y: int, x: int, h: int, w: int) -> list[tuple[int, int]]:
    island = []
    queue = deque([(y, x)])
    seen[y, x] = True
    while queue:
        cy, cx = queue.popleft()
        island.append((cy, cx))
        for ny in range(cy - 1, cy + 2):
            for nx in range(cx - 1, cx + 2):
                if 0 <= ny < h and 0 <= nx < w and opaque[ny, nx] and not seen[ny, nx]:
                    seen[ny, nx] = True
                    queue.append((ny, nx))
    return island
