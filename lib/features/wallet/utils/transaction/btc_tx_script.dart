import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

import 'btc_tx_crypto.dart';

/// BTC 脚本生成与交易序列化工具
class BtcTxScript {
  final BtcTxCrypto _crypto = BtcTxCrypto();

  /// 从 redeem 脚本构造 P2WSH scriptPubKey（0x00 + 0x20 + hash256）
  Uint8List getScriptPubKey(Uint8List redeemScript) {
    final Uint8List witnessScriptHash = _crypto.doubleSha256(redeemScript);
    return Uint8List.fromList([0x00, 0x20, ...witnessScriptHash]);
  }

  /// 解析 Bech32 地址（bc1... / tb1...），返回对应的 scriptPubKey
  Uint8List getScriptPubKeyFromBech32(String bech32Address) {
    final P2wpkhAddress p2wpkhAddress = P2wpkhAddress.fromAddress(
        address: bech32Address, network: BitcoinNetwork.testnet);
    return Uint8List.fromList(p2wpkhAddress.toScriptPubKey().toBytes());
  }

  /// 从压缩公钥计算 P2WPKH scriptPubKey（0x00 + 0x14 + RIPEMD160(SHA256(pubKey))）
  Uint8List getP2WPKHScript(Uint8List publicKey) {
    final Uint8List sha256Hash =
        Uint8List.fromList(sha256.convert(publicKey).bytes);
    final Uint8List pubKeyHash = _ripemd160Hash(sha256Hash);

    final BytesBuilder script = BytesBuilder();
    script.add([0x00]); // Witness version 0
    script.add([0x14]); // 20-byte length
    script.add(pubKeyHash);
    return script.toBytes();
  }

  /// RIPEMD160 哈希
  Uint8List _ripemd160Hash(Uint8List data) {
    return RIPEMD160Digest().process(data);
  }

  /// 将原始交易字节与 witness 签名序列化为最终交易
  Uint8List serializeTransaction(
      Uint8List rawTx, List<Uint8List> signatures, Uint8List publicKey) {
    final ByteData data =
        ByteData(rawTx.length + (signatures.length * 180));
    int offset = 0;

    data.buffer.asUint8List().setRange(0, rawTx.length, rawTx);
    offset += rawTx.length;

    data.setUint8(offset, signatures.length);
    offset += 1;

    for (var sig in signatures) {
      data.setUint8(offset, 2); // witness 包含两个元素
      offset += 1;

      data.setUint8(offset, sig.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + sig.length, sig);
      offset += sig.length;

      data.setUint8(offset, publicKey.length);
      offset += 1;
      data.buffer.asUint8List().setRange(
          offset, offset + publicKey.length, publicKey);
      offset += publicKey.length;
    }

    return data.buffer.asUint8List(0, offset);
  }
}
