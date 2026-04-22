#!/usr/bin/env python3
"""Batch-fix the unnecessary_underscores lint.

Reads `/tmp/uu.log` (lines from `flutter analyze | grep unnecessary_underscores`)
and collapses each underscore run (2+ chars) at the reported column into a
single `_`. Designed to run once then be deleted.
"""
import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(r"C:/N42/n42appv2")
BACKSLASH = "\\"

entries = defaultdict(list)
with open(r"C:/Users/10200/AppData/Local/Temp/uu.log", "r", encoding="utf-8") as fh:
    for line in fh:
        # Match the last "- <path>:LINE:COL - unnecessary_underscores" segment.
        m = re.search(r"- ([A-Za-z][\w\\./-]+\.dart):(\d+):(\d+) - unnecessary_underscores", line)
        if m:
            entries[m.group(1)].append((int(m.group(2)), int(m.group(3))))

total_fixed = 0
for file_rel, positions in entries.items():
    path = ROOT / file_rel.replace(BACKSLASH, "/")
    if not path.exists():
        print("SKIP (not found):", path)
        continue
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    lines = content.splitlines(keepends=True)
    file_fixed = 0
    # Sort desc so column offsets on the same line remain stable as we edit.
    for lineno, col in sorted(positions, key=lambda x: (-x[0], -x[1])):
        if lineno > len(lines):
            continue
        line = lines[lineno - 1]
        idx = col - 1
        if idx >= len(line) or line[idx] != "_":
            continue
        end = idx
        while end < len(line) and line[end] == "_":
            end += 1
        if end - idx < 2:
            continue
        lines[lineno - 1] = line[:idx] + "_" + line[end:]
        file_fixed += 1
    if file_fixed:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.writelines(lines)
        total_fixed += file_fixed
        print(f"{file_fixed:3d} fixed in {file_rel}")

print(f"TOTAL: {total_fixed} / 131")
