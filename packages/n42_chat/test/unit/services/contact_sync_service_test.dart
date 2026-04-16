import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:n42_chat/src/core/services/contact_sync_service.dart';

void main() {
  group('PhoneContact', () {
    test('creates with required fields', () {
      const contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
      );

      expect(contact.id, equals('test-id'));
      expect(contact.displayName, equals('John Doe'));
      expect(contact.phones, isEmpty);
      expect(contact.emails, isEmpty);
    });

    test('creates with all fields', () {
      final contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        phones: ['+1 (234) 567-8900', '555-1234'],
        emails: ['john@example.com', 'john.doe@work.com'],
        photoBytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(contact.firstName, equals('John'));
      expect(contact.lastName, equals('Doe'));
      expect(contact.phones.length, equals(2));
      expect(contact.emails.length, equals(2));
      expect(contact.photoBytes, isNotNull);
    });

    test('primaryPhone returns normalized first phone', () {
      const contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
        phones: ['+1 (234) 567-8900', '555-1234'],
      );

      expect(contact.primaryPhone, equals('+12345678900'));
    });

    test('primaryPhone returns null when no phones', () {
      const contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
      );

      expect(contact.primaryPhone, isNull);
    });

    test('primaryEmail returns lowercase first email', () {
      const contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
        emails: ['John@Example.COM', 'john.doe@work.com'],
      );

      expect(contact.primaryEmail, equals('john@example.com'));
    });

    test('primaryEmail returns null when no emails', () {
      const contact = PhoneContact(
        id: 'test-id',
        displayName: 'John Doe',
      );

      expect(contact.primaryEmail, isNull);
    });
  });

  group('MatchedContact', () {
    test('creates with required fields', () {
      const phoneContact = PhoneContact(
        id: 'phone-id',
        displayName: 'John Doe',
      );

      const match = MatchedContact(
        phoneContact: phoneContact,
        matrixUserId: '@john:matrix.org',
      );

      expect(match.matrixUserId, equals('@john:matrix.org'));
      expect(match.phoneContact.displayName, equals('John Doe'));
      expect(match.matrixDisplayName, isNull);
      expect(match.matrixAvatarUrl, isNull);
    });

    test('creates with all fields', () {
      const phoneContact = PhoneContact(
        id: 'phone-id',
        displayName: 'John Doe',
      );

      const match = MatchedContact(
        phoneContact: phoneContact,
        matrixUserId: '@john:matrix.org',
        matrixDisplayName: 'Johnny',
        matrixAvatarUrl: 'mxc://matrix.org/avatar123',
      );

      expect(match.matrixDisplayName, equals('Johnny'));
      expect(match.matrixAvatarUrl, equals('mxc://matrix.org/avatar123'));
    });
  });

  group('ContactSyncResult', () {
    test('success result with no matches', () {
      const result = ContactSyncResult(
        success: true,
        phoneContacts: [],
        matchedContacts: [],
      );

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.hasMatches, isFalse);
      expect(result.matchCount, equals(0));
    });

    test('success result with matches', () {
      const phoneContact = PhoneContact(
        id: 'phone-id',
        displayName: 'John Doe',
      );

      const match = MatchedContact(
        phoneContact: phoneContact,
        matrixUserId: '@john:matrix.org',
      );

      const result = ContactSyncResult(
        success: true,
        phoneContacts: [phoneContact],
        matchedContacts: [match],
      );

      expect(result.success, isTrue);
      expect(result.hasMatches, isTrue);
      expect(result.matchCount, equals(1));
    });

    test('failure result', () {
      const result = ContactSyncResult(
        success: false,
        error: 'Permission denied',
        phoneContacts: [],
        matchedContacts: [],
      );

      expect(result.success, isFalse);
      expect(result.error, equals('Permission denied'));
      expect(result.hasMatches, isFalse);
    });
  });

  group('PhoneContact phone normalization', () {
    test('removes spaces from phone numbers', () {
      const contact = PhoneContact(
        id: 'test',
        displayName: 'Test',
        phones: ['123 456 7890'],
      );

      expect(contact.primaryPhone, equals('1234567890'));
    });

    test('removes dashes from phone numbers', () {
      const contact = PhoneContact(
        id: 'test',
        displayName: 'Test',
        phones: ['123-456-7890'],
      );

      expect(contact.primaryPhone, equals('1234567890'));
    });

    test('removes parentheses from phone numbers', () {
      const contact = PhoneContact(
        id: 'test',
        displayName: 'Test',
        phones: ['(123) 456-7890'],
      );

      expect(contact.primaryPhone, equals('1234567890'));
    });

    test('preserves plus sign in phone numbers', () {
      const contact = PhoneContact(
        id: 'test',
        displayName: 'Test',
        phones: ['+1 (234) 567-8900'],
      );

      expect(contact.primaryPhone, equals('+12345678900'));
    });
  });
}
