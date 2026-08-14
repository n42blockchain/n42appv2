import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 守护 `_wcClipboardInterceptScript` 里 iOS webkit masking 段的不变量。
///
/// 背景：iOS 上 `window.X` 是 atDocumentStart 的 WKUserScript 注入的别名，
/// `window.X === webkit.messageHandlers.X`——**同一个对象**。历史上这里写过
/// ```js
/// var h = webkit.messageHandlers['N42Wallet'];
/// window.N42Wallet.postMessage = function(m){ h.postMessage([String(m)]); };
/// ```
/// 由于 `h` 就是 `window.N42Wallet`，这等于让 postMessage 调用自身——无限递归、
/// 栈溢出，DApp 只看到 "-32603 Native bridge unavailable"，请求永远到不了 Dart。
/// 该缺陷曾在真机上以「provider 可检测、连接却失败」的形式出现两轮，极难定位，
/// 故在此以结构性断言守护，避免再次复发。
void main() {
  /// 脚本原文（含注释），用于检查注释里显式记录的约定。
  late String script;

  /// 剥离整行注释后的代码。断言必须针对代码本身——注释里为了说明会写出
  /// 反面示例，不能让它触发守护。
  late String code;

  setUpAll(() {
    final file = File('lib/features/browser/provider/browser_provider.dart');
    expect(file.existsSync(), isTrue, reason: '找不到 browser_provider.dart');
    final src = file.readAsStringSync();
    final match = RegExp(
      r"_wcClipboardInterceptScript = r'''(.*?)''';",
      dotAll: true,
    ).firstMatch(src);
    expect(match, isNotNull, reason: '未能提取剪贴板注入脚本');
    script = match!.group(1)!;
    code = script
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
  });

  group('iOS webkit masking 不变量', () {
    test('不得直接给别名对象的 postMessage 赋值（会自递归爆栈）', () {
      // 形如 `window.N42Wallet.postMessage =` / `window['X'].postMessage =`
      final selfAssign = RegExp(
        r"window(\.\w+|\[[^\]]+\])\.postMessage\s*=",
      );
      expect(
        selfAssign.hasMatch(code),
        isFalse,
        reason: '禁止对 window.X.postMessage 直接赋值：iOS 上 window.X 就是 '
            'messageHandlers.X 本身，会形成自递归。应新建包装对象并以原生 '
            'postMessage 函数引用 + 正确 receiver 调用。',
      );
    });

    test('必须先取出原生 postMessage 函数引用再以 handler 为 receiver 调用', () {
      expect(
        code.contains('rawPost.call(handler'),
        isTrue,
        reason: '应保存原生 postMessage 函数并用 .call(handler, ...) 调用，'
            '而不是通过可能已被覆写的属性间接调用。',
      );
    });

    test('送往原生的 body 必须是字符串，不能包成数组', () {
      // Dart 侧取的是 message.body.toString()：数组会得到 "[...]"，
      // provider 的 json.decode 直接失败，剪贴板的 wc: 前缀判断也失败。
      expect(
        RegExp(r'postMessage\(\s*\[').hasMatch(code),
        isFalse,
        reason: 'postMessage 不得传数组；Dart 侧会得到带方括号的字符串。',
      );
      expect(code.contains('String(msg)'), isTrue);
    });

    test('两个 channel 都被固定', () {
      expect(code.contains("_pin('FlutterWcClipboard')"), isTrue);
      expect(code.contains("_pin('N42Wallet')"), isTrue);
    });

    test('provider 桥未固定成功时不得隐藏 window.webkit', () {
      // 隐藏 webkit 会连 messageHandlers 兜底一起切断；固定失败时宁可不隐藏。
      final hideIdx = code.indexOf("defineProperty(window, 'webkit'");
      expect(hideIdx, greaterThan(-1), reason: '未找到隐藏 webkit 的代码');
      final guardIdx = code.indexOf('if (_n42Pinned)');
      expect(
        guardIdx > -1 && guardIdx < hideIdx,
        isTrue,
        reason: '隐藏 window.webkit 必须以 provider 桥固定成功为前提。',
      );
    });
  });
}
