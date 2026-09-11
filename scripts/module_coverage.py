#!/usr/bin/env python3
"""Run bounded Flutter suites and report LCOV without changing the CI gate.

Module traces are stored separately from coverage/lcov.info. Only a full-suite
trace should be used to report whole-project coverage. No files are excluded.
"""

import argparse
from collections import defaultdict
from fnmatch import fnmatchcase
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BASELINE = ROOT / 'docs/testing/coverage-baseline-2026-09-10.json'
MODULES = {
    'deep_links': {
        'source': ['lib/core/platform/deep_link_service.dart', 'lib/core/routing/deep_link_handler.dart', 'lib/shared/utils/wallet_connect_uri.dart'],
        'tests': ['test/core/platform/deep_link_service_test.dart', 'test/core/routing/deep_link_handler_test.dart', 'test/core/routing/deep_link_lifecycle_test.dart', 'test/features/wallet_connect/wallet_connect_uri_test.dart', 'test/features/identity/id_hub_bind_signer_test.dart'],
    },
    'wallet_aggregate': {
        'source': ['lib/features/wallet/models/aggregated_coin_model.dart', 'lib/features/wallet/models/aggregated_token.dart', 'lib/features/wallet/services/aggregated_balance_reader.dart', 'lib/features/wallet/provider/wallet_action_provider_aggregated.dart', 'lib/features/wallet/provider/wallet_action_provider_sort.dart', 'lib/features/wallet/pages/wallet_aggregate_detail_page.dart', 'lib/features/wallet/pages/wallet_coin_item.dart'],
        'tests': ['test/features/wallet/models/aggregated_coin_model_test.dart', 'test/features/wallet/services/aggregated_balance_reader_test.dart', 'test/features/wallet/provider/wallet_aggregated_balances_test.dart', 'test/features/wallet/pages/wallet_aggregate_detail_page_test.dart', 'test/features/wallet/aggregated_token_test.dart', 'test/features/wallet/pages/wallet_compact_home_test.dart'],
    },
    'wallet_home': {
        'source': ['lib/features/wallet/pages/wallet_coin_item.dart', 'lib/features/wallet/pages/wallet_coin_list_header.dart', 'lib/features/wallet/pages/wallet_coin_list_section.dart', 'lib/features/wallet/pages/wallet_page_helpers.dart', 'lib/features/wallet/widgets/wallet_board.dart', 'lib/features/wallet/widgets/feature_entry_cards.dart'],
        'tests': ['test/features/wallet/pages/wallet_compact_home_test.dart', 'test/features/wallet/widgets/wallet_board_freshness_test.dart', 'test/widgets/feature_entry_cards_test.dart'],
    },
    'wallet_refresh': {
        'source': ['lib/features/wallet/provider/wallet_action_provider.dart', 'lib/features/wallet/provider/wallet_action_provider_market.dart', 'lib/features/wallet/widgets/wallet_board.dart', 'lib/features/wallet/provider/wallet_price_refresh_scheduler.dart'],
        'tests': ['test/features/wallet/provider/wallet_market_refresh_test.dart', 'test/features/wallet/widgets/wallet_board_freshness_test.dart', 'test/features/wallet/wallet_ready_gate_test.dart', 'test/features/wallet/provider/wallet_price_refresh_scheduler_test.dart'],
    },
    'solana': {
        'source': ['lib/features/wallet/api/sender/sol*.dart', 'lib/features/wallet/api/chain_api/sol_api.dart', 'lib/features/wallet/pages/send/sol_send_request.dart'],
        'tests': ['test/features/wallet/api/sender/sol*_test.dart', 'test/features/wallet/api/chain_api/sol_api_test.dart', 'test/features/wallet/pages/send/sol_send_request_test.dart'],
    },
    'history': {
        'source': [
            'lib/features/wallet/data/transaction_history*.dart',
            'lib/features/wallet/pages/transactions/transaction_history*.dart',
        ],
        'tests': [
            'test/features/wallet/data/transaction_history*_test.dart',
            'test/features/wallet/transactions/*_test.dart',
            'test/features/wallet/pages/transactions/*_test.dart',
        ],
    },
    'dex': {
        'source': [
            'lib/features/wallet/pages/dex_swap/*.dart',
            'lib/features/wallet/models/dex/*.dart',
            'lib/features/wallet/api/dex_swap_api.dart',
        ],
        'tests': [
            'test/features/wallet/dex*_test.dart',
            'test/features/wallet/pages/dex_swap/*_test.dart',
            'test/features/dex/*_test.dart',
        ],
    },
    'security': {
        'source': ['lib/core/security/*.dart'],
        'tests': ['test/core/security/*_test.dart'],
    },
    'bridge': {
        'source': ['lib/features/bridge/*.dart'],
        'tests': ['test/features/bridge/*_test.dart'],
    },
    'wallet_connect': {
        'source': ['lib/features/wallet_connect/*.dart'],
        'tests': ['test/features/wallet_connect/**/*_test.dart'],
    },
    'security_setup': {
        'source': ['lib/features/home/setting/security/*.dart'],
        'tests': ['test/features/home/setting/security/*_test.dart'],
    },
}
FOCUS = {
    'history/data': ['lib/features/wallet/data/transaction_history*.dart'],
    'history/ui': ['lib/features/wallet/pages/transactions/transaction_history*.dart'],
    'dex/swap_page': ['lib/features/wallet/pages/dex_swap/dex_swap_home.dart'],
    'dex/limit_orders': ['lib/features/wallet/pages/dex_swap/dex_limit_order*.dart'],
    'bridge/provider': ['lib/features/bridge/provider/*.dart'],
    'wallet_connect/session_page': ['lib/features/wallet_connect/pages/wc_session_list_page.dart'],
    'security/signature_decoder': ['lib/core/security/signature_decoder.dart'],
    'security/secure_memory': ['lib/core/security/secure_memory.dart'],
    'security/secure_storage': ['lib/core/security/secure_storage.dart'],
    'security/dapp_security': ['lib/core/security/dapp_security_service.dart'],
    'security/totp': ['lib/core/security/totp_util.dart'],
    'security/goplus_client': ['lib/core/security/goplus_security_service.dart'],
    'security/phishing_dialog': ['lib/core/security/phishing_warning_dialog.dart'],
    'security_setup/google_auth': ['lib/features/home/setting/security/google_auth_setup_page.dart'],
}


