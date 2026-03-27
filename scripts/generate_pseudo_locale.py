#!/usr/bin/env python3
"""
Generate a pseudo-localized ARB file from intl_en.arb.

Each string is transformed to:
  1. Wrap in brackets: [# ... #]  (makes boundaries visible)
  2. Accented Latin:   a→à e→é i→ì o→ö u→ü  (tests font rendering)
  3. Padded +50%:      append repeated chars   (tests layout overflow)
  4. Preserve {placeholders} and ICU syntax

Usage:
    python scripts/generate_pseudo_locale.py

Output:
    lib/l10n/intl_qps.arb   (qps = quasi-pseudo locale)
"""

import json
import re
import sys
from pathlib import Path

# ── Config ───────────────────────────────────────────────────────────────

ACCENT_MAP = str.maketrans(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "àƀçðéƒĝĥìĵķĺṁñöƥɋŗšťüṽŵẋýžÀƁÇÐÉƑĜĤÌĴĶĹṀÑÖƤɊŖŠŤÜṼŴẊÝŽ",
)

PAD_RATIO = 0.5  # add 50% extra length
PAD_CHAR = "~"

# Regex to match {placeholder} tokens and ICU plural/select blocks
# We protect these from transformation.
PLACEHOLDER_RE = re.compile(
    r"\{[a-zA-Z_][a-zA-Z0-9_]*\}"  # simple {name}
    r"|"
    r"\{[^}]*,\s*(?:plural|select|ordinal)\s*,"  # ICU start
)

# ── Transform ────────────────────────────────────────────────────────────

def pseudo_transform(value: str) -> str:
    """Transform a single l10n string value."""
    if not value or not isinstance(value, str):
        return value

    # Split string into protected (placeholders) and transformable segments
    parts = []
    last = 0
    for m in re.finditer(r"\{[^}]*\}", value):
        if last < m.start():
            parts.append(("text", value[last : m.start()]))
        parts.append(("placeholder", m.group()))
        last = m.end()
    if last < len(value):
        parts.append(("text", value[last:]))

    # Transform text segments, leave placeholders intact
    transformed = []
    text_len = 0
    for kind, segment in parts:
        if kind == "text":
            accented = segment.translate(ACCENT_MAP)
            transformed.append(accented)
            text_len += len(segment)
        else:
            transformed.append(segment)

    body = "".join(transformed)

    # Pad to simulate longer translations
    pad_count = max(1, int(text_len * PAD_RATIO))
    padding = PAD_CHAR * pad_count

    return f"[# {body} {padding}#]"


# ── Main ─────────────────────────────────────────────────────────────────

def main():
    root = Path(__file__).resolve().parent.parent
    en_path = root / "lib" / "l10n" / "intl_en.arb"
    out_path = root / "lib" / "l10n" / "intl_qps.arb"

    if not en_path.exists():
        print(f"Error: {en_path} not found", file=sys.stderr)
        sys.exit(1)

    with open(en_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    pseudo = {"@@locale": "qps"}

    for key, value in data.items():
        if key.startswith("@@"):
            continue  # skip metadata
        if key.startswith("@"):
            # Copy metadata entries as-is (e.g. @g_key_46 for placeholders)
            pseudo[key] = value
            continue
        if isinstance(value, str):
            pseudo[key] = pseudo_transform(value)
        else:
            pseudo[key] = value

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(pseudo, f, ensure_ascii=False, indent=2)

    key_count = sum(1 for k in pseudo if not k.startswith("@"))
    print(f"Generated {out_path}")
    print(f"  Keys: {key_count}")
    print(f"  Padding ratio: +{int(PAD_RATIO * 100)}%")
    sample6 = pseudo.get('g_key_6', 'N/A')
    sample46 = pseudo.get('g_key_46', 'N/A')
    print(f"  Sample: g_key_6 = {ascii(sample6)}")
    print(f"  Sample: g_key_46 = {ascii(sample46)}")


if __name__ == "__main__":
    main()
