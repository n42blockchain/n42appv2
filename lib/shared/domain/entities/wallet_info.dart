// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Lightweight wallet representation for cross-feature use.
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

/// Lightweight user representation for cross-feature use.
class SharedUserInfo extends Equatable {
  final String uuid;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? token;
  final String? image;
  final String? desc;
  final bool isLoggedIn;

  const SharedUserInfo({
    required this.uuid,
    required this.email,
    this.name,
    this.avatarUrl,
    this.token,
    this.image,
    this.desc,
    this.isLoggedIn = true,
  });

  factory SharedUserInfo.fromJson(Map<String, dynamic> json) => SharedUserInfo(
        uuid: json['uuid'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String?,
        avatarUrl: json['image'] as String? ?? json['avatarUrl'] as String?,
        token: json['token'] as String?,
        image: json['image'] as String?,
        desc: json['desc'] as String?,
        isLoggedIn: json['isLoggedIn'] as bool? ?? true,
      );

  factory SharedUserInfo.fromLegacyUserInfo(dynamic userInfo) =>
      SharedUserInfo(
        uuid: userInfo.uuid ?? '',
        email: userInfo.email ?? '',
        name: userInfo.name,
        avatarUrl: userInfo.image,
        token: userInfo.token,
        image: userInfo.image,
        desc: userInfo.desc,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'token': token,
        'image': image,
        'desc': desc,
        'isLoggedIn': isLoggedIn,
      };

  @override
  List<Object?> get props => [uuid, email, name, avatarUrl, token, image, desc, isLoggedIn];
}

/// Wallet balance for a specific coin type.
class WalletBalanceInfo extends Equatable {
  final String address;
  final String coinType;
  final double balance;
  final double? usdValue;
  final DateTime? lastUpdated;

  const WalletBalanceInfo({
    required this.address,
    required this.coinType,
    required this.balance,
    this.usdValue,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [address, coinType, balance, usdValue, lastUpdated];
}
