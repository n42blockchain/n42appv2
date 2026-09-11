import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('localization_audit', ROOT / 'scripts/audit_localizations.py')
audit = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = audit
spec.loader.exec_module(audit)


class LocalizationAuditTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.base = self.root / 'intl_en.arb'
        self.target = self.root / 'intl_ar.arb'
        self.audit_spec = audit.AuditSpec('fixture', self.base, 'intl_*.arb')

    def write(self, base, target):
        self.base.write_text(json.dumps(base))
        self.target.write_text(json.dumps(target))

    def test_chat_audit_resolves_the_installed_dependency(self):
        config = self.root / '.dart_tool' / 'package_config.json'
        config.parent.mkdir()
        config.write_text(json.dumps({'packages': [{'name': 'n42_chat', 'rootUri': '../cache/chat%20package/'}]}))
        self.assertEqual(audit.resolved_chat_base(self.root), self.root.resolve() / 'cache/chat package/lib/l10n/app_en.arb')

    def test_chat_audit_resolves_a_git_checkout_file_uri(self):
        config = self.root / '.dart_tool' / 'package_config.json'
        config.parent.mkdir()
        checkout = self.root / 'git checkout'
        config.write_text(json.dumps({'packages': [{'name': 'n42_chat', 'rootUri': checkout.as_uri()}]}))
        self.assertEqual(audit.resolved_chat_base(self.root), checkout / 'lib/l10n/app_en.arb')

    def test_complete_translation_preserves_reordered_parameters(self):
        self.write({'request': '{amount} {symbol}'}, {'request': '{symbol}: {amount}'})
        report = audit.audit_spec(self.audit_spec)
        self.assertFalse(any(report.values()))

    def test_missing_extra_and_empty_messages_are_reported_separately(self):
        self.write({'missing': 'Missing', 'empty': 'Value'}, {'extra': 'زائد', 'empty': '  '})
        report = audit.audit_spec(self.audit_spec)
        self.assertIn('missing', report['missing']['ar'])
        self.assertIn('extra', report['extra']['ar'])
        self.assertIn('empty', report['empty']['ar'])

    def test_translated_or_dropped_placeholder_fails(self):
        self.write({'bad': 'Balance {value}', 'lost': '{amount} tokens'},
                   {'bad': 'الرصيد {القيمة}', 'lost': 'رموز'})
        self.assertEqual(set(audit.audit_spec(self.audit_spec)['placeholders']['ar']), {'bad', 'lost'})

    def test_duplicate_key_is_not_silently_overwritten(self):
        self.base.write_text('{"wallet":"Wallet","wallet":"Chat"}')
        self.target.write_text('{}')
        with self.assertRaisesRegex(ValueError, 'Duplicate localization key'):
            audit.audit_spec(self.audit_spec)

    def test_icu_selector_name_is_checked(self):
        self.assertEqual(audit.placeholder_names('{count, plural, one{One} other{{count} items}}'), {'count'})
        self.assertEqual(audit.placeholder_names('{gender, select, other{User}}'), {'gender'})


if __name__ == '__main__':
    unittest.main()
