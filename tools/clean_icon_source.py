#!/usr/bin/env python3
"""clean_icon_source.py

Remove checkerboard-like background from `assets/icon_souce.png` by
detecting dominant border colors and making connected background areas
transparent. Creates a backup `assets/icon_souce_backup.png` before overwrite.

Usage: python tools/clean_icon_source.py
Requires: Pillow (pip install pillow)
"""
from PIL import Image, ImageFilter
import os
from collections import Counter, deque
import math

SRC = os.path.join("assets", "icon_souce.png")
BACKUP = os.path.join("assets", "icon_souce_backup.png")


def color_dist_sq(a, b):
    return (a[0]-b[0])**2 + (a[1]-b[1])**2 + (a[2]-b[2])**2


def main():
    if not os.path.exists(SRC):
        print(f"Source not found: {SRC}")
        return 2

    if not os.path.exists(BACKUP):
        os.replace(SRC, BACKUP)
        print(f"Backed up original to: {BACKUP}")
    else:
        print(f"Backup already exists: {BACKUP} — will overwrite SRC from backup")

    img = Image.open(BACKUP).convert("RGBA")
    w, h = img.size
    px = img.load()

    # sample border pixels
    border = []
    bw = max(1, int(min(w, h) * 0.06))
    for x in range(w):
        for y in range(bw):
            border.append(px[x, y][:3])
        for y in range(h - bw, h):
            border.append(px[x, y][:3])
    for y in range(h):
        for x in range(bw):
            border.append(px[x, y][:3])
        for x in range(w - bw, w):
            border.append(px[x, y][:3])

    counts = Counter(border)
    common = [c for c, _ in counts.most_common(6)]

    # create boolean map of pixels similar to any common border color
    threshold = 40  # euclidean distance threshold
    threshold_sq = threshold * threshold
    similar = [[False]*h for _ in range(w)]
    for x in range(w):
        for y in range(h):
            rgb = px[x, y][:3]
            md = min(color_dist_sq(rgb, c) for c in common)
            if md <= threshold_sq:
                similar[x][y] = True

    # flood-fill from border to find connected background area
    visited = [[False]*h for _ in range(w)]
    q = deque()
    for x in range(w):
        for y in range(bw):
            if similar[x][y]:
                q.append((x, y)); visited[x][y] = True
        for y in range(h-bw, h):
            if similar[x][y]:
                q.append((x, y)); visited[x][y] = True
    for y in range(h):
        for x in range(bw):
            if similar[x][y] and not visited[x][y]:
                q.append((x, y)); visited[x][y] = True
        for x in range(w-bw, w):
            if similar[x][y] and not visited[x][y]:
                q.append((x, y)); visited[x][y] = True

    while q:
        cx, cy = q.popleft()
        for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
            nx, ny = cx+dx, cy+dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny] and similar[nx][ny]:
                visited[nx][ny] = True
                q.append((nx, ny))

    # prepare cleaned image
    out = Image.new("RGBA", (w, h))
    out_px = out.load()

    # fade threshold for edge pixels (smooth anti-aliased borders)
    fade_threshold = 80
    fade_sq = fade_threshold * fade_threshold

    for x in range(w):
        for y in range(h):
            r, g, b, a = px[x, y]
            if visited[x][y]:
                out_px[x, y] = (r, g, b, 0)
            else:
                # compute min distance to background colors
                md_sq = min(color_dist_sq((r,g,b), c) for c in common)
                if md_sq <= fade_sq:
                    md = math.sqrt(md_sq)
                    new_alpha = int(255 * (md / fade_threshold))
                    new_alpha = max(0, min(255, new_alpha))
                    out_px[x, y] = (r, g, b, new_alpha)
                else:
                    out_px[x, y] = (r, g, b, a)

    # optional slight blur on alpha to smooth edges
    alpha = out.split()[3].filter(ImageFilter.GaussianBlur(radius=1))
    out.putalpha(alpha)

    out.save(SRC)
    print(f"Cleaned image saved to: {SRC}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
