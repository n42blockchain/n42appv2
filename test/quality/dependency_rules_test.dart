import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 架构依赖方向守护（见 docs/MODULARITY_PLAN.md）。
///
/// 扫描 lib/ 全部 import，强制执行 2026-08 模块化工程确立的方向规则；
/// 新增违规会让本测试红掉。规则若需放宽，请同步更新 MODULARITY_PLAN.md
/// 并在下方 allowlist 写明理由。
void main() {
  // 收集 lib/ 下所有 dart 文件（跳过生成物）
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            !f.path.endsWith('.freezed.dart') &&
            !f.path.contains('generated'),
      )
      .toList();

  final importPattern = RegExp("import\\s+'package:n42_wallet/([^']+)'");

  /// 文件相对路径（正斜杠）→ 它 import 的 n42_wallet 内部路径列表
  final imports = <String, List<String>>{};
  for (final f in dartFiles) {
    final rel = f.path.replaceAll('\\', '/');
    imports[rel] = importPattern
        .allMatches(f.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();
  }

  List<String> violations(
    bool Function(String file) fileFilter,
    bool Function(String file, String import) isViolation,
  ) {
    final result = <String>[];
    imports.forEach((file, imps) {
      if (!fileFilter(file)) return;
      for (final imp in imps) {
        if (isViolation(file, imp)) result.add('$file → $imp');
      }
    });
    return result;
  }

  group('依赖方向规则', () {
    test('core/ 不 import features（composition root di/、app/ 豁免）', () {
      final v = violations(
        (f) =>
            f.startsWith('lib/core/') &&
            !f.startsWith('lib/core/di/') &&
            !f.startsWith('lib/core/app/'),
        (f, imp) => imp.startsWith('features/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('shared/ 不 import features 与 core 之外的实现', () {
      final v = violations(
        (f) => f.startsWith('lib/shared/'),
        (f, imp) => imp.startsWith('features/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('共享 UI/工具层（widgets/component/utils）不 import 业务 feature', () {
      // 同层互引（widgets/component/utils 之间）允许
      const sharedTiers = ['widgets', 'component', 'utils'];
      final v = violations(
        (f) => sharedTiers.any((t) => f.startsWith('lib/features/$t/')),
        (f, imp) {
          if (!imp.startsWith('features/')) return false;
          final target = imp.split('/')[1];
          return !sharedTiers.contains(target);
        },
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('sqlite 不 import 任何 feature（DAO 以 extension 下放各 feature）', () {
      final v = violations(
        (f) => f.startsWith('lib/features/sqlite/'),
        (f, imp) =>
            imp.startsWith('features/') && !imp.startsWith('features/sqlite/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('任何 feature 不反向 import home（home 是 App 外壳/聚合器）', () {
      final v = violations(
        (f) =>
            f.startsWith('lib/features/') &&
            !f.startsWith('lib/features/home/'),
        (f, imp) => imp.startsWith('features/home/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('wallet 不 import browser（站内浏览器一律走 shared InAppBrowser）', () {
      final v = violations(
        (f) => f.startsWith('lib/features/wallet/'),
        (f, imp) => imp.startsWith('features/browser/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });

    test('wallet → wallet_connect 仅限 wallet_page 入口（卫星模块方向规则）', () {
      const allowlist = {
        // WC 入口/会话列表/providers 挂在钱包页顶栏——接受项，见 MODULARITY_PLAN
        'lib/features/wallet/pages/wallet_page.dart',
        'lib/features/wallet/pages/wallet_page_top_bar.dart',
      };
      final v = violations(
        (f) => f.startsWith('lib/features/wallet/') && !allowlist.contains(f),
        (f, imp) => imp.startsWith('features/wallet_connect/'),
      );
      expect(v, isEmpty, reason: v.join('\n'));
    });
  });
}
