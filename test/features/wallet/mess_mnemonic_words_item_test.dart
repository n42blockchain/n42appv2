// Tests for MessMnemonicWordsItem (mnemonic word selection model).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/mess_mnemonic_words_item.dart';

void main() {
  group('MessMnemonicWordsItem constructor', () {
    test('sets word, isSelected, and index correctly', () {
      final item = MessMnemonicWordsItem('abandon', false, 0);
      expect(item.word, 'abandon');
      expect(item.isSelected, isFalse);
      expect(item.index, 0);
    });

    test('isSelected can be true', () {
      final item = MessMnemonicWordsItem('zoo', true, 23);
      expect(item.isSelected, isTrue);
      expect(item.word, 'zoo');
      expect(item.index, 23);
    });

    test('fields are mutable — can change isSelected', () {
      final item = MessMnemonicWordsItem('ability', false, 1);
      item.isSelected = true;
      expect(item.isSelected, isTrue);
    });

    test('fields are mutable — can change word', () {
      final item = MessMnemonicWordsItem('ability', false, 1);
      item.word = 'above';
      expect(item.word, 'above');
    });

    test('fields are mutable — can change index', () {
      final item = MessMnemonicWordsItem('act', false, 5);
      item.index = 10;
      expect(item.index, 10);
    });

    test('index 0 is a valid BIP-39 first word position', () {
      final item = MessMnemonicWordsItem('abandon', false, 0);
      expect(item.index, 0);
    });

    test('index 23 is a valid BIP-39 last word position (24-word mnemonic)', () {
      final item = MessMnemonicWordsItem('zoo', false, 23);
      expect(item.index, 23);
    });
  });
}
