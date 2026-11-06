import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_client.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation_receipt.dart';
import 'package:n42_wallet/features/wallet/api/sender/aa_transfer_handler.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

const _owner = '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const _account = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _other = '0xcccccccccccccccccccccccccccccccccccccccc';
const _basePath = "m/44'/60'/0'/0/0";

class _Wallet extends WalletActionProvider {
  WalletInfo current = WalletInfo()..mnemonic = 'fixture mnemonic';
  final coin = CoinModel()
    ..coin = {
      'path': {'legacy': _basePath},
    }
    ..addrType = 'legacy'
    ..pathIndex = 2;
  @override
  bool get isWalletReady => true;
  @override
  String get userUUID => 'owner-session';
  @override
  String get walletDataOwnerUuid => 'owner-session';
  @override
  WalletInfo get walletInfo => current;
}

class _Signer extends Trustdart {
  String address = _owner;
  void Function()? onDerive;
  void Function()? onSign;
  final paths = <String>[];
  final mnemonics = <String>[];
  int signatures = 0;
  @override
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async {
    expect(coin, 'ETH');
    paths.add(path);
    onDerive?.call();
    return {'legacy': address};
  }

  @override
  Future<String> signMessage(
    String coin,
    String path,
    String txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    expect(coin, 'ETH');
    expect(path, paths.single);
    signatures++;
    mnemonics.add(mnemonic);
    onSign?.call();
    return '0x${'11' * 64}1b';
  }
}

class _Api extends TokenViewApi {
  String? rpcUsed;
  @override
  Future<MessageModel?> getGasPrice(
    String blockchain,
    String coinType, {
    bool isTest = false,
    String? rpc,
    String signMessage = '',
  }) async {
    rpcUsed = rpc;
    return MessageModel()..data = BigInt.from(100);
  }
}

class _Bundler extends BundlerClient {
  _Bundler()
    : super(
        bundlerUrl: 'https://unused.invalid',
        entryPoint: AAConfig.entryPointV08,
      );
  int chain = 1;
  int sends = 0;
  int closes = 0;
  UserOperation? submitted;
  void Function()? onEstimate;
  @override
  Future<BigInt> getChainId() async => BigInt.from(chain);
  @override
  Future<GasEstimateResult> estimateUserOperationGas(UserOperation op) async {
    onEstimate?.call();
    return GasEstimateResult(
      verificationGasLimit: BigInt.from(100000),
      callGasLimit: BigInt.from(100000),
      preVerificationGas: BigInt.from(50000),
    );
  }

  @override
  Future<String> sendUserOperation(UserOperation op) async {
    sends++;
    submitted = op;
    return '0x${'12' * 32}';
  }

  @override
  Future<UserOperationReceipt> waitForReceipt(
    String hash, {
    Duration? timeout,
    Duration? pollingInterval,
  }) async => throw ReceiptTimeoutError(hash);
  @override
  void dispose() {
    closes++;
    super.dispose();
  }
}

