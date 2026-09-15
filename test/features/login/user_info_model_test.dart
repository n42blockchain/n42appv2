// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-9: Tests for UserInfo data model
//
// Pure Dart model (dart:convert only) — no platform dependencies.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';

void main() {
  group('UserInfo.fromJson', () {
    test('all fields are parsed from a complete JSON object', () {
      final json = {
        'email': 'alice@example.com',
        'token': 'tok_abc123',
        'uuid': 'uuid-0001',
        'created': 1700000000,
        'image': 'https://example.com/avatar.png',
        'name': 'Alice',
        'desc': 'Artist bio',
        'art_json': jsonEncode({'_id': 'art-1'}),
        'idx_email_hash': 'hash001',
        'source': 'google',
        'bind_google_auth_state': true,
        'createWallet': false,
        'wallet_addr': '0xABCDEF',
        'invite_code': 'INV-123',
      };

      final user = UserInfo.fromJson(json);

      expect(user.email, 'alice@example.com');
      expect(user.token, 'tok_abc123');
      expect(user.uuid, 'uuid-0001');
      expect(user.created, 1700000000);
      expect(user.image, 'https://example.com/avatar.png');
      expect(user.name, 'Alice');
      expect(user.desc, 'Artist bio');
      expect(user.idxEmailHash, 'hash001');
      expect(user.source, 'google');
      expect(user.bindGoogleAuthState, isTrue);
      expect(user.createWallet, isFalse);
      expect(user.walletAddr, '0xABCDEF');
      expect(user.inviteCode, 'INV-123');
    });

    test('empty JSON produces all-null optional fields', () {
      final user = UserInfo.fromJson({});

      expect(user.email, isNull);
      expect(user.token, isNull);
      expect(user.uuid, isNull);
      expect(user.name, isNull);
      expect(user.image, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.displayName', () {
    test('returns name when name is set', () {
      final user = UserInfo(name: 'Bob', email: 'bob@example.com');
      expect(user.displayName, 'Bob');
    });

    test('returns email prefix when name is null', () {
      final user = UserInfo(email: 'carol@example.com');
      expect(user.displayName, 'carol');
    });

    test('returns email prefix when name is empty string', () {
      final user = UserInfo(name: '', email: 'dave@example.com');
      expect(user.displayName, 'dave');
    });

    test('returns "User" fallback when both name and email are null', () {
      final user = UserInfo();
      expect(user.displayName, 'User');
    });

    test('returns "User" fallback when email has no @ symbol', () {
      final user = UserInfo(email: 'notanemail');
      expect(user.displayName, 'User');
    });

    test('name takes priority over email prefix', () {
      final user = UserInfo(name: 'Eve', email: 'other@example.com');
      expect(user.displayName, 'Eve');
    });

    test('email prefix stops at first @ sign', () {
      final user = UserInfo(email: 'prefix@domain.com');
      expect(user.displayName, 'prefix');
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.isArtist', () {
    test('true when artJson contains _id field', () {
      final user = UserInfo(
        artJson: jsonEncode({'_id': 'art-001', 'style': 'oil'}),
      );
      expect(user.isArtist, isTrue);
    });

    test('false when artJson is null', () {
      final user = UserInfo();
      expect(user.isArtist, isFalse);
    });

    test('false when artJson is empty string', () {
      final user = UserInfo(artJson: '');
      expect(user.isArtist, isFalse);
    });

    test('false when artJson is invalid JSON', () {
      final user = UserInfo(artJson: 'not-valid-json');
      expect(user.isArtist, isFalse);
    });

    test('false when artJson is valid JSON but missing _id', () {
      final user = UserInfo(artJson: jsonEncode({'name': 'Alice'}));
      expect(user.isArtist, isFalse);
    });

    test('false when artJson is "{}" (empty object)', () {
      final user = UserInfo(artJson: '{}');
      expect(user.isArtist, isFalse);
    });

    test('isArtist result is cached after first call', () {
      // Call twice to exercise the cache path
      final user = UserInfo(artJson: jsonEncode({'_id': 'art-x'}));
      expect(user.isArtist, isTrue);
      expect(user.isArtist, isTrue); // second call hits cache
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.hasProfileImage', () {
    test('true when image is a non-empty URL', () {
      final user = UserInfo(image: 'https://example.com/img.png');
      expect(user.hasProfileImage, isTrue);
    });

    test('false when image is null', () {
      final user = UserInfo();
      expect(user.hasProfileImage, isFalse);
    });

    test('false when image is empty string', () {
      final user = UserInfo(image: '');
      expect(user.hasProfileImage, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.toJson', () {
    test('round-trip: fromJson → toJson preserves all fields', () {
      final original = {
        'email': 'frank@example.com',
        'token': 'tok_xyz',
        'uuid': 'uuid-frank',
        'created': 1699000000,
        'image': 'https://cdn.example.com/frank.jpg',
        'name': 'Frank',
        'desc': 'Developer',
        'art_json': jsonEncode({'_id': 'art-frank'}),
        'idx_email_hash': 'hash-frank',
        'source': 'apple',
        'bind_google_auth_state': false,
        'createWallet': true,
        'wallet_addr': '0xFRANK',
        'invite_code': 'FRANK-INV',
      };

      final user = UserInfo.fromJson(original);
      final result = user.toJson();

      expect(result['email'], original['email']);
      expect(result['token'], original['token']);
      expect(result['uuid'], original['uuid']);
      expect(result['name'], original['name']);
      expect(result['art_json'], original['art_json']);
      expect(result['wallet_addr'], original['wallet_addr']);
      expect(result['invite_code'], original['invite_code']);
    });

    test('toJson uses snake_case key for art_json', () {
      final user = UserInfo(artJson: '{}');
      final json = user.toJson();

      expect(json.containsKey('art_json'), isTrue);
      expect(json.containsKey('artJson'), isFalse);
    });

    test('toJson uses snake_case key for wallet_addr', () {
      final user = UserInfo(walletAddr: '0x1');
      final json = user.toJson();

      expect(json.containsKey('wallet_addr'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.copyWith', () {
    test('copyWith with no args returns equivalent object', () {
      final user = UserInfo(name: 'Grace', email: 'grace@example.com');
      final copy = user.copyWith();

      expect(copy.name, 'Grace');
      expect(copy.email, 'grace@example.com');
    });

    test('copyWith overrides only specified fields', () {
      final user = UserInfo(
        name: 'Hank',
        email: 'hank@example.com',
        uuid: 'uuid-hank',
      );
      final updated = user.copyWith(name: 'Hank Updated');

      expect(updated.name, 'Hank Updated');
      expect(updated.email, 'hank@example.com'); // unchanged
      expect(updated.uuid, 'uuid-hank'); // unchanged
    });

    test('copyWith can change multiple fields at once', () {
      final user = UserInfo(name: 'Ivy', email: 'ivy@example.com');
      final updated = user.copyWith(
        name: 'Ivy V2',
        email: 'ivy2@example.com',
        walletAddr: '0xIVY',
      );

      expect(updated.name, 'Ivy V2');
      expect(updated.email, 'ivy2@example.com');
      expect(updated.walletAddr, '0xIVY');
    });

    test('copyWith does not mutate the original', () {
      final user = UserInfo(name: 'Jack');
      user.copyWith(name: 'Changed');

      expect(user.name, 'Jack');
    });
  });

  // -------------------------------------------------------------------------
  group('UserInfo.toString', () {
    test('contains uuid, email, and name', () {
      final user = UserInfo(uuid: 'u1', email: 'k@k.com', name: 'Kim');
      final str = user.toString();

      expect(str, contains('u1'));
      expect(str, contains('k@k.com'));
      expect(str, contains('Kim'));
    });
  });
}
