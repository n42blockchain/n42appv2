import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_settings_page.dart';

class MockContactBloc extends Mock implements ContactBloc {
  @override
  ContactState get state => const ContactState.initial();

  @override
  Stream<ContactState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

Widget buildTestWidget(Widget child, {ContactBloc? contactBloc}) {
  final widget = MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  if (contactBloc != null) {
    return BlocProvider<ContactBloc>.value(
      value: contactBloc,
      child: widget,
    );
  }
  return widget;
}

void main() {
  late MockContactBloc mockContactBloc;

  setUp(() {
    mockContactBloc = MockContactBloc();
  });

  group('ContactSettingsPage', () {
    testWidgets('renders basic menu items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 验证基本菜单项存在
      expect(find.textContaining('Report'), findsOneWidget);
      expect(find.textContaining('Delete'), findsOneWidget);
    });

    testWidgets('tapping Report opens report dialog', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 点击投诉按钮
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // 验证投诉对话框弹出，包含举报原因选项
      expect(find.text('Spam'), findsOneWidget);
      expect(find.text('Harassment'), findsOneWidget);
      expect(find.text('Fraud'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('report dialog shows validation error when no reason selected',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 打开投诉对话框
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // 不选择任何原因，直接点击提交
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // 验证显示了验证错误提示
      expect(find.text('Please select a reason'), findsOneWidget);
    });

    testWidgets('report dialog submits successfully when reason is selected',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 打开投诉对话框
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // 选择 Spam 原因
      await tester.tap(find.text('Spam'));
      await tester.pumpAndSettle();

      // 点击提交
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // 对话框应关闭，显示成功 SnackBar
      expect(find.text('Report submitted'), findsOneWidget);
    });

    testWidgets('report dialog has optional description field',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 打开投诉对话框
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // 验证补充说明输入框存在
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('report dialog can be cancelled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ContactSettingsPage(
            userId: '@test:server.com',
            displayName: 'Test User',
          ),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      // 打开投诉对话框
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // 点击取消
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // 验证对话框已关闭（不再显示举报原因选项）
      expect(find.text('Spam'), findsNothing);
    });
  });
}
