import importlib.util
import io
import os
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch
from urllib.error import HTTPError
from urllib.request import Request

spec = importlib.util.spec_from_file_location('release_http_test', Path('scripts/release_http.py'))
http = importlib.util.module_from_spec(spec)
spec.loader.exec_module(http)
API = 'https://api.github.com/repos/simolus3/sqlite3.dart/releases/tags/sqlite3-3.9.0'


class ReleaseHttpTest(unittest.TestCase):
    def setUp(self):
        http.local_github_token.cache_clear()
        self.addCleanup(http.local_github_token.cache_clear)

    def test_scoped_environment_token_only_goes_to_approved_api(self):
        opener = Mock()
        original = Request(API, headers={'Accept': 'application/json'})
        with patch.dict(os.environ, {'GH_TOKEN': 'test-token'}, clear=True), patch.object(http, 'build_opener', return_value=opener):
            http.urlopen(original, timeout=17)
        prepared = opener.open.call_args.args[0]
        self.assertEqual(prepared.get_header('Authorization'), 'Bearer test-token')
        self.assertIsNone(original.get_header('Authorization'))
        self.assertEqual(opener.open.call_args.kwargs['timeout'], 17)

    def test_unapproved_hosts_and_repos_never_receive_or_lookup_credentials(self):
        for url in ['https://example.com/file', 'https://api.github.com/repos/other/project/releases/1',
                    'http://api.github.com/repos/simolus3/sqlite3.dart/releases/1',
                    'https://api.github.com:444/repos/simolus3/sqlite3.dart/releases/1']:
            with patch.dict(os.environ, {'GH_TOKEN': 'test-token'}, clear=True), patch.object(http, 'local_github_token') as token, patch.object(http, 'build_opener') as build:
                http.urlopen(Request(url, headers={'Authorization': 'caller-token'}))
                self.assertIsNone(build.return_value.open.call_args.args[0].get_header('Authorization'))
                token.assert_not_called()

    def test_cdn_redirect_removes_authorization_but_preserves_accept(self):
        request = Request(API, headers={'Authorization': 'Bearer test-token', 'Accept': 'application/octet-stream'})
        redirected = http.ReleaseRedirectHandler().redirect_request(request, None, 302, 'redirect', {}, 'https://release-assets.githubusercontent.com/file')
        self.assertIsNone(redirected.get_header('Authorization'))
        self.assertEqual(redirected.get_header('Accept'), 'application/octet-stream')

    def test_same_approved_api_redirect_can_keep_credential(self):
        request = Request(API, headers={'Authorization': 'Bearer test-token'})
        redirected = http.ReleaseRedirectHandler().redirect_request(request, None, 302, 'redirect', {}, 'https://api.github.com/repos/simolus3/sqlite3.dart/releases/assets/1')
        self.assertEqual(redirected.get_header('Authorization'), 'Bearer test-token')

    def test_https_downgrade_redirect_is_rejected(self):
        with self.assertRaises(HTTPError):
            http.ReleaseRedirectHandler().redirect_request(Request(API), None, 302, 'redirect', {}, 'http://example.com/file')

    def test_local_login_is_used_in_memory_without_exporting_token(self):
        with patch.dict(os.environ, {}, clear=True), patch.object(http.shutil, 'which', return_value='/usr/bin/gh'), patch.object(http.subprocess, 'run', return_value=SimpleNamespace(returncode=0, stdout='test-local-token\n')) as run, patch.object(http, 'build_opener') as build:
            http.urlopen(API)
            self.assertEqual(build.return_value.open.call_args.args[0].get_header('Authorization'), 'Bearer test-local-token')
            self.assertNotIn('GH_TOKEN', os.environ)
            self.assertEqual(run.call_args.args[0], ['/usr/bin/gh', 'auth', 'token', '--hostname', 'github.com'])

    def test_ci_never_looks_up_a_runners_saved_login(self):
        with patch.dict(os.environ, {'GITHUB_ACTIONS': 'true'}, clear=True), patch.object(http.shutil, 'which') as which, patch.object(http, 'build_opener') as build:
            http.urlopen(API)
            which.assert_not_called()
            self.assertIsNone(build.return_value.open.call_args.args[0].get_header('Authorization'))

    def test_invalid_header_value_is_rejected_without_opening_connection(self):
        with patch.dict(os.environ, {'GH_TOKEN': 'bad\ntoken'}, clear=True), patch.object(http, 'build_opener') as build:
            with self.assertRaisesRegex(ValueError, '^Invalid GitHub credential value$'):
                http.urlopen(API)
            build.assert_not_called()

    def test_non_get_methods_are_rejected(self):
        with self.assertRaises(ValueError):
            http.urlopen(Request(API, data=b'body', method='POST'))


if __name__ == '__main__':
    unittest.main()
