from pathlib import Path
import struct
import sys
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from audit_android_native import aligned_elf, audit


def elf(alignment=16384, address=0, relro_end=None):
    count = 2 if relro_end is not None else 1
    data = bytearray(64 + 56 * count)
    data[:6] = b'\x7fELF\x02\x01'
    struct.pack_into('<Q', data, 32, 64)
    struct.pack_into('<HH', data, 54, 56, count)
    struct.pack_into('<I', data, 64, 1)
    struct.pack_into('<Q', data, 64 + 16, address)
    struct.pack_into('<Q', data, 64 + 48, alignment)
    if relro_end is not None:
        struct.pack_into('<I', data, 120, 0x6474e552)
        struct.pack_into('<Q', data, 120 + 16, relro_end - 1)
        struct.pack_into('<Q', data, 120 + 40, 1)
    return data


class AndroidNativeAuditTest(unittest.TestCase):
    def test_4kb_load_segment_is_rejected(self):
        self.assertFalse(aligned_elf(elf(4096)))

    def test_larger_aligned_segments_pass(self):
        for alignment in [16384, 65536]:
            self.assertTrue(aligned_elf(elf(alignment)))

    def test_incongruent_virtual_address_is_rejected(self):
        self.assertFalse(aligned_elf(elf(address=4096)))

    def test_misaligned_gnu_relro_end_is_rejected(self):
        self.assertFalse(aligned_elf(elf(relro_end=4096)))

    def test_aligned_gnu_relro_end_passes(self):
        self.assertTrue(aligned_elf(elf(relro_end=16384)))

    def test_truncated_and_non_elf_data_fail(self):
        for content in [b'not elf', elf()[:90]]:
            with self.assertRaises(ValueError):
                aligned_elf(content)

    def test_aab_reports_the_bad_library_and_does_not_ignore_it(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'app.aab'
            with zipfile.ZipFile(path, 'w') as archive:
                archive.writestr('base/lib/arm64-v8a/good.so', elf())
                archive.writestr('base/lib/x86_64/bad.so', elf(4096))
            result = audit(path)
            self.assertFalse(result['passed'])
            self.assertEqual(result['libraries_checked'], 2)
            self.assertEqual(result['unaligned_libraries'], ['base/lib/x86_64/bad.so'])

    def test_empty_artifact_cannot_pass(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'empty.aab'
            with zipfile.ZipFile(path, 'w'):
                pass
            with self.assertRaises(ValueError):
                audit(path)
