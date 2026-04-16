import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/voip_config.dart';

void main() {
  // ============================================
  // Background Processing Tests
  // ============================================

  group('BackgroundMode', () {
    test('should have all expected modes', () {
      expect(BackgroundMode.values, contains(BackgroundMode.none));
      expect(BackgroundMode.values, contains(BackgroundMode.blur));
      expect(BackgroundMode.values, contains(BackgroundMode.virtualBackground));
      expect(BackgroundMode.values, contains(BackgroundMode.solidColor));
      expect(BackgroundMode.values.length, 4);
    });
  });

  group('BackgroundProcessingConfig', () {
    test('should create with default values', () {
      const config = BackgroundProcessingConfig();

      expect(config.mode, BackgroundMode.none);
      expect(config.blurRadius, 0.5);
      expect(config.virtualBackgroundUrl, null);
      expect(config.solidColor, null);
      expect(config.isEnabled, false);
    });

    test('should create with custom values', () {
      const config = BackgroundProcessingConfig(
        mode: BackgroundMode.blur,
        blurRadius: 0.8,
      );

      expect(config.mode, BackgroundMode.blur);
      expect(config.blurRadius, 0.8);
      expect(config.isEnabled, true);
      expect(config.isBlurMode, true);
    });

    test('static disabled config should have mode none', () {
      const config = BackgroundProcessingConfig.disabled;

      expect(config.mode, BackgroundMode.none);
      expect(config.isEnabled, false);
    });

    test('static lightBlur config should have low blur radius', () {
      const config = BackgroundProcessingConfig.lightBlur;

      expect(config.mode, BackgroundMode.blur);
      expect(config.blurRadius, 0.3);
      expect(config.isBlurMode, true);
    });

    test('static mediumBlur config should have medium blur radius', () {
      const config = BackgroundProcessingConfig.mediumBlur;

      expect(config.mode, BackgroundMode.blur);
      expect(config.blurRadius, 0.5);
    });

    test('static heavyBlur config should have high blur radius', () {
      const config = BackgroundProcessingConfig.heavyBlur;

      expect(config.mode, BackgroundMode.blur);
      expect(config.blurRadius, 0.8);
    });

    test('withVirtualBackground factory should set correct mode', () {
      final config = BackgroundProcessingConfig.withVirtualBackground(
        'https://example.com/bg.jpg',
      );

      expect(config.mode, BackgroundMode.virtualBackground);
      expect(config.virtualBackgroundUrl, 'https://example.com/bg.jpg');
      expect(config.isVirtualBackgroundMode, true);
    });

    test('withSolidColor factory should set correct mode', () {
      final config = BackgroundProcessingConfig.withSolidColor('#FF0000');

      expect(config.mode, BackgroundMode.solidColor);
      expect(config.solidColor, '#FF0000');
    });

    test('copyWith should create new instance with updated values', () {
      const original = BackgroundProcessingConfig(
        mode: BackgroundMode.blur,
        blurRadius: 0.5,
      );

      final modified = original.copyWith(blurRadius: 0.8);

      expect(modified.mode, BackgroundMode.blur);
      expect(modified.blurRadius, 0.8);
      expect(original.blurRadius, 0.5);
    });

    test('toString should return readable string', () {
      const config = BackgroundProcessingConfig(
        mode: BackgroundMode.blur,
        blurRadius: 0.5,
      );
      final str = config.toString();

      expect(str, contains('mode: BackgroundMode.blur'));
      expect(str, contains('blurRadius: 0.5'));
    });
  });

  group('VoIPConfig background processing', () {
    late VoIPConfig config;

    setUp(() {
      config = VoIPConfig();
      // Reset to defaults
      config.backgroundMode = BackgroundMode.none;
      config.backgroundBlurRadius = 0.5;
      config.virtualBackgroundUrl = null;
    });

    test(
      'backgroundProcessing getter should return BackgroundProcessingConfig',
      () {
        final bgConfig = config.backgroundProcessing;

        expect(bgConfig, isA<BackgroundProcessingConfig>());
        expect(bgConfig.mode, config.backgroundMode);
        expect(bgConfig.blurRadius, config.backgroundBlurRadius);
      },
    );

    test('setBackgroundProcessing should update config values', () {
      final newConfig = BackgroundProcessingConfig.withVirtualBackground(
        'https://example.com/bg.jpg',
      );

      config.setBackgroundProcessing(newConfig);

      expect(config.backgroundMode, BackgroundMode.virtualBackground);
      expect(config.virtualBackgroundUrl, 'https://example.com/bg.jpg');
    });

    test('should support blur radius adjustment', () {
      config.backgroundMode = BackgroundMode.blur;
      config.backgroundBlurRadius = 0.3;

      expect(config.backgroundBlurRadius, 0.3);

      config.backgroundBlurRadius = 0.9;
      expect(config.backgroundBlurRadius, 0.9);
    });
  });

  // ============================================
  // Call Recording Config Tests
  // ============================================

  group('CallRecordingConfig', () {
    test('should create with default values', () {
      const config = CallRecordingConfig();

      expect(config.enabled, false);
      expect(config.autoStart, false);
      expect(config.sampleRate, 44100);
      expect(config.bitRate, 128000);
      expect(config.maxDuration, 0);
      expect(config.savePath, null);
    });

    test('should create with custom values', () {
      const config = CallRecordingConfig(
        enabled: true,
        autoStart: true,
        sampleRate: 48000,
        bitRate: 256000,
        maxDuration: 3600,
        savePath: '/custom/path',
      );

      expect(config.enabled, true);
      expect(config.autoStart, true);
      expect(config.sampleRate, 48000);
      expect(config.bitRate, 256000);
      expect(config.maxDuration, 3600);
      expect(config.savePath, '/custom/path');
    });

    test('static defaultConfig should have standard values', () {
      const config = CallRecordingConfig.defaultConfig;

      expect(config.enabled, false);
      expect(config.autoStart, false);
      expect(config.sampleRate, 44100);
    });

    test('static disabled should have enabled=false', () {
      const config = CallRecordingConfig.disabled;

      expect(config.enabled, false);
    });

    test('static autoRecord should have autoStart=true', () {
      const config = CallRecordingConfig.autoRecord;

      expect(config.enabled, true);
      expect(config.autoStart, true);
    });

    test('static highQuality should have higher values', () {
      const config = CallRecordingConfig.highQuality;

      expect(config.enabled, true);
      expect(config.sampleRate, 48000);
      expect(config.bitRate, 256000);
    });

    test('copyWith should create new instance with updated values', () {
      const original = CallRecordingConfig(enabled: true, autoStart: false);

      final modified = original.copyWith(autoStart: true, maxDuration: 1800);

      expect(modified.enabled, true);
      expect(modified.autoStart, true);
      expect(modified.maxDuration, 1800);
      expect(original.autoStart, false);
      expect(original.maxDuration, 0);
    });

    test('toString should return readable string', () {
      const config = CallRecordingConfig();
      final str = config.toString();

      expect(str, contains('enabled: false'));
      expect(str, contains('autoStart: false'));
      expect(str, contains('sampleRate: 44100'));
    });
  });

  group('VoIPConfig call recording', () {
    late VoIPConfig config;

    setUp(() {
      config = VoIPConfig();
      // Reset to defaults
      config.enableCallRecording = true;
      config.autoStartRecording = false;
      config.recordingSampleRate = 44100;
      config.recordingBitRate = 128000;
    });

    test('callRecordingConfig getter should return CallRecordingConfig', () {
      final recordingConfig = config.callRecordingConfig;

      expect(recordingConfig, isA<CallRecordingConfig>());
      expect(recordingConfig.enabled, config.enableCallRecording);
      expect(recordingConfig.autoStart, config.autoStartRecording);
    });

    test('setCallRecordingConfig should update config values', () {
      const newConfig = CallRecordingConfig(
        enabled: true,
        autoStart: true,
        sampleRate: 48000,
        bitRate: 256000,
      );

      config.setCallRecordingConfig(newConfig);

      expect(config.enableCallRecording, true);
      expect(config.autoStartRecording, true);
      expect(config.recordingSampleRate, 48000);
      expect(config.recordingBitRate, 256000);
    });
  });

  // ============================================
  // Audio Processing Tests
  // ============================================
  group('AudioProcessingConfig', () {
    test(
      'should create with default values (all enabled except enhanced mode)',
      () {
        const config = AudioProcessingConfig();

        expect(config.noiseSuppression, true);
        expect(config.echoCancellation, true);
        expect(config.autoGainControl, true);
        expect(config.highPassFilter, true);
        expect(config.enhancedMode, false);
      },
    );

    test('should create with custom values', () {
      const config = AudioProcessingConfig(
        noiseSuppression: false,
        echoCancellation: true,
        autoGainControl: false,
        highPassFilter: true,
        enhancedMode: true,
      );

      expect(config.noiseSuppression, false);
      expect(config.echoCancellation, true);
      expect(config.autoGainControl, false);
      expect(config.highPassFilter, true);
      expect(config.enhancedMode, true);
    });

    test('static enabled config should have all standard features enabled', () {
      const config = AudioProcessingConfig.enabled;

      expect(config.noiseSuppression, true);
      expect(config.echoCancellation, true);
      expect(config.autoGainControl, true);
      expect(config.highPassFilter, true);
      expect(config.enhancedMode, false);
    });

    test('static disabled config should have all features disabled', () {
      const config = AudioProcessingConfig.disabled;

      expect(config.noiseSuppression, false);
      expect(config.echoCancellation, false);
      expect(config.autoGainControl, false);
      expect(config.highPassFilter, false);
      expect(config.enhancedMode, false);
    });

    test('static enhanced config should have enhanced mode enabled', () {
      const config = AudioProcessingConfig.enhanced;

      expect(config.noiseSuppression, true);
      expect(config.echoCancellation, true);
      expect(config.autoGainControl, true);
      expect(config.highPassFilter, true);
      expect(config.enhancedMode, true);
    });

    test('toWebRTCConstraints should return correct map', () {
      const config = AudioProcessingConfig(
        noiseSuppression: true,
        echoCancellation: false,
        autoGainControl: true,
      );

      final constraints = config.toWebRTCConstraints();

      expect(constraints['noiseSuppression'], true);
      expect(constraints['echoCancellation'], false);
      expect(constraints['autoGainControl'], true);
    });

    test('copyWith should create new instance with updated values', () {
      const original = AudioProcessingConfig(
        noiseSuppression: true,
        echoCancellation: true,
        autoGainControl: true,
      );

      final modified = original.copyWith(
        noiseSuppression: false,
        enhancedMode: true,
      );

      // Modified values
      expect(modified.noiseSuppression, false);
      expect(modified.enhancedMode, true);

      // Preserved values
      expect(modified.echoCancellation, true);
      expect(modified.autoGainControl, true);

      // Original unchanged
      expect(original.noiseSuppression, true);
      expect(original.enhancedMode, false);
    });

    test('toString should return readable string', () {
      const config = AudioProcessingConfig();
      final str = config.toString();

      expect(str, contains('NS: true'));
      expect(str, contains('AEC: true'));
      expect(str, contains('AGC: true'));
      expect(str, contains('HPF: true'));
      expect(str, contains('Enhanced: false'));
    });
  });

  group('VoIPConfig audio processing', () {
    late VoIPConfig config;

    setUp(() {
      config = VoIPConfig();
      // Reset to defaults
      config.enableNoiseSuppression = true;
      config.enableEchoCancellation = true;
      config.enableAutoGainControl = true;
      config.enableHighPassFilter = true;
      config.enableEnhancedAudioMode = false;
    });

    test('audioProcessing getter should return AudioProcessingConfig', () {
      final audioConfig = config.audioProcessing;

      expect(audioConfig, isA<AudioProcessingConfig>());
      expect(audioConfig.noiseSuppression, config.enableNoiseSuppression);
      expect(audioConfig.echoCancellation, config.enableEchoCancellation);
      expect(audioConfig.autoGainControl, config.enableAutoGainControl);
      expect(audioConfig.highPassFilter, config.enableHighPassFilter);
      expect(audioConfig.enhancedMode, config.enableEnhancedAudioMode);
    });

    test('setAudioProcessing should update config values', () {
      const newConfig = AudioProcessingConfig(
        noiseSuppression: false,
        echoCancellation: false,
        autoGainControl: true,
        highPassFilter: false,
        enhancedMode: true,
      );

      config.setAudioProcessing(newConfig);

      expect(config.enableNoiseSuppression, false);
      expect(config.enableEchoCancellation, false);
      expect(config.enableAutoGainControl, true);
      expect(config.enableHighPassFilter, false);
      expect(config.enableEnhancedAudioMode, true);
    });

    test('individual toggles should work correctly', () {
      // Default is true
      expect(config.enableNoiseSuppression, true);

      // Toggle off
      config.enableNoiseSuppression = false;
      expect(config.enableNoiseSuppression, false);

      // Toggle on
      config.enableNoiseSuppression = true;
      expect(config.enableNoiseSuppression, true);
    });

    test('audioProcessing should reflect changes to individual settings', () {
      config.enableNoiseSuppression = false;
      config.enableEnhancedAudioMode = true;

      final audioConfig = config.audioProcessing;

      expect(audioConfig.noiseSuppression, false);
      expect(audioConfig.enhancedMode, true);
      // Others unchanged
      expect(audioConfig.echoCancellation, true);
      expect(audioConfig.autoGainControl, true);
    });
  });

  group('VideoResolution', () {
    test('should have correct dimensions for each resolution', () {
      expect(VideoResolution.sd360.width, 640);
      expect(VideoResolution.sd360.height, 360);

      expect(VideoResolution.sd480.width, 854);
      expect(VideoResolution.sd480.height, 480);

      expect(VideoResolution.hd720.width, 1280);
      expect(VideoResolution.hd720.height, 720);

      expect(VideoResolution.hd1080.width, 1920);
      expect(VideoResolution.hd1080.height, 1080);
    });

    test('toConstraints should return correct format', () {
      final constraints = VideoResolution.hd720.toConstraints();

      expect(constraints['width'], {'ideal': 1280});
      expect(constraints['height'], {'ideal': 720});
    });
  });
}
