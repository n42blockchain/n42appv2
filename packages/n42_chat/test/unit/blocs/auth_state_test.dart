// Tests for AuthState and related enums in auth_state.dart.
// Covers AuthStatus, HomeserverStatus, PasswordResetStatus,
// ChangePasswordStatus, ChangeEmailStatus enums, plus
// AuthState constructor, initial(), computed getters, and copyWith.
// Tests avoid UserEntity / AuthErrorType / HomeserverInfo instances
// (all kept as null) so there are no domain-layer dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/auth/auth_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // AuthStatus enum
  // ─────────────────────────────────────────────────

  group('AuthStatus enum', () {
    test('has 6 values', () {
      expect(AuthStatus.values.length, 6);
    });

    test('contains all expected values', () {
      expect(AuthStatus.values, containsAll([
        AuthStatus.initial,
        AuthStatus.checking,
        AuthStatus.loading,
        AuthStatus.authenticated,
        AuthStatus.unauthenticated,
        AuthStatus.error,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // HomeserverStatus enum
  // ─────────────────────────────────────────────────

  group('HomeserverStatus enum', () {
    test('has 4 values', () {
      expect(HomeserverStatus.values.length, 4);
    });

    test('contains all expected values', () {
      expect(HomeserverStatus.values, containsAll([
        HomeserverStatus.unknown,
        HomeserverStatus.checking,
        HomeserverStatus.valid,
        HomeserverStatus.invalid,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // PasswordResetStatus enum
  // ─────────────────────────────────────────────────

  group('PasswordResetStatus enum', () {
    test('has 6 values', () {
      expect(PasswordResetStatus.values.length, 6);
    });

    test('contains all expected values', () {
      expect(PasswordResetStatus.values, containsAll([
        PasswordResetStatus.initial,
        PasswordResetStatus.sendingCode,
        PasswordResetStatus.codeSent,
        PasswordResetStatus.resetting,
        PasswordResetStatus.success,
        PasswordResetStatus.failed,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // ChangePasswordStatus enum
  // ─────────────────────────────────────────────────

  group('ChangePasswordStatus enum', () {
    test('has 4 values', () {
      expect(ChangePasswordStatus.values.length, 4);
    });

    test('contains all expected values', () {
      expect(ChangePasswordStatus.values, containsAll([
        ChangePasswordStatus.initial,
        ChangePasswordStatus.changing,
        ChangePasswordStatus.success,
        ChangePasswordStatus.failed,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // ChangeEmailStatus enum
  // ─────────────────────────────────────────────────

  group('ChangeEmailStatus enum', () {
    test('has 6 values', () {
      expect(ChangeEmailStatus.values.length, 6);
    });

    test('contains all expected values', () {
      expect(ChangeEmailStatus.values, containsAll([
        ChangeEmailStatus.initial,
        ChangeEmailStatus.sendingCode,
        ChangeEmailStatus.codeSent,
        ChangeEmailStatus.confirming,
        ChangeEmailStatus.success,
        ChangeEmailStatus.failed,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.initial() constructor
  // ─────────────────────────────────────────────────

  group('AuthState.initial()', () {
    const s = AuthState.initial();

    test('status is initial', () {
      expect(s.status, AuthStatus.initial);
    });

    test('user is null', () {
      expect(s.user, isNull);
    });

    test('errorMessage is null', () {
      expect(s.errorMessage, isNull);
    });

    test('errorType is null', () {
      expect(s.errorType, isNull);
    });

    test('homeserverStatus is unknown', () {
      expect(s.homeserverStatus, HomeserverStatus.unknown);
    });

    test('homeserverInfo is null', () {
      expect(s.homeserverInfo, isNull);
    });

    test('lastCheckedHomeserver is null', () {
      expect(s.lastCheckedHomeserver, isNull);
    });

    test('passwordResetStatus is initial', () {
      expect(s.passwordResetStatus, PasswordResetStatus.initial);
    });

    test('changePasswordStatus is initial', () {
      expect(s.changePasswordStatus, ChangePasswordStatus.initial);
    });

    test('changeEmailStatus is initial', () {
      expect(s.changeEmailStatus, ChangeEmailStatus.initial);
    });

    test('boundEmail is null', () {
      expect(s.boundEmail, isNull);
    });

    test('isBiometricAvailable is false', () {
      expect(s.isBiometricAvailable, isFalse);
    });

    test('isBiometricEnabled is false', () {
      expect(s.isBiometricEnabled, isFalse);
    });

    test('biometricTypeDescription is null', () {
      expect(s.biometricTypeDescription, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.isLoading
  // ─────────────────────────────────────────────────

  group('AuthState.isLoading', () {
    test('status loading → true', () {
      const s = AuthState(status: AuthStatus.loading);
      expect(s.isLoading, isTrue);
    });

    test('status checking → true', () {
      const s = AuthState(status: AuthStatus.checking);
      expect(s.isLoading, isTrue);
    });

    test('status authenticated → false', () {
      const s = AuthState(status: AuthStatus.authenticated);
      expect(s.isLoading, isFalse);
    });

    test('status unauthenticated → false', () {
      const s = AuthState(status: AuthStatus.unauthenticated);
      expect(s.isLoading, isFalse);
    });

    test('status error → false', () {
      const s = AuthState(status: AuthStatus.error);
      expect(s.isLoading, isFalse);
    });

    test('status initial → false', () {
      const s = AuthState(status: AuthStatus.initial);
      expect(s.isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.isAuthenticated
  // ─────────────────────────────────────────────────

  group('AuthState.isAuthenticated', () {
    test('status authenticated → true', () {
      const s = AuthState(status: AuthStatus.authenticated);
      expect(s.isAuthenticated, isTrue);
    });

    test('status unauthenticated → false', () {
      const s = AuthState(status: AuthStatus.unauthenticated);
      expect(s.isAuthenticated, isFalse);
    });

    test('status loading with null user → false', () {
      const s = AuthState(status: AuthStatus.loading);
      expect(s.isAuthenticated, isFalse);
    });

    test('status error with null user → false', () {
      const s = AuthState(status: AuthStatus.error);
      expect(s.isAuthenticated, isFalse);
    });

    test('status initial → false', () {
      const s = AuthState(status: AuthStatus.initial);
      expect(s.isAuthenticated, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.hasError
  // ─────────────────────────────────────────────────

  group('AuthState.hasError', () {
    test('status error with errorMessage → true', () {
      const s = AuthState(status: AuthStatus.error, errorMessage: 'bad creds');
      expect(s.hasError, isTrue);
    });

    test('status error with null errorMessage → false', () {
      const s = AuthState(status: AuthStatus.error);
      expect(s.hasError, isFalse);
    });

    test('status authenticated with errorMessage → false', () {
      const s = AuthState(status: AuthStatus.authenticated, errorMessage: 'stale');
      expect(s.hasError, isFalse);
    });

    test('status unauthenticated with errorMessage → false', () {
      const s = AuthState(status: AuthStatus.unauthenticated, errorMessage: 'msg');
      expect(s.hasError, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.isHomeserverValid / isCheckingHomeserver
  // ─────────────────────────────────────────────────

  group('AuthState.isHomeserverValid', () {
    test('homeserverStatus valid → true', () {
      const s = AuthState(
        status: AuthStatus.initial,
        homeserverStatus: HomeserverStatus.valid,
      );
      expect(s.isHomeserverValid, isTrue);
    });

    test('homeserverStatus unknown → false', () {
      const s = AuthState(status: AuthStatus.initial);
      expect(s.isHomeserverValid, isFalse);
    });

    test('homeserverStatus invalid → false', () {
      const s = AuthState(
        status: AuthStatus.initial,
        homeserverStatus: HomeserverStatus.invalid,
      );
      expect(s.isHomeserverValid, isFalse);
    });
  });

  group('AuthState.isCheckingHomeserver', () {
    test('homeserverStatus checking → true', () {
      const s = AuthState(
        status: AuthStatus.initial,
        homeserverStatus: HomeserverStatus.checking,
      );
      expect(s.isCheckingHomeserver, isTrue);
    });

    test('homeserverStatus valid → false', () {
      const s = AuthState(
        status: AuthStatus.initial,
        homeserverStatus: HomeserverStatus.valid,
      );
      expect(s.isCheckingHomeserver, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.copyWith — field overrides
  // ─────────────────────────────────────────────────

  group('AuthState.copyWith', () {
    const base = AuthState(
      status: AuthStatus.unauthenticated,
      isBiometricAvailable: true,
      isBiometricEnabled: false,
      homeserverStatus: HomeserverStatus.unknown,
    );

    test('overrides status', () {
      final copy = base.copyWith(status: AuthStatus.loading);
      expect(copy.status, AuthStatus.loading);
      expect(copy.isBiometricAvailable, isTrue); // unchanged
    });

    test('overrides isBiometricAvailable', () {
      final copy = base.copyWith(isBiometricAvailable: false);
      expect(copy.isBiometricAvailable, isFalse);
    });

    test('overrides isBiometricEnabled', () {
      final copy = base.copyWith(isBiometricEnabled: true);
      expect(copy.isBiometricEnabled, isTrue);
    });

    test('overrides biometricTypeDescription', () {
      final copy = base.copyWith(biometricTypeDescription: 'Face ID');
      expect(copy.biometricTypeDescription, 'Face ID');
    });

    test('overrides homeserverStatus', () {
      final copy = base.copyWith(homeserverStatus: HomeserverStatus.valid);
      expect(copy.homeserverStatus, HomeserverStatus.valid);
    });

    test('overrides lastCheckedHomeserver', () {
      final copy = base.copyWith(lastCheckedHomeserver: 'https://matrix.org');
      expect(copy.lastCheckedHomeserver, 'https://matrix.org');
    });

    test('overrides boundEmail', () {
      final copy = base.copyWith(boundEmail: 'user@example.com');
      expect(copy.boundEmail, 'user@example.com');
    });

    test('overrides passwordResetStatus', () {
      final copy = base.copyWith(passwordResetStatus: PasswordResetStatus.codeSent);
      expect(copy.passwordResetStatus, PasswordResetStatus.codeSent);
    });

    test('overrides changePasswordStatus', () {
      final copy = base.copyWith(changePasswordStatus: ChangePasswordStatus.success);
      expect(copy.changePasswordStatus, ChangePasswordStatus.success);
    });

    test('overrides changeEmailStatus', () {
      final copy = base.copyWith(changeEmailStatus: ChangeEmailStatus.confirming);
      expect(copy.changeEmailStatus, ChangeEmailStatus.confirming);
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.copyWith — errorMessage/errorType reset behaviour
  // copyWith does NOT use ?? for errorMessage and errorType:
  //   errorMessage: errorMessage   (not ?? this.errorMessage)
  //   errorType:    errorType      (not ?? this.errorType)
  // So calling copyWith() without those args CLEARS them.
  // ─────────────────────────────────────────────────

  group('AuthState.copyWith errorMessage reset behaviour', () {
    const withError = AuthState(
      status: AuthStatus.error,
      errorMessage: 'network timeout',
    );

    test('calling copyWith() without errorMessage clears it to null', () {
      final copy = withError.copyWith();
      expect(copy.errorMessage, isNull);
    });

    test('calling copyWith(errorMessage: "new") sets new message', () {
      final copy = withError.copyWith(errorMessage: 'new error');
      expect(copy.errorMessage, 'new error');
    });
  });

  // ─────────────────────────────────────────────────
  // AuthState.toString
  // ─────────────────────────────────────────────────

  group('AuthState.toString', () {
    test('includes status name', () {
      const s = AuthState(status: AuthStatus.authenticated);
      expect(s.toString(), contains('authenticated'));
    });

    test('user is null → shows null for userId', () {
      const s = AuthState(status: AuthStatus.unauthenticated);
      expect(s.toString(), contains('null'));
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('AuthState Equatable equality', () {
    test('two initial states are equal', () {
      expect(const AuthState.initial(), equals(const AuthState.initial()));
    });

    test('states with different status are not equal', () {
      expect(
        const AuthState(status: AuthStatus.loading),
        isNot(equals(const AuthState(status: AuthStatus.authenticated))),
      );
    });

    test('states with different homeserverStatus are not equal', () {
      expect(
        const AuthState(
          status: AuthStatus.initial,
          homeserverStatus: HomeserverStatus.valid,
        ),
        isNot(equals(const AuthState(status: AuthStatus.initial))),
      );
    });

    test('states with different isBiometricEnabled are not equal', () {
      expect(
        const AuthState(status: AuthStatus.initial, isBiometricEnabled: true),
        isNot(equals(const AuthState(status: AuthStatus.initial))),
      );
    });
  });
}
