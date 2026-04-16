enum AvatarDecorationPreset { none, aurora, arcade, blossom, cosmic }

extension AvatarDecorationPresetX on AvatarDecorationPreset {
  String get storageKey => switch (this) {
    AvatarDecorationPreset.none => 'none',
    AvatarDecorationPreset.aurora => 'aurora',
    AvatarDecorationPreset.arcade => 'arcade',
    AvatarDecorationPreset.blossom => 'blossom',
    AvatarDecorationPreset.cosmic => 'cosmic',
  };

  String get displayName => switch (this) {
    AvatarDecorationPreset.none => 'Default',
    AvatarDecorationPreset.aurora => 'Aurora Glow',
    AvatarDecorationPreset.arcade => 'Arcade Pulse',
    AvatarDecorationPreset.blossom => 'Blossom Ring',
    AvatarDecorationPreset.cosmic => 'Cosmic Orbit',
  };

  static AvatarDecorationPreset fromStorageKey(String? raw) {
    for (final preset in AvatarDecorationPreset.values) {
      if (preset.storageKey == raw) {
        return preset;
      }
    }
    return AvatarDecorationPreset.none;
  }
}
