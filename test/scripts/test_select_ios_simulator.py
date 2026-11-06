import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('simulator', ROOT / 'scripts/select_ios_simulator.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def device(number, name='iPhone 17', available=True, state='Shutdown'):
    return {'udid': f'00000000-0000-0000-0000-{number:012d}',
            'name': name, 'isAvailable': available, 'state': state}


def runtime(version):
    return 'com.apple.CoreSimulator.SimRuntime.iOS-' + version


class SimulatorSelectionTest(unittest.TestCase):
    def test_latest_numeric_runtime_without_fixed_model(self):
        selected = module.select_device({'devices': {
            runtime('27-9'): [device(1)],
            runtime('27-10'): [device(2, 'iPhone 18 Pro')],
        }})
        self.assertEqual(selected[0], device(2)['udid'])
        self.assertEqual(selected[1], 'iPhone 18 Pro')

    def test_excludes_unavailable_non_phone_old_runtime_and_invalid_id(self):
        selected = module.select_device({'devices': {
            runtime('15-5'): [device(1)],
            runtime('27-1'): [device(2, available=False), device(3, name='iPad Pro'),
                             {**device(4), 'udid': 'bad\nvalue'}, device(5)],
            'com.apple.CoreSimulator.SimRuntime.tvOS-27-1': [device(6)],
        }})
        self.assertEqual(selected[0], device(5)['udid'])

    def test_prefers_booted_device_within_latest_runtime(self):
        selected = module.select_device({'devices': {
            runtime('27-1'): [device(1, state='Booted'), device(2, 'iPhone 18 Pro')],
        }})
        self.assertEqual(selected[0], device(1)['udid'])

    def test_missing_usable_device_fails(self):
        with self.assertRaisesRegex(ValueError, 'No available iPhone'):
            module.select_device({'devices': {runtime('27-1'): [device(1, available=False)]}})
