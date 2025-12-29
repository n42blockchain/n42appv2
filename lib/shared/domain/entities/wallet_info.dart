// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Shared Wallet Info
///
/// A lightweight wallet representation that can be used across features.
/// Contains only the essential information needed by other features.
class SharedWalletInfo extends Equatable {
  final String address;
  final String name;
  final String chainType;
  final String? avatarUrl;

  const SharedWalletInfo({
    required this.address,
    required this.name,
    required this.chainType,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [address, name, chainType, avatarUrl];
}

/// Shared User Info
///
/// A lightweight user representation for cross-feature use.
class SharedUserInfo extends Equatable {
  final String uuid;
  final String email;
  final String? name;
  final String? avatarUrl;
  final bool isLoggedIn;

  const SharedUserInfo({
    required this.uuid,
    required this.email,
    this.name,
    this.avatarUrl,
    this.isLoggedIn = true,
  });

  @override
  List<Object?> get props => [uuid, email, name, avatarUrl, isLoggedIn];
}
