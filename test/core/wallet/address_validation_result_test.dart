// Tests for AddressValidationResult, AddressType, and
// AddressValidator.getAddressPreview — all pure Dart with no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/utils/address_validator.dart';

void main() {
  // ─────────────────────────────────────────────────
  // AddressType enum
  // ─────────────────────────────────────────────────

  group('AddressType enum', () {
    test('has 4 values: standard, contract, ens, multisig', () {
      expect(AddressType.values.length, 4);
      expect(AddressType.values, containsAll([
        AddressType.standard,
        AddressType.contract,
        AddressType.ens,
        AddressType.multisig,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // AddressValidationResult — default constructor
  // ─────────────────────────────────────────────────

  group('AddressValidationResult default constructor', () {
    test('can be constructed with only required field', () {
      const result = AddressValidationResult(isValid: true);
      expect(result.isValid, isTrue);
      expect(result.resolvedAddress, isNull);
      expect(result.errorMessage, isNull);
      expect(result.addressType, AddressType.standard);
      expect(result.isEnsResolved, isFalse);
      expect(result.ensName, isNull);
    });

    test('all optional fields can be set', () {
      const result = AddressValidationResult(
        isValid: true,
        resolvedAddress: '0xabc',
        addressType: AddressType.ens,
        isEnsResolved: true,
        ensName: 'vitalik.eth',
      );
      expect(result.resolvedAddress, '0xabc');
      expect(result.addressType, AddressType.ens);
      expect(result.isEnsResolved, isTrue);
      expect(result.ensName, 'vitalik.eth');
    });
  });

  // ─────────────────────────────────────────────────
  // AddressValidationResult.valid factory
  // ─────────────────────────────────────────────────

  group('AddressValidationResult.valid factory', () {
    test('isValid is true', () {
      final result = AddressValidationResult.valid('0x1234');
      expect(result.isValid, isTrue);
    });

    test('resolvedAddress equals provided address', () {
      final result = AddressValidationResult.valid('0xdeadbeef');
      expect(result.resolvedAddress, '0xdeadbeef');
    });

    test('errorMessage is null', () {
      final result = AddressValidationResult.valid('0xdeadbeef');
      expect(result.errorMessage, isNull);
    });

    test('default addressType is standard', () {
      final result = AddressValidationResult.valid('0x1234');
      expect(result.addressType, AddressType.standard);
    });

    test('addressType can be overridden to ens', () {
      final result = AddressValidationResult.valid(
        '0xresolved',
        type: AddressType.ens,
        isEns: true,
        ensName: 'user.eth',
      );
      expect(result.addressType, AddressType.ens);
      expect(result.isEnsResolved, isTrue);
      expect(result.ensName, 'user.eth');
    });

    test('isEnsResolved defaults to false', () {
      final result = AddressValidationResult.valid('0x1234');
      expect(result.isEnsResolved, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AddressValidationResult.invalid factory
  // ─────────────────────────────────────────────────

  group('AddressValidationResult.invalid factory', () {
    test('isValid is false', () {
      final result = AddressValidationResult.invalid('bad address');
      expect(result.isValid, isFalse);
    });

    test('errorMessage equals provided message', () {
      final result = AddressValidationResult.invalid('Address cannot be empty');
      expect(result.errorMessage, 'Address cannot be empty');
    });

    test('resolvedAddress is null', () {
      final result = AddressValidationResult.invalid('error');
      expect(result.resolvedAddress, isNull);
    });

    test('addressType defaults to standard', () {
      final result = AddressValidationResult.invalid('error');
      expect(result.addressType, AddressType.standard);
    });

    test('isEnsResolved is false', () {
      final result = AddressValidationResult.invalid('error');
      expect(result.isEnsResolved, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AddressValidator.getAddressPreview (pure static)
  // ─────────────────────────────────────────────────

  group('AddressValidator.getAddressPreview', () {
    test('short address (total <= prefix+suffix+3) returned as-is', () {
      // prefixLength=6, suffixLength=4 → threshold = 6+4+3 = 13 chars
      const addr = '0x123456789'; // 11 chars → as-is
      expect(AddressValidator.getAddressPreview(addr), addr);
    });

    test('exactly 13 chars returned as-is', () {
      const addr = '0x12345678abc'; // 13 chars
      expect(AddressValidator.getAddressPreview(addr), addr);
    });

    test('14-char address is shortened with ellipsis', () {
      const addr = '0x1234567890ab'; // 14 chars > threshold 13
      final result = AddressValidator.getAddressPreview(addr);
      expect(result, contains('...'));
    });

    test('standard 42-char Ethereum address is shortened', () {
      const addr = '0xAbCd1234567890abcdef1234567890ABCDEF1234';
      final result = AddressValidator.getAddressPreview(addr);
      // prefix (6) + '...' + suffix (4)
      expect(result, '0xAbCd...1234');
    });

    test('prefix is first 6 chars by default', () {
      const addr = '0xPREFIXSUFFIXXXXXXXX'; // longer than 13
      final result = AddressValidator.getAddressPreview(addr);
      expect(result.startsWith('0xPREF'), isTrue);
    });

    test('suffix is last 4 chars by default', () {
      const addr = '0x000000000000LAST';
      final result = AddressValidator.getAddressPreview(addr);
      expect(result.endsWith('LAST'), isTrue);
    });

    test('custom prefixLength and suffixLength are respected', () {
      const addr = '0xABCDEFGHIJKLMNOP'; // 18 chars
      final result = AddressValidator.getAddressPreview(
        addr,
        prefixLength: 4,
        suffixLength: 3,
      );
      // threshold: 4+3+3=10, addr is 18 → shorten
      expect(result, '0xAB...NOP');
    });

    test('empty string returns empty string', () {
      expect(AddressValidator.getAddressPreview(''), '');
    });

    test('very short address is returned as-is', () {
      expect(AddressValidator.getAddressPreview('0x1'), '0x1');
    });
  });
}
