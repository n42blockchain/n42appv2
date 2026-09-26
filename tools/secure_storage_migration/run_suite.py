#!/usr/bin/env python3
"""Repeat native acceptance on emulator-5554, using only the dedicated fixture app."""
import argparse
import json
import subprocess
import time
import run_fixture as fixture

FAILURES = 'com.it_nomads.fluttersecurestorage.MigrationFailureTest#'
events = []


def stage(name, cipher, method=None, fault=None):
    fixture.stage(name, cipher, FAILURES + method if method else None, fault)
    events.append(dict(case=fixture.LOG_PREFIX, cipher=cipher, stage=name, result='PASS'))
    (fixture.ROOT / 'logs/native-results.json').write_text(json.dumps(events, indent=2) + '\n')


def seed(case, version, cipher):
    fixture.LOG_PREFIX = case + '-'
    fixture.install(version)
    stage('seed', cipher)
    fixture.install('maintained')


def interrupt():
    adb = [str(fixture.ADB), '-s', 'emulator-5554']
    subprocess.run([*adb, 'shell', 'run-as', fixture.APP_ID, 'rm', '-f', 'files/interrupt-ready'], check=True)
    path = fixture.ROOT / 'logs/kill-during-import.log'
    with path.open('w') as output:
        process = subprocess.Popen([*adb, 'shell', 'am', 'instrument', '-w', '-e', 'class',
            FAILURES + 'fault', '-e', 'fault', 'interrupt',
            fixture.APP_ID + '.test/androidx.test.runner.AndroidJUnitRunner'], stdout=output, stderr=subprocess.STDOUT)
        ready = False
        for _ in range(100):
            check = subprocess.run([*adb, 'shell', 'run-as', fixture.APP_ID, 'ls', 'files/interrupt-ready'],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if check.returncode == 0:
                ready = True
                break
            if process.poll() is not None:
                break
            time.sleep(0.1)
        if not ready:
            process.terminate()
            raise RuntimeError('Did not reach the durable partial-import interruption point')
        subprocess.run([*adb, 'shell', 'am', 'force-stop', fixture.APP_ID], check=True)
        process.wait(timeout=10)
    events.append(dict(case='interrupt', result='EXPECTED_PROCESS_TERMINATION',
                       application_id=fixture.APP_ID, signal='durable destination written; no callback/completion'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--skip-build', action='store_true')
    args = parser.parse_args()
    if not args.skip_build:
        for version in ('9.2.4', '10.3.4', 'maintained'):
            fixture.build(version)
    for cipher, version in [('esp', '9.2.4'), ('cbc', '9.2.4'), ('gcm', '10.3.4')]:
        seed('upgrade-' + cipher, version, cipher)
        # Race actual engines while the destination is still incomplete.
        stage('engines', cipher, 'twoEnginesAndDetachKeepQueueAlive')
        stage('verify-initial', cipher)
        stage('verify-restart', cipher)
        stage('crud', cipher)
        stage('queue', cipher, 'queueWaitsForTerminalCallbackExactlyOnce')
        stage('delete', cipher)
        stage('verifyDeleted', cipher)
        seed('missing-' + cipher, version, cipher)
        stage('missingLegacyKey', cipher)
    seed('corruption', '9.2.4', 'esp')
    stage('corruptRetry', 'esp')
    seed('verification', '9.2.4', 'esp')
    stage('verificationRetry', 'esp', 'fault', 'verification')
    stage('verify-after-retry', 'esp')
    stage('completedKeyMissing', 'esp', 'fault', 'completedKeyMissing')
    seed('interrupt', '9.2.4', 'esp')
    interrupt()
    stage('verify-after-interruption', 'esp')
    stage('verify-after-interruption-restart', 'esp')
    fixture.LOG_PREFIX = 'fresh-'
    stage('fresh', 'esp')
    print(f'{sum(e["result"] == "PASS" for e in events)} native stage invocations passed; '
          'one deliberate process termination recovered')
