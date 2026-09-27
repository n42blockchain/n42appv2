import 'dart:io';

import 'package:build_tool/src/builder.dart';
import 'package:build_tool/src/cargo.dart';
import 'package:build_tool/src/options.dart';
import 'package:build_tool/src/target.dart';
import 'package:build_tool/src/util.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late TestRunCommandArgs command;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('vodo-cargo-command-');
    final host = Platform.isMacOS ? 'darwin-x86_64' : 'linux-x86_64';
    final ndkBin = Directory(path.join(temp.path, 'sdk', 'ndk', '28.2.13676358',
        'toolchains', 'llvm', 'prebuilt', host, 'bin'))
      ..createSync(recursive: true);
    for (final name in ['llvm-ar', 'clang', 'clang++', 'llvm-ranlib']) {
      File(path.join(ndkBin.path, name)).createSync();
    }
    testRunCommandOverride = (args) {
      command = args;
      return TestRunCommandResult();
    };
  });

  tearDown(() {
    testRunCommandOverride = null;
    temp.deleteSync(recursive: true);
  });

  Future<void> build(BuildConfiguration mode, Target target) => RustBuilder(
        target: target,
        environment: BuildEnvironment(
          configuration: mode,
          crateOptions: CargokitCrateOptions(),
          targetTempDir: path.join(temp.path, 'build'),
          manifestDir: temp.path,
          crateInfo: CrateInfo(packageName: 'vodozemac_bindings_dart'),
          isAndroid: target.android != null,
          androidSdkPath:
              target.android != null ? path.join(temp.path, 'sdk') : null,
          androidNdkVersion: target.android != null ? '28.2.13676358' : null,
          androidMinSdkVersion: target.android != null ? 26 : null,
        ),
      ).build();

  for (final mode in BuildConfiguration.values) {
    test('Android ${mode.name} Cargo command is locked and offline', () async {
      await build(
        mode,
        Target.all.singleWhere((target) => target.android == 'arm64-v8a'),
      );
      expect(command.executable, 'rustup');
      expect(
          command.arguments,
          containsAllInOrder([
            'cargo',
            'build',
            '--locked',
            '--offline',
            '--manifest-path',
          ]));
    });
  }

  test('non-Android Cargo command retains upstream flag behavior', () async {
    await build(
      BuildConfiguration.release,
      Target.all
          .singleWhere((target) => target.rust == 'x86_64-unknown-linux-gnu'),
    );
    expect(command.arguments, isNot(contains('--locked')));
    expect(command.arguments, isNot(contains('--offline')));
  });
}
