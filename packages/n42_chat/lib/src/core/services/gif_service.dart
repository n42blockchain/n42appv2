import 'giphy_service.dart';

/// Unified GIF data source interface.
abstract class GifService {
  /// Whether the provider is configured with a key or proxy endpoint.
  bool get isAvailable;

  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    int? limit,
    String rating = 'g',
  });

  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  });
}

/// Tries GIF providers in order and returns the first non-empty result.
class CompositeGifService implements GifService {
  final List<GifService> providers;

  CompositeGifService(this.providers);

  List<GifService> get _available =>
      providers.where((provider) => provider.isAvailable).toList();

  @override
  bool get isAvailable => _available.isNotEmpty;

  @override
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    int? limit,
    String rating = 'g',
  }) async {
    var last = GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
    for (final provider in _available) {
      final result = await provider.getTrendingGifs(
        offset: offset,
        limit: limit,
        rating: rating,
      );
      if (result.gifs.isNotEmpty) return result;
      last = result;
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
    for (final provider in _available) {
      final result = await provider.searchGifs(
        query: query,
        offset: offset,
        limit: limit,
        rating: rating,
        lang: lang,
      );
      if (result.gifs.isNotEmpty) return result;
      last = result;
    }
    return last;
  }
}
