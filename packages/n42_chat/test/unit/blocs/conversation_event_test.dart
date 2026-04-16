// Tests for ConversationEvent subclasses in conversation_event.dart.
// Pure Dart Equatable event classes — no external entity deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadConversations', () {
    test('is a ConversationEvent', () {
      expect(const LoadConversations(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadConversations(), equals(const LoadConversations()));
    });
  });

  group('RefreshConversations', () {
    test('is a ConversationEvent', () {
      expect(const RefreshConversations(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const RefreshConversations(), equals(const RefreshConversations()));
    });
  });

  group('SubscribeConversations', () {
    test('is a ConversationEvent', () {
      expect(const SubscribeConversations(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const SubscribeConversations(), equals(const SubscribeConversations()));
    });
  });

  group('UnsubscribeConversations', () {
    test('is a ConversationEvent', () {
      expect(const UnsubscribeConversations(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const UnsubscribeConversations(), equals(const UnsubscribeConversations()));
    });
  });

  group('ClearSearch', () {
    test('is a ConversationEvent', () {
      expect(const ClearSearch(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const ClearSearch(), equals(const ClearSearch()));
    });
  });

  group('LoadHiddenConversations', () {
    test('is a ConversationEvent', () {
      expect(const LoadHiddenConversations(), isA<ConversationEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadHiddenConversations(), equals(const LoadHiddenConversations()));
    });
  });

  // ─────────────────────────────────────────────────
  // Single-String events
  // ─────────────────────────────────────────────────

  group('SearchConversations', () {
    test('stores query', () {
      const e = SearchConversations('alice');
      expect(e.query, 'alice');
    });

    test('same query → equal', () {
      expect(const SearchConversations('q'), equals(const SearchConversations('q')));
    });

    test('different query → not equal', () {
      expect(
        const SearchConversations('a'),
        isNot(equals(const SearchConversations('b'))),
      );
    });

    test('is a ConversationEvent', () {
      expect(const SearchConversations('q'), isA<ConversationEvent>());
    });
  });

  group('MarkConversationAsRead', () {
    test('stores conversationId', () {
      expect(const MarkConversationAsRead('conv_001').conversationId, 'conv_001');
    });

    test('same id → equal', () {
      expect(
        const MarkConversationAsRead('id'),
        equals(const MarkConversationAsRead('id')),
      );
    });

    test('different id → not equal', () {
      expect(
        const MarkConversationAsRead('a'),
        isNot(equals(const MarkConversationAsRead('b'))),
      );
    });

    test('is a ConversationEvent', () {
      expect(const MarkConversationAsRead('id'), isA<ConversationEvent>());
    });
  });

  group('DeleteConversation', () {
    test('stores conversationId', () {
      expect(const DeleteConversation('!room:server').conversationId, '!room:server');
    });

    test('same id → equal', () {
      expect(
        const DeleteConversation('!r:s'),
        equals(const DeleteConversation('!r:s')),
      );
    });

    test('is a ConversationEvent', () {
      expect(const DeleteConversation('!r:s'), isA<ConversationEvent>());
    });
  });

  group('CreateDirectChat', () {
    test('stores userId', () {
      expect(const CreateDirectChat('@alice:server').userId, '@alice:server');
    });

    test('same userId → equal', () {
      expect(
        const CreateDirectChat('@u:s'),
        equals(const CreateDirectChat('@u:s')),
      );
    });

    test('different userId → not equal', () {
      expect(
        const CreateDirectChat('@a:s'),
        isNot(equals(const CreateDirectChat('@b:s'))),
      );
    });

    test('is a ConversationEvent', () {
      expect(const CreateDirectChat('@u:s'), isA<ConversationEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SetConversationMuted
  // ─────────────────────────────────────────────────

  group('SetConversationMuted', () {
    test('stores conversationId and muted', () {
      const e = SetConversationMuted(conversationId: '!r:s', muted: true);
      expect(e.conversationId, '!r:s');
      expect(e.muted, isTrue);
    });

    test('stores muted=false', () {
      expect(
        const SetConversationMuted(conversationId: '!r:s', muted: false).muted,
        isFalse,
      );
    });

    test('same fields → equal', () {
      expect(
        const SetConversationMuted(conversationId: '!r:s', muted: true),
        equals(const SetConversationMuted(conversationId: '!r:s', muted: true)),
      );
    });

    test('different muted → not equal', () {
      expect(
        const SetConversationMuted(conversationId: '!r:s', muted: true),
        isNot(equals(
          const SetConversationMuted(conversationId: '!r:s', muted: false),
        )),
      );
    });

    test('is a ConversationEvent', () {
      expect(
        const SetConversationMuted(conversationId: '!r:s', muted: false),
        isA<ConversationEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SetConversationPinned
  // ─────────────────────────────────────────────────

  group('SetConversationPinned', () {
    test('stores conversationId and pinned', () {
      const e = SetConversationPinned(conversationId: '!r:s', pinned: true);
      expect(e.conversationId, '!r:s');
      expect(e.pinned, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const SetConversationPinned(conversationId: '!r:s', pinned: false),
        equals(const SetConversationPinned(conversationId: '!r:s', pinned: false)),
      );
    });

    test('different pinned → not equal', () {
      expect(
        const SetConversationPinned(conversationId: '!r:s', pinned: true),
        isNot(equals(
          const SetConversationPinned(conversationId: '!r:s', pinned: false),
        )),
      );
    });

    test('is a ConversationEvent', () {
      expect(
        const SetConversationPinned(conversationId: '!r:s', pinned: true),
        isA<ConversationEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SetConversationHidden
  // ─────────────────────────────────────────────────

  group('SetConversationHidden', () {
    test('stores conversationId and hidden', () {
      const e = SetConversationHidden(conversationId: '!r:s', hidden: true);
      expect(e.conversationId, '!r:s');
      expect(e.hidden, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const SetConversationHidden(conversationId: '!r:s', hidden: true),
        equals(const SetConversationHidden(conversationId: '!r:s', hidden: true)),
      );
    });

    test('different hidden → not equal', () {
      expect(
        const SetConversationHidden(conversationId: '!r:s', hidden: true),
        isNot(equals(
          const SetConversationHidden(conversationId: '!r:s', hidden: false),
        )),
      );
    });

    test('is a ConversationEvent', () {
      expect(
        const SetConversationHidden(conversationId: '!r:s', hidden: false),
        isA<ConversationEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // CreateGroupChat
  // ─────────────────────────────────────────────────

  group('CreateGroupChat', () {
    test('stores name', () {
      const e = CreateGroupChat(name: 'Dev Team');
      expect(e.name, 'Dev Team');
    });

    test('topic defaults to null', () {
      expect(const CreateGroupChat(name: 'G').topic, isNull);
    });

    test('memberIds defaults to empty', () {
      expect(const CreateGroupChat(name: 'G').memberIds, isEmpty);
    });

    test('encrypted defaults to true', () {
      expect(const CreateGroupChat(name: 'G').encrypted, isTrue);
    });

    test('stores all fields', () {
      const e = CreateGroupChat(
        name: 'Dev Team',
        topic: 'Engineering',
        memberIds: ['@alice:s', '@bob:s'],
        encrypted: false,
      );
      expect(e.name, 'Dev Team');
      expect(e.topic, 'Engineering');
      expect(e.memberIds, ['@alice:s', '@bob:s']);
      expect(e.encrypted, isFalse);
    });

    test('same fields → equal', () {
      expect(
        const CreateGroupChat(name: 'G', memberIds: ['@u:s'], encrypted: true),
        equals(
          const CreateGroupChat(name: 'G', memberIds: ['@u:s'], encrypted: true),
        ),
      );
    });

    test('different name → not equal', () {
      expect(
        const CreateGroupChat(name: 'A'),
        isNot(equals(const CreateGroupChat(name: 'B'))),
      );
    });

    test('different encrypted → not equal', () {
      expect(
        const CreateGroupChat(name: 'G', encrypted: true),
        isNot(equals(const CreateGroupChat(name: 'G', encrypted: false))),
      );
    });

    test('is a ConversationEvent', () {
      expect(const CreateGroupChat(name: 'G'), isA<ConversationEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ConversationsUpdated
  // ─────────────────────────────────────────────────

  group('ConversationsUpdated', () {
    test('stores empty conversations list', () {
      const e = ConversationsUpdated([]);
      expect(e.conversations, isEmpty);
    });

    test('empty list → equal', () {
      expect(
        const ConversationsUpdated([]),
        equals(const ConversationsUpdated([])),
      );
    });

    test('stores dynamic items', () {
      const e = ConversationsUpdated(['conv1', 'conv2']);
      expect(e.conversations.length, 2);
      expect(e.conversations.first, 'conv1');
    });

    test('is a ConversationEvent', () {
      expect(const ConversationsUpdated([]), isA<ConversationEvent>());
    });
  });
}
