import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';

void main() {
  group('ContactEntity', () {
    test('should create with required parameters', () {
      const contact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      expect(contact.userId, '@alice:server.com');
      expect(contact.displayName, 'Alice');
      expect(contact.isOnline, isFalse);
    });

    test('should extract username correctly', () {
      const contact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      expect(contact.username, 'alice');
    });

    test('should extract server correctly', () {
      const contact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      expect(contact.server, 'server.com');
    });

    test('should return effectiveDisplayName', () {
      const withDisplayName = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice Smith',
      );

      const withRemark = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice Smith',
        remark: 'My Friend',
      );

      expect(withDisplayName.effectiveDisplayName, 'Alice Smith');
      expect(withRemark.effectiveDisplayName, 'My Friend');
    });

    test('should generate initials correctly', () {
      const singleName = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      const fullName = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice Bob',
      );

      expect(singleName.initials, 'AL');
      expect(fullName.initials, 'AB');
    });

    test('should generate indexLetter correctly', () {
      const englishName = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      const chineseName = ContactEntity(
        userId: '@zhang:server.com',
        displayName: '张三',
      );

      const numberName = ContactEntity(
        userId: '@user123:server.com',
        displayName: '123User',
      );

      expect(englishName.indexLetter, 'A');
      // 中文名字返回 #
      expect(chineseName.indexLetter, '#');
      expect(numberName.indexLetter, '#');
    });

    test('should check online status correctly', () {
      const onlineContact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
        presence: PresenceStatus.online,
      );

      const offlineContact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
        presence: PresenceStatus.offline,
      );

      const unavailableContact = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
        presence: PresenceStatus.unavailable,
      );

      expect(onlineContact.isOnline, isTrue);
      expect(offlineContact.isOnline, isFalse);
      expect(unavailableContact.isOnline, isFalse);
    });

    test('should format lastActiveTime correctly', () {
      final recentlyActive = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
        lastActiveTime: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final longAgoActive = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
        lastActiveTime: DateTime.now().subtract(const Duration(days: 2)),
      );

      const neverActive = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      expect(recentlyActive.formattedLastActive, isNotEmpty);
      expect(longAgoActive.formattedLastActive, isNotEmpty);
      expect(neverActive.formattedLastActive, isEmpty);
    });

    test('should support copyWith', () {
      const original = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      final copy = original.copyWith(
        displayName: 'Alice Smith',
        remark: 'Best Friend',
      );

      expect(copy.userId, '@alice:server.com');
      expect(copy.displayName, 'Alice Smith');
      expect(copy.remark, 'Best Friend');
    });

    test('should be equal with same properties', () {
      const contact1 = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      const contact2 = ContactEntity(
        userId: '@alice:server.com',
        displayName: 'Alice',
      );

      expect(contact1, equals(contact2));
    });
  });
}
