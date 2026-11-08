#!/usr/bin/env python3
"""Record login build switches without exporting provider credentials."""
import argparse
import base64
import hashlib
import json
from pathlib import Path


def inspect_settings(path):
    raw = Path(path).read_bytes()
    lines = raw.decode().splitlines()
    encoded = [line.partition('=')[2] for line in lines
               if line.startswith('DART_DEFINES=')]
    if len(encoded) != 1:
        raise ValueError('Expected exactly one DART_DEFINES setting')
    values = {}
    for item in encoded[0].split(','):
        if not item:
            continue
        decoded = base64.b64decode(item, validate=True).decode()
        key, separator, value = decoded.partition('=')
        if not separator or key in values:
            raise ValueError('Malformed or duplicate Dart define')
        values[key] = value
    return {
        'schema': 1,
        'scope': 'Generated compiler inputs only; not archived binary or provider acceptance',
        'settingsSha256': hashlib.sha256(raw).hexdigest(),
        'nativeAuthEndpointConfigured': bool(values.get('N42_NATIVE_AUTH_URL', '').strip()),
        'facebookIosEnabled': values.get('N42_CHAT_FACEBOOK_IOS_ENABLED') == 'true',
        'providerAcceptance': 'not established by this check',
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--settings', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    result = inspect_settings(args.settings)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
