#!/usr/bin/env python3
"""Create non-production Firebase resources only on GitHub-hosted CI runners."""
import argparse
import json
import os
from pathlib import Path
import plistlib


def prepare(root: Path) -> None:
    if (os.environ.get('GITHUB_ACTIONS') != 'true' or
            os.environ.get('RUNNER_ENVIRONMENT') != 'github-hosted'):
        raise RuntimeError('Synthetic Firebase configuration requires hosted CI')
    project = 'n42-ci-not-a-service'
    number = '123456789012'
    api_key = 'AIza' + '0' * 35  # Deliberately not a credential.
    files = {
        root / 'ios/Runner/GoogleService-Info.plist': plistlib.dumps({
            'PLIST_VERSION': '1', 'BUNDLE_ID': 'ai.n42.www',
            'GOOGLE_APP_ID': f'1:{number}:ios:0000000000000000',
            'GCM_SENDER_ID': number, 'PROJECT_ID': project, 'API_KEY': api_key,
            'IS_ADS_ENABLED': False, 'IS_ANALYTICS_ENABLED': False,
            'IS_APPINVITE_ENABLED': False, 'IS_GCM_ENABLED': False,
            'IS_SIGNIN_ENABLED': False,
        }),
        root / 'android/app/google-services.json': json.dumps({
            'project_info': {'project_number': number, 'project_id': project},
            'client': [{
                'client_info': {
                    'mobilesdk_app_id': f'1:{number}:android:0000000000000000',
                    'android_client_info': {'package_name': 'ai.n42.www'},
                },
                'api_key': [{'current_key': api_key}],
                'oauth_client': [],
                'services': {'appinvite_service': {'other_platform_oauth_client': []}},
            }],
            'configuration_version': '1',
        }, indent=2).encode(),
    }
    if any(path.exists() or path.is_symlink() for path in files):
        raise FileExistsError('Refusing to replace existing Firebase configuration')
    created = []
    try:
        for path, content in files.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            with path.open('xb') as output:
                created.append(path)
                output.write(content)
    except Exception:
        for path in created:
            path.unlink(missing_ok=True)
        raise


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    prepare(parser.parse_args().root)
    print('Prepared synthetic CI Firebase resources; no service credentials configured')
