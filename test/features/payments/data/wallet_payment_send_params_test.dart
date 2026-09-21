import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/data/wallet_payment_send_params.dart';
import 'package:n42_wallet/features/payments/domain/payment_amount.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  const adapter = WalletPaymentSendParamsAdapter();
  const from = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1';
  const recipient = '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2';
  const contract = '0xccccccccccccccccccccccccccccccccccccccc3';

  CoinModel coin({
    Object chainId = 1,
    Object testChainId = 11155111,
    Object decimals = 18,
    Object? legacyDecimals,
    bool includeLegacyDecimals = false,
    bool isContract = false,
    bool isTest = false,
    String mainContract = '',
    String testContract = '',
    Object service = 'https://main.example',
    Object testService = 'https://test.example',
    String path = "m/44'/60'/0'/0/9",
    int pathIndex = 0,
    String address = from,
    String? privateKey,
  }) {
    final raw = <String, dynamic>{
      'mKey': isContract ? 'USDC' : 'ETH',
      'coinType': 'ETH',
      'blockchainType': 'Ethereum',
      'chainId': chainId,
      'chainId_test': testChainId,
      'service': service,
      'service_test': testService,
      'decimals': decimals,
      'isContract': isContract,
      'contract': mainContract,
      'contract_test': testContract,
      'path': {'legacy': path},
      'privateKey': 'must-not-propagate',
      'unknownNested': {'privateKey': 'also-must-not-propagate'},
    };
    if (includeLegacyDecimals) raw['decimal'] = legacyDecimals;
    return CoinModel.fromMap(raw)
      ..isTest = isTest
      ..address = address
      ..addrType = 'legacy'
      ..pathIndex = pathIndex
      ..privateKey = privateKey;
  }

  PaymentAsset asset({
    String network = '1',
    String? contractAddress,
    int decimals = 18,
  }) => PaymentAsset(
    id: PaymentAssetId(
      namespace: 'eip155',
      network: network,
      contract: contractAddress,
    ),
    symbol: contractAddress == null ? 'ETH' : 'USDC',
    decimals: decimals,
  );

  WalletPaymentSendParamsException failure({
    required CoinModel selected,
    required PaymentAmount amount,
    String expectedFrom = from,
    String to = recipient,
  }) {
    try {
      adapter.build(
        coins: [selected],
        amount: amount,
        expectedFromAddress: expectedFrom,
        recipient: to,
      );
      fail('Expected adapter to reject input');
    } on WalletPaymentSendParamsException catch (error) {
      return error;
    }
  }

  test('native params carry exact units only in native override', () {
    final selected = coin(pathIndex: 0);
    final exact = BigInt.parse('9007199254740993');
    final params = adapter.build(
      coins: [selected],
      amount: PaymentAmount(asset: asset(), units: exact),
      expectedFromAddress: from.toUpperCase(),
      recipient: recipient,
    );

    expect(params.amount, exact / BigInt.from(10).pow(18));
    expect(params.valueWeiOverride, exact);
    expect(params.tokenValueWeiOverride, isNull);
    expect(params.contractAddress, isEmpty);
    expect(params.tokenDecimals, 0);
    expect(params.path, "m/44'/60'/0'/0/0");
    expect(params.privateKey, isNull);
    expect(params.isTest, isFalse);
    expect(EvmSender.resolveChainId(params.chainConfig, isTest: false), 1);
    expect(
      EvmSender.resolveRpcOverride(params.chainConfig, isTest: false),
      'https://main.example',
    );
  });

  test('ERC20 testnet params select only test identity and exact override', () {
    final selected = coin(
      decimals: '6',
      isContract: true,
      isTest: true,
      mainContract: '0xddddddddddddddddddddddddddddddddddddddd4',
      testContract: contract,
      pathIndex: 7,
    );
    final exact = BigInt.parse('1234567');
    final params = adapter.build(
      coins: [selected],
      amount: PaymentAmount(
        asset: asset(
          network: '11155111',
          contractAddress: contract,
          decimals: 6,
        ),
        units: exact,
      ),
      expectedFromAddress: from,
      recipient: recipient,
    );

    expect(params.valueWeiOverride, isNull);
    expect(params.tokenValueWeiOverride, exact);
    expect(params.contractAddress, contract);
    expect(params.tokenDecimals, 6);
    expect(params.path, "m/44'/60'/0'/0/7");
    expect(params.isTest, isTrue);
    expect(params.chainConfig, isNot(contains('chainId')));
    expect(params.chainConfig, isNot(contains('service')));
    expect(
      EvmSender.resolveChainId(params.chainConfig, isTest: true),
      11155111,
    );
  });

  test('chain snapshot is immutable and contains only approved fields', () {
    final selected = coin();
    final params = adapter.build(
      coins: [selected],
      amount: PaymentAmount(asset: asset(), units: BigInt.one),
      expectedFromAddress: from,
      recipient: recipient,
    );

    expect(params.chainConfig, isNot(contains('privateKey')));
    expect(params.chainConfig, isNot(contains('unknownNested')));
    expect(() => params.chainConfig!['chainId'] = 2, throwsUnsupportedError);
    selected.coin['chainId'] = 2;
    expect(params.chainConfig!['chainId'], 1);
  });

  test('rejects zero and overflowing exact units', () {
    final selected = coin();
    for (final units in [BigInt.zero, BigInt.one << 256]) {
      expect(
        failure(
          selected: selected,
          amount: PaymentAmount(asset: asset(), units: units),
        ).error,
        WalletPaymentSendParamsError.invalidAmount,
      );
    }
    expect(
      () => PaymentAmount(asset: asset(), units: -BigInt.one),
      throwsArgumentError,
    );
  });

  test('rejects precision mismatch, invalid type and conflicting alias', () {
    final cases = <CoinModel>[
      coin(decimals: 6),
      coin(decimals: 18.0),
      coin(decimals: 18, includeLegacyDecimals: true, legacyDecimals: 6),
    ];
    for (final selected in cases) {
      expect(
        failure(
          selected: selected,
          amount: PaymentAmount(asset: asset(), units: BigInt.one),
        ).error,
        WalletPaymentSendParamsError.precisionMismatch,
      );
    }
  });

  test('rejects invalid, zero, or mismatched EVM addresses', () {
    final amount = PaymentAmount(asset: asset(), units: BigInt.one);
    expect(
      failure(selected: coin(), amount: amount, to: 'not-an-address').error,
      WalletPaymentSendParamsError.invalidAddress,
    );
    expect(
      failure(
        selected: coin(),
        amount: amount,
        to: '0x0000000000000000000000000000000000000000',
      ).error,
      WalletPaymentSendParamsError.invalidAddress,
    );
    expect(
      failure(selected: coin(), amount: amount, expectedFrom: recipient).error,
      WalletPaymentSendParamsError.fromAddressMismatch,
    );
  });

  test('rejects imported-key wallets before exposing the key', () {
    expect(
      failure(
        selected: coin(privateKey: 'secret'),
        amount: PaymentAmount(asset: asset(), units: BigInt.one),
      ).error,
      WalletPaymentSendParamsError.importedKeyUnsupported,
    );
  });

  test('rejects missing, malformed and out-of-range derivation data', () {
    final amount = PaymentAmount(asset: asset(), units: BigInt.one);
    final cases = <CoinModel>[
      coin(path: ''),
      coin(path: "m/44'/60'/bad/0/0"),
      coin(path: "m/44'/2147483648'/0/0/0"),
      coin(pathIndex: -1),
      coin(pathIndex: 0x80000000),
    ];
    for (final selected in cases) {
      expect(
        failure(selected: selected, amount: amount).error,
        WalletPaymentSendParamsError.invalidDerivation,
      );
    }
  });

  test('rejects chain ID beyond signed machine-int range', () {
    const tooLarge = '9223372036854775808';
    final selected = coin(chainId: tooLarge);
    expect(
      failure(
        selected: selected,
        amount: PaymentAmount(
          asset: asset(network: tooLarge),
          units: BigInt.one,
        ),
      ).error,
      WalletPaymentSendParamsError.invalidChainConfig,
    );
  });

  test(
    'rejects missing or unsafe RPC instead of allowing backend fallback',
    () {
      final amount = PaymentAmount(asset: asset(), units: BigInt.one);
      for (final selected in <CoinModel>[
        coin(service: ''),
        coin(service: 'ftp://rpc.example'),
        coin(service: 'https://user:secret@rpc.example'),
        coin(service: 'https://@rpc.example'),
        coin(service: 'https://rpc.example:not-a-port'),
        coin(service: 'https://rpc.example/#fragment'),
        coin(service: 42),
      ]) {
        expect(
          failure(selected: selected, amount: amount).error,
          WalletPaymentSendParamsError.invalidChainConfig,
        );
      }
    },
  );
}
