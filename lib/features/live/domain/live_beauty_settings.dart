import 'package:shared_preferences/shared_preferences.dart';

enum LiveFilterPreset { none, natural, warm, cool, vivid, mono }

extension LiveFilterPresetLabel on LiveFilterPreset {
  String get label => switch (this) {
    LiveFilterPreset.none => '原图',
    LiveFilterPreset.natural => '自然',
    LiveFilterPreset.warm => '暖阳',
    LiveFilterPreset.cool => '清冷',
    LiveFilterPreset.vivid => '鲜明',
    LiveFilterPreset.mono => '黑白',
  };
}

class LiveBeautySettings {
  const LiveBeautySettings({
    this.smooth = 0.35,
    this.brightness = 0.18,
    this.rosy = 0.12,
    this.filter = LiveFilterPreset.natural,
    this.filterStrength = 0.22,
  });

  const LiveBeautySettings.off()
    : smooth = 0,
      brightness = 0,
      rosy = 0,
      filter = LiveFilterPreset.none,
      filterStrength = 0;

  final double smooth;
  final double brightness;
  final double rosy;
  final LiveFilterPreset filter;
  final double filterStrength;

  bool get isEnabled =>
      smooth > 0 ||
      brightness > 0 ||
      rosy > 0 ||
      (filter != LiveFilterPreset.none && filterStrength > 0);

  LiveBeautySettings copyWith({
    double? smooth,
    double? brightness,
    double? rosy,
    LiveFilterPreset? filter,
    double? filterStrength,
  }) => LiveBeautySettings(
    smooth: (smooth ?? this.smooth).clamp(0.0, 1.0),
    brightness: (brightness ?? this.brightness).clamp(0.0, 1.0),
    rosy: (rosy ?? this.rosy).clamp(0.0, 1.0),
    filter: filter ?? this.filter,
    filterStrength: (filterStrength ?? this.filterStrength).clamp(0.0, 1.0),
  );
}

class LiveBeautySettingsStore {
  static const _prefix = 'n42.live.beauty.';

  Future<LiveBeautySettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final filterName = prefs.getString('${_prefix}filter');
    return LiveBeautySettings(
      smooth: prefs.getDouble('${_prefix}smooth') ?? 0.35,
      brightness: prefs.getDouble('${_prefix}brightness') ?? 0.18,
      rosy: prefs.getDouble('${_prefix}rosy') ?? 0.12,
      filter: LiveFilterPreset.values.firstWhere(
        (value) => value.name == filterName,
        orElse: () => LiveFilterPreset.natural,
      ),
      filterStrength: prefs.getDouble('${_prefix}filterStrength') ?? 0.22,
    );
  }

  Future<void> save(LiveBeautySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble('${_prefix}smooth', settings.smooth),
      prefs.setDouble('${_prefix}brightness', settings.brightness),
      prefs.setDouble('${_prefix}rosy', settings.rosy),
      prefs.setString('${_prefix}filter', settings.filter.name),
      prefs.setDouble('${_prefix}filterStrength', settings.filterStrength),
    ]);
  }
}
