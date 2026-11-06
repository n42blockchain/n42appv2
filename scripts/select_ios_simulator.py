#!/usr/bin/env python3
"""Select a usable iPhone UDID from `simctl list devices available --json`."""
import json
import re
import sys
import uuid


def select_device(inventory):
    candidates = []
    for runtime, devices in inventory['devices'].items():
        match = re.fullmatch(r'com\.apple\.CoreSimulator\.SimRuntime\.iOS-(\d+(?:-\d+)*)', runtime)
        if not match:
            continue
        version = tuple(int(part) for part in match[1].split('-'))
        if version < (16,):  # Runner's deployment target.
            continue
        for device in devices:
            if device.get('isAvailable') is not True or not device.get('name', '').startswith('iPhone '):
                continue
            try:
                identifier = str(uuid.UUID(device['udid'])).upper()
            except (ValueError, TypeError, KeyError):
                continue
            candidates.append((version, device.get('state') == 'Booted',
                               device['name'], identifier, runtime))
    if not candidates:
        raise ValueError('No available iPhone simulator with iOS 16 or later')
    _, _, name, identifier, runtime = max(candidates)
    return identifier, name, runtime


if __name__ == '__main__':
    try:
        identifier, name, runtime = select_device(json.load(sys.stdin))
    except (ValueError, KeyError, TypeError, AttributeError) as error:
        sys.exit(f'Cannot select iOS simulator: {error}')
    print(f'Selected {name} ({runtime})', file=sys.stderr)
    print(identifier)
