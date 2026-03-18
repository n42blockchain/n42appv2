#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BASELINE_PATH = ROOT / 'scripts' / 'localization_audit_baseline.json'


GENERIC_ALLOWED_PATTERNS = (
    re.compile(r'^https?://[^\s]*$'),
    re.compile(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    re.compile(r'^@[A-Za-z0-9._=-]+:[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    re.compile(r'^v\d+(?:\.\d+)+$'),
    re.compile(r'^\d+(?:\.\d+)?$'),
    re.compile(r'^-+$'),
    re.compile(r'^≈ \{amount\}(?:\{token\}| USDT)$'),
    re.compile(r'^\{current\} / \{total\}$'),
    re.compile(r'^\{month\}/\{day\}$'),
    re.compile(r'^\{value\}d unbond$'),
    re.compile(r'^N42 ID: \{id\}$'),
    re.compile(r'^Option \{index\}$'),
    re.compile(r'^Version \{version\}$'),
    re.compile(r'^\[Moment\] \{content\}$'),
    re.compile(r'^Kick \{name\}$'),
    re.compile(r'^Error: \{message\}$'),
    re.compile(r'^poked \{name\}\{suffix\}$'),
)


@dataclass(frozen=True)
class AuditSpec:
    name: str
    base_path: Path
    locale_glob: str
    excluded_names: tuple[str, ...] = ()


SPECS = {
    'wallet': AuditSpec(
        name='wallet',
        base_path=ROOT / 'lib' / 'l10n' / 'intl_en.arb',
        locale_glob='intl_*.arb',
    ),
    'chat': AuditSpec(
        name='chat',
        base_path=(ROOT / '..' / 'n42_chat' / 'lib' / 'l10n' / 'app_en.arb').resolve(),
        locale_glob='app_*.arb',
        excluded_names=('app_localizations',),
    ),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description='Audit wallet/chat localization assets against English baselines.',
    )
    parser.add_argument(
        '--mode',
        choices=('wallet', 'chat', 'all'),
        default='all',
        help='Audit wallet, chat, or both.',
    )
    parser.add_argument(
        '--update-baseline',
        action='store_true',
        help='Replace the accepted-English baseline with the current audit result.',
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    baseline = load_baseline()
    selected_specs = list(iter_specs(args.mode))

    reports = {spec.name: audit_spec(spec) for spec in selected_specs}

    fatal = False
    for spec_name, report in reports.items():
        print_report(spec_name, report)
        if report['missing'] or report['extra'] or report['empty']:
            fatal = True

    if fatal:
        print('Audit failed: missing/extra/empty localization entries detected.', file=sys.stderr)
        return 1

    current_baseline = {
        spec_name: report['identical']
        for spec_name, report in reports.items()
    }

    if args.update_baseline:
        write_baseline(current_baseline)
        print(f'Updated baseline: {BASELINE_PATH}')
        return 0

    diff_failed = False
    for spec_name, report in reports.items():
        accepted = baseline.get(spec_name, {})
        unexpected = diff_entries(report['identical'], accepted)
        resolved = diff_entries(accepted, report['identical'])

        if unexpected:
            diff_failed = True
            print(f'[{spec_name}] New English-identical entries:')
            print_entries(unexpected)

        if resolved:
            print(f'[{spec_name}] Baseline entries now resolved:')
            print_entries(resolved)

    if diff_failed:
        print(
            'Audit failed: new English-identical entries were introduced. '
            'Run with --update-baseline only after review.',
            file=sys.stderr,
        )
        return 1

    print('Localization audit passed.')
    return 0


def iter_specs(mode: str) -> list[AuditSpec]:
    if mode == 'all':
        return [SPECS['wallet'], SPECS['chat']]
    return [SPECS[mode]]


def load_baseline() -> dict[str, dict[str, dict[str, str]]]:
    if not BASELINE_PATH.exists():
        return {}
    return json.loads(BASELINE_PATH.read_text(encoding='utf-8'))


def write_baseline(baseline: dict[str, dict[str, dict[str, str]]]) -> None:
    BASELINE_PATH.write_text(
        json.dumps(baseline, ensure_ascii=False, indent=2, sort_keys=True) + '\n',
        encoding='utf-8',
    )


def audit_spec(spec: AuditSpec) -> dict[str, dict[str, dict[str, str]]]:
    base = load_messages(spec.base_path)
    base_keys = set(base)
    locale_dir = spec.base_path.parent

    missing: dict[str, dict[str, str]] = {}
    extra: dict[str, dict[str, str]] = {}
    empty: dict[str, dict[str, str]] = {}
    identical: dict[str, dict[str, str]] = {}

    for path in sorted(locale_dir.glob(spec.locale_glob)):
        if path == spec.base_path:
            continue
        if any(path.name.startswith(prefix) for prefix in spec.excluded_names):
            continue

        locale = path.stem.split('_', 1)[1]
        data = load_messages(path)
        locale_keys = set(data)

        missing_keys = sorted(base_keys - locale_keys)
        extra_keys = sorted(locale_keys - base_keys)
        empty_keys = sorted(
            key for key, value in data.items()
            if isinstance(value, str) and not value.strip()
        )

        identical_keys = {
            key: value
            for key, value in data.items()
            if value == base.get(key) and is_unexpected_identical(value)
        }

        if missing_keys:
            missing[locale] = {key: base[key] for key in missing_keys}
        if extra_keys:
            extra[locale] = {key: data[key] for key in extra_keys}
        if empty_keys:
            empty[locale] = {key: data[key] for key in empty_keys}
        if identical_keys:
            identical[locale] = dict(sorted(identical_keys.items()))

    return {
        'missing': missing,
        'extra': extra,
        'empty': empty,
        'identical': identical,
    }


def load_messages(path: Path) -> dict[str, str]:
    raw = json.loads(path.read_text(encoding='utf-8'))
    return {
        key: value
        for key, value in raw.items()
        if not key.startswith('@') and isinstance(value, str)
    }


def is_unexpected_identical(value: str) -> bool:
    text = value.strip()
    if not text:
        return False
    return not any(pattern.match(text) for pattern in GENERIC_ALLOWED_PATTERNS)


def diff_entries(
    left: dict[str, dict[str, str]],
    right: dict[str, dict[str, str]],
) -> dict[str, dict[str, str]]:
    diff: dict[str, dict[str, str]] = {}
    locales = sorted(set(left) | set(right))
    for locale in locales:
        left_entries = left.get(locale, {})
        right_entries = right.get(locale, {})
        locale_diff = {
            key: value
            for key, value in left_entries.items()
            if right_entries.get(key) != value
        }
        if locale_diff:
            diff[locale] = dict(sorted(locale_diff.items()))
    return diff


def print_report(spec_name: str, report: dict[str, dict[str, dict[str, str]]]) -> None:
    missing_count = sum(len(entries) for entries in report['missing'].values())
    extra_count = sum(len(entries) for entries in report['extra'].values())
    empty_count = sum(len(entries) for entries in report['empty'].values())
    identical_count = sum(len(entries) for entries in report['identical'].values())
    print(
        f'[{spec_name}] '
        f'missing={missing_count} extra={extra_count} empty={empty_count} '
        f'identical={identical_count}'
    )


def print_entries(entries: dict[str, dict[str, str]]) -> None:
    for locale, values in sorted(entries.items()):
        print(f'  {locale}: {len(values)}')
        for key, value in sorted(values.items()):
            print(f'    {key} = {value}')


if __name__ == '__main__':
    raise SystemExit(main())
