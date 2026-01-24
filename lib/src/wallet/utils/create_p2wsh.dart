import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/crypto.dart';

class CreateP2WSH{
  String? p2wsh(int lockTime,{String? uPubKey,String? cPubKey}) {
    // 示例：用户公钥和 Canister 公钥
    uPubKey ??= '02a50eb66887d03fe186b608f477d99bc7631f56e34e3a4843565c55f1aa0c043a';
    cPubKey ??= '03cc9054981c2c0c891db4d99818dde7e4a7d0b272b4464a48e5c03de8652fc721';
    final userPubKey = Uint8List.fromList(hexToBytes(uPubKey));
    final canisterPubKey = Uint8List.fromList(hexToBytes(cPubKey));

    // 质押时间（区块高度）
    //final lockTime = 800000;

    // 构建锁定脚本
    final redeemScript = buildRedeemScript(userPubKey, canisterPubKey, lockTime);
    final scriptHash = sha256a(redeemScript);

    // 生成 P2WSH 地址
    final p2wshAddress = createP2WSHAddress(scriptHash);
    return p2wshAddress;
  }
  /// 构建锁定脚本
  Uint8List buildRedeemScript(Uint8List userPubKey, Uint8List canisterPubKey, int lockTime) {
    List<int> script1=[0x63];
    script1.addAll(encodeNumber(lockTime).toList());
    script1.addAll([0xb1, 0x75]);
    script1.addAll(userPubKey.toList());
    script1.addAll([0xac]);
    script1.addAll([0x67]);
    script1.addAll(canisterPubKey.toList());
    script1.addAll([0xac]);
    script1.addAll([0x68]);

    return Uint8List.fromList(script1);
  }

  /// 将数字编码为比特币脚本格式
  Uint8List encodeNumber(int number) {
    if (number == 0) {
      return Uint8List.fromList([0x00]);
    }
    final bytes = Uint8List(8);
    var value = number;
    var length = 0;
    while (value != 0) {
      bytes[length] = value & 0xff;
      value >>= 8;
      length++;
    }
    return bytes.sublist(0, length);
  }
  /// 计算 SHA-256 哈希
  Uint8List sha256a(Uint8List data) {
    final hash = sha256.convert(data);
    return Uint8List.fromList(hash.bytes);
  }
  /// 生成 P2WSH 地址
  String createP2WSHAddress(Uint8List scriptHash) {
    // 生成 P2WSH 地址
    final p2wshAddress = bech32Encode('bc', scriptHash);
    if (kDebugMode) debugPrint('P2WSH Address: $p2wshAddress');
    return p2wshAddress;
  }
  /// Bech32 字符集
  final String _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

  /// Bech32 编码
  String bech32Encode(String hrp, Uint8List data) {
    // 1. 将 HRP 转换为小写
    hrp = hrp.toLowerCase();

    // 2. 将数据部分转换为 5 位一组
    final converted = _convertBits(data, 8, 5, true);

    // 3. 计算校验和
    final checksum = _createChecksum(hrp, converted);

    // 4. 组合 HRP、数据和校验和
    final combined = Uint8List(converted.length + checksum.length)
      ..setAll(0, converted)
      ..setAll(converted.length, checksum);

    // 5. 将数据编码为 Bech32 字符串
    final bech32 = StringBuffer('${hrp}1');
    for (final value in combined) {
      bech32.write(_charset[value]);
    }

    return bech32.toString();
  }

  /// 将数据从 fromBits 转换为 toBits
  Uint8List _convertBits(Uint8List data, int fromBits, int toBits, bool pad) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << toBits) - 1;

    for (var i = 0; i < data.length; i++) {
      acc = (acc << fromBits) | data[i];
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad && bits > 0) {
      result.add((acc << (toBits - bits)) & maxv);
    }

    return Uint8List.fromList(result);
  }

  /// 创建校验和
  Uint8List _createChecksum(String hrp, Uint8List data) {
    final values = _hrpExpand(hrp) + data.toList();
    final polymod = _polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1;
    final checksum = <int>[];
    for (var i = 0; i < 6; i++) {
      checksum.add((polymod >> 5 * (5 - i)) & 31);
    }
    return Uint8List.fromList(checksum);
  }

  /// 扩展 HRP
  List<int> _hrpExpand(String hrp) {
    final result = <int>[];
    for (var i = 0; i < hrp.length; i++) {
      result.add(hrp.codeUnitAt(i) >> 5);
    }
    result.add(0);
    for (var i = 0; i < hrp.length; i++) {
      result.add(hrp.codeUnitAt(i) & 31);
    }
    return result;
  }

  /// 计算 polymod
  int _polymod(List<int> values) {
    const generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
    var chk = 1;
    for (final value in values) {
      final top = chk >> 25;
      chk = (chk & 0x1ffffff) << 5 ^ value;
      for (var i = 0; i < 5; i++) {
        if ((top >> i) & 1 == 1) {
          chk ^= generator[i];
        }
      }
    }
    return chk;
  }
}