def selected(path, patterns):
    return any(fnmatchcase(path, pattern) for pattern in patterns)


def read_lcov(path):
    records = defaultdict(dict)
    source = None
    for line in Path(path).read_text().splitlines():
        if line.startswith('SF:'):
            source_path = Path(line[3:])
            if source_path.is_absolute():
                source_path = source_path.resolve().relative_to(ROOT)
            source = source_path.as_posix()
            records[source]  # Preserve measured files with zero executable lines.
        elif line.startswith('DA:'):
            if source is None:
                raise ValueError('DA record without a source file')
            number, hits, *_ = line[3:].split(',')
            number, hits = int(number), int(hits)
            if number < 1 or hits < 0:
                raise ValueError('Invalid LCOV line/hit count')
            records[source][number] = max(records[source].get(number, 0), hits)
        elif line == 'end_of_record':
            source = None
    if not records:
        raise ValueError(f'No source records in {path}')
    return {
        source: {'hit': sum(hits > 0 for hits in lines.values()), 'found': len(lines)}
        for source, lines in sorted(records.items())
    }


def totals(files):
    return {
        'hit': sum(stats['hit'] for stats in files.values()),
        'found': sum(stats['found'] for stats in files.values()),
        'files': len(files),
    }


def percent(stats):
    return 100 * stats['hit'] / stats['found'] if stats['found'] else 0.0


def feature(path):
    parts = path.split('/')
    return '/'.join(parts[1:3]) if parts[1] == 'features' else parts[1]


def summarize(files, label):
    groups = defaultdict(dict)
    for path, stats in files.items():
        groups[feature(path)][path] = stats
    scopes = {name: config['source'] for name, config in MODULES.items()} | FOCUS
    return {
        'label': label,
        'overall': totals(files),
        'features': {name: totals(group) for name, group in sorted(groups.items())},
        'scopes': {
            name: totals({p: s for p, s in files.items() if selected(p, patterns)})
            for name, patterns in scopes.items()
        },
        'files': {
            p: s for p, s in files.items()
            if any(selected(p, config['source']) for config in MODULES.values())
        },
    }


