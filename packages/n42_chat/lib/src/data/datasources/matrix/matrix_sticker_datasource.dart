import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/matrix_utils.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import '../bundled_sticker_packs.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix 贴纸数据源
///
/// 使用 Matrix 账户数据存储贴纸包信息
/// 遵循 Matrix Sticker Pack MSC2545 规范
class MatrixStickerDataSource {
  final MatrixClientManager _clientManager;

  /// 贴纸包账户数据类型
  static const String stickerPackType = 'im.ponies.user_emotes';

  /// 已安装贴纸包列表账户数据类型
  static const String installedPacksType = 'n42.sticker.installed_packs';

  /// 常用贴纸账户数据类型
  static const String recentStickersType = 'n42.sticker.recent';

  /// 自定义贴纸包房间标签
  static const String customPackRoomTag = 'n42.sticker.custom';

  MatrixStickerDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  /// 获取已安装的贴纸包列表
  Future<List<StickerPack>> getInstalledPacks() async {
    if (_client == null) return [];

    try {
      // 从账户数据获取已安装的贴纸包 ID 列表
      final installedData = await _client!.getAccountData(
        _client!.userID!,
        installedPacksType,
      );

      final packIds =
          (installedData['pack_ids'] as List?)?.cast<String>() ?? [];
      final packs = <StickerPack>[];

      // 获取每个贴纸包的详情
      for (final packId in packIds) {
        final pack = await _getPackFromAccountData(packId);
        if (pack != null) {
          packs.add(pack.copyWith(isInstalled: true));
        }
      }

      // 添加内置贴纸包
      packs.addAll(await _getBuiltinPacks());

      return packs;
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to get installed packs: $e');
      // 返回内置贴纸包作为后备
      return await _getBuiltinPacks();
    }
  }

  /// 从账户数据获取贴纸包
  Future<StickerPack?> _getPackFromAccountData(String packId) async {
    try {
      final data = await _client!.getAccountData(
        _client!.userID!,
        '$stickerPackType.$packId',
      );

      return _parseStickerPack(packId, data);
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to get pack $packId: $e');
      return null;
    }
  }

