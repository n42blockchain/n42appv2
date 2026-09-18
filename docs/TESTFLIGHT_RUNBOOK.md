# TestFlight release runbook

This is an executable handoff for the next operator or coding model, including
Sol. Use the existing macOS desktop session, Xcode account and signing keys.
Never print passwords, private keys, `.env` contents or encoded Dart defines.

For WebRTC / ML Kit dependency failures on another Mac, first follow
[iOS dependency troubleshooting](IOS_DEPENDENCY_TROUBLESHOOTING.md).

## Preconditions and release identity

Run from the repository root on the release Mac:

```sh
pwd
git status --short
git rev-parse HEAD
rg '^version:' pubspec.yaml
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
security find-identity -v -p codesigning
```

Record the source commit and `version: name+build`. The app is `ai.n42.www`, its
extension is `ai.n42.www.NotificationExtension`, and the team is `CFRXH38L48`.
Do not upload old artifacts left under `build/`. Check their embedded versions.
Do not rebuild an already uploaded build number. The pre-commit hook advances
the development build number, including documentation-only commits.

## Desktop keychain access: test before compiling

A visible certificate from `security find-identity` does not prove private-key
access. This Mac's background execution session can return
`errSecInternalComponent` even while the desktop session can sign successfully.
Do not repeatedly ask the user to unlock the keychain before trying Terminal.

Create a disposable signing probe, then execute it in desktop Terminal:

```sh
rm -f /tmp/n42-sign-probe.exit /tmp/n42-sign-probe.log
cp /usr/bin/true /tmp/n42-sign-probe
osascript <<'APPLESCRIPT'
tell application "Terminal"
  do script "codesign --force --sign 'iPhone Distribution: SI46WORLD DIGITAL TECHNOLOGY INC. (CFRXH38L48)' /tmp/n42-sign-probe > /tmp/n42-sign-probe.log 2>&1; echo $? > /tmp/n42-sign-probe.exit"
end tell
APPLESCRIPT
```

Wait for the exit file and check it is `0`. If desktop signing also fails, open
Keychain Access and have the user unlock the login keychain or approve the
private-key prompt locally. Do not ask for their macOS password in chat.

## Build in desktop Terminal

Use a new log directory for every attempt so stale exit files cannot look like
success. The following generates a command file without copying credentials:

```sh
python3 - <<'PY'
from pathlib import Path
import shlex, tempfile
root = Path.cwd()
run = Path(tempfile.mkdtemp(prefix='n42-testflight-'))
q = shlex.quote
script = '''#!/bin/zsh
umask 077
export PATH="/opt/homebrew/bin:/opt/homebrew/share/flutter/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
'''
script += f'cd {q(str(root))} || exit 1\n'
script += f'bash scripts/prepare_ios_release.sh > {q(str(run / "build.log"))} 2>&1\n'
script += f'printf "%s\\n" "$?" > {q(str(run / "build.exit"))}\n'
(run / 'build.command').write_text(script)
print(run)
PY
```

Copy the printed absolute directory into the command below:

```sh
osascript -e 'tell application "Terminal" to do script "zsh /tmp/REPLACE_WITH_RUN_DIRECTORY/build.command"'
```

Poll `build.exit` and the tail of `build.log`, providing progress updates. The
canonical builder preserves `pubspec.yaml`, loads local `.env` when present,
archives, corrects the known `objective_c.framework` platform/minimum-OS issue
when necessary, and exports `build/ios/ipa/N42Wallet.ipa`. Always use the same
private release configuration for rebuilds. Never use `-v` with private defines
in a log intended for publication.

## Validate the actual IPA before upload

Require build exit `0`. Read the IPA's main and extension `Info.plist` using
Python `zipfile` and `plistlib`: both must match the intended short version and
build. This check reads the expected version from the source and verifies both
bundles and the signature:

