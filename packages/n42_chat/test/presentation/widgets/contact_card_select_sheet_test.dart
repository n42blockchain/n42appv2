import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/presentation/widgets/chat/contact_card_select_sheet.dart';

void main() {
  test('direct chat contact picker excludes the current peer', () {
    const sheet = ContactCardSelectSheet(
      isDark: false,
      selectContactText: 'Select Contact',
      searchContactHintText: 'Search contacts',
      noContactsFoundText: 'No contacts found',
      conversation: ConversationEntity(
        id: '!direct:hs',
        name: 'Current peer',
        directUserId: '@peer:hs',
      ),
    );
    const contacts = [
      ContactEntity(userId: '@peer:hs', displayName: 'Current peer'),
      ContactEntity(userId: '@friend:hs', displayName: 'Other friend'),
    ];

    expect(
      ContactCardSelectSheet.filterContacts(contacts, sheet.excludedUserId),
      [contacts.last],
    );
  });
}
