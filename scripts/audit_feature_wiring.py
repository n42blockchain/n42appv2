#!/usr/bin/env python3
"""Reproducible Dart UI reference inventory; not a runtime reachability proof.

Tracks public widgets and constructor references outside their declaration file.
Comments are removed. Factory tear-offs, generated routes, conditional imports,
platform feature flags, and widgets called only from dead code need human review.
"""
from collections import Counter, defaultdict
from pathlib import Path
import argparse
import re

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ('.g.dart', '.freezed.dart', '.pb.dart', '.pbenum.dart', '.pbjson.dart')
WIDGET = re.compile(r'\bclass\s+(\w+)\s+extends\s+(ConsumerStatefulWidget|ConsumerWidget|StatefulWidget|StatelessWidget)\b')
CALL = re.compile(r'\b([A-Z]\w*)\s*\(')


def inventory():
    files = {p: p.read_text() for p in sorted((ROOT / 'lib').rglob('*.dart'))
             if 'generated' not in p.parts and not p.name.endswith(GENERATED)}
    calls = defaultdict(set)
    widgets = []
    modules = Counter()
    tests = Counter()
    for p, source in files.items():
        rel = p.relative_to(ROOT)
        module = rel.parts[2] if rel.parts[:2] == ('lib', 'features') else rel.parts[1]
        modules[module] += 1
        # Remove block comments and full-line comments, preserving URL strings.
        clean = re.sub(r'/\*.*?\*/', '', source, flags=re.DOTALL)
        clean = re.sub(r'^\s*//.*$', '', clean, flags=re.MULTILINE)
        for match in CALL.finditer(clean):
            calls[match[1]].add(p)
        if '/pages/' in str(rel) or '/setting/' in str(rel) or '/profile/' in str(rel):
            for match in WIDGET.finditer(clean):
                name = match[1]
                if not name.startswith('_'):
                    line = source[:source.find('class ' + name)].count('\n') + 1
                    widgets.append((module, name, p, line))
    for p in (ROOT / 'test').rglob('*_test.dart'):
        rel = p.relative_to(ROOT)
        module = rel.parts[2] if rel.parts[:2] == ('test', 'features') else rel.parts[1]
        tests[module] += 1
    return files, modules, tests, widgets, calls


def render():
    files, modules, tests, widgets, calls = inventory()
    out = ['# 功能与 UI 入口源码清单', '',
           '由 `python3 scripts/audit_feature_wiring.py` 生成。统计排除自动生成的 Dart 文件。', '',
           '本表是静态构造引用索引，不代表按钮可点击、平台可见、签名正确或链上流程通过。'
           '零外部引用是复核候选；同文件调用、构造函数 tear-off 和备用实现可能导致误报。'
           '外部引用也可能来自未启用代码。运行时结论见配套审计报告。', '',
           f'纳入 {len(files)} 个 Dart 源文件、{sum(tests.values())} 个测试文件、{len(widgets)} 个公开页面或页面组件类。', '',
           '## 模块覆盖清单', '', '| 模块 | Dart 源文件 | 对应目录测试文件 |', '|---|---:|---:|']
    for module, count in sorted(modules.items()):
        out.append(f'| {module} | {count} | {tests[module]} |')
    out += ['', '测试计数按目录归属，不把文件数当作行为覆盖率。', '', '## UI 构造入口索引', '',
            '| 模块 | 页面/组件 | 声明 | 外部构造引用 |', '|---|---|---|---|']
    for module, name, p, line in sorted(widgets):
        references = sorted(calls[name] - {p})
        links = '<br>'.join(f'[{r.name}](../{r.relative_to(ROOT)})' for r in references)
        declaration = f'[{p.name}:{line}](../{p.relative_to(ROOT)})'
        out.append(f'| {module} | `{name}` | {declaration} | {links or "需人工复核：无外部构造调用"} |')
    return '\n'.join(out) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Fail if the checked-in inventory is stale')
    args = parser.parse_args()
    destination = ROOT / 'docs/wallet-feature-wiring-inventory-2026-09-10.md'
    result = render()
    if args.check:
        if not destination.exists() or destination.read_text() != result:
            raise SystemExit('UI inventory is stale; run scripts/audit_feature_wiring.py')
    else:
        destination.write_text(result)
    print(destination.relative_to(ROOT))


if __name__ == '__main__':
    main()
