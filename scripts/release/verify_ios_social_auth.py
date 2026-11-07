#!/usr/bin/env python3
"""Verify native login resources in an IPA without emitting their values."""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path
import zipfile


def sha256(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def verify(ipa, google_plist, native_config):
    report = {'passed': False, 'checks': []}

    def check(name, passed):
        report['checks'].append({'name': name, 'passed': bool(passed)})
        if not passed:
            raise ValueError(name)

    try:
        report.update(ipaSha256=sha256(ipa), googlePlistSha256=sha256(google_plist),
                      nativeConfigSha256=sha256(native_config))
        config = {}
        for line in Path(native_config).read_text().splitlines():
            line = line.strip()
            if not line or line.startswith('//') or '=' not in line:
                continue
            key, value = line.split('=', 1)
            config[key.strip()] = value.strip().strip('"')
        required = ['N42_CHAT_GOOGLE_CLIENT_ID', 'N42_CHAT_GOOGLE_SERVER_CLIENT_ID',
                    'N42_CHAT_GOOGLE_REVERSED_CLIENT_ID', 'N42_CHAT_FACEBOOK_APP_ID',
                    'N42_CHAT_FACEBOOK_CLIENT_TOKEN', 'N42_CHAT_FACEBOOK_URL_SCHEME']
        check('resolved_native_configuration', all(
            config.get(key) and '$(' not in config[key] and '${' not in config[key]
            for key in required))
        with zipfile.ZipFile(ipa) as archive:
            names = [n for n in archive.namelist() if n.startswith('Payload/')
                     and n.count('/') == 2 and n.endswith('.app/Info.plist')]
            check('one_main_app', len(names) == 1)
            info = plistlib.loads(archive.read(names[0]))
            prefix = names[0].rsplit('/', 1)[0]
            google_name = prefix + '/GoogleService-Info.plist'
            check('one_google_resource', archive.namelist().count(google_name) == 1)
            actual = plistlib.loads(archive.read(google_name))
            check('bundled_google_configuration', actual == plistlib.loads(Path(google_plist).read_bytes()))
            check('bundle_identity', actual.get('BUNDLE_ID') == info.get('CFBundleIdentifier') == 'ai.n42.www')
            for field, key in [
                ('FacebookAppID', 'N42_CHAT_FACEBOOK_APP_ID'),
                ('FacebookClientToken', 'N42_CHAT_FACEBOOK_CLIENT_TOKEN'),
                ('N42ChatGoogleClientID', 'N42_CHAT_GOOGLE_CLIENT_ID'),
                ('N42ChatGoogleServerClientID', 'N42_CHAT_GOOGLE_SERVER_CLIENT_ID'),
            ]:
                check(field, info.get(field) == config[key])
            schemes = {s for row in info.get('CFBundleURLTypes', [])
                       for s in row.get('CFBundleURLSchemes', [])}
            check('google_callback_scheme', config['N42_CHAT_GOOGLE_REVERSED_CLIENT_ID'] in schemes)
            check('facebook_callback_scheme', config['N42_CHAT_FACEBOOK_URL_SCHEME'] in schemes)
            check('facebook_callback_binding', config['N42_CHAT_FACEBOOK_URL_SCHEME'] == 'fb' + config['N42_CHAT_FACEBOOK_APP_ID'])
            suffix = '.apps.googleusercontent.com'
            client = config['N42_CHAT_GOOGLE_CLIENT_ID']
            check('google_callback_binding', client.endswith(suffix) and config['N42_CHAT_GOOGLE_REVERSED_CLIENT_ID'] == 'com.googleusercontent.apps.' + client[:-len(suffix)])
            check('unconfigured_callback_absent', 'n42-google-unconfigured' not in schemes)
        report['passed'] = True
    except Exception as error:
        # Parsing errors can contain resource values. Report only the class and
        # the named failed check, never exception text or native configuration.
        report['errorType'] = type(error).__name__
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ipa', required=True)
    parser.add_argument('--google-plist', required=True)
    parser.add_argument('--native-config', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    report = verify(args.ipa, args.google_plist, args.native_config)
    Path(args.output).write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'passed': report['passed'], 'checks': len(report['checks'])}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
