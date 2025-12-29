// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// User Entity
class UserEntity extends Equatable {
  final String uuid;
  final String email;
  final String? name;
  final String? avatar;
  final String? description;
  final DateTime? createdAt;
  final bool hasWallet;
  final bool googleAuthEnabled;
  final String? inviteCode;

  const UserEntity({
    required this.uuid,
    required this.email,
    this.name,
    this.avatar,
    this.description,
    this.createdAt,
    this.hasWallet = false,
    this.googleAuthEnabled = false,
    this.inviteCode,
  });

  /// Get display name
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email.contains('@')) return email.split('@').first;
    return 'User';
  }

  UserEntity copyWith({
    String? uuid,
    String? email,
    String? name,
    String? avatar,
    String? description,
    DateTime? createdAt,
    bool? hasWallet,
    bool? googleAuthEnabled,
    String? inviteCode,
  }) {
    return UserEntity(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      hasWallet: hasWallet ?? this.hasWallet,
      googleAuthEnabled: googleAuthEnabled ?? this.googleAuthEnabled,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        email,
        name,
        avatar,
        description,
        createdAt,
        hasWallet,
        googleAuthEnabled,
        inviteCode,
      ];
}

/// Auth Token Entity
class AuthTokenEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  const AuthTokenEntity({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

/// Google Auth Setup Entity
class GoogleAuthEntity extends Equatable {
  final String secret;
  final String qrCodeUrl;
  final List<String> backupCodes;

  const GoogleAuthEntity({
    required this.secret,
    required this.qrCodeUrl,
    required this.backupCodes,
  });

  @override
  List<Object?> get props => [secret, qrCodeUrl, backupCodes];
}

/// Security Settings Entity
class SecuritySettingsEntity extends Equatable {
  final bool lockEnabled;
  final String? lockPassword;
  final bool biometricEnabled;
  final bool faceIdEnabled;
  final bool gestureEnabled;
  final String? gesturePassword;
  final int lockTimeout; // in seconds

  const SecuritySettingsEntity({
    this.lockEnabled = false,
    this.lockPassword,
    this.biometricEnabled = false,
    this.faceIdEnabled = false,
    this.gestureEnabled = false,
    this.gesturePassword,
    this.lockTimeout = 30,
  });

  SecuritySettingsEntity copyWith({
    bool? lockEnabled,
    String? lockPassword,
    bool? biometricEnabled,
    bool? faceIdEnabled,
    bool? gestureEnabled,
    String? gesturePassword,
    int? lockTimeout,
  }) {
    return SecuritySettingsEntity(
      lockEnabled: lockEnabled ?? this.lockEnabled,
      lockPassword: lockPassword ?? this.lockPassword,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
      gestureEnabled: gestureEnabled ?? this.gestureEnabled,
      gesturePassword: gesturePassword ?? this.gesturePassword,
      lockTimeout: lockTimeout ?? this.lockTimeout,
    );
  }

  @override
  List<Object?> get props => [
        lockEnabled,
        lockPassword,
        biometricEnabled,
        faceIdEnabled,
        gestureEnabled,
        gesturePassword,
        lockTimeout,
      ];
}

