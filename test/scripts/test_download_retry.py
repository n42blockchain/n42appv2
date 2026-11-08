import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock
from urllib.error import HTTPError, URLError

spec = importlib.util.spec_from_file_location('retry', Path('scripts/download_retry.py'))
retry = importlib.util.module_from_spec(spec)
spec.loader.exec_module(retry)


class DownloadRetryTest(unittest.TestCase):
    def test_transient_errors_recover_with_bounded_backoff(self):
        for code in (429, 500, 502, 503, 504):
            with self.subTest(code=code):
                operation = Mock(side_effect=[HTTPError('https://test', code, 'transient', {}, None), b'verified transport bytes'])
                sleep = Mock()
                self.assertEqual(retry.retry_download(operation, sleep=sleep), b'verified transport bytes')
                sleep.assert_called_once_with(2)

    def test_persistent_errors_stop_after_three_attempts(self):
        operation = Mock(side_effect=URLError('offline'))
        sleep = Mock()
        with self.assertRaises(URLError):
            retry.retry_download(operation, sleep=sleep)
        self.assertEqual(operation.call_count, 3)
        self.assertEqual([call.args[0] for call in sleep.call_args_list], [2, 4])

    def test_permanent_http_errors_are_not_retried(self):
        for code in (400, 401, 403, 404):
            operation = Mock(side_effect=HTTPError('https://test', code, 'permanent', {}, None))
            sleep = Mock()
            with self.assertRaises(HTTPError):
                retry.retry_download(operation, sleep=sleep)
            self.assertEqual(operation.call_count, 1)
            sleep.assert_not_called()

    def test_checksum_and_validation_errors_are_not_retried(self):
        operation = Mock(side_effect=ValueError('checksum mismatch'))
        sleep = Mock()
        with self.assertRaises(ValueError):
            retry.retry_download(operation, sleep=sleep)
        self.assertEqual(operation.call_count, 1)
        sleep.assert_not_called()

    def test_network_timeout_can_recover(self):
        operation = Mock(side_effect=[TimeoutError(), b'ok'])
        self.assertEqual(retry.retry_download(operation, sleep=Mock()), b'ok')


if __name__ == '__main__':
    unittest.main()
