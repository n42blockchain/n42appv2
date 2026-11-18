import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:wallet/wallet.dart' as wallet;
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';

const _path = "m/44'/60'/0'/0/0";
const _chainId = 31337;

class _LoopbackHttp extends HttpOverrides {
  int deniedConnections = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (_) => 'DIRECT';
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      if (uri.host != '127.0.0.1' || proxyHost != null) {
        deniedConnections++;
        throw StateError('Recovery test attempted an external connection');
      }
      return Socket.startConnect(uri.host, uri.port);
    };
    return client;
  }
}

// Desktop fixture for the native signing boundary. Real BIP39/BIP32 and
// secp256k1, with the same Dart sender and RPC transport as the application.
class _LocalSigner extends Trustdart {
  int signatures = 0;

  static EthPrivateKey restore(String mnemonic, String pk) {
    if (pk.isNotEmpty) return EthPrivateKey.fromHex(pk);
    const hardened = 0x80000000;
    final seed = wallet.mnemonicToSeed(mnemonic.split(' '));
    final key = wallet.ExtendedPrivateKey.master(seed, wallet.xprv)
        .derive(hardened + 44)
        .derive(hardened + 60)
        .derive(hardened)
        .derive(0)
        .derive(0);
    return EthPrivateKey.fromHex(key.key.toRadixString(16).padLeft(64, '0'));
  }

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
    if (path != _path) throw StateError('Unexpected derivation path');
    return {'legacy': restore(mnemonic, pk).address.with0x};
  }

  @override
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    if (path != _path) throw StateError('Unexpected derivation path');
    signatures++;
    BigInt hex(String field) =>
        BigInt.parse(txData[field] as String, radix: 16);
    final transaction = Transaction(
      to: EthereumAddress.fromHex(txData['toAddress'] as String),
      nonce: hex('nonce').toInt(),
      maxGas: hex('gasLimit').toInt(),
      maxFeePerGas: EtherAmount.inWei(hex('gasPrice')),
      maxPriorityFeePerGas: EtherAmount.inWei(hex('gasPrice2')),
      value: EtherAmount.inWei(hex('amount')),
      data: hexToBytes(txData['msgData'] as String),
    );
    return bytesToHex(
      signTransactionRaw(
        transaction,
        restore(mnemonic, pk),
        chainId: hex('chainId').toInt(),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final endpoint = Platform.environment['N42_RECOVERY_LOOPBACK_RPC'];

  test(
    'restore mnemonic and private key and transfer through a replacement RPC',
    () async {
      final uri = Uri.parse(endpoint!);
      if (uri.scheme != 'http' ||
          uri.host != '127.0.0.1' ||
          !uri.hasPort ||
          uri.userInfo.isNotEmpty ||
          !(uri.path.isEmpty || uri.path == '/') ||
          uri.hasQuery ||
          uri.hasFragment) {
        fail('Only a plain IPv4 loopback Anvil endpoint is allowed');
      }
      final originalOverrides = HttpOverrides.current;
      final loopback = _LoopbackHttp();
      HttpOverrides.global = loopback;
      addTearDown(() => HttpOverrides.global = originalOverrides);
      await S.load(const Locale('en'));
      final client = Web3Client(uri.toString(), http.Client());
      addTearDown(client.dispose);
      expect(await client.getChainId(), BigInt.from(_chainId));

      final unavailable = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() => unavailable.close(force: true));
      unavailable.listen((request) async {
        await request.drain<void>();
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
      });

      final recipient = _LocalSigner.restore(
        wallet.generateMnemonic().join(' '),
        '',
      ).address;
      const value = 1000000;
      for (final useMnemonic in [true, false]) {
        final mnemonic = wallet.generateMnemonic().join(' ');
        final original = _LocalSigner.restore(mnemonic, '');
        final backupKey = useMnemonic ? null : bytesToHex(original.privateKey);
        final signer = _LocalSigner();
        final sender = EvmSender(
          trustdart: signer,
          readMnemonic: () => useMnemonic ? mnemonic : null,
          ownerIdentity: () => original.address.with0x,
          readWallet: () => null,
        );
        final restored = _LocalSigner.restore(
          useMnemonic ? mnemonic : '',
          backupKey ?? '',
        );
        expect(restored.address, original.address);
        await client.makeRPCCall<dynamic>('anvil_setBalance', [
          original.address.with0x,
          '0xde0b6b3a7640000',
        ]);
        SendParams params(String rpc) => SendParams(
          coinType: 'ETH',
          fromAddress: original.address.with0x,
          toAddress: recipient.with0x,
          amount: 0,
          decimals: 18,
          path: _path,
          isTest: true,
          privateKey: backupKey,
          chainConfig: {'chainId_test': _chainId, 'service_test': rpc},
          valueWeiOverride: BigInt.from(value),
        );
        final initial = await sender.send(
          params('http://127.0.0.1:${unavailable.port}'),
        );
        expect(initial.success, isFalse);
        expect(initial.txHash, isNull);
        expect(signer.signatures, 0);

        final sent = await sender.send(params(uri.toString()));
        expect(sent.success, isTrue);
        expect(signer.signatures, 1);
        final receipt = await client.getTransactionReceipt(sent.txHash!);
        expect(receipt?.status, isTrue);
        expect(receipt?.from, original.address);
        expect(receipt?.to, recipient);
      }
      expect(
        (await client.getBalance(recipient)).getInWei,
        BigInt.from(2 * value),
      );
      expect(loopback.deniedConnections, 0);
    },
    skip: endpoint == null
        ? 'Set N42_RECOVERY_LOOPBACK_RPC to a local Anvil'
        : false,
  );
}
