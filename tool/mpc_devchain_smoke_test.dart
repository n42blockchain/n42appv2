// Explicit local Anvil acceptance; outside the default test/ suite.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _LocalProvider implements MpcProvider {
  // Public secp256k1 test vector. Only used on an owned, disposable Anvil.
  final key = EthPrivateKey.fromHex('1'.padLeft(64, '0'));
  @override
  String get providerId => 'local-acceptance';
  @override
  String get currentAddress => key.address.with0x;
  @override
  bool get isLoggedIn => true;
  @override
  bool get isInitialized => true;
  @override
  Future<MpcSignResult> signTransaction(Uint8List preimage) async {
    final signature = key.signToUint8List(preimage);
    return MpcSignResult(
      signature: signature,
      signatureHex: '0x${bytesToHex(signature)}',
    );
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> logout() async {}
  @override
  void dispose() {}
  @override
  Future<List<String>> getRecoveryFactors() async => [];
  @override
  Future<MpcLoginResult> login(MpcLoginType type, {String? hint}) =>
      throw UnsupportedError('fixture');
  @override
  Future<MpcSignResult> signMessage(Uint8List messageHash) =>
      throw UnsupportedError('fixture');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'MPC routing mines exact native and ERC20 transfers on owned Anvil',
    () async {
      final uri = Uri.tryParse(
        Platform.environment['N42_QA_DEVCHAIN_RPC'] ?? '',
      );
      if (uri == null ||
          uri.scheme != 'http' ||
          uri.host != '127.0.0.1' ||
          uri.port != 18549 ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment) {
        throw StateError(
          'Explicit owned Anvil at http://127.0.0.1:18549 required',
        );
      }
      final artifactPath = Platform.environment['N42_QA_TOKEN_ARTIFACT'];
      if (artifactPath == null) {
        throw StateError('Compiled QA token artifact required');
      }
      final previous = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previous);
      final transport = http.Client();
      addTearDown(transport.close);
      final client = Web3Client(uri.toString(), transport);
      addTearDown(client.dispose);
      var rpcId = 0;
      Future<dynamic> rpc(String method, List<Object?> params) async {
        final response = await transport.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': ++rpcId,
            'method': method,
            'params': params,
          }),
        );
        final body = jsonDecode(response.body) as Map;
        if (response.statusCode != 200 || body['error'] != null) {
          throw StateError('Local RPC failed: $method');
        }
        return body['result'];
      }

      expect(await rpc('eth_chainId', []), '0x7a69');
      expect(await rpc('web3_clientVersion', []), startsWith('anvil/'));
      await S.load(const Locale('en'));
      final provider = _LocalProvider();
      await rpc('anvil_setBalance', [
        provider.currentAddress,
        '0x${(BigInt.from(10).pow(22)).toRadixString(16)}',
      ]);
      final recipient = EthereumAddress.fromHex('0x${'35' * 20}');
      final exact = BigInt.parse('1000000000000000001');
      final wallet = WalletInfo()
        ..isMpc = true
        ..mpcProvider = provider.providerId
        ..mpcUserId = 'local-only'
        ..coinInfo = {
          'ETH': {'address': provider.currentAddress},
        };
      final sender = EvmSender(
        readWallet: () => wallet,
        ownerIdentity: () => wallet,
        resolveMpcProvider: (_) => provider,
        readMnemonic: () =>
            throw StateError('Local MPC must not read local wallet secrets'),
      );
      final evidence = await Directory.systemTemp.createTemp('n42-mpc-ledger-');
      addTearDown(() => evidence.delete(recursive: true));
      final journal = File('${evidence.path}/prepared.json');
      final hashes = <String>[];
      Future<void> persist(String hash) async {
        hashes.add(hash);
        await journal.writeAsString(jsonEncode(hashes), flush: true);
      }

      Future<TransactionReceipt> receipt(String hash) async {
        for (var i = 0; i < 50; i++) {
          final value = await client.getTransactionReceipt(hash);
          if (value != null) {
            expect(value.status, isTrue);
            return value;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        throw StateError('Transaction was not mined');
      }

      SendParams request({String contract = ''}) => SendParams(
        coinType: 'ETH',
        fromAddress: provider.currentAddress,
        toAddress: recipient.with0x,
        amount: 0,
        decimals: 18,
        path: '',
        isTest: true,
        chainConfig: {'chainId_test': 31337, 'service_test': uri.toString()},
        contractAddress: contract,
        tokenDecimals: 18,
        valueWeiOverride: contract.isEmpty ? exact : null,
        tokenValueWeiOverride: contract.isEmpty ? null : exact,
        beforeBroadcast: persist,
      );
      final nativeBefore = (await client.getBalance(recipient)).getInWei;
      final nativeOwnerBefore = (await client.getBalance(provider.key.address))
          .getInWei;
      final native = await sender.send(request());
      expect(native.success, isTrue, reason: native.error);
      expect(native.txHash, hashes.single);
      final nativeReceipt = await receipt(native.txHash!);
      final rawReceipt =
          await rpc('eth_getTransactionReceipt', [native.txHash!]) as Map;
      final effectiveGasPrice = BigInt.parse(
        (rawReceipt['effectiveGasPrice'] as String).substring(2),
        radix: 16,
      );
      expect(nativeReceipt.gasUsed, BigInt.from(21000));
      expect(
        nativeOwnerBefore -
            (await client.getBalance(provider.key.address)).getInWei,
        exact + nativeReceipt.gasUsed! * effectiveGasPrice,
      );
      expect(
        (await client.getBalance(recipient)).getInWei - nativeBefore,
        exact,
      );

      final artifact =
          jsonDecode(await File(artifactPath).readAsString()) as Map;
      final deployment = await client.sendTransaction(
        provider.key,
        Transaction(
          data: hexToBytes((artifact['bytecode'] as Map)['object'] as String),
          maxGas: 500000,
        ),
        chainId: 31337,
      );
      final deployed = await receipt(deployment);
      expect(deployed.contractAddress, isNotNull);
      final token = DeployedContract(
        ContractAbi.fromJson(jsonEncode(artifact['abi']), 'MpcQaToken'),
        deployed.contractAddress!,
      );
      Future<BigInt> balance(EthereumAddress account) async =>
          (await client.call(
                contract: token,
                function: token.function('balanceOf'),
                params: [account],
              )).single
              as BigInt;
      final tokenBefore = await balance(recipient);
      final ownerBefore = await balance(provider.key.address);
      final sentToken = await sender.send(
        request(contract: deployed.contractAddress!.with0x),
      );
      expect(sentToken.success, isTrue, reason: sentToken.error);
      await receipt(sentToken.txHash!);
      expect(await balance(recipient) - tokenBefore, exact);
      expect(ownerBefore - await balance(provider.key.address), exact);
      expect(hashes.toSet(), hasLength(2));
      expect(jsonDecode(await journal.readAsString()), hashes);
      final output = {
        'chain_id': 31337,
        'node_version': await rpc('web3_clientVersion', []),
        'native_tx': native.txHash,
        'token_deployment_tx': deployment,
        'token_tx': sentToken.txHash,
        'native_and_token_exact_units': exact.toString(),
        'mined_receipts': 3,
        'durable_transfer_hashes': 2,
        'native_fee_accounting_checked': true,
        'erc20_sender_recipient_balances_checked': true,
        'passed': true,
        'scope': 'owned Anvil and deterministic provider; not live social-provider or public-network acceptance',
      };
      final outputPath = Platform.environment['N42_QA_DEVCHAIN_RESULT'];
      if (outputPath != null) {
        await File(outputPath).writeAsString(jsonEncode(output), flush: true);
      }
      // ignore: avoid_print
      print(jsonEncode(output));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
