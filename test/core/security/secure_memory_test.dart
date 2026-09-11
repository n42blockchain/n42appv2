import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_memory.dart';

void main() {
  test('sensitive text preserves UTF-8 including non-ASCII passwords', () {
    const text = '密码-é-🔑';
    final value = SecureString(text);
    expect(value.bytes, utf8.encode(text));
    expect(value.value, text);
    expect(value.toString(), isNot(contains(text)));
    final retainedBytes = value.bytes!;
    value.dispose();
    expect(retainedBytes, everyElement(0));
    expect(value.isDisposed, isTrue);
    expect(value.bytes, isNull);
    expect(() => value.value, throwsStateError);
    value.dispose(); // Disposing twice must remain safe.
  });

  test('constructing from bytes isolates the caller buffer before wiping', () {
    final original = Uint8List.fromList(utf8.encode('secret'));
    final value = SecureString.fromBytes(original);
    original[0] = 88;
    expect(value.value, 'secret');
    value.dispose();
    expect(original, utf8.encode('Xecret'));
  });

  test(
    'zeroing byte views wipes only the sensitive range in backing memory',
    () {
      final backing = Uint8List.fromList([9, 1, 2, 3, 9]);
      SecureMemory.zeroOut(Uint8List.sublistView(backing, 1, 4));
      expect(backing, [9, 0, 0, 0, 9]);
      final list = [1, 2, 3];
      SecureMemory.zeroOutList(list);
      expect(list, [0, 0, 0]);
      SecureMemory.zeroOutList([]);
      expect(SecureMemory.createSecureBytes(4), [0, 0, 0, 0]);
    },
  );

  test('byte comparison checks length and differences at either end', () {
    final a = Uint8List.fromList([1, 2, 3]);
    for (final other in [
      [0, 2, 3],
      [1, 2, 0],
      [1, 2],
      <int>[],
    ]) {
      expect(
        SecureMemory.constantTimeEquals(a, Uint8List.fromList(other)),
        isFalse,
      );
    }
    expect(
      SecureMemory.constantTimeEquals(a, SecureMemory.secureClone(a)),
      isTrue,
    );
    expect(SecureMemory.constantTimeEquals(Uint8List(0), Uint8List(0)), isTrue);
  });

  test('key disposal wipes retained bytes and prevents reuse or equality', () {
    final original = [11, 22, 33];
    final key = SecureKey.fromBytes(original);
    final same = SecureKey.fromBytes(original);
    expect(key.equals(same), isTrue);
    key[0] = 44;
    expect(key[0], 44);
    expect(original, [11, 22, 33]);
    expect(key.equals(same), isFalse);
    expect(key.toString(), 'SecureKey(length: 3)');
    final retained = key.bytes!;
    key.dispose();
    expect(retained, [0, 0, 0]);
    expect(key.isDisposed, isTrue);
    expect(key.length, 0);
    expect(key.bytes, isNull);
    expect(key[0], isNull);
    key[0] = 9;
    expect(key.equals(same), isFalse);
    expect(same.equals(key), isFalse);
    key.dispose();
    same.dispose();
  });

  test(
    'random and blank keys allocate independent buffers of requested size',
    () {
      final blank = SecureKey(32);
      final random = SecureKey.random(32);
      expect(blank.bytes, everyElement(0));
      expect(random.length, 32);
      expect(random.bytes, everyElement(inInclusiveRange(0, 255)));
      // No probabilistic assertions about entropy: this verifies buffer ownership.
      final retained = random.bytes!;
      random.dispose();
      expect(retained, everyElement(0));
      expect(SecureMemory.generateRandomBytes(0), isEmpty);
      blank.dispose();
    },
  );
}
