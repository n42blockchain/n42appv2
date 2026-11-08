"""Authenticated official release reads with credential-safe redirects."""
from functools import lru_cache
import os
import shutil
import subprocess
from urllib.error import HTTPError
from urllib.parse import urlparse
from urllib.request import HTTPRedirectHandler, Request, build_opener

RELEASE_PATHS = (
    '/repos/simolus3/sqlite3.dart/releases/',
    '/repos/gradle/gradle-distributions/releases/',
    '/repos/d-date/google-mlkit-swiftpm/releases/',
)


def credential_target(url):
    parsed = urlparse(url)
    return (parsed.scheme == 'https' and parsed.hostname == 'api.github.com'
            and parsed.port in (None, 443) and parsed.username is None
            and any(parsed.path.startswith(prefix) for prefix in RELEASE_PATHS))


def remove_authorization(request):
    for key, _ in list(request.header_items()):
        if key.lower() == 'authorization':
            request.remove_header(key)


class ReleaseRedirectHandler(HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, msg, headers, newurl):
        if urlparse(newurl).scheme != 'https':
            raise HTTPError(newurl, 403, 'Insecure release redirect refused', headers, None)
        redirected = super().redirect_request(request, fp, code, msg, headers, newurl)
        if redirected is not None and not credential_target(newurl):
            remove_authorization(redirected)
        return redirected


@lru_cache(maxsize=1)
def local_github_token():
    # CI must receive its scoped token explicitly, never read a runner's account.
    if os.environ.get('GITHUB_ACTIONS') == 'true':
        return None
    gh = shutil.which('gh')
    if gh is None:
        return None
    try:
        result = subprocess.run([gh, 'auth', 'token', '--hostname', 'github.com'],
                                capture_output=True, text=True, timeout=5, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def urlopen(request, *, timeout=30):
    if isinstance(request, str):
        request = Request(request)
    if request.get_method() != 'GET':
        raise ValueError('Release transport only supports GET')
    # Clone rather than add credentials to a caller-owned request object.
    prepared = Request(request.full_url, headers=dict(request.header_items()), method='GET')
    remove_authorization(prepared)
    if credential_target(prepared.full_url):
        token = (os.environ.get('GH_TOKEN') or os.environ.get('GITHUB_TOKEN')
                 or local_github_token())
        if token:
            if len(token) > 8192 or any(c.isspace() for c in token):
                raise ValueError('Invalid GitHub credential value')
            prepared.add_header('Authorization', 'Bearer ' + token)
    return build_opener(ReleaseRedirectHandler()).open(prepared, timeout=timeout)
