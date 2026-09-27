import 'dart:io';

import 'package:build_tool/src/android_environment.dart';
import 'package:build_tool/src/target.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late String sdk;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('vodo-page-flags-');
    sdk = path.join(temp.path, 'sdk');
    final ndk = path.join(sdk, 'ndk', '28.2.13676358');
    final host = Platform.isMacOS ? 'darwin-x86_64' : 'linux-x86_64';
    final bin =
        Directory(path.join(ndk, 'toolchains', 'llvm', 'prebuilt', host, 'bin'))
          ..createSync(recursive: true);
    for (final tool in ['llvm-ar', 'clang', 'clang++', 'llvm-ranlib']) {
      File(path.join(bin.path, tool)).createSync();
    }
    File(path.join(ndk, 'package.xml')).createSync();
  });

  tearDown(() => temp.deleteSync(recursive: true));

  for (final abi in ['arm64-v8a', 'x86_64']) {
    test('$abi passes both 16 KiB page flags to Rust', () async {
      final target = Target.all.singleWhere((item) => item.android == abi);
      final env = AndroidEnvironment(
        sdkPath: sdk,
        ndkVersion: '28.2.13676358',
        minSdkVersion: 26,
        targetTempDir: path.join(temp.path, 'build'),
        target: target,
      );
      final flags = (await env.buildEnvironment())['CARGO_ENCODED_RUSTFLAGS']!
          .split('\x1f');
      expect(
          flags,
          containsAllInOrder([
            '-C',
            'link-arg=-Wl,--hash-style=both',
            '-C',
            'link-arg=-Wl,-z,max-page-size=16384',
            '-C',
            'link-arg=-Wl,-z,common-page-size=16384',
          ]));
    });
  }

  test('32-bit target retains its existing page flags', () async {
    final env = AndroidEnvironment(
      sdkPath: sdk,
      ndkVersion: '28.2.13676358',
      minSdkVersion: 26,
      targetTempDir: path.join(temp.path, 'build'),
      target: Target.all.singleWhere((item) => item.android == 'armeabi-v7a'),
    );
    final flags = (await env.buildEnvironment())['CARGO_ENCODED_RUSTFLAGS']!;
    expect(flags, isNot(contains('page-size')));
  });
}
