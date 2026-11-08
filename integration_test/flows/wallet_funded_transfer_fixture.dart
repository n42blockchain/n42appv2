import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';

import '../../test/helpers/widget_test_helpers.dart';
import '../fixtures/disposable_transfer_config.dart';

const _enabled =
    bool.fromEnvironment('N42_FUNDED_TX_QA') &&
    bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');

/// Real app sender/native signing against a separately owned disposable node.
/// Does not establish public-network, physical-device or full send-page QA.
void registerWalletFundedTransferFixture() {
  testWidgets(
    _enabled ? 'TX-06 sends a disposable testnet transaction' : 'TX-06 [BLOCKED: requires explicit owned-chain and simulator configuration]',
    (tester) async {
      final device = DeviceInfoPlugin();
      final virtual = Platform.isAndroid
          ? !(await device.androidInfo).isPhysicalDevice
          : Platform.isIOS && !(await device.iosInfo).isPhysicalDevice;
      expect(virtual, isTrue, reason: 'Disposable simulators only');
      if (!virtual) return;
      late DisposableTransferConfig config;
      try {
        config = DisposableTransferConfig.fromJson(
          jsonDecode(const String.fromEnvironment('N42_FUNDED_TX_CONFIG'))
              as Map<String, dynamic>,
        );
      } catch (_) {
        throw StateError(
          'Disposable transfer configuration is missing or invalid',
        );
      }
      var approved = false;
      await tester.pumpWidget(
        wrapForTest(
          Scaffold(
            body: TextButton(
              onPressed: () => approved = true,
              child: const Text('Approve disposable test transfer'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve disposable test transfer'));
      expect(approved, isTrue);

      await tester.runAsync(() async {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 10);
        try {
          var requestId = 0;
          Future<dynamic> rpc(String method, List<dynamic> params) async {
            final request = await client
                .postUrl(config.rpc)
                .timeout(const Duration(seconds: 10));
            request.followRedirects = false;
            request.headers.contentType = ContentType.json;
            final id = ++requestId;
            request.write(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': id,
                'method': method,
                'params': params,
              }),
            );
            final response = await request.close().timeout(
              const Duration(seconds: 10),
            );
            if (response.statusCode != 200) {
              throw StateError('Disposable RPC HTTP failure');
            }
            var size = 0;
            final bytes = <int>[];
            await for (final chunk in response.timeout(
              const Duration(seconds: 10),
            )) {
              size += chunk.length;
              if (size > 1024 * 1024) {
                throw StateError('Disposable RPC response too large');
              }
              bytes.addAll(chunk);
            }
            final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
            if (data['id'] != id || data['error'] != null) {
              throw StateError('Disposable RPC rejected request');
            }
            return data['result'];
          }

          BigInt quantity(dynamic value) =>
              BigInt.parse((value as String).substring(2), radix: 16);
          Future<void> checkNetwork() async {
            expect(
              quantity(await rpc('eth_chainId', [])),
              BigInt.from(DisposableTransferConfig.chainId),
            );
            final genesis =
                await rpc('eth_getBlockByNumber', ['0x0', false]) as Map;
            expect(genesis['hash'], config.genesisHash);
            expect(await rpc('web3_clientVersion', []), config.clientVersion);
            expect(quantity(await rpc('net_peerCount', [])), BigInt.zero);
          }

          await checkNetwork();
          final beforeSender = quantity(
            await rpc('eth_getBalance', [config.sender, 'latest']),
          );
          final beforeRecipient = quantity(
            await rpc('eth_getBalance', [config.recipient, 'latest']),
          );
          expect(beforeSender >= BigInt.from(1000000000000000), isTrue);
          String? localHash;
          final sender = EvmSender(
            ownerIdentity: () => 'owned-disposable-transaction',
            readWallet: () => null,
          );
          final result = await sender.send(
            SendParams(
              coinType: 'ETH',
              fromAddress: config.sender,
              toAddress: config.recipient,
              amount: 0,
              decimals: 18,
              path: "m/44'/60'/0'/0/0",
              isTest: true,
              privateKey: config.walletPrivateKey,
              valueWeiOverride: BigInt.from(1000000),
              chainConfig: {
                'chainId_test': DisposableTransferConfig.chainId,
                'service_test': config.rpc.toString(),
              },
              beforeBroadcast: (hash) async {
                await checkNetwork();
                localHash = hash;
              },
              onBroadcastStarting: (_) => checkNetwork(),
            ),
          );
          expect(
            localHash != null,
            isTrue,
            reason: 'Sender must compute the hash before dispatch',
          );
          expect(result.txHash, localHash);
          Map? receipt;
          for (var i = 0; i < 60; i++) {
            receipt =
                await rpc('eth_getTransactionReceipt', [localHash]) as Map?;
            if (receipt != null) break;
            await Future<void>.delayed(const Duration(seconds: 1));
          }
          expect(receipt, isNotNull);
          expect(receipt!['status'], '0x1');
          expect(receipt['transactionHash'], localHash);
          final tx = await rpc('eth_getTransactionByHash', [localHash]) as Map;
          expect(
            (tx['from'] as String).toLowerCase(),
            config.sender.toLowerCase(),
          );
          expect(
            (tx['to'] as String).toLowerCase(),
            config.recipient.toLowerCase(),
          );
          expect(quantity(tx['value']), BigInt.from(1000000));
          final afterRecipient = quantity(
            await rpc('eth_getBalance', [config.recipient, 'latest']),
          );
          final afterSender = quantity(
            await rpc('eth_getBalance', [config.sender, 'latest']),
          );
          expect(afterRecipient - beforeRecipient, BigInt.from(1000000));
          final fee =
              quantity(receipt['gasUsed']) *
              quantity(receipt['effectiveGasPrice']);
          expect(beforeSender - afterSender, BigInt.from(1000000) + fee);
          await checkNetwork();
        } finally {
          client.close(force: true);
        }
      });
    },
    skip: !_enabled,
  );
}
