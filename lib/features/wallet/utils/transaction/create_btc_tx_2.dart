import 'package:flutter/foundation.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:web3dart/web3dart.dart';

class CreateBtcTX2 {
  String createTapRoot(
    ECPrivate fromPriv2,
    List<TxInput> txInputs,
    List<BigInt> txInputAmount,
    List<Script> txInputScript,
    List<TxOutput> txOutputs,
  ) {
    var tx = BtcTransaction(inputs: txInputs, outputs: txOutputs);

    const signHash = BitcoinOpCodeConst.sighashAll;
    final signatures = <TxWitnessInput>[];

    for (int i = 0; i < txInputs.length; i++) {
      final txDigit = tx.getTransactionTaprootDigset(
        txIndex: i,
        scriptPubKeys: txInputScript,
        amounts: txInputAmount,
        sighash: signHash,
      );
      final signature = fromPriv2.signBip340(txDigit, sighash: signHash, tweak: false);
      signatures.add(TxWitnessInput(stack: [signature]));
    }

    tx = tx.copyWith(witnesses: signatures);
    if (kDebugMode) debugPrint(tx.serialize());
    return tx.serialize();
  }

  String createSegwit(
    ECPrivate fromPriv2,
    List<TxInput> txInputs,
    List<BigInt> txInputAmount,
    List<Script> txInputScript,
    List<TxOutput> txOutputs,
  ) {
    var tx = BtcTransaction(inputs: txInputs, outputs: txOutputs);
    final signatures = <TxWitnessInput>[];

    for (int i = 0; i < txInputs.length; i++) {
      final txDigit = tx.getTransactionSegwitDigit(
        txInIndex: i,
        script: txInputScript[i],
        amount: txInputAmount[i],
      );
      final signature = fromPriv2.signECDSA(txDigit);
      signatures.add(TxWitnessInput(stack: [signature, fromPriv2.getPublic().toHex()]));
    }

    tx = tx.copyWith(witnesses: signatures);
    return tx.serialize();
  }

  void createMessage(ECPrivate fromPriv2, String message, ECPublic pub) {
    final sign = fromPriv2.signMessage(message.codeUnits);
    if (kDebugMode) debugPrint(sign);
    final v = pub.verify(message: message.codeUnits, signature: hexToBytes(sign));
    if (kDebugMode) debugPrint(v.toString());
  }

  String createSegwitV2(ECPrivate fromPriv2, P2wshAddress out1) {
    const network = BitcoinCashNetwork.mainnet;
    final examplePublicKey = fromPriv2.getPublic();
    final out2 = examplePublicKey.toSegwitAddress();

    final b = BitcoinTransactionBuilder(
      outPuts: [
        BitcoinOutput(address: out1, value: BtcUtils.toSatoshi('0.001')),
        BitcoinOutput(address: out2, value: BtcUtils.toSatoshi('0.0039')),
      ],
      fee: BtcUtils.toSatoshi('0.0001'),
      network: network,
      utxos: [
        UtxoWithAddress(
          utxo: BitcoinUtxo(
            txHash: '47537040763fcc505821a1198656c1aa4053d8dd0edac84e6b9efe86e2673f17',
            value: BtcUtils.toSatoshi('0.005'),
            vout: 1,
            scriptType: examplePublicKey.toAddress().type,
          ),
          ownerDetails: UtxoAddressDetails(
            publicKey: examplePublicKey.toHex(),
            address: examplePublicKey.toAddress(),
          ),
        ),
      ],
      inputOrdering: BitcoinOrdering.bip69,
      outputOrdering: BitcoinOrdering.bip69,
      enableRBF: true,
    );

    final tr = b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      if (publicKey == examplePublicKey.toHex()) {
        return fromPriv2.signECDSA(trDigest, sighash: sighash);
      }
      throw UnimplementedError();
    });

    return tr.serialize();
  }
}
