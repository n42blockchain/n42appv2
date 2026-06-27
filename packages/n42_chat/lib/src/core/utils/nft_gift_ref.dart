/// NFT 引用（合约 + tokenId + 链）
///
/// 统一 `nft://<contract>/<tokenId>@<chainId>` 文本格式（与 NFT 头像选择器
/// 既有写法一致），用于赠送流程在聊天内携带 NFT 标识。纯逻辑，便于单测。
class NftGiftRef {
  final String contractAddress;
  final String tokenId;
  final int chainId;

  const NftGiftRef({
    required this.contractAddress,
    required this.tokenId,
    this.chainId = 1,
  });

  /// 格式化为 `nft://contract/tokenId@chainId`
  String format() =>
      'nft://${contractAddress.trim()}/${tokenId.trim()}@$chainId';

  /// 简短展示名：`#tokenId`
  String get shortLabel => '#$tokenId';

  /// 解析 `nft://contract/tokenId@chainId`；非法返回 null。
  static NftGiftRef? tryParse(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.toLowerCase().startsWith('nft://')) return null;

    final rest = trimmed.substring('nft://'.length);
    // contract/tokenId[@chainId]
    final slash = rest.indexOf('/');
    if (slash <= 0) return null;

    final contract = rest.substring(0, slash).trim();
    var tokenPart = rest.substring(slash + 1).trim();
    if (contract.isEmpty || tokenPart.isEmpty) return null;

    var chainId = 1;
    final at = tokenPart.lastIndexOf('@');
    if (at >= 0) {
      final chainStr = tokenPart.substring(at + 1).trim();
      tokenPart = tokenPart.substring(0, at).trim();
      final parsed = int.tryParse(chainStr);
      if (parsed == null || parsed <= 0) return null;
      chainId = parsed;
    }
    if (tokenPart.isEmpty || tokenPart.contains('/')) return null;

    return NftGiftRef(
      contractAddress: contract,
      tokenId: tokenPart,
      chainId: chainId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NftGiftRef &&
      other.contractAddress == contractAddress &&
      other.tokenId == tokenId &&
      other.chainId == chainId;

  @override
  int get hashCode => Object.hash(contractAddress, tokenId, chainId);
}
