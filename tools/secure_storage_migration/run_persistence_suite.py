#!/usr/bin/env python3
"""Fresh-process disk-corruption acceptance on the dedicated emulator fixture only."""
import json
import subprocess
import run_fixture as fixture

TEST = 'com.it_nomads.fluttersecurestorage.MigrationPersistenceTest#'
ADB = [str(fixture.ADB), '-s', 'emulator-5554']
APP = fixture.APP_ID
events = []


def stage(name, method='strictDiskStage', fault='deny', cipher='esp'):
    subprocess.run([*ADB, 'shell', 'am', 'force-stop', APP], check=True)
    fixture.stage(name, cipher, TEST + method, fault)
    events.append(dict(case=fixture.LOG_PREFIX, stage=name, result='PASS'))
    (fixture.ROOT / 'logs/persistence-results.json').write_text(json.dumps(events, indent=2) + '\n')


def read(name):
    return subprocess.check_output([*ADB, 'exec-out', 'run-as', APP, 'cat', 'shared_prefs/' + name])


def write(name, value):
    subprocess.run([*ADB, 'exec-in', 'run-as', APP, 'tee', 'shared_prefs/' + name],
                   input=value, stdout=subprocess.DEVNULL, check=True)


def remove(name):
    subprocess.run([*ADB, 'shell', 'run-as', APP, 'rm', 'shared_prefs/' + name], check=True)


def seed(name, version='9.2.4', cipher='esp'):
    fixture.LOG_PREFIX = 'review-' + name + '-'
    fixture.install(version)
    fixture.stage('seed', cipher)
    fixture.install('maintained')


def damage_case(label, filename, completed=False, deleted=False, cipher='esp'):
    seed(label, '10.3.4' if cipher == 'gcm' else '9.2.4', cipher)
    if completed:
        fixture.stage('verify-before-damage', cipher)
    if deleted:
        fixture.stage('delete', cipher)
    original = read(filename)
    for kind, bad in [('malformed', b'<?xml version="1.0"?><map><string name="broken">'),
                      ('truncated', original[:max(1, len(original) // 2)])]:
        subprocess.run([*ADB, 'shell', 'am', 'force-stop', APP], check=True)
        write(filename, bad)
        stage(kind, cipher=cipher)
        assert read(filename) == bad, 'corrupted bytes changed'
        # Repair only before the next migration call, always in a fresh process.
        write(filename, original)
        stage(kind + '-repair', fault='deleted' if deleted else 'credential', cipher=cipher)
        if not completed:
            # Repair succeeded: the next corruption should still test pre-import state.
            seed(label + '-second', '10.3.4' if cipher == 'gcm' else '9.2.4', cipher)
            original = read(filename)


if __name__ == '__main__':
    seed('completion')
    stage('failed-completion', 'failedCompletionCannotAuthorizeOtherEngines', '')
    stage('failed-completion-restart', fault='deleted')
    damage_case('source', 'n42_secure_prefs.xml')
    damage_case('source-config', 'FlutterSecureStorageConfiguration:n42_secure_prefs.xml', cipher='gcm')
    damage_case('source-wrapped', 'FlutterSecureKeyStorage.xml', cipher='gcm')
    damage_case('journal', 'n42_secure_v11_migration.xml', completed=True, deleted=True)
    damage_case('destination-data', 'n42_secure_v11_wallet.xml', completed=True)
    damage_case('destination-config', 'FlutterSecureStorageConfiguration:n42_secure_v11_wallet.xml', completed=True)
    damage_case('destination-wrapped', 'FlutterSecureKeyStorage:n42_secure_v11_wallet.xml', completed=True)
    seed('source-backup')
    original = read('n42_secure_prefs.xml')
    write('n42_secure_prefs.xml.bak', original)
    write('n42_secure_prefs.xml', b'<map>truncated')
    stage('backup-denied')
    assert read('n42_secure_prefs.xml.bak') == original
    assert read('n42_secure_prefs.xml') == b'<map>truncated'
    remove('n42_secure_prefs.xml.bak')
    write('n42_secure_prefs.xml', original)
    stage('backup-repair', fault='credential')
    seed('missing-journal')
    fixture.stage('verify-before-damage', 'esp')
    fixture.stage('delete', 'esp')
    original = read('n42_secure_v11_migration.xml')
    remove('n42_secure_v11_migration.xml')
    stage('missing-journal-denied')
    write('n42_secure_v11_migration.xml', original)
    stage('missing-journal-repair', fault='deleted')
    # Android's normal SharedPreferences loader would rename/delete these .bak files.
    for label, filename in [('journal-backup', 'n42_secure_v11_migration.xml'),
                            ('destination-backup', 'n42_secure_v11_wallet.xml')]:
        seed(label)
        fixture.stage('verify-before-damage', 'esp')
        fixture.stage('delete', 'esp')
        original = read(filename)
        write(filename + '.bak', original)
        stage('backup-denied')
        assert read(filename + '.bak') == original and read(filename) == original
        remove(filename + '.bak')
        stage('backup-repair', fault='deleted')
    for label, filename, completed in [('source-unreadable', 'n42_secure_prefs.xml', False),
                                      ('journal-unreadable', 'n42_secure_v11_migration.xml', True)]:
        seed(label)
        if completed:
            fixture.stage('verify-before-damage', 'esp')
            fixture.stage('delete', 'esp')
        original = read(filename)
        subprocess.run([*ADB, 'shell', 'run-as', APP, 'chmod', '000', 'shared_prefs/' + filename], check=True)
        try:
            stage('unreadable-denied')
        finally:
            subprocess.run([*ADB, 'shell', 'run-as', APP, 'chmod', '600', 'shared_prefs/' + filename], check=True)
        assert read(filename) == original, 'unreadable preference bytes changed'
        stage('unreadable-repair', fault='deleted' if completed else 'credential')
    print(f'{len(events)} persistence/corruption stages passed')
