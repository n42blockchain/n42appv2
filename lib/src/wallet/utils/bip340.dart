import 'dart:typed_data';
import 'package:eth_sig_util/util/bigint.dart';
import 'dart:math';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class Bip340{
  var curve = ECCurve_secp256k1();
  ECPoint? G ;
  BigInt? n ;

  /// 生成随机私钥
  BigInt generatePrivateKey() {
    var random = FortunaRandom();
    var seed = Uint8List.fromList(List.generate(32, (_) => Random().nextInt(256)));
    random.seed(KeyParameter(seed));
    return decodeBigInt(random.nextBytes(32)) % n!;
  }

  /// 计算公钥
  ECPoint getPublicKey(BigInt privateKey) {
    return (G! * privateKey)!;
  }

  /// 计算 SHA256 哈希
  BigInt hashMessage(Uint8List message) {
    var sha256 = SHA256Digest();
    return decodeBigInt(sha256.process(message)) % n!;
  }

  /// Schnorr 签名
  Uint8List schnorrSign(Uint8List message,BigInt privateKey) {
    curve = ECCurve_secp256k1();
    G = curve.G;
    n = curve.n;
    // 生成随机数 k
    BigInt k = generatePrivateKey();
    ECPoint R = (G! * k)!;

    // 计算挑战 e = H(R || P || m)
    ECPoint P = getPublicKey(privateKey);
    var e = hashMessage(Uint8List.fromList([...R.getEncoded(), ...P.getEncoded(), ...message]));

    // 计算 s = k + e * d mod n
    BigInt s = (k + e * privateKey) % n!;
    return getWitnessSignature(hex.encode(R.getEncoded()),s.toRadixString(16));
    /*return {
      'R': hex.encode(R.getEncoded()),
      's': s.toRadixString(16)
    };*/
  }
  /// 获取 Witness 签名数据
  Uint8List getWitnessSignature(String rHex, String sHex) {
    // 解析 R 并提取 x 坐标
    Uint8List rBytes = Uint8List.fromList(hex.decode(rHex));
    Uint8List rX = rBytes.sublist(1, 33); // 截取 x 坐标（去掉前缀字节）

    // 解析 s
    Uint8List sBytes = Uint8List.fromList(hex.decode(sHex));

    // 组合成 Witness 签名格式 (rX || s)
    return Uint8List.fromList([...rX, ...sBytes]);
  }
  /// Schnorr 验证
  bool schnorrVerify(ECPoint publicKey, Uint8List message, String rHex, String sHex) {
    ECPoint r = curve.curve.decodePoint(hex.decode(rHex))!;
    BigInt s = BigInt.parse(sHex, radix: 16);

    // 计算挑战 e
    var e = hashMessage(Uint8List.fromList([...r.getEncoded(), ...publicKey.getEncoded(), ...message]));

    // 计算 R' = s * G - e * P
    ECPoint rPrime = ((G! * s)! - (publicKey * e)!)!;

    return r == rPrime;
  }
}
