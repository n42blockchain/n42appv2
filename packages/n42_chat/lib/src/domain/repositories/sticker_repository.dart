import 'dart:typed_data';

import '../entities/sticker_pack_entity.dart';

/// 贴纸仓库接口
abstract class IStickerRepository {
  /// 获取已安装的贴纸包列表
  Future<List<StickerPack>> getInstalledPacks();

  /// 获取贴纸商店中的贴纸包列表
  Future<List<StickerPack>> getStorePacks({
    int limit = 20,
    int offset = 0,
    String? category,
  });

  /// 获取贴纸包详情
  Future<StickerPack?> getPackById(String packId);

  /// 安装贴纸包
  Future<bool> installPack(String packId);

  /// 卸载贴纸包
  Future<bool> uninstallPack(String packId);

  /// 获取常用贴纸
  Future<List<RecentSticker>> getRecentStickers({int limit = 20});

  /// 记录贴纸使用
  Future<void> recordStickerUsage(String packId, String stickerId);

  /// 清除常用贴纸记录
  Future<void> clearRecentStickers();

  /// 搜索贴纸包
  Future<List<StickerPack>> searchPacks(String query);

  /// 在已安装贴纸包内按关键词/emoji 搜索单个贴纸
  ///
  /// 用于贴纸面板搜索框与输入框联想（输入词推荐贴纸）。按相关度排序：
  /// emoji 精确匹配 > 名称前缀匹配 > 名称包含。
  Future<List<StickerHit>> searchStickers(String query, {int limit = 24});

  /// 获取贴纸分类列表
  Future<List<StickerCategory>> getCategories();

  /// 创建自定义贴纸包
  Future<StickerPack?> createCustomPack({
    required String name,
    String? description,
    Uint8List? avatarBytes,
  });

  /// 向贴纸包添加贴纸
  Future<bool> addStickerToPack({
    required String packId,
    required Uint8List imageBytes,
    required String filename,
    String? name,
    String? emoji,
  });

  /// 从贴纸包移除贴纸
  Future<bool> removeStickerFromPack({
    required String packId,
    required String stickerId,
  });

  /// 删除自定义贴纸包
  Future<bool> deleteCustomPack(String packId);

  /// 重命名贴纸包
  Future<bool> renamePack(String packId, String newName);

  /// 导入贴纸包（从其他用户分享）
  Future<StickerPack?> importPack(String shareUrl);

  /// 获取贴纸包分享链接
  Future<String?> getPackShareUrl(String packId);

  /// 监听已安装贴纸包变化
  Stream<List<StickerPack>> watchInstalledPacks();
}
