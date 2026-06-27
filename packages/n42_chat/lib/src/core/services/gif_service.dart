import 'giphy_service.dart';

/// 统一 GIF 数据源接口
///
/// 让 GIF 选择器与具体提供方（Giphy / Tenor / 代理）解耦。
/// 复用 [GiphySearchResult] / [GiphyGif] 作为中性返回模型，避免重写 UI。
abstract class GifService {
  /// 当前源是否可用（已配置 key 或代理端点）
  bool get isAvailable;

  /// 热门 GIF
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    int? limit,
    String rating = 'g',
  });

  /// 搜索 GIF
  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  });
}

/// 多源聚合 GIF 服务
///
/// 按 [providers] 顺序尝试（如 Giphy 主、Tenor 兜底）：返回首个有结果的源；
/// 全部为空/失败则返回最后一次结果。"任一可用即可"。
class CompositeGifService implements GifService {
  final List<GifService> providers;

  CompositeGifService(this.providers);

  List<GifService> get _available =>
      providers.where((p) => p.isAvailable).toList();

  @override
  bool get isAvailable => _available.isNotEmpty;

  @override
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    int? limit,
    String rating = 'g',
  }) async {
    var last = GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
    for (final p in _available) {
      final r = await p.getTrendingGifs(
        offset: offset,
        limit: limit,
        rating: rating,
      );
      if (r.gifs.isNotEmpty) return r;
      last = r;
    }
    return last;
  }

  @override
  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  }) async {
    var last = GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
    for (final p in _available) {
      final r = await p.searchGifs(
        query: query,
        offset: offset,
        limit: limit,
        rating: rating,
        lang: lang,
      );
      if (r.gifs.isNotEmpty) return r;
      last = r;
    }
    return last;
  }
}