  /// 解析贴纸包数据
  StickerPack? _parseStickerPack(String packId, Map<String, dynamic> data) {
    try {
      final pack = data['pack'] as Map<String, dynamic>?;
      final images = data['images'] as Map<String, dynamic>?;

      if (pack == null || images == null) return null;

      final stickers = <Sticker>[];
      images.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final url = value['url'] as String?;
          if (url != null) {
            stickers.add(
              Sticker(
                id: key,
                url: url,
                httpUrl: _getHttpUrl(url),
                name: (value['body'] ?? value['name']) as String?,
                emoji: key,
                width: (value['info']?['w'] as num?)?.toInt(),
                height: (value['info']?['h'] as num?)?.toInt(),
                mimeType: value['info']?['mimetype'] as String?,
                size: (value['info']?['size'] as num?)?.toInt(),
              ),
            );
          }
        }
      });

      return StickerPack(
        id: packId,
        name: pack['display_name'] as String? ?? packId,
        description: pack['description'] as String?,
        avatarUrl: pack['avatar_url'] as String?,
        avatarHttpUrl: _getHttpUrl(pack['avatar_url'] as String?),
        author: pack['author'] as String?,
        source: StickerPackSource.matrix,
        stickers: stickers,
      );
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to parse pack: $e');
      return null;
    }
  }

  /// 获取内置贴纸包
  Future<List<StickerPack>> _getBuiltinPacks() async {
    // 返回一些示例贴纸包
    // 实际应用中这些应该从服务器或本地资源加载
    return [
      const StickerPack(
        id: 'builtin_emoji',
        name: 'Emoji',
        description: 'Standard emoji stickers',
        source: StickerPackSource.builtin,
        isInstalled: true,
        isOfficial: true,
        stickers: [
          Sticker(id: 'smile', url: 'emoji:😊', emoji: '😊'),
          Sticker(id: 'laugh', url: 'emoji:😂', emoji: '😂'),
          Sticker(id: 'heart', url: 'emoji:❤️', emoji: '❤️'),
          Sticker(id: 'thumbsup', url: 'emoji:👍', emoji: '👍'),
          Sticker(id: 'clap', url: 'emoji:👏', emoji: '👏'),
          Sticker(id: 'fire', url: 'emoji:🔥', emoji: '🔥'),
          Sticker(id: 'party', url: 'emoji:🎉', emoji: '🎉'),
          Sticker(id: 'thinking', url: 'emoji:🤔', emoji: '🤔'),
        ],
      ),
    ];
  }

  /// 安装贴纸包
  Future<bool> installPack(String packId, StickerPack pack) async {
    if (_client == null) return false;

    try {
      // 保存贴纸包数据
      await _client!.setAccountData(
        _client!.userID!,
        '$stickerPackType.$packId',
        _packToJson(pack),
      );

      // 更新已安装列表
      final installedData = await _getInstalledPackIds();
      if (!installedData.contains(packId)) {
        installedData.add(packId);
        await _client!.setAccountData(_client!.userID!, installedPacksType, {
          'pack_ids': installedData,
        });
      }

      return true;
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to install pack: $e');
      return false;
    }
  }

  /// 卸载贴纸包
  Future<bool> uninstallPack(String packId) async {
    if (_client == null) return false;

    try {
      // 从已安装列表移除
      final installedData = await _getInstalledPackIds();
      installedData.remove(packId);
      await _client!.setAccountData(_client!.userID!, installedPacksType, {
        'pack_ids': installedData,
      });

      return true;
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to uninstall pack: $e');
      return false;
    }
  }

  /// 获取已安装贴纸包 ID 列表
  Future<List<String>> _getInstalledPackIds() async {
    try {
      final data = await _client!.getAccountData(
        _client!.userID!,
        installedPacksType,
      );
      return (data['pack_ids'] as List?)?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// 转换贴纸包为 JSON
  Map<String, dynamic> _packToJson(StickerPack pack) {
    final images = <String, dynamic>{};
    for (final sticker in pack.stickers) {
      images[sticker.emoji ?? sticker.id] = {
        'url': sticker.url,
        'body': sticker.name ?? sticker.emoji,
        'info': {
          'w': sticker.width,
          'h': sticker.height,
          'mimetype': sticker.mimeType,
          'size': sticker.size,
        },
      };
    }

    return {
      'pack': {
        'display_name': pack.name,
        'description': pack.description,
        'avatar_url': pack.avatarUrl,
        'author': pack.author,
      },
      'images': images,
    };
  }

  /// 获取常用贴纸
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async {
    if (_client == null) return [];

    try {
      final data = await _client!.getAccountData(
        _client!.userID!,
        recentStickersType,
      );

      final recentList = data['recent'] as List? ?? [];
      final result = <RecentSticker>[];

      for (final item in recentList.take(limit)) {
        if (item is Map<String, dynamic>) {
          final packId = item['pack_id'] as String?;
          final stickerId = item['sticker_id'] as String?;
          final lastUsed = item['last_used'] as int?;
          final count = item['count'] as int? ?? 1;

          if (packId != null && stickerId != null) {
            final pack = await _getPackFromAccountData(packId);
            final sticker = pack?.stickers
                .where((s) => s.id == stickerId)
                .firstOrNull;

            if (sticker != null) {
              result.add(
                RecentSticker(
                  sticker: sticker,
                  packId: packId,
                  lastUsedAt: lastUsed != null
                      ? DateTime.fromMillisecondsSinceEpoch(lastUsed)
                      : DateTime.now(),
                  usageCount: count,
                ),
              );
            }
          }
        }
      }

      return result;
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to get recent stickers: $e');
      return [];
    }
  }

  /// 记录贴纸使用
  Future<void> recordStickerUsage(String packId, String stickerId) async {
    if (_client == null) return;

    try {
      List<Map<String, dynamic>> recentList = [];

      try {
        final data = await _client!.getAccountData(
          _client!.userID!,
          recentStickersType,
        );
        recentList =
            (data['recent'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      } catch (e) {
        // 账户数据不存在，使用空列表
        debugLog('Error: $e');
      }

      // 查找现有记录
      final existingIndex = recentList.indexWhere(
        (item) => item['pack_id'] == packId && item['sticker_id'] == stickerId,
      );

      final now = DateTime.now().millisecondsSinceEpoch;

      if (existingIndex >= 0) {
        // 更新现有记录
        final existing = recentList[existingIndex];
        recentList.removeAt(existingIndex);
        recentList.insert(0, {
          'pack_id': packId,
          'sticker_id': stickerId,
          'last_used': now,
          'count': (existing['count'] as int? ?? 0) + 1,
        });
      } else {
        // 添加新记录
        recentList.insert(0, {
          'pack_id': packId,
          'sticker_id': stickerId,
          'last_used': now,
          'count': 1,
        });
      }

      // 限制列表长度
      if (recentList.length > 50) {
        recentList = recentList.sublist(0, 50);
      }

      await _client!.setAccountData(_client!.userID!, recentStickersType, {
        'recent': recentList,
      });
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to record sticker usage: $e');
    }
  }

  /// 清除常用贴纸记录
  Future<void> clearRecentStickers() async {
    if (_client == null) return;

    try {
      await _client!.setAccountData(_client!.userID!, recentStickersType, {
        'recent': [],
      });
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to clear recent stickers: $e');
    }
  }

  /// 上传贴纸图片
  Future<String?> uploadStickerImage(
    Uint8List bytes,
    String filename,
    String? mimeType,
  ) async {
    if (_client == null) return null;

    try {
      final uri = await _client!.uploadContent(
        bytes,
        filename: filename,
        contentType: mimeType,
      );
      return uri.toString();
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to upload sticker: $e');
      return null;
    }
  }

  /// 获取 HTTP URL
  String? _getHttpUrl(String? mxcUrl) {
    return MatrixUtils.getMediaDownloadUrl(mxcUrl, client: _client);
  }

  /// 内置 asset 贴纸上传后的 mxc 缓存（避免每次发送重复上传）
  static final Map<String, String> _assetMxcCache = {};

  /// 发送贴纸消息
  Future<String?> sendStickerMessage(String roomId, Sticker sticker) async {
    if (_client == null) return null;

    try {
      final room = _client!.getRoomById(roomId);
      if (room == null) return null;

      // 如果是 emoji 贴纸，发送为文本消息
      if (sticker.url.startsWith('emoji:')) {
        final emoji = sticker.url.substring(6);
        return await room.sendTextEvent(emoji);
      }

      // 内置 asset 贴纸（SVG）：首次发送时把资源字节上传到媒体库换取 mxc，
      // 之后复用缓存。这样接收方（含其它客户端）可从媒体库下载渲染。
      var mxcUrl = sticker.url;
      if (BundledStickerPacks.isAssetSticker(sticker.url)) {
        final cached = _assetMxcCache[sticker.url];
        if (cached != null) {
          mxcUrl = cached;
        } else {
          final path = BundledStickerPacks.assetPath(sticker.url);
          final data = await rootBundle.load(path);
          final bytes = data.buffer.asUint8List();
          final filename = path.split('/').last;
          final uploaded = await uploadStickerImage(
            bytes,
            filename,
            BundledStickerPacks.mimeForAsset(sticker.url),
          );
          if (uploaded == null) {
            // 上传失败兜底：发 emoji 文本，保证用户操作有反馈
            return await room.sendTextEvent(sticker.emoji ?? sticker.name ?? '🙂');
          }
          _assetMxcCache[sticker.url] = uploaded;
          mxcUrl = uploaded;
        }
      }

      // 发送图片贴纸
      final content = {
        'body': sticker.name ?? sticker.emoji ?? 'sticker',
        'url': mxcUrl,
        'info': {
          'w': sticker.width ?? 256,
          'h': sticker.height ?? 256,
          'mimetype': sticker.mimeType ?? 'image/png',
          if (sticker.size != null) 'size': sticker.size,
        },
      };

      return await room.sendEvent(content, type: 'm.sticker');
    } catch (e) {
      debugLog('MatrixStickerDataSource: Failed to send sticker: $e');
      return null;
    }
  }
}
