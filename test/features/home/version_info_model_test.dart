// Tests for VersionInfoModel (home module version update model).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/models/version_info_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('VersionInfoModel construction', () {
    test('all fields default to null', () {
      final model = VersionInfoModel();
      expect(model.versionName, isNull);
      expect(model.versionCode, isNull);
      expect(model.updateTitle, isNull);
      expect(model.updateContent, isNull);
      expect(model.isForce, isNull);
    });

    test('accepts all fields via named parameters', () {
      final model = VersionInfoModel(
        versionName: '2.5.0',
        versionCode: 250,
        updateTitle: 'What\'s new',
        updateContent: 'Bug fixes',
        isForce: true,
      );
      expect(model.versionName, '2.5.0');
      expect(model.versionCode, 250);
      expect(model.updateTitle, 'What\'s new');
      expect(model.updateContent, 'Bug fixes');
      expect(model.isForce, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('VersionInfoModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = VersionInfoModel.fromJson({
        'versionName': '3.0.0',
        'versionCode': 300,
        'updateTitle': 'Major update',
        'updateContent': 'New UI and performance improvements',
        'isForce': true,
      });
      expect(model.versionName, '3.0.0');
      expect(model.versionCode, 300);
      expect(model.updateTitle, 'Major update');
      expect(model.updateContent, 'New UI and performance improvements');
      expect(model.isForce, isTrue);
    });

    test('isForce=false is parsed correctly', () {
      final model = VersionInfoModel.fromJson({
        'versionName': '1.0.1',
        'versionCode': 101,
        'isForce': false,
      });
      expect(model.isForce, isFalse);
    });

    test('all fields are null when keys are absent', () {
      final model = VersionInfoModel.fromJson({});
      expect(model.versionName, isNull);
      expect(model.versionCode, isNull);
      expect(model.updateTitle, isNull);
      expect(model.updateContent, isNull);
      expect(model.isForce, isNull);
    });

    test('mixed null and non-null fields', () {
      final model = VersionInfoModel.fromJson({
        'versionName': '2.0.0',
        // versionCode absent
        'isForce': false,
      });
      expect(model.versionName, '2.0.0');
      expect(model.versionCode, isNull);
      expect(model.isForce, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────

  group('VersionInfoModel.toJson', () {
    test('includes all keys', () {
      final model = VersionInfoModel(
        versionName: '1.2.3',
        versionCode: 123,
        updateTitle: 'Update',
        updateContent: 'Content',
        isForce: false,
      );
      final json = model.toJson();
      expect(
        json.keys,
        containsAll([
          'versionName',
          'versionCode',
          'updateTitle',
          'updateContent',
          'isForce',
        ]),
      );
    });

    test('values match the model fields', () {
      final model = VersionInfoModel(
        versionName: '1.0.0',
        versionCode: 100,
        updateTitle: 'Title',
        updateContent: 'Body',
        isForce: true,
      );
      final json = model.toJson();
      expect(json['versionName'], '1.0.0');
      expect(json['versionCode'], 100);
      expect(json['updateTitle'], 'Title');
      expect(json['updateContent'], 'Body');
      expect(json['isForce'], isTrue);
    });

    test('null fields are preserved in map', () {
      final model = VersionInfoModel(versionName: '1.0.0');
      final json = model.toJson();
      expect(json['versionName'], '1.0.0');
      expect(json['versionCode'], isNull);
      expect(json['isForce'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('VersionInfoModel fromJson/toJson roundtrip', () {
    test('full roundtrip preserves all values', () {
      final original = VersionInfoModel(
        versionName: '2.1.0',
        versionCode: 210,
        updateTitle: 'Release notes',
        updateContent: 'Stability improvements',
        isForce: true,
      );
      final restored = VersionInfoModel.fromJson(original.toJson());
      expect(restored.versionName, original.versionName);
      expect(restored.versionCode, original.versionCode);
      expect(restored.updateTitle, original.updateTitle);
      expect(restored.updateContent, original.updateContent);
      expect(restored.isForce, original.isForce);
    });
  });
}
