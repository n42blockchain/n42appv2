import 'dart:typed_data';

import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';

import 'mpc_provider.dart';

/// Signs a fully prepared EVM transaction without exporting provider keys.
/// RPC preparation, review, durable persistence and broadcast remain the caller's
/// responsibility. A signature alone is never a successful transfer result.
class MpcEvmTransactionSigner {
  MpcEvmTransactionSigner(this.provider, {required this.isCurrent});

  final MpcProvider provider;
  final bool Function() isCurrent;

  Future<Uint8List> sign(
    Transaction transaction, {
    required int chainId,
  }) async {
    if (chainId <= 0 ||
        transaction.nonce == null ||
        transaction.nonce! < 0 ||
        transaction.maxGas == null ||
        transaction.maxGas! <= 0 ||
        transaction.value == null ||
        transaction.data == null ||
        (!transaction.isEIP1559 && transaction.gasPrice == null) ||
        (transaction.isEIP1559 &&
            (transaction.maxFeePerGas == null ||
                transaction.maxPriorityFeePerGas == null))) {
      throw ArgumentError(
        'A fully prepared replay-protected EVM transaction is required',
      );
    }
    final maxUint256 = (BigInt.one << 256) - BigInt.one;
    final amounts = [
      transaction.value,
      transaction.gasPrice,
      transaction.maxFeePerGas,
      transaction.maxPriorityFeePerGas,
    ];
    if (amounts.whereType<EtherAmount>().any(
          (amount) =>
              amount.getInWei < BigInt.zero || amount.getInWei > maxUint256,
        ) ||
        (transaction.isEIP1559 &&
            transaction.maxPriorityFeePerGas!.getInWei >
                transaction.maxFeePerGas!.getInWei)) {
      throw ArgumentError('Invalid EVM amount or fee caps');
    }
    final address = provider.currentAddress;
    bool current() =>
        isCurrent() &&
        provider.isLoggedIn &&
        address != null &&
        provider.currentAddress?.toLowerCase() == address.toLowerCase();
    if (!current()) throw StateError('MPC signing session is unavailable');
    final expected = EthereumAddress.fromHex(address!);
    if (transaction.from != null && transaction.from != expected) {
      throw StateError('Transaction sender does not match the MPC account');
    }
    final preimage = Uint8List.fromList(
      transaction.getUnsignedSerialized(chainId: chainId),
    );
    final result = await provider.signTransaction(Uint8List.fromList(preimage));
    if (!current()) throw StateError('MPC signing session changed');
    final bytes = Uint8List.fromList(result.signature);
    if (bytes.length != 65) throw StateError('Invalid MPC signature length');
    final r = bytesToUnsignedInt(bytes.sublist(0, 32));
    final s = bytesToUnsignedInt(bytes.sublist(32, 64));
    final parity = bytes[64] >= 27 ? bytes[64] - 27 : bytes[64];
    final order = BigInt.parse(
      'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
      radix: 16,
    );
    if (parity > 1 ||
        r <= BigInt.zero ||
        r >= order ||
        s <= BigInt.zero ||
        s > (order >> 1)) {
      throw StateError('Invalid or noncanonical MPC signature');
    }
    final signature = MsgSignature(r, s, parity + 27);
    final recovered = EthereumAddress.fromHex(
      bytesToHex(
        keccak256(ecRecover(keccak256(preimage), signature)).sublist(12),
      ),
    );
    if (recovered != expected) {
      throw StateError('MPC signature belongs to another account');
    }
    final encoded = signTransactionRaw(
      transaction,
      _PreparedSignature(
        expected,
        preimage,
        chainId,
        transaction.isEIP1559,
        MsgSignature(
          r,
          s,
          transaction.isEIP1559 ? parity : chainId * 2 + 35 + parity,
        ),
      ),
      chainId: chainId,
    );
    if (!current()) throw StateError('MPC signing session changed');
    return encoded;
  }
}

class _PreparedSignature extends CredentialsWithKnownAddress {
  _PreparedSignature(
    this.address,
    this.preimage,
    this.chain,
    this.typed,
    this.signature,
  );
  @override
  final EthereumAddress address;
  final Uint8List preimage;
  final int chain;
  final bool typed;
  final MsgSignature signature;

  @override
  MsgSignature signToEcSignature(
    Uint8List payload, {
    int? chainId,
    bool isEIP1559 = false,
  }) {
    if (chainId != chain ||
        isEIP1559 != typed ||
        payload.length != preimage.length) {
      throw StateError('Transaction changed during MPC signing');
    }
    for (var i = 0; i < payload.length; i++) {
      if (payload[i] != preimage[i]) {
        throw StateError('Transaction changed during MPC signing');
      }
    }
    return signature;
  }
}
