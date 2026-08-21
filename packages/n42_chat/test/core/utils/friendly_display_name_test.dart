import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/friendly_display_name.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/entities/user_entity.dart';

void main() {
  test('keeps deliberate human-readable nicknames', () {
    expect(
      FriendlyDisplayName.resolve(
        displayName: 'Alice Chen',
        userId: '@u_a18f0947c45b:example.org',
      ),
      'Alice Chen',
    );
    expect(
      FriendlyDisplayName.resolve(
        displayName: '',
        userId: '@alice:example.org',
      ),
      'alice',
    );
  });

  test('replaces opaque IDs with stable friendly labels', () {
    const id = '@u_k9z7q2m4v8n6:example.org';
    final first = FriendlyDisplayName.resolve(
      displayName: 'u_k9z7q2m4v8n6',
      userId: id,
    );
    final second = FriendlyDisplayName.resolve(displayName: '', userId: id);

    expect(first, matches(RegExp(r'^N42 User \d{4}$')));
    expect(second, first);
    expect(first, isNot(contains('u_')));
  });

  test('anonymous IDs use a live guest label across entities', () {
    const id = '@anon_abcdef123456:example.org';
    const user = UserEntity(userId: id, displayName: 'anon_abcdef123456');
    const contact = ContactEntity(userId: id, displayName: 'anon_abcdef123456');

    expect(user.effectiveDisplayName, startsWith('Live Guest '));
    expect(contact.effectiveDisplayName, user.effectiveDisplayName);
  });
}
