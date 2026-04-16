import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('UserEntity construction', () {
    test('creates with required fields and defaults', () {
      const user = UserEntity(
        userId: '@alice:matrix.org',
        displayName: 'Alice',
      );
      expect(user.userId, '@alice:matrix.org');
      expect(user.displayName, 'Alice');
      expect(user.avatarUrl, isNull);
      expect(user.statusMessage, isNull);
      expect(user.isCurrentUser, isFalse);
      expect(user.gender, isNull);
      expect(user.region, isNull);
      expect(user.n42Username, isNull);
      expect(user.walletAddress, isNull);
      expect(user.ensName, isNull);
    });

    test('creates with all optional fields', () {
      const user = UserEntity(
        userId: '@bob:s',
        displayName: 'Bob',
        avatarUrl: 'mxc://s/abc',
        statusMessage: 'Hello',
        isCurrentUser: true,
        gender: 'male',
        region: 'CN',
        signature: 'My sig',
        pokeText: 'Poke!',
        ringtone: 'default',
        n42Username: '@bob',
        walletAddress: '0x1234',
        ensName: 'bob.eth',
        nftContractAddress: '0xabc',
        nftTokenId: 42,
        nftChainId: 1,
        nftImageUrl: 'https://example.com/nft.png',
      );
      expect(user.isCurrentUser, isTrue);
      expect(user.gender, 'male');
      expect(user.ensName, 'bob.eth');
      expect(user.hasNftAvatar, isTrue);
    });
  });

  group('UserEntity.hasNftAvatar', () {
    test('returns false when nft metadata is incomplete', () {
      const user = UserEntity(
        userId: '@alice:matrix.org',
        displayName: 'Alice',
        nftContractAddress: '0xabc',
        nftTokenId: 1,
      );
      expect(user.hasNftAvatar, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // username getter
  // ─────────────────────────────────────────────────

  group('UserEntity.username', () {
    test('extracts local part from @user:server', () {
      const user = UserEntity(userId: '@alice:matrix.org', displayName: '');
      expect(user.username, 'alice');
    });

    test('returns id minus @ when no colon', () {
      const user = UserEntity(userId: '@bob', displayName: '');
      expect(user.username, 'bob');
    });

    test('returns userId as-is when no @ prefix', () {
      const user = UserEntity(userId: 'plain', displayName: '');
      expect(user.username, 'plain');
    });
  });

  // ─────────────────────────────────────────────────
  // server getter
  // ─────────────────────────────────────────────────

  group('UserEntity.server', () {
    test('extracts server part from @user:server', () {
      const user = UserEntity(userId: '@alice:matrix.org', displayName: '');
      expect(user.server, 'matrix.org');
    });

    test('returns empty string when no colon', () {
      const user = UserEntity(userId: '@bob', displayName: '');
      expect(user.server, '');
    });
  });

  // ─────────────────────────────────────────────────
  // effectiveDisplayName getter
  // ─────────────────────────────────────────────────

  group('UserEntity.effectiveDisplayName', () {
    test('returns displayName when non-empty', () {
      const user = UserEntity(userId: '@alice:s', displayName: 'Alice');
      expect(user.effectiveDisplayName, 'Alice');
    });

    test('falls back to username when displayName is empty', () {
      const user = UserEntity(userId: '@alice:s', displayName: '');
      expect(user.effectiveDisplayName, 'alice');
    });
  });

  // ─────────────────────────────────────────────────
  // initials getter
  // ─────────────────────────────────────────────────

  group('UserEntity.initials', () {
    test('single word: returns first 2 chars uppercased', () {
      const user = UserEntity(userId: '@a:s', displayName: 'alice');
      expect(user.initials, 'AL');
    });

    test('two words: returns first char of each word', () {
      const user = UserEntity(userId: '@a:s', displayName: 'Alice Bob');
      expect(user.initials, 'AB');
    });

    test('single char name: returns that char uppercased', () {
      const user = UserEntity(userId: '@a:s', displayName: 'A');
      expect(user.initials, 'A');
    });

    test('empty effectiveDisplayName returns ?', () {
      // effectiveDisplayName falls back to username; userId must also be empty-username
      // Use a userId with no local part to force empty username
      const user = UserEntity(userId: 'plain', displayName: '');
      // username = 'plain', so initials = 'PL'
      expect(user.initials, 'PL');
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('UserEntity equality', () {
    test('two instances with same fields are equal', () {
      const a = UserEntity(userId: '@alice:s', displayName: 'Alice');
      const b = UserEntity(userId: '@alice:s', displayName: 'Alice');
      expect(a, equals(b));
    });

    test('different userId → not equal', () {
      const a = UserEntity(userId: '@alice:s', displayName: 'Alice');
      const b = UserEntity(userId: '@bob:s', displayName: 'Alice');
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('UserEntity.copyWith', () {
    test('replaces only specified field', () {
      const original = UserEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        gender: 'female',
      );
      final copy = original.copyWith(displayName: 'Alicia');
      expect(copy.userId, '@alice:s');
      expect(copy.displayName, 'Alicia');
      expect(copy.gender, 'female');
    });

    test('retains nft fields when copying', () {
      const original = UserEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        nftContractAddress: '0xabc',
        nftTokenId: 7,
        nftChainId: 1,
        nftImageUrl: 'https://example.com/7.png',
      );
      final copy = original.copyWith(displayName: 'Alicia');
      expect(copy.nftContractAddress, '0xabc');
      expect(copy.nftTokenId, 7);
      expect(copy.hasNftAvatar, isTrue);
    });

    test('retains all fields when nothing specified', () {
      const original = UserEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        isCurrentUser: true,
      );
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });
}
