"""Bounded retries for transient release-asset transport failures only."""
from http.client import IncompleteRead
import time
from urllib.error import HTTPError, URLError


def retry_download(operation, *, sleep=None):
    sleep = time.sleep if sleep is None else sleep
    for attempt in range(3):
        try:
            return operation()
        except HTTPError as error:
            if error.code not in (429, 500, 502, 503, 504) or attempt == 2:
                raise
            if error.fp is not None:
                error.close()
        except (URLError, TimeoutError, ConnectionError, IncompleteRead):
            if attempt == 2:
                raise
        sleep(2 ** (attempt + 1))
