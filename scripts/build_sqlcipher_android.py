#!/usr/bin/env python3
"""Build the pinned SQLCipher 4.19 Android JNI with 16 KB RELRO alignment.

The input is an isolated checkout of the Android wrapper with its stale core
gitlink deliberately replaced by the official SQLCipher 4.19 core revision.
The LibTomCrypt submodule remains at the wrapper's exact revision.
"""

import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


WRAPPER_REV = '9a5d685404489cbff14d4c46da81555de1a38787'
CORE_REV = 'c4b275a47932888216bade83aff2bbc73df0ff85'
CRYPT_REV = '476a9579ae94f32b9ea9e2747bfb04b302370259'
ABIS = ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64')
NDK_REV = '28.2.13676358'
NDK_TOOL_SHA256 = {
    'ndk_build': '4dab4ba20f79dc510ce760110d897d07a89d7389c2af162c416d14133a7102c7',
    'clang': 'df85444b66234bf4cae267e22bde45ea8fef596d30ca2991b2091a27e6ea7718',
    'clang++': 'df85444b66234bf4cae267e22bde45ea8fef596d30ca2991b2091a27e6ea7718',
    'ld.lld': '295bc36e1b10be0137f09904b7cc928a11ab3d44a8ec8250e4087ebd71f091c2',
    'llvm-ar': '3705c4237aab47a369b999f5b0af572a6ea56488df7174aaab29e5fc4b082ea3',
    'llvm-strip': '438848c3cb13a8fa7607507779465f3e3426637eb2e9c605cde44e49c8539f1f',
    'readelf': '37e565359be0c9f2868348dd314416a420d137ee84c891ec8474cf7d29cfd995',
}
NDK_PROPERTIES_SHA256 = 'c00aa236fdb205e9be9edd9e2169763e48aca52735efff4e16f34205d49783b5'
HOST_TOOL_SHA256 = {
    'tclsh': '086b37d045ce937d286df2b2026cdc7f8b08ea31693dd5c2f15a6ed7271741fa',
    'make': 'b8763cf250e607a778bb4603cecb5b90338814d0a3dfcba0d57b1de242f610e9',
    'clang': '1590ac950a3d627817d09ade5cb60b2115f17a72182a3141e010b4bcc482a0c9',
    'sdk_settings': '7b93ad7e534cc4b31c6a4e39d19b5e0288acf2168c2649479a796d1cb51939fb',
}
HOST_CLANG = Path('/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang')
HOST_SDK = Path('/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk')
CORE = Path('sqlcipher/src/main/jni/sqlcipher/src')
CRYPT = Path('sqlcipher/src/main/jni/libtomcrypt/src')
JNI = Path('sqlcipher/src/main/jni/sqlcipher')
ANDROID_MK = JNI / 'Android.mk'
INPUT_SHA256 = {
    ANDROID_MK: '6161bb1a5e76e3e38ff93016aaeb2da0fa4e0f719cb637201636ee5833c13a7b',
    JNI / 'JNIHelp.cpp':
        'e7e046482a0817965ca291e0d9adc01462db52ea357e09003538522affc90d29',
    Path('sqlcipher/src/main/jni/Application.mk'):
        '59be7d34c9950e747708fba78e52471e69472dd6f4414caf82f6e83a15391824',
    Path('LICENSE'): '09e4af560ce2e3c9c2aa6b564e35947b03db7d1ae345f22a32793ed46542cc14',
    CORE / 'src/sqlcipher.c':
        '594987c41f5b5d371dbd5a7471c6e8710e39e41dd4ea3889c3528eaf8abd70d9',
    CORE / 'src/crypto_libtomcrypt.c':
        '389c700c0d47bb3a2b79c278893a65f9dbdda329d1ad209932f36c81455af899',
    CORE / 'LICENSE.md':
        '2a2826f6acf46fa650730cf42cbb22a642be33a7ef119c9c4f4bf6daf3bef48e',
    CRYPT / 'LICENSE':
        '8f196cb13afd271f5e267fd29543fc454596382ad580e7592709492843996ac8',
}
OVERRIDE_KEYS = (
    'SQLCIPHER_CFLAGS', 'CC', 'CXX', 'CFLAGS', 'CXXFLAGS', 'CPPFLAGS',
    'LDFLAGS', 'MAKEFLAGS', 'MFLAGS', 'NDK_PROJECT_PATH', 'NDK_APPLICATION_MK',
    'APP_BUILD_SCRIPT', 'APP_ABI', 'APP_PLATFORM', 'APP_OPTIM', 'NDK_OUT',
    'NDK_LIBS_OUT', 'NDK_TOOLCHAIN_VERSION', 'ANDROID_NDK_HOME',
    'ANDROID_NDK_ROOT', 'CPATH', 'C_INCLUDE_PATH', 'CPLUS_INCLUDE_PATH',
    'LIBRARY_PATH', 'PKG_CONFIG_PATH', 'PKG_CONFIG_LIBDIR', 'TCL_LIBRARY',
    'TCLLIBPATH', 'SOURCE_DATE_EPOCH', 'CC_FOR_BUILD', 'autosetup_tclsh',
    'SDKROOT', 'DEVELOPER_DIR', 'TOOLCHAINS',
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def require_digest(path, expected, label):
    require(path.is_file() and digest(path) == expected,
            f'{label} byte mismatch')


def git(repo, *args):
    result = subprocess.run(['git', '-C', str(repo), *args], check=False,
                            capture_output=True, text=True)
    require(result.returncode == 0,
            f'git {" ".join(args)} failed in {repo}: {result.stderr.strip()}')
    return result.stdout.strip()


def reject_stale_amalgamation(jni):
    for name in ('sqlite3.c', 'sqlite3.h'):
        require(not (jni / name).exists(), f'stale amalgamation: {jni / name}')


def patch_android_mk(original):
    old = 'LOCAL_LDFLAGS += -Wl,-z,max-page-size=16384\n'
    require(original.count(old) == 1 and 'common-page-size=' not in original,
            'unexpected SQLCipher final-link flags')
    return original.replace(old, old +
                            'LOCAL_LDFLAGS += -Wl,-z,common-page-size=16384\n')


def patch_jni_help(original):
    old = ('#if __GLIBC__\n'
           '    // Note: glibc has a nonstandard strerror_r that returns char* rather than POSIX\'s int.\n'
           '    // char *strerror_r(int errnum, char *buf, size_t n);\n'
           '    return strerror_r(errnum, buf, buflen);\n'
           '#else\n'
           '    char* msg = strerror_r(errnum, buf, buflen);\n'
           '    if (msg != nullptr){\n'
           '        return msg;\n'
           '    }\n'
           '    snprintf(buf, buflen, "errno %d", errnum);\n'
           '    return buf;\n'
           '#endif\n')
    replacement = (
        '#if defined(__GLIBC__) || (defined(__ANDROID__) && defined(__USE_GNU) && __ANDROID_API__ >= 23)\n'
        '    char* msg = strerror_r(errnum, buf, buflen);\n'
        '    if (msg != nullptr) {\n'
        '        return msg;\n'
        '    }\n'
        '#else\n'
        '    int status = strerror_r(errnum, buf, buflen);\n'
        '    if (status == 0) {\n'
        '        return buf;\n'
        '    }\n'
        '#endif\n'
        '    snprintf(buf, buflen, "errno %d", errnum);\n'
        '    return buf;\n'
    )
    require(original.count(old) == 1, 'unexpected JNI strerror_r implementation')
    return original.replace(old, replacement)


def ndk_command(tool, abi):
    require(abi in ABIS, f'unsupported ABI: {abi}')
    return [tool, '-B', '-j4', 'V=1', f'APP_ABI={abi}',
            'APP_PLATFORM=android-23']


def child_environment(inherited):
    env = {key: value for key, value in inherited.items()
           if key not in OVERRIDE_KEYS and not key.startswith('NDK_')}
    env['LC_ALL'] = 'C'
    env['LANG'] = 'C'
    env['TZ'] = 'UTC'
    env['SOURCE_DATE_EPOCH'] = '1780000000'
    env['PATH'] = '/usr/bin:/bin:/usr/sbin:/sbin'
    return env


def require_clean_repository(repo):
    require(not git(repo, 'status', '--porcelain=v1', '--untracked-files=all',
                    '--ignored', '--ignore-submodules=all'),
            f'dirty or generated source: {repo}')


def verify_sources(source):
    require(git(source, 'rev-parse', 'HEAD') == WRAPPER_REV,
            'wrapper revision mismatch')
    require(git(source / CORE, 'rev-parse', 'HEAD') == CORE_REV,
            'core revision mismatch; wrapper tag gitlink is stale 4.16')
    require(git(source / CRYPT, 'rev-parse', 'HEAD') == CRYPT_REV,
            'LibTomCrypt revision mismatch')
    for repo in (source, source / CORE, source / CRYPT):
        require_clean_repository(repo)
    reject_stale_amalgamation(source / JNI)
    for relative, expected in INPUT_SHA256.items():
        path = source / relative
        require(path.is_file() and digest(path) == expected,
                f'source byte mismatch: {relative}')
    require('CIPHER_VERSION_NUMBER 4.19.0' in
            (source / CORE / 'src/sqlcipher.c').read_text(),
            'core version differs from 4.19.0')
    return {name: git(repo, 'rev-parse', 'HEAD^{tree}') for name, repo in (
        ('wrapper', source), ('core', source / CORE),
        ('libtomcrypt', source / CRYPT))}


def verify_ndk(ndk):
    properties = ndk / 'source.properties'
    require(properties.is_file() and f'Pkg.Revision = {NDK_REV}' in
            properties.read_text(), 'NDK revision mismatch')
    require_digest(properties, NDK_PROPERTIES_SHA256, 'NDK source.properties')
    binary_dir = ndk / 'toolchains/llvm/prebuilt/darwin-x86_64/bin'
    tools = {
        'ndk_build': ndk / 'ndk-build',
        'clang': binary_dir / 'clang', 'clang++': binary_dir / 'clang++',
        'ld.lld': binary_dir / 'ld.lld', 'llvm-ar': binary_dir / 'llvm-ar',
        'llvm-strip': binary_dir / 'llvm-strip',
        'readelf': binary_dir / 'llvm-readelf',
    }
    for name, path in tools.items():
        require_digest(path, NDK_TOOL_SHA256[name], f'NDK {name}')
    return {name: {'path': str(path.resolve()), 'sha256': digest(path)}
            for name, path in tools.items()}


def verify_host_tools():
    tools = {'tclsh': Path('/usr/bin/tclsh'), 'make': Path('/usr/bin/make'),
             'clang': HOST_CLANG,
             'sdk_settings': HOST_SDK / 'SDKSettings.json'}
    for name, path in tools.items():
        require_digest(path, HOST_TOOL_SHA256[name], f'host {name}')
    require(HOST_SDK.is_dir(), 'pinned host SDK missing')
    finder = subprocess.run(['xcrun', '--find', 'clang'], capture_output=True,
                            text=True, check=False)
    sdk = subprocess.run(['xcrun', '--show-sdk-path'], capture_output=True,
                         text=True, check=False)
    version = subprocess.run(['xcodebuild', '-version'], capture_output=True,
                             text=True, check=False)
    require(finder.returncode == sdk.returncode == version.returncode == 0,
            'Xcode tool discovery failed')
    require(Path(finder.stdout.strip()).resolve() == HOST_CLANG.resolve() and
            Path(sdk.stdout.strip()).resolve() == HOST_SDK.resolve() and
            version.stdout.strip() == 'Xcode 27.0\nBuild version 27A266a',
            'Xcode compiler/SDK identity mismatch')
    return {name: {'path': str(path.resolve()), 'sha256': digest(path)}
            for name, path in tools.items()}


def run(command, cwd, env, log):
    with log.open('w') as stream:
        stream.write('command: ' + ' '.join(map(str, command)) + '\n')
        stream.write('cwd: ' + str(cwd) + '\n')
        stream.flush()
        result = subprocess.run(list(map(str, command)), cwd=cwd, env=env,
                                stdout=stream, stderr=subprocess.STDOUT,
                                check=False)
        stream.write(f'\nexit: {result.returncode}\n')
    require(result.returncode == 0,
            f'command failed ({result.returncode}); see {log}')


def build(source, out, ndk):
    require(not out.exists(), f'output already exists: {out}')
    trees = verify_sources(source)
    tools = verify_ndk(ndk)
    host_tools = verify_host_tools()
    out.mkdir(parents=True)
    logs = out / 'logs'
    logs.mkdir()
    env = child_environment(os.environ)
    env.update({'CC': str(HOST_CLANG), 'CC_FOR_BUILD': str(HOST_CLANG),
                'autosetup_tclsh': '/usr/bin/tclsh', 'SDKROOT': str(HOST_SDK),
                'DEVELOPER_DIR': '/Applications/Xcode.app/Contents/Developer'})
    mk = source / ANDROID_MK
    mk.write_text(patch_android_mk(mk.read_text()))
    helper = source / JNI / 'JNIHelp.cpp'
    helper.write_text(patch_jni_help(helper.read_text()))
    patch = git(source, 'diff', '--', str(ANDROID_MK), str(JNI / 'JNIHelp.cpp'))
    require(patch.count('common-page-size=16384') == 1 and
            patch.count('int status = strerror_r') == 1,
            'unexpected source patch')
    (out / 'source.patch').write_text(patch + '\n')
    core = source / CORE
    run(['./configure', '--with-tempstore=yes', '--disable-tcl'], core, env,
        logs / 'configure.log')
    run(['/usr/bin/make', 'clean'], core, env, logs / 'make-clean.log')
    run(['/usr/bin/make', 'sqlite3.c'], core, env, logs / 'make-sqlite3.log')
    amalgamation = {}
    for name in ('sqlite3.c', 'sqlite3.h'):
        generated = core / name
        require(generated.is_file() and generated.stat().st_size > 0,
                f'missing generated {name}')
        destination = source / JNI / name
        shutil.copyfile(generated, destination)
        amalgamation[name] = {'size': destination.stat().st_size,
                              'sha256': digest(destination)}
    native = source / 'sqlcipher/src/main/jni'
    binaries = {}
    for abi in ABIS:
        native_env = dict(env)
        native_env.update({
            'ANDROID_NDK_HOME': str(ndk),
            'NDK_PROJECT_PATH': str(source / 'sqlcipher/src/main'),
            'APP_BUILD_SCRIPT': str(native / 'Android.mk'),
            'NDK_APPLICATION_MK': str(native / 'Application.mk'),
            'APP_ABI': abi, 'APP_PLATFORM': 'android-23',
            'APP_OPTIM': 'release', 'NDK_OUT': str(out / 'obj' / abi),
            'NDK_LIBS_OUT': str(out / 'libs'),
        })
        run(ndk_command(ndk / 'ndk-build', abi), native, native_env,
            logs / f'ndk-build-{abi}.log')
        binary = out / 'libs' / abi / 'libsqlcipher.so'
        require(binary.is_file(), f'missing {abi} libsqlcipher.so')
        binaries[abi] = {'size': binary.stat().st_size, 'sha256': digest(binary)}
    manifest = {
        'schema_version': 1,
        'source_revisions': {'wrapper': WRAPPER_REV, 'core': CORE_REV,
                             'libtomcrypt': CRYPT_REV},
        'source_trees': trees,
        'input_sha256': {str(key): value for key, value in INPUT_SHA256.items()},
        'ndk_revision': NDK_REV, 'ndk_tools': tools,
        'host_tools': host_tools,
        'amalgamation': amalgamation,
        'source_patch_sha256': digest(out / 'source.patch'),
        'abi_binaries': binaries,
        'flags': ['-Wl,-z,max-page-size=16384',
                  '-Wl,-z,common-page-size=16384'],
    }
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2,
                                                sort_keys=True) + '\n')
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--ndk', type=Path, required=True)
    parser.add_argument('--preflight-only', action='store_true')
    args = parser.parse_args()
    try:
        source, out, ndk = (args.source.resolve(), args.out.resolve(),
                            args.ndk.resolve())
        if args.preflight_only:
            print(json.dumps({'source_trees': verify_sources(source),
                              'ndk_tools': verify_ndk(ndk),
                              'host_tools': verify_host_tools()}, indent=2))
        else:
            print(json.dumps(build(source, out, ndk), indent=2))
    except (OSError, ValueError) as error:
        print(f'SQLCipher build rejected: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