```sh
python3 - <<'PY'
import hashlib, plistlib, re, subprocess, tempfile, zipfile
from pathlib import Path
version, build = re.search(r'^version:\s*(\S+)\+(\d+)',
    Path('pubspec.yaml').read_text(), re.M).groups()
ipa = Path('build/ios/ipa/N42Wallet.ipa')
bundles = {
    'Payload/Runner.app': 'ai.n42.www',
    'Payload/Runner.app/PlugIns/N42Extension.appex':
        'ai.n42.www.NotificationExtension',
}
with tempfile.TemporaryDirectory(prefix='n42-ipa-check-') as folder:
    with zipfile.ZipFile(ipa) as archive:
        for bundle, identifier in bundles.items():
            info = plistlib.loads(archive.read(bundle + '/Info.plist'))
            assert info['CFBundleIdentifier'] == identifier
            assert info['CFBundleShortVersionString'] == version
            assert info['CFBundleVersion'] == build
            print(identifier, version, build)
        archive.extractall(folder)
    app = Path(folder) / 'Payload/Runner.app'
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)],
                   check=True)
    for bundle in bundles:
        subprocess.run(['codesign', '-d', '--entitlements', ':-',
                        str(Path(folder) / bundle)], check=True)
with ipa.open('rb') as handle:
    print('SHA-256:', hashlib.file_digest(handle, 'sha256').hexdigest())
print('Bytes:', ipa.stat().st_size)
PY
```

For additional inspection, extract into a temporary directory and run:

```sh
codesign --verify --deep --strict /tmp/EXTRACTED/Payload/Runner.app
codesign -d --entitlements :- /tmp/EXTRACTED/Payload/Runner.app
codesign -d --entitlements :- /tmp/EXTRACTED/Payload/Runner.app/PlugIns/N42Extension.appex
shasum -a 256 build/ios/ipa/N42Wallet.ipa
bash scripts/check_ios_version.sh build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
```

Check distribution signing, team and application identifiers, production APNs,
required app/keychain groups, and that `get-task-allow` is false or absent. Do
not repair entitlements by dropping capabilities. Compare with the project's
entitlements and embedded distribution provisioning profiles. The notification
extension currently has an empty source entitlement dictionary; do not require
the main app's app/keychain groups on that extension.

## Upload the verified archive through Xcode

Create a local upload plist from the maintained export settings:

```sh
python3 - <<'PY'
import plistlib
from pathlib import Path
p = plistlib.loads(Path('ios/ExportOptions-AppStore.plist').read_bytes())
p['destination'] = 'upload'
p['manageAppVersionAndBuildNumber'] = False
Path('/tmp/n42-testflight-upload.plist').write_bytes(plistlib.dumps(p))
PY
```

Run the following in desktop Terminal, with fresh log/exit paths. The existing
Xcode account supplies authentication; an API key is not required for this
verified workflow:

```sh
cd /Users/jieliu/Documents/n42/n42appv2
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist /tmp/n42-testflight-upload.plist \
  -exportPath build/ios/testflight-upload \
  -allowProvisioningUpdates > /tmp/UNIQUE-upload.log 2>&1
printf '%s\n' "$?" > /tmp/UNIQUE-upload.exit
```

Do not rebuild or replace the archive between IPA validation and upload.
Require upload exit `0` plus `Upload succeeded` / `Uploaded Runner` and
`EXPORT SUCCEEDED`. Missing dSYMs can be non-blocking warnings; distinguish
those from an actual upload failure. Upload acceptance does not prove Apple
processing is complete or the build is available to testers. Report those
states separately and verify in App Store Connect when access is available.

## Failures and evidence

- `errSecInternalComponent` in the background but desktop probe succeeds: run
  the builder and exporter through desktop Terminal.
- Version already used (`-19232`): inspect the last accepted build; advance the
  canonical version and rebuild, including the extension. Never relabel an IPA.
- Archive error: inspect the actual failing target and nearby log lines. A
  summary such as `CodeSign failed` is insufficient. If a second build phase
  also fails, investigate it independently after signing is restored.
- Xcode account/session or agreement error: open Xcode/App Store Connect and
  report the exact required user action; do not fabricate upload success.
- Existing IPA after a failed build: treat it as stale until verified.

After upload, write a dated release record with source commit, dependency ref,
version, SHA-256, size, signature/version checks, upload completion evidence,
and any remaining processing or device-validation gap. Commit only sanitized
evidence; raw verbose build and distribution logs stay local. Use an English
commit subject and the configured human author. Push the record and explain
that its commit hook may advance the next development version.

Android companion build: `bash build_release.sh apk` produces a signed APK;
`bash scripts/prepare_android_release.sh` produces both AAB and APK. Verify the
embedded version and signature with Android SDK `aapt`/`apksigner`, and record
the checksum. Building Android does not establish device acceptance.
