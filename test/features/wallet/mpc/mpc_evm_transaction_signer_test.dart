import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_evm_transaction_signer.dart';

class _Provider extends Mock implements MpcProvider {}

void main() {
  final key = EthPrivateKey.fromHex(
    '1'.padLeft(64, '0'),
  ); // Public test vector.
  final other = EthPrivateKey.fromHex('2'.padLeft(64, '0'));
  late _Provider provider;
  var current = true;
  setUpAll(() => registerFallbackValue(Uint8List(0)));
  setUp(() {
    current = true;
    provider = _Provider();
    when(() => provider.isLoggedIn).thenReturn(true);
    when(() => provider.currentAddress).thenReturn(key.address.with0x);
    when(() => provider.signTransaction(any())).thenAnswer((call) async {
      final bytes = key.signToUint8List(
        call.positionalArguments.first as Uint8List,
      );
      return MpcSignResult(signature: bytes, signatureHex: 'unused');
    });
  });
  Transaction transaction({bool typed = false, Uint8List? data}) => Transaction(
    from: key.address,
    to: EthereumAddress.fromHex('0x${'35' * 20}'),
    nonce: 7,
    maxGas: 65000,
    value: EtherAmount.inWei(BigInt.one),
    data: data ?? Uint8List.fromList([1, 2, 3]),
    gasPrice: typed ? null : EtherAmount.inWei(BigInt.from(3000000000)),
    maxFeePerGas: typed ? EtherAmount.inWei(BigInt.from(3000000000)) : null,
    maxPriorityFeePerGas: typed
        ? EtherAmount.inWei(BigInt.from(1000000000))
        : null,
  );
  MpcEvmTransactionSigner signer() =>
      MpcEvmTransactionSigner(provider, isCurrent: () => current);
  for (final typed in [false, true]) {
    for (final chain in [1, 8453]) {
      test(
        'canonical signed bytes match local signer: typed=$typed chain=$chain',
        () async {
          final tx = transaction(typed: typed);
          expect(
            await signer().sign(tx, chainId: chain),
            orderedEquals(signTransactionRaw(tx, key, chainId: chain)),
          );
        },
      );
    }
  }
  test('rejects a personal-message signature', () async {
    when(() => provider.signTransaction(any())).thenAnswer((call) async {
      final bytes = key.signPersonalMessageToUint8List(
        call.positionalArguments.first as Uint8List,
      );
      return MpcSignResult(signature: bytes, signatureHex: 'unused');
    });
    await expectLater(
      signer().sign(transaction(), chainId: 1),
      throwsStateError,
    );
  });
  test(
    'rejects a different signer even if provider claims expected address',
    () async {
      when(() => provider.signTransaction(any())).thenAnswer((call) async {
        final bytes = other.signToUint8List(
          call.positionalArguments.first as Uint8List,
        );
        return MpcSignResult(signature: bytes, signatureHex: 'unused');
      });
      await expectLater(
        signer().sign(transaction(), chainId: 1),
        throwsStateError,
      );
    },
  );
  test('rejects account/session replacement across signing await', () async {
    final pending = Completer<MpcSignResult>();
    Uint8List? preimage;
    when(() => provider.signTransaction(any())).thenAnswer((call) {
      preimage = Uint8List.fromList(
        call.positionalArguments.first as Uint8List,
      );
      return pending.future;
    });
    final future = signer().sign(transaction(), chainId: 1);
    final result = expectLater(future, throwsStateError);
    current = false;
    pending.complete(
      MpcSignResult(
        signature: key.signToUint8List(preimage!),
        signatureHex: 'unused',
      ),
    );
    await result;
  });
  test('rejects transaction mutation while provider signs', () async {
    final data = Uint8List.fromList([1, 2, 3]);
    when(() => provider.signTransaction(any())).thenAnswer((call) async {
      final bytes = key.signToUint8List(
        call.positionalArguments.first as Uint8List,
      );
      data[0] = 9;
      return MpcSignResult(signature: bytes, signatureHex: 'unused');
    });
    await expectLater(
      signer().sign(transaction(data: data), chainId: 1),
      throwsStateError,
    );
  });
  for (final length in [0, 64, 66]) {
    test('rejects signature length $length', () async {
      when(() => provider.signTransaction(any())).thenAnswer(
        (_) async =>
            MpcSignResult(signature: Uint8List(length), signatureHex: 'unused'),
      );
      await expectLater(
        signer().sign(transaction(), chainId: 1),
        throwsStateError,
      );
    });
  }
  test('rejects a valid but high-S malleable signature', () async {
    when(() => provider.signTransaction(any())).thenAnswer((call) async {
      final bytes = key.signToUint8List(
        call.positionalArguments.first as Uint8List,
      );
      final order = BigInt.parse(
        'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
        radix: 16,
      );
      final highS = order - bytesToUnsignedInt(bytes.sublist(32, 64));
      final encodedS = hexToBytes(highS.toRadixString(16).padLeft(64, '0'));
      bytes.setRange(32, 64, encodedS);
      bytes[64] = bytes[64] == 27 ? 28 : 27;
      return MpcSignResult(signature: bytes, signatureHex: 'unused');
    });
    await expectLater(
      signer().sign(transaction(), chainId: 1),
      throwsStateError,
    );
  });
  test('rejects a signature bound to another chain', () async {
    when(() => provider.signTransaction(any())).thenAnswer((_) async {
      final bytes = key.signToUint8List(
        transaction().getUnsignedSerialized(chainId: 8453),
      );
      return MpcSignResult(signature: bytes, signatureHex: 'unused');
    });
    await expectLater(
      signer().sign(transaction(), chainId: 1),
      throwsStateError,
    );
  });
  test('does not invoke a stale signing session', () async {
    current = false;
    await expectLater(
      signer().sign(transaction(), chainId: 1),
      throwsStateError,
    );
    verifyNever(() => provider.signTransaction(any()));
  });
  test('rejects fee caps with priority above maximum before signing', () async {
    final tx = transaction(typed: true).copyWith(
      maxPriorityFeePerGas: EtherAmount.inWei(BigInt.from(4000000000)),
    );
    await expectLater(signer().sign(tx, chainId: 1), throwsArgumentError);
    verifyNever(() => provider.signTransaction(any()));
  });
  test('rejects unprepared input before invoking provider', () async {
    await expectLater(
      signer().sign(Transaction(), chainId: 1),
      throwsArgumentError,
    );
    verifyNever(() => provider.signTransaction(any()));
  });
  test(
    'rejects chain IDs whose legacy v cannot be encoded exactly on Web',
    () async {
      await expectLater(
        signer().sign(transaction(), chainId: 4503599627370479),
        throwsArgumentError,
      );
      verifyNever(() => provider.signTransaction(any()));
    },
  );
  for (final field in ['nonce', 'gas']) {
    test('rejects $field outside the portable exact integer range', () async {
      final tx = transaction().copyWith(
        nonce: field == 'nonce' ? 9007199254740992 : 7,
        maxGas: field == 'gas' ? 9007199254740992 : 65000,
      );
      await expectLater(signer().sign(tx, chainId: 1), throwsArgumentError);
      verifyNever(() => provider.signTransaction(any()));
    });
  }
  test('rejects missing replay protection before invoking provider', () async {
    await expectLater(
      signer().sign(transaction(), chainId: 0),
      throwsArgumentError,
    );
    verifyNever(() => provider.signTransaction(any()));
  });
}
