import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/router/app_router.dart';

void main() {
  setUp(() async {
    N42ChatRouter.reset();
    await resetDependencies();
  });

  tearDown(() async {
    N42ChatRouter.reset();
    await resetDependencies();
  });

  test('router instance is cached until reset', () {
    N42ChatRouter.configure(enableDebugLogs: false);

    final first = N42ChatRouter.router;
    final second = N42ChatRouter.router;

    expect(identical(first, second), isTrue);

    N42ChatRouter.reset();

    final third = N42ChatRouter.router;
    expect(identical(first, third), isFalse);
  });

  test('debug diagnostics disabled when config is missing', () {
    expect(N42ChatRouter.debugLogDiagnosticsEnabled, isFalse);
  });

  test('debug diagnostics follow config flag', () async {
    N42ChatRouter.configure(enableDebugLogs: true);

    expect(N42ChatRouter.debugLogDiagnosticsEnabled, isTrue);

    N42ChatRouter.reset();
    await resetDependencies();
    N42ChatRouter.configure(enableDebugLogs: false);

    expect(N42ChatRouter.debugLogDiagnosticsEnabled, isFalse);
  });
}
