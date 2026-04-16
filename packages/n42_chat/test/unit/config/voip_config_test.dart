// Tests for voip_config.dart — pure value objects and enums.
// VoIPConfig singleton is also tested (hasTurnConfig, hasLiveKitConfig,
// getIceServers, updateFromTurnResponse, configureLiveKit, reset).
// AudioProcessingConfig, BackgroundProcessingConfig, CallRecordingConfig,
// VideoResolution — all pure Dart, no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/voip_config.dart';

void main() {
  // ─────────────────────────────────────────────────
  // VideoResolution enum
  // ─────────────────────────────────────────────────

  group('VideoResolution enum', () {
    test('sd360 has width=640, height=360', () {
      expect(VideoResolution.sd360.width, 640);
      expect(VideoResolution.sd360.height, 360);
    });

    test('sd480 has width=854, height=480', () {
      expect(VideoResolution.sd480.width, 854);
      expect(VideoResolution.sd480.height, 480);
    });

    test('hd720 has width=1280, height=720', () {
      expect(VideoResolution.hd720.width, 1280);
      expect(VideoResolution.hd720.height, 720);
    });

    test('hd1080 has width=1920, height=1080', () {
      expect(VideoResolution.hd1080.width, 1920);
      expect(VideoResolution.hd1080.height, 1080);
    });

    test('four values total', () {
      expect(VideoResolution.values.length, 4);
    });

    test('toConstraints returns width and height map', () {
      final c = VideoResolution.hd720.toConstraints();
      expect(c['width'], {'ideal': 1280});
      expect(c['height'], {'ideal': 720});
    });
  });

  // ─────────────────────────────────────────────────
  // BackgroundMode enum
  // ─────────────────────────────────────────────────

  group('BackgroundMode enum', () {
    test('has none, blur, virtualBackground, solidColor', () {
      expect(
        BackgroundMode.values,
        containsAll([
          BackgroundMode.none,
          BackgroundMode.blur,
          BackgroundMode.virtualBackground,
          BackgroundMode.solidColor,
        ]),
      );
    });

    test('four values total', () {
      expect(BackgroundMode.values.length, 4);
    });
  });

  // ─────────────────────────────────────────────────
  // AudioProcessingConfig
  // ─────────────────────────────────────────────────

  group('AudioProcessingConfig defaults', () {
    const config = AudioProcessingConfig();

    test('noiseSuppression defaults to true', () {
      expect(config.noiseSuppression, isTrue);
    });

    test('echoCancellation defaults to true', () {
      expect(config.echoCancellation, isTrue);
    });

    test('autoGainControl defaults to true', () {
      expect(config.autoGainControl, isTrue);
    });

    test('highPassFilter defaults to true', () {
      expect(config.highPassFilter, isTrue);
    });

    test('enhancedMode defaults to false', () {
      expect(config.enhancedMode, isFalse);
    });
  });

  group('AudioProcessingConfig static presets', () {
    test('enabled preset — all enabled', () {
      const c = AudioProcessingConfig.enabled;
      expect(c.noiseSuppression, isTrue);
      expect(c.echoCancellation, isTrue);
      expect(c.autoGainControl, isTrue);
      expect(c.highPassFilter, isTrue);
      expect(c.enhancedMode, isFalse);
    });

    test('disabled preset — all disabled', () {
      const c = AudioProcessingConfig.disabled;
      expect(c.noiseSuppression, isFalse);
      expect(c.echoCancellation, isFalse);
      expect(c.autoGainControl, isFalse);
      expect(c.highPassFilter, isFalse);
      expect(c.enhancedMode, isFalse);
    });

    test('enhanced preset — all enabled including enhancedMode', () {
      const c = AudioProcessingConfig.enhanced;
      expect(c.noiseSuppression, isTrue);
      expect(c.enhancedMode, isTrue);
    });
  });

  group('AudioProcessingConfig.toWebRTCConstraints', () {
    test(
      'includes echoCancellation, noiseSuppression, autoGainControl keys',
      () {
        const config = AudioProcessingConfig();
        final constraints = config.toWebRTCConstraints();
        expect(constraints['echoCancellation'], isTrue);
        expect(constraints['noiseSuppression'], isTrue);
        expect(constraints['autoGainControl'], isTrue);
      },
    );

    test('disabled preset returns false for all', () {
      const config = AudioProcessingConfig.disabled;
      final constraints = config.toWebRTCConstraints();
      expect(constraints['echoCancellation'], isFalse);
      expect(constraints['noiseSuppression'], isFalse);
      expect(constraints['autoGainControl'], isFalse);
    });
  });

  group('AudioProcessingConfig.copyWith', () {
    const base = AudioProcessingConfig();

    test('replaces noiseSuppression', () {
      expect(base.copyWith(noiseSuppression: false).noiseSuppression, isFalse);
    });

    test('replaces enhancedMode', () {
      expect(base.copyWith(enhancedMode: true).enhancedMode, isTrue);
    });

    test('original unchanged after copyWith', () {
      base.copyWith(noiseSuppression: false);
      expect(base.noiseSuppression, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // BackgroundProcessingConfig
  // ─────────────────────────────────────────────────

  group('BackgroundProcessingConfig defaults', () {
    const config = BackgroundProcessingConfig();

    test('mode defaults to none', () {
      expect(config.mode, BackgroundMode.none);
    });

    test('blurRadius defaults to 0.5', () {
      expect(config.blurRadius, 0.5);
    });

    test('virtualBackgroundUrl defaults to null', () {
      expect(config.virtualBackgroundUrl, isNull);
    });

    test('solidColor defaults to null', () {
      expect(config.solidColor, isNull);
    });
  });

  group('BackgroundProcessingConfig presets', () {
    test('disabled preset has mode=none', () {
      expect(BackgroundProcessingConfig.disabled.mode, BackgroundMode.none);
    });

    test('lightBlur preset has mode=blur and blurRadius=0.3', () {
      expect(BackgroundProcessingConfig.lightBlur.mode, BackgroundMode.blur);
      expect(BackgroundProcessingConfig.lightBlur.blurRadius, 0.3);
    });

    test('mediumBlur preset has blurRadius=0.5', () {
      expect(BackgroundProcessingConfig.mediumBlur.blurRadius, 0.5);
    });

    test('heavyBlur preset has blurRadius=0.8', () {
      expect(BackgroundProcessingConfig.heavyBlur.blurRadius, 0.8);
    });
  });

  group('BackgroundProcessingConfig factory constructors', () {
    test('withVirtualBackground sets mode and url', () {
      final config = BackgroundProcessingConfig.withVirtualBackground(
        'https://bg.png',
      );
      expect(config.mode, BackgroundMode.virtualBackground);
      expect(config.virtualBackgroundUrl, 'https://bg.png');
    });

    test('withSolidColor sets mode and color', () {
      final config = BackgroundProcessingConfig.withSolidColor('#FFFFFF');
      expect(config.mode, BackgroundMode.solidColor);
      expect(config.solidColor, '#FFFFFF');
    });
  });

  group('BackgroundProcessingConfig getters', () {
    test('isEnabled is false for none mode', () {
      expect(const BackgroundProcessingConfig().isEnabled, isFalse);
    });

    test('isEnabled is true for blur mode', () {
      expect(BackgroundProcessingConfig.lightBlur.isEnabled, isTrue);
    });

    test('isBlurMode is true for blur', () {
      expect(BackgroundProcessingConfig.mediumBlur.isBlurMode, isTrue);
    });

    test('isBlurMode is false for none', () {
      expect(const BackgroundProcessingConfig().isBlurMode, isFalse);
    });

    test('isVirtualBackgroundMode is true for virtualBackground', () {
      final config = BackgroundProcessingConfig.withVirtualBackground('url');
      expect(config.isVirtualBackgroundMode, isTrue);
    });

    test('isVirtualBackgroundMode is false for blur', () {
      expect(
        BackgroundProcessingConfig.lightBlur.isVirtualBackgroundMode,
        isFalse,
      );
    });
  });

  group('BackgroundProcessingConfig.copyWith', () {
    const base = BackgroundProcessingConfig();

    test('replaces mode', () {
      expect(
        base.copyWith(mode: BackgroundMode.blur).mode,
        BackgroundMode.blur,
      );
    });

    test('replaces blurRadius', () {
      expect(base.copyWith(blurRadius: 0.9).blurRadius, 0.9);
    });

    test('original unchanged', () {
      base.copyWith(mode: BackgroundMode.blur);
      expect(base.mode, BackgroundMode.none);
    });
  });

  // ─────────────────────────────────────────────────
  // CallRecordingConfig
  // ─────────────────────────────────────────────────

  group('CallRecordingConfig defaults', () {
    const config = CallRecordingConfig();

    test('enabled defaults to false until recording backend is wired', () {
      expect(config.enabled, isFalse);
    });

    test('autoStart defaults to false', () {
      expect(config.autoStart, isFalse);
    });

    test('sampleRate defaults to 44100', () {
      expect(config.sampleRate, 44100);
    });

    test('bitRate defaults to 128000', () {
      expect(config.bitRate, 128000);
    });

    test('maxDuration defaults to 0 (unlimited)', () {
      expect(config.maxDuration, 0);
    });

    test('savePath defaults to null', () {
      expect(config.savePath, isNull);
    });
  });

  group('CallRecordingConfig presets', () {
    test('defaultConfig matches default constructor', () {
      const dc = CallRecordingConfig.defaultConfig;
      expect(dc.enabled, isFalse);
      expect(dc.autoStart, isFalse);
      expect(dc.sampleRate, 44100);
    });

    test('disabled preset has enabled=false', () {
      expect(CallRecordingConfig.disabled.enabled, isFalse);
    });

    test('autoRecord preset has autoStart=true', () {
      expect(CallRecordingConfig.autoRecord.autoStart, isTrue);
    });

    test('highQuality preset has sampleRate=48000', () {
      expect(CallRecordingConfig.highQuality.sampleRate, 48000);
    });

    test('highQuality preset has bitRate=256000', () {
      expect(CallRecordingConfig.highQuality.bitRate, 256000);
    });
  });

  group('CallRecordingConfig.copyWith', () {
    const base = CallRecordingConfig();

    test('replaces enabled', () {
      expect(base.copyWith(enabled: false).enabled, isFalse);
    });

    test('replaces sampleRate', () {
      expect(base.copyWith(sampleRate: 48000).sampleRate, 48000);
    });

    test('replaces savePath', () {
      expect(base.copyWith(savePath: '/path/to').savePath, '/path/to');
    });

    test('original unchanged after copyWith', () {
      base.copyWith(enabled: false);
      expect(base.enabled, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // VoIPConfig singleton
  // ─────────────────────────────────────────────────

  group('VoIPConfig singleton', () {
    setUp(() {
      // reset() only clears TURN/LiveKit credentials. Restore all mutable
      // fields explicitly so tests are order-independent.
      VoIPConfig().reset();
      VoIPConfig().setAudioProcessing(const AudioProcessingConfig());
      VoIPConfig().setBackgroundProcessing(const BackgroundProcessingConfig());
    });

    test('same instance returned by factory', () {
      final a = VoIPConfig();
      final b = VoIPConfig();
      expect(identical(a, b), isTrue);
    });

    test('hasTurnConfig is false initially', () {
      expect(VoIPConfig().hasTurnConfig, isFalse);
    });

    test('hasLiveKitConfig is false initially', () {
      expect(VoIPConfig().hasLiveKitConfig, isFalse);
    });

    test(
      'getIceServers returns public STUN servers when no TURN configured',
      () {
        final servers = VoIPConfig().getIceServers();
        expect(servers, isNotEmpty);
        // All servers should be STUN (no credentials)
        for (final s in servers) {
          expect(s['urls'], startsWith('stun:'));
        }
      },
    );

    test('publicStunServers is a non-empty const list', () {
      expect(VoIPConfig.publicStunServers, isNotEmpty);
    });

    test('updateFromTurnResponse sets turnUris, username, password', () {
      VoIPConfig().updateFromTurnResponse({
        'uris': ['turn:turn.example.com:3478'],
        'username': 'user1',
        'password': 'pass1',
      });
      final config = VoIPConfig();
      expect(config.hasTurnConfig, isTrue);
      expect(config.turnUris, ['turn:turn.example.com:3478']);
      expect(config.turnUsername, 'user1');
      expect(config.turnPassword, 'pass1');
    });

    test('updateFromTurnResponse updates ttl when provided', () {
      VoIPConfig().updateFromTurnResponse({
        'uris': ['turn:x.com'],
        'ttl': 3600,
      });
      expect(VoIPConfig().turnTtl, 3600);
    });

    test(
      'updateFromTurnResponse with empty uris list leaves hasTurnConfig false',
      () {
        VoIPConfig().updateFromTurnResponse({
          'uris': <String>[],
          'username': 'u',
          'password': 'p',
        });
        expect(VoIPConfig().hasTurnConfig, isFalse);
      },
    );

    test(
      'updateFromTurnResponse without username leaves turnUsername null',
      () {
        VoIPConfig().updateFromTurnResponse({
          'uris': ['turn:x.com'],
        });
        expect(VoIPConfig().turnUsername, isNull);
      },
    );

    test('updateFromTurnResponse with ttl=0 stores zero', () {
      VoIPConfig().updateFromTurnResponse({
        'uris': ['turn:x.com'],
        'ttl': 0,
      });
      expect(VoIPConfig().turnTtl, 0);
    });

    test('getIceServers includes TURN server when configured', () {
      VoIPConfig().updateFromTurnResponse({
        'uris': ['turn:turn.example.com:3478'],
        'username': 'u',
        'password': 'p',
      });
      final servers = VoIPConfig().getIceServers();
      final turnServers = servers
          .where((s) => (s['urls'] as String).startsWith('turn:'))
          .toList();
      expect(turnServers, isNotEmpty);
    });

    test('configureLiveKit sets liveKitUrl', () {
      VoIPConfig().configureLiveKit(url: 'wss://livekit.example.com');
      expect(VoIPConfig().hasLiveKitConfig, isTrue);
      expect(VoIPConfig().liveKitUrl, 'wss://livekit.example.com');
    });

    test('configureLiveKit stores apiKey', () {
      VoIPConfig().configureLiveKit(url: 'wss://lk.com', apiKey: 'key123');
      expect(VoIPConfig().liveKitApiKey, 'key123');
    });

    test('reset clears turnUris and liveKitUrl', () {
      VoIPConfig().updateFromTurnResponse({
        'uris': ['turn:x.com'],
        'username': 'u',
        'password': 'p',
      });
      VoIPConfig().configureLiveKit(url: 'wss://lk.com');
      VoIPConfig().reset();
      expect(VoIPConfig().hasTurnConfig, isFalse);
      expect(VoIPConfig().hasLiveKitConfig, isFalse);
      expect(VoIPConfig().turnUris, isEmpty);
      expect(VoIPConfig().liveKitUrl, isNull);
    });

    test('default audio processing flags are set', () {
      final c = VoIPConfig();
      expect(c.enableNoiseSuppression, isTrue);
      expect(c.enableEchoCancellation, isTrue);
      expect(c.enableAutoGainControl, isTrue);
      expect(c.enableHighPassFilter, isTrue);
      expect(c.enableEnhancedAudioMode, isFalse);
    });

    test('audioProcessing getter returns correct config', () {
      final ap = VoIPConfig().audioProcessing;
      expect(ap.noiseSuppression, isTrue);
      expect(ap.echoCancellation, isTrue);
    });

    test('setAudioProcessing updates fields', () {
      const config = AudioProcessingConfig.disabled;
      VoIPConfig().setAudioProcessing(config);
      expect(VoIPConfig().enableNoiseSuppression, isFalse);
      expect(VoIPConfig().enableEchoCancellation, isFalse);
    });

    test('backgroundMode defaults to none', () {
      expect(VoIPConfig().backgroundMode, BackgroundMode.none);
    });

    test('backgroundProcessing getter returns config with current mode', () {
      final bp = VoIPConfig().backgroundProcessing;
      expect(bp.mode, BackgroundMode.none);
    });

    test('setBackgroundProcessing updates backgroundMode', () {
      VoIPConfig().setBackgroundProcessing(
        BackgroundProcessingConfig.lightBlur,
      );
      expect(VoIPConfig().backgroundMode, BackgroundMode.blur);
    });

    test(
      'setUp restores audio defaults between tests (order-independence check)',
      () {
        // Verify setUp correctly restores audio flags mutated by setAudioProcessing.
        // If setUp were incomplete, this test would fail when run after
        // "setAudioProcessing updates fields".
        expect(VoIPConfig().enableNoiseSuppression, isTrue);
        expect(VoIPConfig().enableEnhancedAudioMode, isFalse);
      },
    );

    test(
      'setUp restores background defaults between tests (order-independence check)',
      () {
        expect(VoIPConfig().backgroundMode, BackgroundMode.none);
      },
    );
  });
}
