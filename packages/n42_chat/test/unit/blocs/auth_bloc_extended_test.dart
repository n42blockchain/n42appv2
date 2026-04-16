// Extended AuthBloc tests — covers event handlers not exercised in
// auth_bloc_test.dart:
//   AuthCheckRequested, AuthHomeserverCheckRequested,
//   UpdateAvatar, UpdateDisplayName, UpdateUserProfile, LoadUserProfileData,
//   AuthGetBoundEmailRequested, AuthTokenLoginRequested,
//   AuthLoginTokenLoginRequested, AuthErrorCleared,
//   AuthCheckBiometricAvailability, AuthBiometricLoginRequested,
//   AuthEnableBiometricLogin, AuthDisableBiometricLogin.
//
// BiometricService and SecureStorageDataSource are injected via the
// AuthBloc constructor's optional parameters and mocked with mocktail.

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/biometric_service.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';
import 'package:n42_chat/src/domain/repositories/auth_repository.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_event.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

class MockSecureStorageDataSource extends Mock
    implements SecureStorageDataSource {}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const testUser = UserEntity(
  userId: '@user:server.com',
  displayName: 'Test User',
);

void main() {
  setUpAll(() {
    // mocktail requires fallback values for non-nullable types used with any().
    registerFallbackValue(Uint8List(0));
  });

  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late MockSecureStorageDataSource mockSecureStorage;

  /// Factory — always injects all three mocks so no test depends on the real
  /// BiometricService (which uses platform channels).
  AuthBloc buildBloc() => AuthBloc(
    authRepository: mockAuthRepository,
    biometricService: mockBiometricService,
    secureStorage: mockSecureStorage,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    mockSecureStorage = MockSecureStorageDataSource();

    // Required stubs shared by every test.
    when(
      () => mockAuthRepository.loginStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(
      () => mockAuthRepository.getCurrentUserProfile(),
    ).thenAnswer((_) async => null);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthCheckRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [checking, authenticated] when already logged in',
      build: () {
        when(() => mockAuthRepository.isLoggedIn).thenReturn(true);
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.checking),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [checking, unauthenticated] when not logged in',
      build: () {
        when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.checking),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthHomeserverCheckRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthHomeserverCheckRequested', () {
    const serverInfo = HomeserverInfo(
      serverName: 'server.com',
      serverVersion: '1.9',
      supportedLoginTypes: ['m.login.password'],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [checking, valid] when homeserver is reachable',
      build: () {
        when(
          () => mockAuthRepository.checkHomeserver(any()),
        ).thenAnswer((_) async => serverInfo);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AuthHomeserverCheckRequested('https://server.com')),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.homeserverStatus,
          'hs',
          HomeserverStatus.checking,
        ),
        isA<AuthState>()
            .having((s) => s.homeserverStatus, 'hs', HomeserverStatus.valid)
            .having((s) => s.homeserverInfo, 'info', serverInfo),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [checking, invalid] when homeserver throws',
      build: () {
        when(
          () => mockAuthRepository.checkHomeserver(any()),
        ).thenThrow(Exception('Connection refused'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AuthHomeserverCheckRequested('https://bad.server')),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.homeserverStatus,
          'hs',
          HomeserverStatus.checking,
        ),
        isA<AuthState>()
            .having((s) => s.homeserverStatus, 'hs', HomeserverStatus.invalid)
            .having((s) => s.errorMessage, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UpdateAvatar
  // ─────────────────────────────────────────────────────────────────────────

  group('UpdateAvatar', () {
    final avatarBytes = Uint8List.fromList([0, 1, 2, 3]);

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when upload succeeds',
      build: () {
        when(
          () => mockAuthRepository.updateAvatar(any(), any()),
        ).thenAnswer((_) async => true);
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        UpdateAvatar(avatarBytes: avatarBytes, filename: 'avatar.jpg'),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when upload returns false',
      build: () {
        when(
          () => mockAuthRepository.updateAvatar(any(), any()),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        UpdateAvatar(avatarBytes: avatarBytes, filename: 'avatar.jpg'),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'error', 'Avatar upload failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when upload throws',
      build: () {
        when(
          () => mockAuthRepository.updateAvatar(any(), any()),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        UpdateAvatar(avatarBytes: avatarBytes, filename: 'avatar.jpg'),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('Avatar upload failed'),
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UpdateDisplayName
  // ─────────────────────────────────────────────────────────────────────────

  group('UpdateDisplayName', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when update succeeds',
      build: () {
        when(
          () => mockAuthRepository.updateDisplayName(any()),
        ).thenAnswer((_) async => true);
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateDisplayName('New Name')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when update returns false',
      build: () {
        when(
          () => mockAuthRepository.updateDisplayName(any()),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateDisplayName('New Name')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'error', 'Update nickname failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when update throws',
      build: () {
        when(
          () => mockAuthRepository.updateDisplayName(any()),
        ).thenThrow(Exception('Server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateDisplayName('New Name')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('Update nickname failed'),
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UpdateUserProfile
  // ─────────────────────────────────────────────────────────────────────────

  group('UpdateUserProfile', () {
    blocTest<AuthBloc, AuthState>(
      'calls updateDisplayName only when only displayName is provided',
      build: () {
        when(
          () => mockAuthRepository.updateDisplayName(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthRepository.getUserProfileData(),
        ).thenAnswer((_) async => null);
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateUserProfile(displayName: 'New Name')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
      ],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateDisplayName('New Name'),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'calls updateUserProfileData when profile fields are present',
      build: () {
        when(
          () => mockAuthRepository.updateUserProfileData(
            gender: any(named: 'gender'),
            region: any(named: 'region'),
            signature: any(named: 'signature'),
            pokeText: any(named: 'pokeText'),
            ringtone: any(named: 'ringtone'),
            avatarDecorationPreset: any(named: 'avatarDecorationPreset'),
            nftContractAddress: any(named: 'nftContractAddress'),
            nftTokenId: any(named: 'nftTokenId'),
            nftChainId: any(named: 'nftChainId'),
            nftImageUrl: any(named: 'nftImageUrl'),
            clearNftAvatar: any(named: 'clearNftAvatar'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthRepository.getUserProfileData(),
        ).thenAnswer((_) async => null);
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const UpdateUserProfile(gender: 'male', signature: 'Hello world'),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'forwards nft avatar updates to profile data storage',
      build: () {
        when(
          () => mockAuthRepository.updateUserProfileData(
            gender: any(named: 'gender'),
            region: any(named: 'region'),
            signature: any(named: 'signature'),
            pokeText: any(named: 'pokeText'),
            ringtone: any(named: 'ringtone'),
            avatarDecorationPreset: any(named: 'avatarDecorationPreset'),
            nftContractAddress: any(named: 'nftContractAddress'),
            nftTokenId: any(named: 'nftTokenId'),
            nftChainId: any(named: 'nftChainId'),
            nftImageUrl: any(named: 'nftImageUrl'),
            clearNftAvatar: any(named: 'clearNftAvatar'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthRepository.getUserProfileData(),
        ).thenAnswer((_) async => null);
        when(() => mockAuthRepository.currentUser).thenReturn(
          const UserEntity(
            userId: '@user:server.com',
            displayName: 'Test User',
            nftContractAddress: '0xabc',
            nftTokenId: 42,
            nftChainId: 1,
            nftImageUrl: 'https://example.com/nft.png',
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const UpdateUserProfile(
          nftContractAddress: '0xabc',
          nftTokenId: 42,
          nftChainId: 1,
          nftImageUrl: 'https://example.com/nft.png',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.authenticated,
        ),
      ],
      verify: (_) {
        verify(
          () => mockAuthRepository.updateUserProfileData(
            gender: null,
            region: null,
            signature: null,
            pokeText: null,
            ringtone: null,
            avatarDecorationPreset: null,
            nftContractAddress: '0xabc',
            nftTokenId: 42,
            nftChainId: 1,
            nftImageUrl: 'https://example.com/nft.png',
            clearNftAvatar: false,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when any update throws',
      build: () {
        when(
          () => mockAuthRepository.updateUserProfileData(
            gender: any(named: 'gender'),
            region: any(named: 'region'),
            signature: any(named: 'signature'),
            pokeText: any(named: 'pokeText'),
            ringtone: any(named: 'ringtone'),
            avatarDecorationPreset: any(named: 'avatarDecorationPreset'),
            nftContractAddress: any(named: 'nftContractAddress'),
            nftTokenId: any(named: 'nftTokenId'),
            nftChainId: any(named: 'nftChainId'),
            nftImageUrl: any(named: 'nftImageUrl'),
            clearNftAvatar: any(named: 'clearNftAvatar'),
          ),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateUserProfile(gender: 'female')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('Update profile failed'),
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // LoadUserProfileData
  // ─────────────────────────────────────────────────────────────────────────

  group('LoadUserProfileData', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated state with refreshed user when profile loads',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUserProfile(),
        ).thenAnswer((_) async => testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadUserProfileData()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits nothing when getCurrentUserProfile returns null',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUserProfile(),
        ).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadUserProfileData()),
      expect: () => <AuthState>[],
    );

    blocTest<AuthBloc, AuthState>(
      'does not change state on exception — load failure is non-fatal',
      build: () {
        when(
          () => mockAuthRepository.getCurrentUserProfile(),
        ).thenThrow(Exception('Timeout'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadUserProfileData()),
      expect: () => <AuthState>[],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthGetBoundEmailRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthGetBoundEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'updates boundEmail in state on success',
      build: () {
        when(
          () => mockAuthRepository.getBoundEmail(),
        ).thenAnswer((_) async => 'user@example.com');
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGetBoundEmailRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.boundEmail,
          'boundEmail',
          'user@example.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits nothing on exception — non-fatal',
      build: () {
        when(
          () => mockAuthRepository.getBoundEmail(),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGetBoundEmailRequested()),
      expect: () => <AuthState>[],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthTokenLoginRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthTokenLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on success',
      build: () {
        when(
          () => mockAuthRepository.loginWithToken(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        when(
          () => mockAuthRepository.getCurrentUserProfile(),
        ).thenAnswer((_) async => testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthTokenLoginRequested(
          homeserver: 'https://server.com',
          accessToken: 'tok_123',
          userId: '@user:server.com',
          deviceId: 'device_1',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on failure result',
      build: () {
        when(
          () => mockAuthRepository.loginWithToken(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => AuthResult.failure('Invalid token'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthTokenLoginRequested(
          homeserver: 'https://server.com',
          accessToken: 'bad_tok',
          userId: '@user:server.com',
          deviceId: 'device_1',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'error', 'Invalid token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on exception',
      build: () {
        when(
          () => mockAuthRepository.loginWithToken(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenThrow(Exception('Connection failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthTokenLoginRequested(
          homeserver: 'https://server.com',
          accessToken: 'tok',
          userId: '@user:server.com',
          deviceId: 'device_1',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('Token login failed'),
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthLoginTokenLoginRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthLoginTokenLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on success',
      build: () {
        when(
          () => mockAuthRepository.loginWithLoginToken(
            homeserver: any(named: 'homeserver'),
            loginToken: any(named: 'loginToken'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthLoginTokenLoginRequested(
          homeserver: 'https://server.com',
          loginToken: 'login_token_123',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on failure result',
      build: () {
        when(
          () => mockAuthRepository.loginWithLoginToken(
            homeserver: any(named: 'homeserver'),
            loginToken: any(named: 'loginToken'),
          ),
        ).thenAnswer((_) async => AuthResult.failure('SSO token expired'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthLoginTokenLoginRequested(
          homeserver: 'https://server.com',
          loginToken: 'expired_token',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'error', 'SSO token expired'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on exception',
      build: () {
        when(
          () => mockAuthRepository.loginWithLoginToken(
            homeserver: any(named: 'homeserver'),
            loginToken: any(named: 'loginToken'),
          ),
        ).thenThrow(Exception('OIDC callback rejected'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthLoginTokenLoginRequested(
          homeserver: 'https://server.com',
          loginToken: 'broken_token',
        ),
      ),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('SSO token login failed'),
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthErrorCleared
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthErrorCleared', () {
    blocTest<AuthBloc, AuthState>(
      'clears error and reverts to unauthenticated when no user in state',
      build: buildBloc,
      seed: () =>
          const AuthState(status: AuthStatus.error, errorMessage: 'Some error'),
      act: (bloc) => bloc.add(const AuthErrorCleared()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'error', isNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'clears error and reverts to authenticated when user is present',
      build: buildBloc,
      seed: () => const AuthState(
        status: AuthStatus.error,
        user: testUser,
        errorMessage: 'Some error',
      ),
      act: (bloc) => bloc.add(const AuthErrorCleared()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.errorMessage, 'error', isNull)
            .having((s) => s.user, 'user', testUser),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthCheckBiometricAvailability
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthCheckBiometricAvailability', () {
    blocTest<AuthBloc, AuthState>(
      'emits available=true, description when device supports biometrics',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => mockBiometricService.getBiometricTypeDescription(),
        ).thenAnswer((_) async => 'Face ID');
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckBiometricAvailability()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.isBiometricAvailable, 'available', true)
            .having((s) => s.isBiometricEnabled, 'enabled', false)
            .having((s) => s.biometricTypeDescription, 'desc', 'Face ID'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits available=false, no description when device has no biometrics',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => false);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckBiometricAvailability()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.isBiometricAvailable, 'available', false)
            .having((s) => s.biometricTypeDescription, 'desc', isNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits enabled=true when biometric login is configured',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockBiometricService.getBiometricTypeDescription(),
        ).thenAnswer((_) async => 'Fingerprint');
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckBiometricAvailability()),
      expect: () => [
        isA<AuthState>().having((s) => s.isBiometricEnabled, 'enabled', true),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthBiometricLoginRequested
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthBiometricLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when device biometrics unavailable',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              'Biometric authentication not available',
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when biometric login is not enabled by user',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              'Biometric login not enabled',
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when no saved credentials exist',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.getCredentials(),
        ).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having(
              (s) => s.errorMessage,
              'error',
              'No saved credentials found',
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when user cancels biometric prompt',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getCredentials()).thenAnswer(
          (_) async => {
            'homeserver': 'https://server.com',
            'username': 'user',
            'password': 'pass',
          },
        );
        when(
          () => mockBiometricService.authenticate(reason: any(named: 'reason')),
        ).thenAnswer(
          (_) async => BiometricResult.failure(
            message: 'User cancelled',
            code: BiometricErrorCode.userCanceled,
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'error', 'User cancelled'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on full biometric login success',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getCredentials()).thenAnswer(
          (_) async => {'homeserver': 'https://server.com', 'username': 'user'},
        );
        when(() => mockSecureStorage.getSession()).thenAnswer(
          (_) async => {
            'homeserver': 'https://server.com',
            'accessToken': 'tok',
            'userId': '@user:server.com',
            'deviceId': 'device_1',
          },
        );
        when(
          () => mockBiometricService.authenticate(reason: any(named: 'reason')),
        ).thenAnswer((_) async => BiometricResult.success());
        when(
          () => mockAuthRepository.loginWithToken(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => AuthResult.success(testUser));
        when(
          () => mockAuthRepository.getCurrentUserProfile(),
        ).thenAnswer((_) async => testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when biometric succeeds but matrix login fails',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.isBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getCredentials()).thenAnswer(
          (_) async => {'homeserver': 'https://server.com', 'username': 'user'},
        );
        when(() => mockSecureStorage.getSession()).thenAnswer(
          (_) async => {
            'homeserver': 'https://server.com',
            'accessToken': 'tok',
            'userId': '@user:server.com',
            'deviceId': 'device_1',
          },
        );
        when(
          () => mockBiometricService.authenticate(reason: any(named: 'reason')),
        ).thenAnswer((_) async => BiometricResult.success());
        when(
          () => mockAuthRepository.loginWithToken(
            homeserver: any(named: 'homeserver'),
            accessToken: any(named: 'accessToken'),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => AuthResult.failure('Invalid credentials'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthBiometricLoginRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.error)
            .having((s) => s.errorMessage, 'error', 'Invalid credentials'),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthEnableBiometricLogin
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthEnableBiometricLogin', () {
    blocTest<AuthBloc, AuthState>(
      'emits error when biometric not available on device',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthEnableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.errorMessage,
          'error',
          'Biometric authentication not available on this device',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error when no credentials saved (user not yet logged in)',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecureStorage.getCredentials(),
        ).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthEnableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.errorMessage,
          'error',
          contains('login first'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits isBiometricEnabled=true when auth and storage succeed',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getCredentials()).thenAnswer(
          (_) async => {
            'homeserver': 'https://server.com',
            'username': 'user',
            'password': 'pass',
          },
        );
        when(
          () => mockBiometricService.authenticate(reason: any(named: 'reason')),
        ).thenAnswer((_) async => BiometricResult.success());
        when(
          () => mockSecureStorage.enableBiometricLogin(
            homeserver: any(named: 'homeserver'),
            username: any(named: 'username'),
          ),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthEnableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having((s) => s.isBiometricEnabled, 'enabled', true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error when biometric verification fails during enable',
      build: () {
        when(
          () => mockBiometricService.isAvailable(),
        ).thenAnswer((_) async => true);
        when(() => mockSecureStorage.getCredentials()).thenAnswer(
          (_) async => {
            'homeserver': 'https://server.com',
            'username': 'user',
            'password': 'pass',
          },
        );
        when(
          () => mockBiometricService.authenticate(reason: any(named: 'reason')),
        ).thenAnswer(
          (_) async => BiometricResult.failure(
            message: 'Too many attempts',
            code: BiometricErrorCode.lockedOut,
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthEnableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.errorMessage,
          'error',
          'Too many attempts',
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthDisableBiometricLogin
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthDisableBiometricLogin', () {
    blocTest<AuthBloc, AuthState>(
      'emits isBiometricEnabled=false on success',
      build: () {
        when(
          () => mockSecureStorage.disableBiometricLogin(),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthDisableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having((s) => s.isBiometricEnabled, 'enabled', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error message when disable throws',
      build: () {
        when(
          () => mockSecureStorage.disableBiometricLogin(),
        ).thenThrow(Exception('Storage error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthDisableBiometricLogin()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.errorMessage,
          'error',
          contains('Failed to disable biometric login'),
        ),
      ],
    );
  });
}