class _Handler extends AATransferHandler {
  _Handler(
    this.wallet,
    this.api,
    this.map,
    _Signer signer,
    BundlerClient Function(AAChainConfig, String?) factory,
  ) : super(
        'ETH',
        signer: signer,
        coinModelReader: (_) => wallet.coin,
        bundlerFactory: factory,
      );
  final _Wallet wallet;
  final _Api api;
  final Map<String, dynamic> map;
  @override
  WalletActionProvider get walletProvider => wallet;
  @override
  TokenViewApi get tokenViewApi => api;
  @override
  Map<String, dynamic>? getChainMap(String symbol) => map;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previous = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = previous);
  for (final scenario in [
    'mainnet',
    'gas mainnet',
    'gas testnet',
    'testnet',
    'testnet deployment',
    'mainnet deployment',
    'private key',
    'literal path',
    'missing key',
    'passkey',
    'wrong owner',
    'wrong sender',
    'wrong account chain',
    'wrong RPC chain',
    'wrong bundler chain',
    'owner during derive',
    'owner during nonce',
    'owner during estimate',
    'owner during sign',
    'key during estimate',
    'path during estimate',
    'disposed',
  ]) {
    test('AA signer and network: $scenario', () async {
      final wallet = _Wallet();
      if (scenario == 'missing key') wallet.current.mnemonic = '';
      final signer = _Signer();
      final api = _Api();
      final bundler = _Bundler();
      final testnet =
          scenario.startsWith('testnet') || scenario == 'gas testnet';
      final chainId = testnet ? 11155111 : 1;
      final requests = <String>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final rpc = 'http://127.0.0.1:${server.port}';
      server.listen((request) async {
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        requests.add(body['method'] as String);
        if (scenario == 'owner during nonce' && body['method'] == 'eth_call') {
          wallet.current = WalletInfo()..mnemonic = 'replacement';
        }
        final result = body['method'] == 'eth_chainId'
            ? '0x${(scenario == 'wrong RPC chain' ? 137 : chainId).toRadixString(16)}'
            : '0x0';
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
        );
        await request.response.close();
      });
      AAChainConfig? selectedConfig;
      final handler = _Handler(
        wallet,
        api,
        {
          'baseInfo': {
            'service': rpc,
            'service_test': rpc,
            'path': {'legacy': _basePath},
          },
        },
        signer,
        (config, key) {
          selectedConfig = config;
          bundler.chain = scenario == 'wrong bundler chain'
              ? 137
              : config.chainId;
          return bundler;
        },
      );
      addTearDown(handler.dispose);
      if (scenario == 'wrong owner') signer.address = _other;
      if (scenario == 'owner during derive') {
        signer.onDerive = () {
          wallet.current = WalletInfo();
        };
      }
      if (scenario == 'owner during sign') {
        signer.onSign = () {
          wallet.current = WalletInfo();
        };
      }
      bundler.onEstimate = () {
        if (scenario == 'owner during estimate') wallet.current = WalletInfo();
        if (scenario == 'key during estimate') {
          wallet.current.mnemonic = 'replacement';
        }
        if (scenario == 'path during estimate') wallet.coin.pathIndex = 3;
      };
      if (scenario == 'disposed') handler.dispose();
      final params = AATransferParams(
        chainSymbol: 'ETH',
        fromAddress: scenario == 'wrong sender' ? _other : _account,
        toAddress: _other,
        value: 0.01,
        isTest: testnet,
        privateKey: scenario == 'private key' ? 'fixture private key' : null,
        chainMap: {
          'path': scenario == 'literal path'
              ? "m/44'/60'/0'/0/5"
              : {'legacy': _basePath},
        },
        smartAccount: SmartAccount(
          address: _account,
          type: SmartAccountType.simpleAccount,
          ownerAddress: _owner,
          state: scenario.endsWith('deployment')
              ? SmartAccountState.notDeployed
              : SmartAccountState.deployed,
          signerType: scenario == 'passkey'
              ? SignerType.passkey
              : SignerType.eoa,
          chainId: scenario == 'wrong account chain' ? 137 : chainId,
          salt: BigInt.zero,
          factoryAddress: _other,
          createdAt: DateTime.utc(2026),
        ),
      );
      if (scenario.startsWith('gas ')) {
        final quote = await handler.estimateGas(params);
        expect(quote.errorMessage, isNull);
        expect(quote.totalFee, greaterThan(BigInt.zero));
        expect(selectedConfig!.chainId, chainId);
        expect(api.rpcUsed, rpc);
        expect(signer.paths, isEmpty);
        expect(signer.signatures, 0);
        expect(bundler.sends, 0);
        expect(bundler.closes, 1);
        return;
      }
      final result = await handler.transfer(params);
      final sent =
          [
            'mainnet',
            'mainnet deployment',
            'private key',
            'literal path',
          ].contains(scenario) ||
          testnet;
      expect(
        result.error,
        isTrue,
      ); // Successful submission still awaits a receipt.
      expect(bundler.sends, sent ? 1 : 0);
      expect(
        signer.signatures,
        sent || scenario == 'owner during sign' ? 1 : 0,
      );
      if (sent) {
        expect((result.data as Map)['isPending'], isTrue);
        expect(bundler.submitted!.sender, _account);
        expect(selectedConfig!.chainId, chainId);
        expect(
          selectedConfig!.bundlerUrl,
          AAConfig.getChainConfig(
            testnet ? 'SEPOLIA' : 'ETH',
            isTestnet: testnet,
          )!.bundlerUrl,
        );
        expect(signer.paths, [
          scenario == 'literal path' ? "m/44'/60'/0'/0/5" : "m/44'/60'/0'/0/2",
        ]);
        expect(signer.mnemonics, [
          scenario == 'private key' ? '' : 'fixture mnemonic',
        ]);
        expect(
          bundler.submitted!.initCode?.isNotEmpty ?? false,
          scenario.endsWith('deployment'),
        );
        expect(api.rpcUsed, rpc);
        expect(bundler.closes, 1);
      }
      if ([
        'wrong sender',
        'wrong owner',
        'wrong account chain',
        'owner during derive',
        'disposed',
      ].contains(scenario)) {
        expect(requests, isEmpty);
      }
    });
  }
}
