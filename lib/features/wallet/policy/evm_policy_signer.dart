import 'package:sqflite/sqflite.dart' show Database;
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';

import 'restricted_signer.dart';

/// Offline EIP-155 signer for an isolated, host-owned EVM agent account.
/// Give the agent only the returned facade, never credentials or policy admin.
/// No RPC request or broadcast is made. This does not retrofit existing EOA,
/// hardware or AA signing paths and is not an on-chain policy enforcement claim.
RestrictedSigner createEvmPolicySigner({
  required Database database,
  required String scope,
  required EthPrivateKey credentials,
  required Future<bool> Function(RestrictedTransfer) approve,
  required int Function() now,
}) => RestrictedSigner(
  database: database,
  scope: scope,
  approve: approve,
  now: now,
  sign: (tx) async {
    if (credentials.address.with0x.toLowerCase() != tx.account) {
      throw StateError('Signer does not own approved account');
    }
    // web3dart uses int for nonce/gas. Do not truncate arbitrary uint256 values.
    if (tx.nonce > BigInt.from(9007199254740991) ||
        tx.gasLimit > BigInt.from(9007199254740991)) {
      throw StateError('Nonce or gas exceeds exact adapter range');
    }
    final transaction = Transaction(
      from: credentials.address,
      to: EthereumAddress.fromHex(tx.payload['to']! as String),
      value: EtherAmount.inWei(BigInt.parse(tx.payload['value']! as String)),
      data: hexToBytes(tx.data),
      nonce: tx.nonce.toInt(),
      maxGas: tx.gasLimit.toInt(),
      gasPrice: EtherAmount.inWei(tx.gasPrice),
    );
    return bytesToHex(
      signTransactionRaw(transaction, credentials, chainId: tx.chainId),
      include0x: true,
    );
  },
);
