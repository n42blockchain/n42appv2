import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

/// 创建可测试的 Widget 包装器
/// 
/// 用于 Widget 测试，提供必要的上下文
Widget createTestableWidget({
  required Widget child,
  List<ChangeNotifierProvider>? providers,
}) {
  return MaterialApp(
    home: providers != null && providers.isNotEmpty
        ? MultiProvider(
            providers: providers,
            child: child,
          )
        : child,
  );
}

/// 创建带有 Scaffold 的可测试 Widget
Widget createTestableWidgetWithScaffold({
  required Widget child,
  List<ChangeNotifierProvider>? providers,
}) {
  return createTestableWidget(
    providers: providers,
    child: Scaffold(body: child),
  );
}

/// 等待所有异步操作完成
Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// 等待指定时间后继续
Future<void> pumpWithDuration(
  WidgetTester tester,
  Duration duration,
) async {
  await tester.pump(duration);
}

/// 查找包含指定文本的 Widget
Finder findByText(String text) {
  return find.text(text);
}

/// 查找指定类型的 Widget
Finder findByType<T extends Widget>() {
  return find.byType(T);
}

/// 查找指定 Key 的 Widget
Finder findByKey(Key key) {
  return find.byKey(key);
}

/// 验证 Widget 存在
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// 验证 Widget 不存在
void expectWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// 验证 Widget 存在多个
void expectMultipleWidgets(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Mock 类的辅助扩展
extension MockExtensions<T extends Mock> on T {
  /// 设置方法返回 Future 值
  void whenAsync<R>(
    Function(T) methodCall,
    R value,
  ) {
    when(methodCall(this)).thenAnswer((_) async => value);
  }

  /// 设置方法抛出异常
  void whenThrows(
    Function(T) methodCall,
    Exception exception,
  ) {
    when(methodCall(this)).thenThrow(exception);
  }

  /// 设置方法返回 Stream
  void whenStream<R>(
    Function(T) methodCall,
    Stream<R> stream,
  ) {
    when(methodCall(this)).thenAnswer((_) => stream);
  }
}

/// 测试数据生成器
class TestDataGenerator {
  /// 生成测试用户数据
  static Map<String, dynamic> generateUserData({
    String? uuid,
    String? email,
    String? name,
  }) {
    return {
      'uuid': uuid ?? 'test_uuid_${DateTime.now().millisecondsSinceEpoch}',
      'email': email ?? 'test@example.com',
      'name': name ?? 'Test User',
      'token': 'test_token',
      'created': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 生成测试钱包数据
  static Map<String, dynamic> generateWalletData({
    String? address,
    String? name,
    String? type,
  }) {
    return {
      'address': address ?? '0x1234567890abcdef',
      'name': name ?? 'Test Wallet',
      'type': type ?? 'ethereum',
      'balance': '1000000000000000000',
    };
  }

  /// 生成测试交易数据
  static Map<String, dynamic> generateTransactionData({
    String? hash,
    String? from,
    String? to,
    String? value,
  }) {
    return {
      'hash': hash ?? '0xabc123',
      'from': from ?? '0x1234567890abcdef',
      'to': to ?? '0xfedcba0987654321',
      'value': value ?? '1000000000000000000',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': 'confirmed',
    };
  }
}

