import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';

void main() {
  const address = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';

  PaymentAssetId evm({String network = '1', String? contract = address}) =>
      PaymentAssetId(namespace: 'eip155', network: network, contract: contract);

  test(
    'same display symbol cannot merge assets across networks or contracts',
    () {
      final ethereum = PaymentAsset(id: evm(), symbol: 'USDC', decimals: 6);
      final base = PaymentAsset(
        id: evm(network: '8453'),
        symbol: 'USDC',
        decimals: 6,
      );
      final otherContract = PaymentAsset(
        id: evm(contract: '0x1111111111111111111111111111111111111111'),
        symbol: 'USDC',
        decimals: 6,
      );
      expect(ethereum.symbol, base.symbol);
      expect({ethereum.id, base.id, otherContract.id}, hasLength(3));
      final balances = {ethereum.id: BigInt.one, base.id: BigInt.two};
      expect(balances[ethereum.id], BigInt.one);
      expect(balances[base.id], BigInt.two);
    },
  );

  test('EIP-155 normalizes numeric chain IDs and address case', () {
    final canonical = evm();
    final alternate = PaymentAssetId(
      namespace: 'EIP155',
      network: '0001',
      contract: address.toUpperCase(),
    );
    expect(alternate, canonical);
    expect(alternate.hashCode, canonical.hashCode);
    expect(alternate.network, '1');
    expect(alternate.contract, address);
    expect(alternate.canonicalId, 'eip155:1/contract:$address');
    expect(alternate.toString(), alternate.canonicalId);
  });

  test('non-EVM networks and addresses retain case-sensitive identity', () {
    for (final namespace in ['solana', 'tron']) {
      PaymentAssetId id(String network, String contract) => PaymentAssetId(
        namespace: namespace,
        network: network,
        contract: contract,
      );
      final original = id('NetworkA', 'MintABC');
      expect(original, isNot(id('networka', 'MintABC')));
      expect(original, isNot(id('NetworkA', 'mintabc')));
      expect(original, id('NetworkA', 'MintABC'));
    }
  });

  test(
    'namespace is part of identity and native does not alias a contract',
    () {
      final native = evm(contract: null);
      expect(native.isNative, isTrue);
      expect(native, isNot(evm()));
      expect(native.canonicalId, 'eip155:1/native');
      final otherNamespace = PaymentAssetId(
        namespace: 'other',
        network: '1',
        contract: address,
      );
      expect(otherNamespace, isNot(evm()));
      final namedNative = PaymentAssetId(
        namespace: 'other',
        network: '1',
        contract: 'native',
      );
      final actualNative = PaymentAssetId(
        namespace: 'other',
        network: '1',
        contract: null,
      );
      expect(namedNative, isNot(actualNative));
      expect(namedNative.canonicalId, isNot(actualNative.canonicalId));
    },
  );

  test('malformed EVM chain references and contracts are rejected', () {
    for (final network in [
      '',
      '0',
      '000',
      '-1',
      '+1',
      '1.0',
      '1e3',
      ' 1',
      '1\n',
      'mainnet',
    ]) {
      expect(() => evm(network: network), throwsArgumentError, reason: network);
    }
    for (final contract in [
      '',
      '0x1234',
      '${address}0',
      address.replaceFirst('a', 'z'),
      '$address\n',
    ]) {
      expect(
        () => evm(contract: contract),
        throwsArgumentError,
        reason: contract,
      );
    }
  });

  test(
    'identity components cannot inject delimiters or invisible whitespace',
    () {
      for (final namespace in ['', ' eip155', 'eip155:', '1chain', 'chain\n']) {
        expect(
          () => PaymentAssetId(
            namespace: namespace,
            network: '1',
            contract: null,
          ),
          throwsArgumentError,
        );
      }
      for (final network in ['a:b', 'a/b', 'a b', 'a\n']) {
        expect(
          () => PaymentAssetId(
            namespace: 'other',
            network: network,
            contract: null,
          ),
          throwsArgumentError,
        );
      }
      for (final contract in ['a:b', 'a/b', 'a b']) {
        expect(
          () => PaymentAssetId(
            namespace: 'other',
            network: '1',
            contract: contract,
          ),
          throwsArgumentError,
        );
      }
    },
  );

  test('asset metadata validates precision without changing identity', () {
    for (final decimals in [-1, 256]) {
      expect(
        () => PaymentAsset(id: evm(), symbol: 'TEST', decimals: decimals),
        throwsRangeError,
      );
    }
    expect(
      () => PaymentAsset(id: evm(), symbol: ' ', decimals: 6),
      throwsArgumentError,
    );
    final first = PaymentAsset(id: evm(), symbol: 'TEST', decimals: 0);
    final renamed = PaymentAsset(id: evm(), symbol: 'RENAMED', decimals: 255);
    expect(first.id, renamed.id);
    expect(first.decimals, 0);
    expect(renamed.decimals, 255);
  });
}
