// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

/// User Information Model
///
/// Represents the authenticated user's profile and credentials.
class UserInfo {
  String? email;
  String? token;
  String? uuid;
  int? created;
  String? idxEmailHash;
  String? source;
  String? image;
  String? name;
  String? desc;
  String? artJson;
  bool? bindGoogleAuthState;
  bool? createWallet;
  String? walletAddr;
  String? inviteCode;

  bool follower = false;
  bool following = false;
  bool followAction = false;
  bool? _isArtist;

  UserInfo({
    this.email,
    this.token,
    this.uuid,
    this.created,
    this.image,
    this.name,
    this.desc,
    this.artJson,
    this.idxEmailHash,
    this.source,
    this.bindGoogleAuthState,
    this.createWallet,
    this.inviteCode,
    this.walletAddr,
  });

  /// Create from JSON map
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email'] as String?,
      token: json['token'] as String?,
      uuid: json['uuid'] as String?,
      created: json['created'] as int?,
      image: json['image'] as String?,
      name: json['name'] as String?,
      desc: json['desc'] as String?,
      artJson: json['art_json'] as String?,
      idxEmailHash: json['idx_email_hash'] as String?,
      source: json['source'] as String?,
      bindGoogleAuthState: json['bind_google_auth_state'] as bool?,
      createWallet: json['createWallet'] as bool?,
      inviteCode: json['invite_code'] as String?,
      walletAddr: json['wallet_addr'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'uuid': uuid,
      'created': created,
      'idx_email_hash': idxEmailHash,
      'source': source,
      'image': image,
      'name': name,
      'desc': desc,
      'art_json': artJson,
      'bind_google_auth_state': bindGoogleAuthState,
      'createWallet': createWallet,
      'wallet_addr': walletAddr,
      'invite_code': inviteCode,
    };
  }

  /// Check if user is an artist
  bool get isArtist {
    if (_isArtist != null) return _isArtist!;
    
    if (artJson == null || artJson!.isEmpty) {
      _isArtist = false;
      return false;
    }
    
    try {
      Map<String, dynamic>? artData = json.decode(artJson!);
      _isArtist = artData != null && artData['_id'] != null;
    } catch (_) {
      _isArtist = false;
    }
    
    return _isArtist!;
  }

  /// Get display name (name or email prefix)
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (email != null && email!.contains('@')) {
      return email!.split('@').first;
    }
    return 'User';
  }

  /// Check if user has a profile image
  bool get hasProfileImage => image != null && image!.isNotEmpty;

  /// Create a copy with optional field updates
  UserInfo copyWith({
    String? email,
    String? token,
    String? uuid,
    int? created,
    String? idxEmailHash,
    String? source,
    String? image,
    String? name,
    String? desc,
    String? artJson,
    bool? bindGoogleAuthState,
    bool? createWallet,
    String? walletAddr,
    String? inviteCode,
  }) {
    return UserInfo(
      email: email ?? this.email,
      token: token ?? this.token,
      uuid: uuid ?? this.uuid,
      created: created ?? this.created,
      idxEmailHash: idxEmailHash ?? this.idxEmailHash,
      source: source ?? this.source,
      image: image ?? this.image,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      artJson: artJson ?? this.artJson,
      bindGoogleAuthState: bindGoogleAuthState ?? this.bindGoogleAuthState,
      createWallet: createWallet ?? this.createWallet,
      walletAddr: walletAddr ?? this.walletAddr,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  String toString() {
    return 'UserInfo(uuid: $uuid, email: $email, name: $name)';
  }
}

