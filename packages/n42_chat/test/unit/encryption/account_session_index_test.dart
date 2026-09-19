import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/src/core/encryption/account_session_index.dart';

void main() {
  late AccountSessionIndex index;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    index = AccountSessionIndex();
  });

  test(
    'legacy session is registered without moving or replacing its database',
    () async {
      expect(await index.activeDatabaseName(), 'N42Chat');
      await index.remember(
        Uri.parse('https://hs.test'),
        '@a:hs',
        'A',
        'N42Chat',
      );
      expect(
        await index.lookup(Uri.parse('https://hs.test/'), '@a:hs', 'A'),
        'N42Chat',
      );
      expect(
        await index.lookup(Uri.parse('https://other.test'), '@a:hs', 'A'),
        isNull,
      );
      expect(
        await index.lookup(Uri.parse('https://hs.test'), '@b:hs', 'A'),
        isNull,
      );
      expect(
        await index.lookup(Uri.parse('https://hs.test'), '@a:hs', 'B'),
        isNull,
      );
    },
  );

  test(
    'account databases survive switching and reconstructing the index',
    () async {
      final server = Uri.parse('https://hs.test');
      final a = index.newDatabaseName();
      final b = index.newDatabaseName();
      expect(a, isNot(b));
      await index.remember(server, '@a:hs', 'A', a);
      await index.remember(server, '@b:hs', 'B', b);
      final reopened = AccountSessionIndex();
      expect(await reopened.activeDatabaseName(), b);
      expect(await reopened.lookup(server, '@a:hs', 'A'), a);
      await reopened.remember(server, '@a:hs', 'A', a);
      expect(await reopened.activeDatabaseName(), a);
      await reopened.forget(server, '@a:hs', 'A');
      expect(await reopened.lookup(server, '@a:hs', 'A'), isNull);
      expect(await reopened.lookup(server, '@b:hs', 'B'), b);
    },
  );

  test(
    'cannot map a second account or device onto an owned SDK database',
    () async {
      final server = Uri.parse('https://hs.test');
      await index.remember(server, '@a:hs', 'A', 'N42Chat');
      await expectLater(
        index.remember(server, '@b:hs', 'B', 'N42Chat'),
        throwsStateError,
      );
      expect(await index.lookup(server, '@b:hs', 'B'), isNull);
      await expectLater(
        index.remember(server, '@a:hs', 'NEW', 'N42Chat'),
        throwsStateError,
      );
    },
  );

  test('rejects database paths outside the managed directory', () async {
    await expectLater(
      index.remember(Uri.parse('https://hs.test'), '@a:hs', 'A', '../other'),
      throwsArgumentError,
    );
  });
}
