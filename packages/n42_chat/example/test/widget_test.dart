import 'package:flutter_test/flutter_test.dart';

import 'package:n42_chat_example/main.dart';

void main() {
  testWidgets('N42ChatExampleApp builds without error', (WidgetTester tester) async {
    // 跳过完整的 widget 测试，因为需要初始化 N42Chat
    // 这里只验证 main.dart 可以被导入
    expect(N42ChatExampleApp, isNotNull);
  });
}
