#!/usr/bin/env python3
"""Link four Wallet Core Android JNI candidates from reviewed generated inputs."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import subprocess
import sys


SOURCE_COMMIT = 'd40d24a63d92619167903369308bf0e2f7eb3a59'
GENERATED_MANIFEST_SHA256 = 'bf90d3a23eb754fa59df4d869fdd1d04c53eb499d86b91013a3ff8bab36d1821'
ARCHIVE_MANIFEST_SHA256 = '5206251069cbc844de00d9ee567ffbf3a5ff659ae4798855c8da8a6f42a55c23'
ORIGINAL_CMAKE_SHA256 = '09e0cf9e4cfcd832f5133a30e7dd4a0467e460eb7a76ed5a0065c3d47ab8c792'
PATCHED_CMAKE_SHA256 = 'c9f5f43c1677e9d6a26c663c20dc5a27568198af3c7ee0e03351f770ecedcb15'
TOOLCHAIN_SHA256 = 'dbad92d9dcfea0d32b7c5e5f82f5072d878ded5d46a5d3f1f581ea108ca7fe89'
NINJA_SHA256 = '5b861a9e1e062ad8e01a1370f5909b36c086774899b4ac2029192744352404d0'
ARCHIVES = {
    'arm64-v8a': '5888e672c1e04b918eb3d5c84c9d8268f2fe0e08092666cc2c2ffb2c53a097c2',
    'armeabi-v7a': 'befcc6da08a5b55f1a863265caf41d45924c369eff0334de418aba38b1a3f22c',
    'x86': '1aef18d44e9b748214474e2a59cc1f4e17a813d080a0d2e7771c3e86bff85bd5',
    'x86_64': '79e7195105061192a0faabc4b57977517f4fcee378597fa5a8aa8ebf68ca05a4',
}
ANCHOR = (b'    add_library(TrustWalletCore SHARED ${sources} ${PROTO_SRCS} ${PROTO_HDRS})\n'
          b'    find_library(log-lib log)')
REPLACEMENT = (b'    add_library(TrustWalletCore SHARED ${sources} ${PROTO_SRCS} ${PROTO_HDRS})\n'
               b'    target_link_options(TrustWalletCore PRIVATE -Wl,-z,max-page-size=16384 '
               b'-Wl,-z,common-page-size=16384)\n'
               b'    find_library(log-lib log)')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256_bytes(value):
    return sha256(value).hexdigest()


def digest(path):
    value = sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def pinned_json(path, expected):
    require(digest(path) == expected, f'pinned manifest changed: {path}')
    return json.loads(path.read_text())


def patch_cmake_text(original):
    require(original.count(ANCHOR) == 1, 'Android shared target anchor mismatch')
    return original.replace(ANCHOR, REPLACEMENT, 1)


def verify_generated_files(source, manifest):
    files = manifest['files']
    for relative, record in files.items():
        name = Path(relative)
        require(not name.is_absolute() and '..' not in name.parts,
                f'unsafe generated path: {relative}')
        path = source / name
        require(path.is_file() and path.stat().st_size == record['bytes'] and
                digest(path) == record['sha256'], f'generated file mismatch: {relative}')
    if 'folders' in manifest:
        actual = {path.relative_to(source).as_posix()
                  for folder in manifest['folders']
                  for path in (source / folder).rglob('*') if path.is_file()}
        require(actual == set(files), 'generated output file set mismatch')


def preflight(task, build, source):
    app = Path(__file__).resolve().parents[1]
    receipt = build / 'link-preflight.json'
    command = [sys.executable, str(app / 'scripts/walletcore_android_preflight.py'),
               '--source', str(source), '--source-inputs',
               str(task / 'task-16f-walletcore-source-inputs/manifest.json'),
               '--tool-inputs', str(build / 'tool-inputs.json'),
               '--boost-manifest', str(build / 'boost-header-manifest.json'),
               '--boost-headers', str(build / 'host-tools/boost-1.90.0_1/include/boost'),
               '--official-dir', str(build / 'official'), '--receipt', str(receipt)]
    process = subprocess.run(command, capture_output=True, text=True, check=False)
    (build / 'link-preflight-process.log').write_text(
        f'exit={process.returncode}\n{process.stdout}{process.stderr}')
    require(process.returncode == 0, 'link preflight process failed')
    data = json.loads(receipt.read_text())
    require(data.get('passed') is True and data.get('source', {}).get('commit') ==
            SOURCE_COMMIT and data.get('built_candidate') is False,
            'link preflight receipt mismatch')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--task-root', type=Path, required=True)
    args = parser.parse_args()
    task = args.task_root.resolve()
    build = task / 'task-16f-walletcore-build'
    source = build / 'source'
    preflight(task, build, source)
    generated = pinned_json(build / 'generated-outputs.json', GENERATED_MANIFEST_SHA256)
    verify_generated_files(source, generated)
    archive_manifest = pinned_json(build / 'rust-archives.json', ARCHIVE_MANIFEST_SHA256)
    require(set(archive_manifest) == set(ARCHIVES), 'Rust ABI set mismatch')
    for abi, expected in ARCHIVES.items():
        record = archive_manifest[abi]
        path = Path(record['path'])
        require(path.is_file() and path.stat().st_size == record['bytes'] and
                digest(path) == expected == record['sha256'],
                f'Rust archive mismatch: {abi}')
    files = json.loads((build / 'tool-inputs.json').read_text())['files']
    ndk = Path(files['ndk_source_properties']['path']).parent
    cmake = Path(files['android_cmake']['path'])
    toolchain = ndk / 'build/cmake/android.toolchain.cmake'
    ninja = cmake.parent / 'ninja'
    require(digest(toolchain) == TOOLCHAIN_SHA256 and
            digest(ninja) == NINJA_SHA256, 'Android CMake/Ninja tool mismatch')
    cmake_source = source / 'CMakeLists.txt'
    original = cmake_source.read_bytes()
    require(sha256_bytes(original) == ORIGINAL_CMAKE_SHA256,
            'tagged CMake source differs before Android link patch')
    patched = patch_cmake_text(original)
    require(sha256_bytes(patched) == PATCHED_CMAKE_SHA256,
            'Android link patch differs')
    cmake_source.write_bytes(patched)
    patch = subprocess.run(['git', '-C', str(source), 'diff', '--binary', '--',
                            'CMakeLists.txt'], capture_output=True, check=True)
    (build / 'android-final-link.patch').write_bytes(patch.stdout)
    env = json.loads((build / 'generation-environment.json').read_text())
    candidates = {}
    for abi in ARCHIVES:
        output = build / 'candidate-cmake' / abi
        output.mkdir(parents=True, exist_ok=True)
        configure = [str(cmake), '-G', 'Ninja', '-S', str(source), '-B', str(output),
                     '-DCMAKE_TOOLCHAIN_FILE=' + str(toolchain),
                     '-DCMAKE_MAKE_PROGRAM=' + str(ninja),
                     '-DANDROID_NDK=' + str(ndk), '-DANDROID_ABI=' + abi,
                     '-DANDROID_PLATFORM=android-23', '-DANDROID_STL=c++_static',
                     '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_SHARED_LIBS=OFF',
                     '-DTW_UNITY_BUILD=ON', '-DTW_UNIT_TESTS=OFF',
                     '-DTW_BUILD_EXAMPLES=OFF',
                     '-DTW_ENABLE_CCACHE=OFF', '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON']
        with (output / 'configure.log').open('w') as log:
            log.write(json.dumps({'command': configure, 'environment': env}) + '\n')
            log.flush()
            status = subprocess.run(configure, cwd=source, env=env, stdout=log,
                                    stderr=subprocess.STDOUT, check=False).returncode
            log.write(f'configure_exit={status}\n')
        require(status == 0, f'CMake configure failed: {abi}')
        command = [str(cmake), '--build', str(output), '--target',
                   'TrustWalletCore', '--parallel', '2', '--', '-v']
        with (output / 'build.log').open('w') as log:
            log.write(json.dumps({'command': command}) + '\n')
            log.flush()
            status = subprocess.run(command, cwd=source, env=env, stdout=log,
                                    stderr=subprocess.STDOUT, check=False).returncode
            log.write(f'build_exit={status}\n')
        require(status == 0, f'CMake native link failed: {abi}')
        so = output / 'libTrustWalletCore.so'
        require(so.is_file(), f'CMake shared output missing: {abi}')
        candidates[abi] = {'path': str(so), 'bytes': so.stat().st_size,
                           'sha256': digest(so)}
        (build / 'candidate-native.json').write_text(json.dumps(candidates, indent=2) + '\n')
        print(json.dumps({'completed_abi': abi, 'candidate': candidates[abi]}), flush=True)
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, IndexError, json.JSONDecodeError) as error:
        print(f'Wallet Core link rejected: {error}', file=sys.stderr)
        raise SystemExit(1)
