#!/usr/bin/env python3
"""Stage bounded SQLCipher 16F.5 evidence without build products or caches."""

from pathlib import Path
import shutil
import subprocess


ROOT = Path(__file__).resolve().parents[3]
W = Path(__file__).resolve().parent
BUILD = W / 'task-16f-sqlcipher-build'
DEST = W / 'task-16f-sqlcipher-evidence'
HEAD = 'a62e6fa7276d007313aada0e7b1bff452aeccce3'
RUNTIME = 'dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055'


def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def git_file(commit, name, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(subprocess.check_output(['git', 'show', f'{commit}:{name}'], cwd=ROOT))


def main():
    if DEST.exists():
        raise RuntimeError(f'archive staging exists: {DEST}')
    DEST.mkdir()
    copy(BUILD / 'sqlcipher-three-apks.tar.zst', DEST / 'artifacts/three-installed-apks.tar.zst')
    copy(BUILD / 'pack_sqlcipher_apks.py', DEST / 'source-proof/pack_sqlcipher_apks.py')
    copy(BUILD / 'combined-apk-pack.json', DEST / 'source-proof/combined-apk-pack.json')
    copy(BUILD / 'candidate4/manifest.json', DEST / 'source-proof/candidate4-manifest.json')
    copy(BUILD / 'candidate4/source.patch', DEST / 'source-proof/candidate4-source.patch')
    copy(BUILD / 'official-maven/sqlcipher-android-4.19.0.aar',
         DEST / 'artifacts/official-sqlcipher-android-4.19.0.aar')
    maintained = ROOT / 'android/native/sqlcipher_android/maven/net/zetetic/sqlcipher-android/4.19.0'
    for source in sorted(maintained.iterdir()):
        if source.is_file():
            copy(source, DEST / 'artifacts/maintained-maven' / source.name)
    for phase in ('seed', 'official', 'candidate'):
        run = BUILD / f'run-{phase}-strict1'
        copy(run / 'receipt.json', DEST / 'runs' / phase / 'receipt.json')
        copy(run / 'flutter-test.log', DEST / 'runs' / phase / 'flutter-test.log')
    for source in sorted(BUILD.glob('*.log')):
        copy(source, DEST / 'logs' / source.name)
    for source in sorted(BUILD.glob('*.json')):
        if source.name != 'combined-apk-pack.json':
            copy(source, DEST / 'checks' / source.name)
    for source in sorted(BUILD.glob('*.err')):
        copy(source, DEST / 'logs' / source.name)
    for source in sorted((BUILD / 'candidate4/logs').glob('*.log')):
        copy(source, DEST / 'logs/candidate4' / source.name)
    for name in ('candidate1', 'candidate2'):
        source = BUILD / name / 'logs/ndk-build-armeabi-v7a.log'
        if source.exists():
            copy(source, DEST / 'logs' / name / source.name)
    for name in ('task-16f-sqlcipher-source-report.md',
                 'task-16f-sqlcipher-stage2-report.md',
                 'task-16f-sqlcipher-stage3-report.md',
                 'task-16f-sqlcipher-stage3-fix1-report.md'):
        copy(W / name, DEST / 'reports' / name)
    for source in sorted(W.glob('task-16f-sqlcipher-*review.md')):
        copy(source, DEST / 'reviews' / source.name)
    historical = [
        'tools/android_native_smoke/harness/integration_test/sqlcipher_migration_test.dart',
        'tools/android_native_smoke/harness/android/build.gradle.kts',
        'tools/android_native_smoke/harness/android/app/build.gradle.kts',
        'tools/android_native_smoke/harness/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt',
        'tools/android_native_smoke/harness/pubspec.yaml',
        'tools/android_native_smoke/harness/pubspec.lock',
    ]
    for name in historical:
        git_file(RUNTIME, name, DEST / 'source/historical' / name)
    ignored_name = '.superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build/run_sqlcipher_phase.py'
    copy(BUILD / 'run_sqlcipher_phase.py', DEST / 'source/historical' / ignored_name)
    for name in (
        'android/native/sqlcipher_android/README.md',
        'android/build.gradle.kts',
        'packages/sqflite_sqlcipher/android/build.gradle',
        'scripts/build_sqlcipher_android.py',
        'scripts/build_sqlcipher_android_maven.py',
        'test/scripts/test_sqlcipher_android_build.py',
        'test/scripts/test_sqlcipher_android_maven.py',
        'tools/android_native_smoke/run_sqlcipher_fixture.py',
        'tools/android_native_smoke/sqlcipher_fixture_controls.py',
        'tools/android_native_smoke/verify_sqlcipher_fixture.py',
    ):
        git_file(HEAD, name, DEST / 'source/final' / name)
    print(DEST)


if __name__ == '__main__':
    main()
