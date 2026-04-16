// Tests for ContactEvent subclasses in contact_event.dart.
// Pure Dart Equatable event classes — no platform deps.
// Note: SearchContacts here is from contact_event.dart (local search),
// distinct from the SearchContacts in search_event.dart (global).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadContacts', () {
    test('is a ContactEvent', () {
      expect(const LoadContacts(), isA<ContactEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadContacts(), equals(const LoadContacts()));
    });
  });

  group('RefreshContacts', () {
    test('is a ContactEvent', () {
      expect(const RefreshContacts(), isA<ContactEvent>());
    });

    test('two instances are equal', () {
      expect(const RefreshContacts(), equals(const RefreshContacts()));
    });
  });

  group('ClearSearch', () {
    test('is a ContactEvent', () {
      expect(const ClearSearch(), isA<ContactEvent>());
    });

    test('two instances are equal', () {
      expect(const ClearSearch(), equals(const ClearSearch()));
    });
  });

  group('LoadFriendRequests', () {
    test('is a ContactEvent', () {
      expect(const LoadFriendRequests(), isA<ContactEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadFriendRequests(), equals(const LoadFriendRequests()));
    });
  });

  group('ContactsUpdated', () {
    test('is a ContactEvent', () {
      expect(const ContactsUpdated(), isA<ContactEvent>());
    });

    test('two instances are equal', () {
      expect(const ContactsUpdated(), equals(const ContactsUpdated()));
    });
  });

  // ─────────────────────────────────────────────────
  // Single-String events
  // ─────────────────────────────────────────────────

  group('SearchContacts', () {
    test('stores query', () {
      expect(const SearchContacts('alice').query, 'alice');
    });

    test('same query → equal', () {
      expect(const SearchContacts('q'), equals(const SearchContacts('q')));
    });

    test('different query → not equal', () {
      expect(
        const SearchContacts('a'),
        isNot(equals(const SearchContacts('b'))),
      );
    });

    test('is a ContactEvent', () {
      expect(const SearchContacts('q'), isA<ContactEvent>());
    });
  });

  group('StartChat', () {
    test('stores userId', () {
      expect(const StartChat('@alice:server').userId, '@alice:server');
    });

    test('same userId → equal', () {
      expect(const StartChat('@u:s'), equals(const StartChat('@u:s')));
    });

    test('different userId → not equal', () {
      expect(const StartChat('@a:s'), isNot(equals(const StartChat('@b:s'))));
    });

    test('is a ContactEvent', () {
      expect(const StartChat('@u:s'), isA<ContactEvent>());
    });
  });

  group('IgnoreUser', () {
    test('stores userId', () {
      expect(const IgnoreUser('@bob:s').userId, '@bob:s');
    });

    test('same userId → equal', () {
      expect(const IgnoreUser('@u:s'), equals(const IgnoreUser('@u:s')));
    });

    test('is a ContactEvent', () {
      expect(const IgnoreUser('@u:s'), isA<ContactEvent>());
    });
  });

  group('UnignoreUser', () {
    test('stores userId', () {
      expect(const UnignoreUser('@bob:s').userId, '@bob:s');
    });

    test('same userId → equal', () {
      expect(const UnignoreUser('@u:s'), equals(const UnignoreUser('@u:s')));
    });

    test('is a ContactEvent', () {
      expect(const UnignoreUser('@u:s'), isA<ContactEvent>());
    });
  });

  group('DeleteContact', () {
    test('stores userId', () {
      expect(const DeleteContact('@user:s').userId, '@user:s');
    });

    test('same userId → equal', () {
      expect(const DeleteContact('@u:s'), equals(const DeleteContact('@u:s')));
    });

    test('different userId → not equal', () {
      expect(
        const DeleteContact('@a:s'),
        isNot(equals(const DeleteContact('@b:s'))),
      );
    });

    test('is a ContactEvent', () {
      expect(const DeleteContact('@u:s'), isA<ContactEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SearchUsers
  // ─────────────────────────────────────────────────

  group('SearchUsers', () {
    test('stores query', () {
      const e = SearchUsers('alice');
      expect(e.query, 'alice');
    });

    test('limit defaults to 20', () {
      expect(const SearchUsers('q').limit, 20);
    });

    test('stores custom limit', () {
      expect(const SearchUsers('q', limit: 50).limit, 50);
    });

    test('same fields → equal', () {
      expect(
        const SearchUsers('q', limit: 30),
        equals(const SearchUsers('q', limit: 30)),
      );
    });

    test('different query → not equal', () {
      expect(
        const SearchUsers('a'),
        isNot(equals(const SearchUsers('b'))),
      );
    });

    test('different limit → not equal', () {
      expect(
        const SearchUsers('q', limit: 10),
        isNot(equals(const SearchUsers('q', limit: 20))),
      );
    });

    test('is a ContactEvent', () {
      expect(const SearchUsers('q'), isA<ContactEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // AcceptFriendRequest / RejectFriendRequest
  // ─────────────────────────────────────────────────

  group('AcceptFriendRequest', () {
    test('stores requestId', () {
      expect(const AcceptFriendRequest('req001').requestId, 'req001');
    });

    test('same requestId → equal', () {
      expect(
        const AcceptFriendRequest('req'),
        equals(const AcceptFriendRequest('req')),
      );
    });

    test('different requestId → not equal', () {
      expect(
        const AcceptFriendRequest('a'),
        isNot(equals(const AcceptFriendRequest('b'))),
      );
    });

    test('is a ContactEvent', () {
      expect(const AcceptFriendRequest('req'), isA<ContactEvent>());
    });
  });

  group('RejectFriendRequest', () {
    test('stores requestId', () {
      expect(const RejectFriendRequest('req002').requestId, 'req002');
    });

    test('same requestId → equal', () {
      expect(
        const RejectFriendRequest('req'),
        equals(const RejectFriendRequest('req')),
      );
    });

    test('is a ContactEvent', () {
      expect(const RejectFriendRequest('req'), isA<ContactEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // OnlineStatusUpdated
  // ─────────────────────────────────────────────────

  group('OnlineStatusUpdated', () {
    test('stores statusMap', () {
      const e = OnlineStatusUpdated({'@alice:s': true, '@bob:s': false});
      expect(e.statusMap['@alice:s'], isTrue);
      expect(e.statusMap['@bob:s'], isFalse);
    });

    test('empty map stored', () {
      expect(const OnlineStatusUpdated({}).statusMap, isEmpty);
    });

    test('same map → equal', () {
      expect(
        const OnlineStatusUpdated({'@u:s': true}),
        equals(const OnlineStatusUpdated({'@u:s': true})),
      );
    });

    test('different values → not equal', () {
      expect(
        const OnlineStatusUpdated({'@u:s': true}),
        isNot(equals(const OnlineStatusUpdated({'@u:s': false}))),
      );
    });

    test('is a ContactEvent', () {
      expect(const OnlineStatusUpdated({}), isA<ContactEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SetContactRemark
  // ─────────────────────────────────────────────────

  group('SetContactRemark', () {
    test('stores userId and remark', () {
      const e = SetContactRemark('@bob:s', 'My friend Bob');
      expect(e.userId, '@bob:s');
      expect(e.remark, 'My friend Bob');
    });

    test('remark can be null (clear remark)', () {
      const e = SetContactRemark('@bob:s', null);
      expect(e.remark, isNull);
    });

    test('same fields → equal', () {
      expect(
        const SetContactRemark('@u:s', 'Name'),
        equals(const SetContactRemark('@u:s', 'Name')),
      );
    });

    test('null remark → equal', () {
      expect(
        const SetContactRemark('@u:s', null),
        equals(const SetContactRemark('@u:s', null)),
      );
    });

    test('different remark → not equal', () {
      expect(
        const SetContactRemark('@u:s', 'A'),
        isNot(equals(const SetContactRemark('@u:s', 'B'))),
      );
    });

    test('is a ContactEvent', () {
      expect(const SetContactRemark('@u:s', null), isA<ContactEvent>());
    });
  });
}
