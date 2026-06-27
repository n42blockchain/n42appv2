import 'dart:typed_data';
import 'dart:async';


import '../../domain/entities/sticker_pack_entity.dart';
import '../../domain/repositories/sticker_repository.dart';
import '../datasources/matrix/matrix_sticker_datasource.dart';
import '../datasources/bundled_sticker_packs.dart';
import '../../core/utils/debug_log.dart';
import '../../core/utils/sticker_suggestion_utils.dart';

/// 贴纸仓库实现
class StickerRepositoryImpl implements IStickerRepository {
  final MatrixStickerDataSource _dataSource;

  /// 已安装贴纸包缓存
  List<StickerPack>? _installedPacksCache;

  /// 已安装贴纸包变化流控制器
  final _installedPacksController = StreamController<List<StickerPack>>.broadcast();

  StickerRepositoryImpl(this._dataSource);

  @override
  Future<List<StickerPack>> getInstalledPacks() async {
    if (_installedPacksCache != null) {
      return _installedPacksCache!;
    }

    final remotePacks = await _dataSource.getInstalledPacks();
    // 内置贴纸包始终置顶且默认"已安装"，保证面板不空；按 id 去重避免与远端重复。
    final bundledIds = BundledStickerPacks.all.map((p) => p.id).toSet();
    final packs = <StickerPack>[
      ...BundledStickerPacks.all,
      ...remotePacks.where((p) => !bundledIds.contains(p.id)),
    ];
    _installedPacksCache = packs;
    return packs;
  }

  @override
  Future<List<StickerPack>> getStorePacks({
    int limit = 20,
    int offset = 0,
    String? category,
  }) async {
    // Built-in sample stickers — replace with Matrix sticker pack API (m.sticker_pack)
    // TODO: 从贴纸商店 API 获取
    // 目前返回一些示例贴纸包
    final packs = _filterStorePacks(
      _getSampleStorePacks(),
      category: category,
    );
    return packs.skip(offset).take(limit).toList();
  }

  List<StickerPack> _getSampleStorePacks() {
    return [
      const StickerPack(
        id: 'store_cute_animals',
        name: 'Cute Animals',
        description: 'Adorable animal stickers for every occasion',
        author: 'N42 Studio',
        source: StickerPackSource.store,
        isOfficial: true,
        downloadCount: 12500,
        stickers: [
          Sticker(id: 'cat1', url: 'emoji:🐱', emoji: '🐱'),
          Sticker(id: 'dog1', url: 'emoji:🐶', emoji: '🐶'),
          Sticker(id: 'bunny1', url: 'emoji:🐰', emoji: '🐰'),
          Sticker(id: 'bear1', url: 'emoji:🐻', emoji: '🐻'),
        ],
      ),
      const StickerPack(
        id: 'store_emotions',
        name: 'Emotions',
        description: 'Express your feelings with these stickers',
        author: 'N42 Studio',
        source: StickerPackSource.store,
        isOfficial: true,
        downloadCount: 8900,
        stickers: [
          Sticker(id: 'happy1', url: 'emoji:😊', emoji: '😊'),
          Sticker(id: 'sad1', url: 'emoji:😢', emoji: '😢'),
          Sticker(id: 'angry1', url: 'emoji:😠', emoji: '😠'),
          Sticker(id: 'love1', url: 'emoji:😍', emoji: '😍'),
        ],
      ),
      const StickerPack(
        id: 'store_food',
        name: 'Yummy Food',
        description: 'Delicious food stickers',
        author: 'Community',
        source: StickerPackSource.store,
        downloadCount: 5600,
        stickers: [
          Sticker(id: 'pizza1', url: 'emoji:🍕', emoji: '🍕'),
          Sticker(id: 'burger1', url: 'emoji:🍔', emoji: '🍔'),
          Sticker(id: 'sushi1', url: 'emoji:🍣', emoji: '🍣'),
          Sticker(id: 'cake1', url: 'emoji:🎂', emoji: '🎂'),
        ],
      ),
      const StickerPack(
        id: 'store_celebration',
        name: 'Celebration',
        description: 'Party and celebration stickers',
        author: 'Community',
        source: StickerPackSource.store,
        downloadCount: 4200,
        stickers: [
          Sticker(id: 'party1', url: 'emoji:🎉', emoji: '🎉'),
          Sticker(id: 'gift1', url: 'emoji:🎁', emoji: '🎁'),
          Sticker(id: 'balloon1', url: 'emoji:🎈', emoji: '🎈'),
          Sticker(id: 'confetti1', url: 'emoji:🎊', emoji: '🎊'),
        ],
      ),
    ];
  }

