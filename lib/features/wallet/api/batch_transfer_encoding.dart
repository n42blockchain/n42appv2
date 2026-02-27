part of 'batch_transfer_api.dart';

/// ABI 编码 helper —— Multicall3 calldata 构建
///
/// 所有方法通过 part 机制作为 [BatchTransferApi] 的私有成员。
extension _BatchTransferEncoding on BatchTransferApi {
  // ---------------------------------------------------------------------------
  // Multicall calldata builders
  // ---------------------------------------------------------------------------

  /// 构建原生代币 Multicall 数据 (aggregate3Value selector: 0xe8917eb5)
  ///
  /// aggregate3Value(Call3Value[] calldata calls)
  /// Call3Value: { target, allowFailure, value, callData }
  String _buildNativeMulticallData(List<BatchTransferItem> items) {
    const selector = '0xe8917eb5';
    final callsData = StringBuffer()
      ..write(_padLeft('20', 64)) // 数组偏移
      ..write(_padLeft(items.length.toRadixString(16), 64)); // 数组长度

    // 每个 Call3Value 结构：5 个 word (160 bytes)
    int currentOffset = items.length * 32;
    final offsets = <String>[];
    final structures = <String>[];

    for (final item in items) {
      offsets.add(_padLeft(currentOffset.toRadixString(16), 64));

      final structure = StringBuffer()
        ..write(_padLeft(
            item.toAddress.toLowerCase().replaceFirst('0x', ''), 64)) // target
        ..write(_padLeft('0', 64)) // allowFailure = false
        ..write(_padLeft(item.amount.toRadixString(16), 64)) // value
        ..write(_padLeft('80', 64)) // callData offset (4 * 32 = 0x80)
        ..write(_padLeft('0', 64)); // callData length = 0 (native)
      structures.add(structure.toString());

      currentOffset += 160; // 5 * 32 bytes
    }

    final result = StringBuffer(selector)..write(callsData);
    for (final offset in offsets) {
      result.write(offset);
    }
    for (final structure in structures) {
      result.write(structure);
    }
    return result.toString();
  }

  /// 构建 ERC20 Multicall 数据 (aggregate3 selector: 0x82ad56cb)
  ///
  /// aggregate3(Call3[] calldata calls)
  /// Call3: { target, allowFailure, callData }
  String _buildErc20MulticallData(
      String tokenAddress, List<BatchTransferItem> items) {
    const selector = '0x82ad56cb';
    final result = StringBuffer(selector)
      ..write(_padLeft('20', 64)) // 数组偏移
      ..write(_padLeft(items.length.toRadixString(16), 64)); // 数组长度

    int baseOffset = items.length * 32;
    final offsets = <String>[];
    final calls = <String>[];

    for (final item in items) {
      offsets.add(_padLeft(baseOffset.toRadixString(16), 64));

      final callData = _buildErc20TransferData(item.toAddress, item.amount);
      final callDataHex = callData.replaceFirst('0x', '');
      final callDataBytes = callDataHex.length ~/ 2;
      final paddedLength = ((callDataHex.length + 63) ~/ 64) * 64;

      final call = StringBuffer()
        ..write(_padLeft(
            tokenAddress.toLowerCase().replaceFirst('0x', ''), 64)) // target
        ..write(_padLeft('0', 64)) // allowFailure = false
        ..write(_padLeft('60', 64)) // callData offset (0x60 = 96)
        ..write(_padLeft(callDataBytes.toRadixString(16), 64)) // length
        ..write(callDataHex.padRight(paddedLength, '0')); // callData padded
      calls.add(call.toString());

      baseOffset += 128 + paddedLength ~/ 2; // 4 * 32 + callData bytes
    }

    for (final offset in offsets) {
      result.write(offset);
    }
    for (final call in calls) {
      result.write(call);
    }
    return result.toString();
  }

  // ---------------------------------------------------------------------------
  // Shared utilities
  // ---------------------------------------------------------------------------

  /// 构建 ERC20 transfer(address,uint256) calldata
  String _buildErc20TransferData(String to, BigInt amount) {
    final toPadded = _padLeft(to.toLowerCase().replaceFirst('0x', ''), 64);
    final amountHex = _padLeft(amount.toRadixString(16), 64);
    return '${BatchTransferApi.erc20TransferSelector}$toPadded$amountHex';
  }

  String _padLeft(String str, int length) => str.padLeft(length, '0');

  BigInt _hexToBigInt(String hex) {
    final cleaned = (hex.startsWith('0x') || hex.startsWith('0X'))
        ? hex.substring(2)
        : hex;
    if (cleaned.isEmpty) return BigInt.zero;
    return BigInt.parse(cleaned, radix: 16);
  }
}
