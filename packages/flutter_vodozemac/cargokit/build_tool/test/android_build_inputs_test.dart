import 'package:build_tool/src/builder.dart';
import 'package:build_tool/src/cargo.dart';
import 'package:build_tool/src/options.dart';
import 'package:build_tool/src/rustup.dart';
import 'package:build_tool/src/target.dart';
import 'package:build_tool/src/util.dart';
import 'package:test/test.dart';

void main() {
  String compilerVersion = 'rustc 1.97.1 (8bab26f4f 2026-07-14)';
  final target = Target.all.singleWhere((item) => item.android == 'arm64-v8a');

  setUp(() {
    compilerVersion = 'rustc 1.97.1 (8bab26f4f 2026-07-14)';
    testRunCommandOverride = (args) {
      if (args.arguments case ['toolchain', 'list']) {
        return TestRunCommandResult(stdout: 'stable-aarch64-apple-darwin\n');
      }
      if (args.arguments
          case ['target', 'list', '--toolchain', _, '--installed']) {
        return TestRunCommandResult(stdout: '${target.rust}\n');
      }
      if (args.arguments case ['run', _, 'rustc', '--version']) {
        return TestRunCommandResult(stdout: '$compilerVersion\n');
      }
      throw StateError('Unexpected rustup command: ${args.arguments}');
    };
  });

  tearDown(() => testRunCommandOverride = null);

  BuildEnvironment environment({String ndk = '28.2.13676358'}) =>
      BuildEnvironment(
        configuration: BuildConfiguration.release,
        crateOptions: CargokitCrateOptions(),
        targetTempDir: '/tmp/vodo-test',
        manifestDir: '/tmp/vodo-test',
        crateInfo: CrateInfo(packageName: 'vodozemac_bindings_dart'),
        isAndroid: true,
        androidSdkPath: '/tmp/sdk',
        androidNdkVersion: ndk,
        androidMinSdkVersion: 26,
      );

  test('Android build refuses another stable Rust compiler', () {
    compilerVersion = 'rustc 1.98.0 (wrong 2026-08-01)';
    expect(
      () => RustBuilder(target: target, environment: environment())
          .prepare(Rustup()),
      throwsA(isA<BuildException>().having(
        (error) => error.message,
        'message',
        contains('Rust compiler mismatch'),
      )),
    );
  });

  test('Android build refuses another NDK revision', () {
    expect(
      () => RustBuilder(target: target, environment: environment(ndk: '27.0'))
          .prepare(Rustup()),
      throwsA(isA<BuildException>().having(
        (error) => error.message,
        'message',
        contains('NDK revision mismatch'),
      )),
    );
  });

  test('Android build accepts pinned compiler and NDK', () {
    RustBuilder(target: target, environment: environment()).prepare(Rustup());
  });
}
