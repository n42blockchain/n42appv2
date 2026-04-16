import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/avatar_decoration_preset.dart';

void main() {
  group('AvatarDecorationPresetX', () {
    test('round-trips storage keys', () {
      for (final preset in AvatarDecorationPreset.values) {
        expect(
          AvatarDecorationPresetX.fromStorageKey(preset.storageKey),
          preset,
        );
      }
    });

    test('falls back to none for unknown values', () {
      expect(
        AvatarDecorationPresetX.fromStorageKey('unknown'),
        AvatarDecorationPreset.none,
      );
    });
  });
}
