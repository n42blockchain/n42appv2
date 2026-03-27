#!/usr/bin/env python3
"""
Pseudo-Localization Stress Test Report

Reads all ARB locale files, compares string lengths across languages,
and identifies keys that are significantly longer in some locales vs English.
These are the highest-risk keys for UI overflow.

Output: a ranked report of keys by max expansion ratio.

Usage:
    python scripts/pseudo_locale_stress_test.py
"""

import json
import sys
from pathlib import Path
from collections import defaultdict


def visible_length(s: str) -> int:
    """Length excluding {placeholder} tokens."""
    import re
    cleaned = re.sub(r"\{[^}]*\}", "", s)
    return len(cleaned)


def main():
    root = Path(__file__).resolve().parent.parent
    l10n_dir = root / "lib" / "l10n"

    if not l10n_dir.exists():
        print(f"Error: {l10n_dir} not found", file=sys.stderr)
        sys.exit(1)

    # Load all ARB files
    locales = {}
    for arb_file in sorted(l10n_dir.glob("intl_*.arb")):
        locale_name = arb_file.stem.replace("intl_", "")
        if locale_name == "qps":
            continue  # skip pseudo
        with open(arb_file, "r", encoding="utf-8") as f:
            locales[locale_name] = json.load(f)

    en_data = locales.get("en", {})
    if not en_data:
        print("Error: intl_en.arb not found", file=sys.stderr)
        sys.exit(1)

    # Analyze each key across all locales
    analysis = []
    for key, en_value in en_data.items():
        if key.startswith("@") or not isinstance(en_value, str):
            continue

        en_len = visible_length(en_value)
        if en_len < 3:  # skip very short strings
            continue

        max_len = en_len
        max_locale = "en"
        all_lengths = {"en": en_len}

        for locale_name, locale_data in locales.items():
            if locale_name == "en":
                continue
            translated = locale_data.get(key, "")
            if isinstance(translated, str) and translated:
                t_len = visible_length(translated)
                all_lengths[locale_name] = t_len
                if t_len > max_len:
                    max_len = t_len
                    max_locale = locale_name

        if en_len > 0:
            ratio = max_len / en_len
        else:
            ratio = 1.0

        analysis.append({
            "key": key,
            "en_text": en_value[:60],
            "en_len": en_len,
            "max_len": max_len,
            "max_locale": max_locale,
            "ratio": ratio,
            "lengths": all_lengths,
        })

    # Sort by expansion ratio (highest first)
    analysis.sort(key=lambda x: x["ratio"], reverse=True)

    # Report
    print("=" * 80)
    print("PSEUDO-LOCALIZATION STRESS TEST REPORT")
    print("=" * 80)
    print()

    # Summary stats
    ratios = [a["ratio"] for a in analysis]
    high_risk = [a for a in analysis if a["ratio"] >= 2.0]
    medium_risk = [a for a in analysis if 1.5 <= a["ratio"] < 2.0]
    low_risk = [a for a in analysis if 1.3 <= a["ratio"] < 1.5]

    print(f"Total keys analyzed: {len(analysis)}")
    print(f"Locales compared:    {len(locales)}")
    print(f"Average expansion:   {sum(ratios)/len(ratios):.1f}x")
    print(f"Max expansion:       {max(ratios):.1f}x")
    print()
    print(f"HIGH risk (2.0x+):   {len(high_risk)} keys")
    print(f"MEDIUM risk (1.5x+): {len(medium_risk)} keys")
    print(f"LOW risk (1.3x+):    {len(low_risk)} keys")
    print()

    # Top 50 highest expansion keys
    print("-" * 80)
    print("TOP 50 HIGHEST EXPANSION KEYS")
    print("-" * 80)
    print(f"{'Key':<35} {'EN len':>6} {'Max len':>7} {'Ratio':>6} {'Locale':>6}  EN text")
    print("-" * 80)

    for a in analysis[:50]:
        en_preview = a["en_text"][:40].replace("\n", " ")
        print(f"{a['key']:<35} {a['en_len']:>6} {a['max_len']:>7} {a['ratio']:>5.1f}x {a['max_locale']:>6}  {en_preview}")

    # Per-locale stats
    print()
    print("-" * 80)
    print("PER-LOCALE AVERAGE EXPANSION vs ENGLISH")
    print("-" * 80)

    locale_ratios = defaultdict(list)
    for a in analysis:
        for locale_name, length in a["lengths"].items():
            if locale_name != "en" and a["en_len"] > 0:
                locale_ratios[locale_name].append(length / a["en_len"])

    sorted_locales = sorted(locale_ratios.items(), key=lambda x: sum(x[1])/len(x[1]), reverse=True)
    for locale_name, ratios_list in sorted_locales:
        avg = sum(ratios_list) / len(ratios_list)
        max_r = max(ratios_list)
        print(f"  {locale_name:<8} avg {avg:.2f}x  max {max_r:.1f}x  ({len(ratios_list)} keys)")

    # Output JSON for test consumption
    report_path = root / "test" / "pseudo_locale_report.json"
    report_data = {
        "summary": {
            "total_keys": len(analysis),
            "locales": len(locales),
            "high_risk_count": len(high_risk),
            "medium_risk_count": len(medium_risk),
        },
        "high_risk_keys": [
            {"key": a["key"], "en_len": a["en_len"], "max_len": a["max_len"],
             "ratio": round(a["ratio"], 2), "max_locale": a["max_locale"]}
            for a in high_risk
        ],
        "top50": [
            {"key": a["key"], "ratio": round(a["ratio"], 2), "max_locale": a["max_locale"],
             "en_text": a["en_text"]}
            for a in analysis[:50]
        ],
    }
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report_data, f, ensure_ascii=False, indent=2)

    print()
    print(f"JSON report saved to: {report_path}")
    print()

    # Actionable list
    if high_risk:
        print("=" * 80)
        print("ACTION REQUIRED: Keys expanding 2x+ need overflow protection")
        print("=" * 80)
        for a in high_risk[:20]:
            print(f"  {a['key']}: EN({a['en_len']}) -> {a['max_locale']}({a['max_len']}) = {a['ratio']:.1f}x")
            print(f"    EN: \"{a['en_text']}\"")


if __name__ == "__main__":
    main()
