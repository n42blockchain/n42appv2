import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/services/voip/voip_config.dart';
import 'package:n42_chat/src/services/voip/livekit_service.dart';

void main() {
  group('VoIPConfig', () {
    late VoIPConfig config;

    setUp(() {
      config = VoIPConfig();
      config.reset(); // 重置单例状态
    });

    test('should be a singleton', () {
      final config1 = VoIPConfig();
      final config2 = VoIPConfig();
      expect(identical(config1, config2), isTrue);
    });

    test('should have default values', () {
      expect(config.turnUris, isEmpty);
      expect(config.turnUsername, isNull);
      expect(config.turnPassword, isNull);
      expect(config.liveKitUrl, isNull);
      expect(config.defaultVideoEnabled, isTrue);
      expect(config.defaultAudioEnabled, isTrue);
      expect(config.callTimeout, equals(60));
    });

    test('should update from TURN response', () {
      config.updateFromTurnResponse({
        'uris': ['turn:turn.example.com:3478'],
        'username': 'user123',
        'password': 'pass456',
        'ttl': 3600000,
      });

      expect(config.turnUris, contains('turn:turn.example.com:3478'));
      expect(config.turnUsername, equals('user123'));
      expect(config.turnPassword, equals('pass456'));
      expect(config.turnTtl, equals(3600000));
    });

    test('should configure LiveKit', () {
      config.configureLiveKit(
        url: 'wss://livekit.example.com',
        apiKey: 'key123',
        apiSecret: 'secret456',
      );

      expect(config.liveKitUrl, equals('wss://livekit.example.com'));
      expect(config.liveKitApiKey, equals('key123'));
      expect(config.liveKitApiSecret, equals('secret456'));
    });

    test('hasTurnConfig should return correct value', () {
      expect(config.hasTurnConfig, isFalse);

      config.turnUris = ['turn:turn.example.com:3478'];
      expect(config.hasTurnConfig, isTrue);
    });

    test('hasLiveKitConfig should return correct value', () {
      expect(config.hasLiveKitConfig, isFalse);

      config.liveKitUrl = 'wss://livekit.example.com';
      expect(config.hasLiveKitConfig, isTrue);
    });

    test('getIceServers should include public STUN servers', () {
      final servers = config.getIceServers();
      
      // 应该至少包含公共 STUN 服务器
      expect(servers, isNotEmpty);
      expect(
        servers.any((s) => s['urls'].toString().contains('google.com')),
        isTrue,
      );
    });

    test('getIceServers should include TURN when configured', () {
      config.turnUris = ['turn:turn.example.com:3478'];
      config.turnUsername = 'user';
      config.turnPassword = 'pass';

      final servers = config.getIceServers();
      
      expect(
        servers.any((s) => s['urls'] == 'turn:turn.example.com:3478'),
        isTrue,
      );
    });

    test('reset should clear all configuration', () {
      config.turnUris = ['turn:turn.example.com:3478'];
      config.turnUsername = 'user';
      config.liveKitUrl = 'wss://livekit.example.com';

      config.reset();

      expect(config.turnUris, isEmpty);
      expect(config.turnUsername, isNull);
      expect(config.liveKitUrl, isNull);
    });
  });

  group('VideoResolution', () {
    test('sd360 should have correct dimensions', () {
      expect(VideoResolution.sd360.width, equals(640));
      expect(VideoResolution.sd360.height, equals(360));
    });

    test('hd720 should have correct dimensions', () {
      expect(VideoResolution.hd720.width, equals(1280));
      expect(VideoResolution.hd720.height, equals(720));
    });

    test('hd1080 should have correct dimensions', () {
      expect(VideoResolution.hd1080.width, equals(1920));
      expect(VideoResolution.hd1080.height, equals(1080));
    });

    test('toConstraints should return valid map', () {
      final constraints = VideoResolution.hd720.toConstraints();

      expect(constraints['width'], isA<Map>());
      expect(constraints['height'], isA<Map>());
      expect(constraints['width']['ideal'], equals(1280));
      expect(constraints['height']['ideal'], equals(720));
    });
  });

  group('LiveKitService', () {
    late LiveKitService liveKitService;

    setUp(() {
      liveKitService = LiveKitService();
    });

    tearDown(() {
      liveKitService.dispose();
    });

    test('initial state should be idle', () {
      expect(liveKitService.state, equals(MeetingState.idle));
      expect(liveKitService.isInMeeting, isFalse);
      expect(liveKitService.participants, isEmpty);
    });

    test('should not be muted by default', () {
      expect(liveKitService.isMuted, isFalse);
      expect(liveKitService.isVideoEnabled, isTrue);
      expect(liveKitService.isScreenSharing, isFalse);
    });

    test('currentMeeting should be null when not in meeting', () {
      expect(liveKitService.currentMeeting, isNull);
    });

    test('joinMeeting should fail without LiveKit URL configured', () async {
      final result = await liveKitService.joinMeeting(
        roomName: 'test-room',
        token: 'test-token',
        participantName: 'Test User',
      );

      expect(result, isFalse);
      expect(liveKitService.state, equals(MeetingState.idle));
    });

    test('leaveMeeting should be safe when not in meeting', () async {
      // Should not throw
      await liveKitService.leaveMeeting();
      expect(liveKitService.state, equals(MeetingState.idle));
    });

    test('toggleMicrophone should be safe when not in meeting', () async {
      // Should not throw
      await liveKitService.toggleMicrophone();
    });

    test('toggleCamera should be safe when not in meeting', () async {
      // Should not throw
      await liveKitService.toggleCamera();
    });

    test('duration should be zero when not in meeting', () {
      expect(liveKitService.duration, equals(Duration.zero));
    });
  });

  group('MeetingParticipant', () {
    test('should create with required fields', () {
      final participant = MeetingParticipant(
        id: 'user-123',
        name: 'Test User',
      );

      expect(participant.id, equals('user-123'));
      expect(participant.name, equals('Test User'));
      expect(participant.isLocal, isFalse);
      expect(participant.isMuted, isFalse);
      expect(participant.isVideoEnabled, isTrue);
    });

    test('copyWith should create new instance with updated fields', () {
      final participant = MeetingParticipant(
        id: 'user-123',
        name: 'Test User',
      );

      final updated = participant.copyWith(
        isMuted: true,
        isVideoEnabled: false,
      );

      expect(updated.id, equals('user-123'));
      expect(updated.name, equals('Test User'));
      expect(updated.isMuted, isTrue);
      expect(updated.isVideoEnabled, isFalse);
    });

    test('copyWith should preserve unchanged fields', () {
      final participant = MeetingParticipant(
        id: 'user-123',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.png',
        isLocal: true,
      );

      final updated = participant.copyWith(isMuted: true);

      expect(updated.avatarUrl, equals('https://example.com/avatar.png'));
      expect(updated.isLocal, isTrue);
    });
  });

  group('MeetingInfo', () {
    test('should create with required fields', () {
      final now = DateTime.now();
      final info = MeetingInfo(
        roomId: 'room-123',
        roomName: 'Test Room',
        startTime: now,
      );

      expect(info.roomId, equals('room-123'));
      expect(info.roomName, equals('Test Room'));
      expect(info.startTime, equals(now));
      expect(info.maxParticipants, equals(50));
      expect(info.isRecording, isFalse);
    });

    test('should create with optional fields', () {
      final now = DateTime.now();
      final info = MeetingInfo(
        roomId: 'room-123',
        roomName: 'Test Room',
        startTime: now,
        maxParticipants: 100,
        isRecording: true,
      );

      expect(info.maxParticipants, equals(100));
      expect(info.isRecording, isTrue);
    });
  });
}