def render(current, baseline, scope=None):
    out = ['# 模块行覆盖率', '', f"数据：{current['label']}", '',
           '按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。',
           '行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。', '']

    def table(title, rows, old):
        out.extend([f'## {title}', '',
                    '| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |',
                    '|---|---:|---:|---:|---:|'])
        for name, stats in rows.items():
            before = old.get(name)
            previous = f'{percent(before):.2f}%' if before else '—'
            delta = f'{percent(stats) - percent(before):+.2f}' if before else '—'
            out.append(f"| `{name}` | {previous} | {percent(stats):.2f}% | "
                       f"{stats['hit']} / {stats['found']} | {delta} |")
        out.append('')

    if scope is None:
        table('全项目（仅用于完整测试集的 LCOV）',
              {'overall': current['overall']}, {'overall': baseline.get('overall')})
    else:
        out.extend(['本次是模块测试结果；不据此计算或更新全项目覆盖率。', ''])
    rows = {k: v for k, v in current['scopes'].items()
            if scope is None or k == scope or k.startswith(scope + '/')}
    table('模块与本批重点范围（这些范围有包含关系，不可相加）', rows, baseline.get('scopes', {}))
    if scope is None:
        table('完整功能模块台账', current['features'], baseline.get('features', {}))
    patterns = MODULES[scope]['source'] if scope else [p for m in MODULES.values() for p in m['source']]
    files = {p: s for p, s in current['files'].items() if selected(p, patterns)}
    missing = [p for p in baseline.get('files', {}) if selected(p, patterns) and p not in files]
    if missing:
        out.extend(['注意：以下基线文件未出现在本次 LCOV 中，不能把较小分母解释为覆盖率提升：', ''])
        out.extend(f'- `{p}`' for p in missing)
        out.append('')
    table('文件明细', files, baseline.get('files', {}))
    return '\n'.join(out) + '\n'


def write(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def test_module(name, baseline_path):
    tests = sorted({p for pattern in MODULES[name]['tests'] for p in ROOT.glob(pattern)})
    if not tests:
        raise ValueError(f'No tests for {name}')
    if sys.platform != 'win32':
        import resource
        soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
        desired = 8192 if hard == resource.RLIM_INFINITY else min(8192, hard)
        if soft < desired:
            resource.setrlimit(resource.RLIMIT_NOFILE, (desired, hard))
    trace = ROOT / f'coverage/modules/{name}.info'
    report = ROOT / f'coverage/modules/{name}.md'
    trace.parent.mkdir(parents=True, exist_ok=True)
    # Delete this module's prior trace, so a failed run cannot report stale data.
    trace.unlink(missing_ok=True)
    report.unlink(missing_ok=True)
    command = ['flutter', 'test', '--no-pub', '--coverage', '--concurrency=2',
               f'--coverage-path={trace}', *[str(p.relative_to(ROOT)) for p in tests]]
    print(f'Running {name}: {len(tests)} test files', flush=True)
    result = subprocess.run(command, cwd=ROOT)
    if result.returncode:
        return result.returncode
    summary = summarize(read_lcov(trace), f'module suite: {name}')
    baseline = json.loads(Path(baseline_path).read_text())
    write(report, render(summary, baseline, scope=name))
    print(f'Report: {report}')
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    snapshot = sub.add_parser('snapshot', help='save a compact baseline from a full-suite LCOV')
    snapshot.add_argument('--input', type=Path, default=ROOT / 'coverage/lcov.info')
    snapshot.add_argument('--output', type=Path, required=True)
    snapshot.add_argument('--label', required=True)
    report = sub.add_parser('report', help='compare an LCOV trace with a saved baseline')
    report.add_argument('--input', type=Path, default=ROOT / 'coverage/lcov.info')
    report.add_argument('--baseline', type=Path, default=BASELINE)
    report.add_argument('--output', type=Path, required=True)
    report.add_argument('--scope', choices=MODULES)
    run = sub.add_parser('test', help='run one module; preserve the full-suite trace')
    run.add_argument('module', choices=MODULES)
    run.add_argument('--baseline', type=Path, default=BASELINE)
    args = parser.parse_args()
    if args.command == 'test':
        return test_module(args.module, args.baseline)
    current = summarize(read_lcov(args.input), getattr(args, 'label', str(args.input)))
    if args.command == 'snapshot':
        write(args.output, json.dumps(current, ensure_ascii=False, indent=2) + '\n')
    else:
        baseline = json.loads(args.baseline.read_text())
        write(args.output, render(current, baseline, scope=args.scope))
    print(args.output)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