  @override
  Future<StickerPack?> getPackById(String packId) async {
    // 先从已安装列表查找
    final installed = await getInstalledPacks();
    final installedPack = installed.where((p) => p.id == packId).firstOrNull;
    if (installedPack != null) return installedPack;

    // 从商店查找
    final storePacks = _getSampleStorePacks();
    return storePacks.where((p) => p.id == packId).firstOrNull;
  }

  @override
  Future<bool> installPack(String packId) async {
    final pack = await getPackById(packId);
    if (pack == null) return false;

    final success = await _dataSource.installPack(packId, pack);
    if (success) {
      _invalidateCache();
      _notifyInstalledPacksChanged();
    }
    return success;
  }

  @override
  Future<bool> uninstallPack(String packId) async {
    final success = await _dataSource.uninstallPack(packId);
    if (success) {
      _invalidateCache();
      _notifyInstalledPacksChanged();
    }
    return success;
  }

  @override
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async {
    return await _dataSource.getRecentStickers(limit: limit);
  }

  @override
  Future<void> recordStickerUsage(String packId, String stickerId) async {
    await _dataSource.recordStickerUsage(packId, stickerId);
  }

  @override
  Future<void> clearRecentStickers() async {
    await _dataSource.clearRecentStickers();
  }

  @override
  Future<List<StickerPack>> searchPacks(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    // 搜索已安装的贴纸包
    final installed = await getInstalledPacks();
    final installedMatches = installed.where((pack) =>
        pack.name.toLowerCase().contains(queryLower) ||
        (pack.description?.toLowerCase().contains(queryLower) ?? false) ||
        pack.stickers.any((s) =>
            (s.name?.toLowerCase().contains(queryLower) ?? false) ||
            (s.emoji?.contains(queryLower) ?? false)));

    // 搜索商店贴纸包
    final storePacks = _getSampleStorePacks();
    final storeMatches = storePacks.where((pack) =>
        pack.name.toLowerCase().contains(queryLower) ||
        (pack.description?.toLowerCase().contains(queryLower) ?? false));

    return _dedupePacksById([...installedMatches, ...storeMatches]);
  }

  @override
  Future<List<StickerHit>> searchStickers(String query, {int limit = 24}) async {
    if (query.trim().isEmpty) return const [];
    final installed = await getInstalledPacks();
    return StickerSuggestionUtils.rank(installed, query, limit: limit);
  }

  @override
  Future<List<StickerCategory>> getCategories() async {
    return const [
      StickerCategory(id: 'popular', name: 'Popular', icon: '🔥', packCount: 10),
      StickerCategory(id: 'new', name: 'New', icon: '✨', packCount: 5),
      StickerCategory(id: 'animals', name: 'Animals', icon: '🐾', packCount: 8),
      StickerCategory(id: 'emotions', name: 'Emotions', icon: '😊', packCount: 12),
      StickerCategory(id: 'food', name: 'Food', icon: '🍔', packCount: 6),
      StickerCategory(id: 'celebration', name: 'Celebration', icon: '🎉', packCount: 4),
    ];
  }

  @override
  Future<StickerPack?> createCustomPack({
    required String name,
    String? description,
    Uint8List? avatarBytes,
  }) async {
    try {
      String? avatarUrl;
      if (avatarBytes != null) {
        avatarUrl = await _dataSource.uploadStickerImage(
          avatarBytes,
          'avatar.png',
          'image/png',
        );
      }

      final packId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final pack = StickerPack(
        id: packId,
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        source: StickerPackSource.custom,
        isInstalled: true,
        createdAt: DateTime.now(),
      );

      final success = await _dataSource.installPack(packId, pack);
      if (success) {
        _invalidateCache();
        _notifyInstalledPacksChanged();
        return pack;
      }
      return null;
    } catch (e) {
      debugLog('StickerRepositoryImpl: Failed to create custom pack: $e');
      return null;
    }
  }

