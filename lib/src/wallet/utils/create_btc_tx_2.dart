import 'package:flutter/foundation.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:web3dart/crypto.dart';
class CreateBtcTX2{
  createTapRoot(ECPrivate fromPriv2,List<TxInput>txInputs,List<BigInt>txInputAmount,List<Script>txInputScript,List<TxOutput> txOutputs,){
    //ECPrivate privkeyTrScript1 = ECPrivate.fromWif('cSW2kQbqC9zkqagw8oTYKFTozKuZ214zd6CMTDs4V32cMfH3dgKa', netVersion: BitcoinNetwork.testnet.wifNetVer);
    //ECPublic pubkeyTrScript1 = privkeyTrScript1.getPublic();
    //Script trScriptP2pk1 = Script(script: [pubkeyTrScript1.toXOnlyHex(), 'OP_CHECKSIG']);
    //ECPrivate toPriv2 = ECPrivate.fromWif('cNxX8M7XU8VNa5ofd8yk1eiZxaxNrQQyb7xNpwAmsrzEhcVwtCjs', netVersion: BitcoinNetwork.testnet.wifNetVer);
    //ECPublic toPub2 = toPriv2.getPublic();

    //P2trAddress toAddress2 = toPub2.toTaprootAddress();

    /*TxInput txIn2 = TxInput(
        txId:
        '3d4c9d73c4c65772e645ff26493590ae4913d9c37125b72398222a553b73fa66',
        txIndex: 0);
    TxOutput txOut2 = TxOutput(
        amount: BigInt.from(3000), scriptPubKey: toAddress2.toScriptPubKey());
*/
    //ECPrivate fromPriv2 = ECPrivate.fromWif('cT33CWKwcV8afBs5NYzeSzeSoGETtAB8izjDjMEuGqyqPoF7fbQR', netVersion: BitcoinNetwork.testnet.wifNetVer);
    //ECPublic fromPub2 = fromPriv2.getPublic();
    //P2trAddress fromAddress2 = fromPub2.toTaprootAddress(scripts: [[trScriptP2pk1]]);
    //Script scriptPubKey2=fromAddress2.toScriptPubKey();
    var tx =
    BtcTransaction(inputs: txInputs, outputs: txOutputs, hasSegwit: true);

    const signHash = BitcoinOpCodeConst.TAPROOT_SIGHASH_ALL;
    List<TxWitnessInput>signaturs=[];
    for(int i=0;i<txInputs.length;i++){
      final txDigit = tx.getTransactionTaprootDigset(
          txIndex: i,
          scriptPubKeys:txInputScript,
          amounts: txInputAmount,
          sighash: signHash);
      final signatur = fromPriv2.signTapRoot(txDigit,
          tapScripts: [
            //[trScriptP2pk1]
          ],
          sighash: signHash,
          tweak:false
      );
      signaturs.add(TxWitnessInput(stack: [signatur]));
    }

    tx = tx.copyWith(witnesses: signaturs);
    if (kDebugMode) debugPrint(tx.serialize());
    return tx.serialize();
    /*//print(signedTx2);
    //expect(tx.serialize(), signedTx2);
    final decode = BtcTransaction.fromRaw(tx.serialize());
    if (kDebugMode) debugPrint(decode.serialize());
    if (kDebugMode) debugPrint(tx.serialize());*/
  }
  createSegwit(ECPrivate fromPriv2,List<TxInput>txInputs,List<BigInt>txInputAmount,List<Script>txInputScript,List<TxOutput> txOutputs,){
    //BitcoinOutput bitcoinOutput=BitcoinOutput(address: P2wshAddress.fromScript(script: txOutputs[0].scriptPubKey), value: txOutputs[0].amount);
    var tx =
    BtcTransaction(inputs: txInputs, outputs: txOutputs, hasSegwit: true);
    List<TxWitnessInput>signaturs=[];
    for(int i=0;i<txInputs.length;i++){
      final txDigit =tx.getTransactionSegwitDigit(txInIndex: i, script: txInputScript[i], amount: txInputAmount[i]);
      final signatur = fromPriv2.signInput(txDigit);
      signaturs.add(TxWitnessInput(stack: [signatur,fromPriv2.getPublic().toHex()]));
    }
    tx = tx.copyWith(witnesses: signaturs);
    return tx.serialize();
    /*//print(signedTx2);
    //expect(tx.serialize(), signedTx2);
    final decode = BtcTransaction.fromRaw(tx.serialize());
    if (kDebugMode) debugPrint(decode.serialize());
    if (kDebugMode) debugPrint(tx.serialize());*/
  }
  createMessage(ECPrivate fromPriv2,String message,ECPublic pub){
    String sign=fromPriv2.signMessage(message.codeUnits);
    if (kDebugMode) debugPrint(sign);
    bool v=pub.verify(message.codeUnits, hexToBytes(sign));
    if (kDebugMode) debugPrint(v.toString());
  }
  createSegwitV2(ECPrivate fromPriv2,P2wshAddress out1){
    const network = BitcoinCashNetwork.mainnet;
    final examplePublicKey = fromPriv2.getPublic();
    final out2 = examplePublicKey.toSegwitAddress();
    /*final out1 = P2wshAddress.fromAddress(
        address: "tb1qnfppjfejp5yhmm8rt4sqj7ezmgtlp6v54urxgzkh5lqff388d6nq29qq65",
        network: network);*/

    final b =BitcoinTransactionBuilder(
      outPuts: [
        BitcoinOutput(address: out1, value: BtcUtils.toSatoshi("0.001")),
        BitcoinOutput(address: out2, value: BtcUtils.toSatoshi("0.0039")),
      ],
      fee: BtcUtils.toSatoshi("0.0001"),
      network: network,
      utxos: [
        UtxoWithAddress(
          /// Create a UTXO using a BitcoinUtxo with specific details
            utxo: BitcoinUtxo(
              /// Transaction hash uniquely identifies the referenced transaction
              txHash:
              "47537040763fcc505821a1198656c1aa4053d8dd0edac84e6b9efe86e2673f17",
              /// Value represents the amount of the UTXO in satoshis.
              value: BtcUtils.toSatoshi("0.005"),
              /// Vout is the output index of the UTXO within the referenced transaction
              vout: 1,
              /// Script type indicates the type of script associated with the UTXO's address
              scriptType: examplePublicKey.toAddress().type,
            ),
            /// Include owner details with the public key and address associated with the UTXO
            ownerDetails: UtxoAddressDetails(
              publicKey: examplePublicKey.toHex(),
              address: examplePublicKey.toAddress(),
            ),
        ),
      ],
      inputOrdering: BitcoinOrdering.bip69,
      outputOrdering: BitcoinOrdering.bip69,
      enableRBF: true
    );
    /// Build the transaction by invoking the buildTransaction method on the ForkedTransactionBuilder
    final tr = b.buildTransaction((trDigest, utxo, publicKey, int sighash) {
      /// For each input in the transaction, locate the corresponding private key
      /// and sign the transaction digest to construct the unlocking script.
      if (publicKey == examplePublicKey.toHex()) {
        return fromPriv2.signInput(trDigest, sigHash: sighash);
      }

      throw UnimplementedError();
    });
    return tr.serialize();
  }
}
