// BrowserProvider URL 安全逻辑单元测试
//
// 覆盖范围：
// - checkHttp：搜索词 → Google 搜索 URL（查询词编码）、补 https:// 前缀、
//   已带协议原样返回、javascript: 伪协议的现状行为
// - checkUrl：危险协议（javascript/data/blob/file）全拦截；
//   WalletConnect URI 派发与去重（lastDispatchedWcUri）；
//   amazeapp:///wc?uri= 深链提取；普通 http(s) 放行
//
// 敏感方法清单（_sensitiveMethods/_isSensitiveMethod）为私有成员，无法在
// 测试中直接访问；其行为覆盖见 dapp_request_handler_test.dart 的
// 「审批闸门」组（每个敏感方法均需审批、无审批通道时 4001 终止）。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // BrowserProvider 构造函数会读 SharedPreferences（浏览器设置），
  // 需要初始化测试 binding 并 mock SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  late BrowserProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = BrowserProvider();
  });

  group('checkHttp：地址栏输入归一化', () {
    test('非 URL 输入 "btc" → Google 搜索 URL', () {
      expect(provider.checkHttp('btc'), 'https://www.google.com/search?q=btc');
    });

    test('裸域名 "example.com" → 补 https:// 前缀', () {
      expect(provider.checkHttp('example.com'), 'https://example.com');
    });

    test('已带 http:// 协议 → 原样返回（不强升 https）', () {
      expect(provider.checkHttp('http://x.com'), 'http://x.com');
    });

    test('已带 https:// 协议 → 原样返回', () {
      expect(
        provider.checkHttp('https://app.uniswap.org/swap'),
        'https://app.uniswap.org/swap',
      );
    });

    test('含空格查询词被正确编码（空格 → +）', () {
      expect(
        provider.checkHttp('hello world'),
        'https://www.google.com/search?q=hello+world',
      );
    });

    test('中文查询词被 percent 编码', () {
      expect(
        provider.checkHttp('比特币 价格'),
        'https://www.google.com/search?q=%E6%AF%94%E7%89%B9%E5%B8%81+%E4%BB%B7%E6%A0%BC',
      );
    });

    test('javascript: 伪协议现状行为：判为非 URL，编码后进搜索（不会被执行）', () {
      // 现状断言：validators.isURL 不认 "javascript:alert(1)"（无合法 host:port），
      // 因此走搜索分支且冒号/括号被编码，不会作为可执行 URL 加载。
      // 真正的导航拦截兜底在 checkUrl 的 blockedSchemes。
      final result = provider.checkHttp('javascript:alert(1)');
      expect(
        result,
        'https://www.google.com/search?q=javascript%3Aalert%281%29',
      );
      expect(result.startsWith('javascript:'), isFalse);
    });
  });

  group('checkUrl：危险协议拦截', () {
    test('javascript: 协议被拦截', () {
      expect(provider.checkUrl('javascript:alert(1)'), isFalse);
    });

    test('data: 协议被拦截', () {
      expect(
        provider.checkUrl('data:text/html;base64,PHNjcmlwdD48L3NjcmlwdD4='),
        isFalse,
      );
    });

    test('blob: 协议被拦截', () {
      expect(provider.checkUrl('blob:https://evil.com/6a5f0a-uuid'), isFalse);
    });

    test('file: 协议被拦截', () {
      expect(provider.checkUrl('file:///etc/passwd'), isFalse);
    });

    test('普通 https URL 放行', () {
      expect(provider.checkUrl('https://app.uniswap.org/swap'), isTrue);
    });

    test('普通 http URL 放行', () {
      expect(provider.checkUrl('http://example.com'), isTrue);
    });
  });

  group('checkUrl：WalletConnect URI 派发与去重', () {
    const wcUri = 'wc:pairing-topic-1@2?relay-protocol=irn&symKey=abc123';

    test('wc: URI 触发 connectDAPPCallBack 一次并阻止导航', () {
      final dispatched = <String>[];
      provider.connectDAPPCallBack = dispatched.add;

      expect(provider.checkUrl(wcUri), isFalse);
      expect(dispatched, [wcUri]);
      expect(provider.lastDispatchedWcUri, wcUri);
    });

    test('同一 URI 重复调用只派发一次（lastDispatchedWcUri 去重）', () {
      final dispatched = <String>[];
      provider.connectDAPPCallBack = dispatched.add;

      expect(provider.checkUrl(wcUri), isFalse);
      expect(provider.checkUrl(wcUri), isFalse);
      expect(provider.checkUrl(wcUri), isFalse);
      expect(dispatched, hasLength(1));
    });

    test('重置 lastDispatchedWcUri 后同一 URI 可再次派发（重试场景）', () {
      final dispatched = <String>[];
      provider.connectDAPPCallBack = dispatched.add;

      provider.checkUrl(wcUri);
      // BrowserPage 在 WalletConnect 弹窗关闭时会重置，模拟该行为
      provider.lastDispatchedWcUri = null;
      provider.checkUrl(wcUri);
      expect(dispatched, hasLength(2));
    });

    test('不同 URI 各自派发', () {
      const wcUri2 = 'wc:pairing-topic-2@2?relay-protocol=irn&symKey=def456';
      final dispatched = <String>[];
      provider.connectDAPPCallBack = dispatched.add;

      provider.checkUrl(wcUri);
      provider.checkUrl(wcUri2);
      expect(dispatched, [wcUri, wcUri2]);
    });

    test('amazeapp:///wc?uri= 深链中提取 WalletConnect URI', () {
      final dispatched = <String>[];
      provider.connectDAPPCallBack = dispatched.add;

      final deepLink = 'amazeapp:///wc?uri=${Uri.encodeComponent(wcUri)}';
      expect(provider.checkUrl(deepLink), isFalse);
      expect(dispatched, [wcUri]);
    });

    test('未设置 connectDAPPCallBack 时 wc: URI 的现状行为：放行且不记录', () {
      // 现状断言：callback 为 null 时 _tryHandleWalletConnect 返回 false，
      // wc: 也不在 blockedSchemes 内，checkUrl 最终返回 true（允许 WebView
      // 尝试导航 wc:，实际会加载失败）。lastDispatchedWcUri 保持未记录，
      // 后续设置 callback 后同一 URI 仍可正常派发。
      expect(provider.connectDAPPCallBack, isNull);
      expect(provider.checkUrl(wcUri), isTrue);
      expect(provider.lastDispatchedWcUri, isNull);
    });
  });
}