  @override
  Future<bool> addStickerToPack({
    required String packId,
    required Uint8List imageBytes,
    required String filename,
    String? name,
    String? emoji,
  }) async {
    try {
      final pack = await getPackById(packId);
      if (pack == null) return false;

      // 上传贴纸图片
      final url = await _dataSource.uploadStickerImage(
        imageBytes,
        filename,
        _getMimeType(filename),
      );
      if (url == null) return false;

      // 创建新贴纸
      final stickerId = 'sticker_${DateTime.now().millisecondsSinceEpoch}';
      final sticker = Sticker(
        id: stickerId,
        url: url,
        name: name,
        emoji: emoji,
        mimeType: _getMimeType(filename),
        size: imageBytes.length,
      );

      // 更新贴纸包
      final updatedPack = pack.copyWith(
        stickers: [...pack.stickers, sticker],
        updatedAt: DateTime.now(),
      );

      final success = await _dataSource.installPack(packId, updatedPack);
      if (success) {
        _invalidateCache();
        _notifyInstalledPacksChanged();
      }
      return success;
    } catch (e) {
      debugLog('StickerRepositoryImpl: Failed to add sticker: $e');
      return false;
    }
  }

  @override
  Future<bool> removeStickerFromPack({
    required String packId,
    required String stickerId,
  }) async {
    try {
      final pack = await getPackById(packId);
      if (pack == null) return false;

      final updatedStickers = pack.stickers.where((s) => s.id != stickerId).toList();
      final updatedPack = pack.copyWith(
        stickers: updatedStickers,
        updatedAt: DateTime.now(),
      );

      final success = await _dataSource.installPack(packId, updatedPack);
      if (success) {
        _invalidateCache();
        _notifyInstalledPacksChanged();
      }
      return success;
    } catch (e) {
      debugLog('StickerRepositoryImpl: Failed to remove sticker: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteCustomPack(String packId) async {
    return await uninstallPack(packId);
  }

  @override
  Future<bool> renamePack(String packId, String newName) async {
    try {
      final pack = await getPackById(packId);
      if (pack == null) return false;

      final updatedPack = pack.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      final success = await _dataSource.installPack(packId, updatedPack);
      if (success) {
        _invalidateCache();
        _notifyInstalledPacksChanged();
      }
      return success;
    } catch (e) {
      debugLog('StickerRepositoryImpl: Failed to rename pack: $e');
      return false;
    }
  }

  @override
  Future<StickerPack?> importPack(String shareUrl) async {
    // TODO: 实现从分享链接导入贴纸包
    debugLog('StickerRepositoryImpl: Import pack from $shareUrl');
    return null;
  }

  @override
  Future<String?> getPackShareUrl(String packId) async {
    // TODO: 实现获取贴纸包分享链接
    return null;
  }

  @override
  Stream<List<StickerPack>> watchInstalledPacks() {
    // 立即发送当前数据
    getInstalledPacks().then((packs) {
      if (!_installedPacksController.isClosed) {
        _installedPacksController.add(packs);
      }
    });

    return _installedPacksController.stream;
  }

  void _invalidateCache() {
    _installedPacksCache = null;
  }

  List<StickerPack> _filterStorePacks(
    Iterable<StickerPack> packs, {
    String? category,
  }) {
    final filtered = category == null
        ? packs.toList()
        : packs.where((pack) => _matchesStoreCategory(pack, category)).toList();

    if (category == 'popular') {
      filtered.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    } else if (category == 'new') {
      filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    return filtered;
  }

  bool _matchesStoreCategory(StickerPack pack, String category) {
    switch (category) {
      case 'popular':
      case 'new':
        return true;
      case 'animals':
        return pack.id.contains('animal');
      case 'emotions':
        return pack.id.contains('emotion');
      case 'food':
        return pack.id.contains('food');
      case 'celebration':
        return pack.id.contains('celebration');
      default:
        return false;
    }
  }

  List<StickerPack> _dedupePacksById(Iterable<StickerPack> packs) {
    final deduped = <String, StickerPack>{};
    for (final pack in packs) {
      deduped.putIfAbsent(pack.id, () => pack);
    }
    return deduped.values.toList();
  }

  void _notifyInstalledPacksChanged() {
    getInstalledPacks().then((packs) {
      if (!_installedPacksController.isClosed) {
        _installedPacksController.add(packs);
      }
    });
  }

  String? _getMimeType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  void dispose() {
    _installedPacksController.close();
  }
}
