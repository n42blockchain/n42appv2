import 'giphy_service.dart';

/// GIF data source shared by the expression panel and its providers.
abstract class GifService {
  bool get isAvailable;

  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    String? cursor,
    int? limit,
    String rating = 'g',
  });

  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    String? cursor,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  });
}

/// First-page fallback with subsequent pages pinned to the selected provider.
/// A failed continuation must be retried, not mixed with another source's page.
class CompositeGifService implements GifService {
  final List<GifService> providers;

  CompositeGifService(List<GifService> providers)
    : providers = List.unmodifiable(providers);

  @override
  bool get isAvailable => providers.any((provider) => provider.isAvailable);

  @override
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    String? cursor,
    int? limit,
    String rating = 'g',
  }) => _load(
    offset,
    cursor,
    (provider, token) => provider.getTrendingGifs(
      offset: offset,
      cursor: token,
      limit: limit,
      rating: rating,
    ),
  );

  @override
  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    String? cursor,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  }) => _load(
    offset,
    cursor,
    (provider, token) => provider.searchGifs(
      query: query,
      offset: offset,
      cursor: token,
      limit: limit,
      rating: rating,
      lang: lang,
    ),
  );

  Future<GiphySearchResult> _load(
    int offset,
    String? cursor,
    Future<GiphySearchResult> Function(GifService, String?) fetch,
  ) async {
    GiphySearchResult failure() => GiphySearchResult(
      gifs: const [],
      totalCount: 0,
      offset: offset,
      isError: true,
    );

    GiphySearchResult wrap(
      GiphySearchResult result,
      int index,
    ) => GiphySearchResult(
      gifs: result.gifs,
      totalCount: result.totalCount,
      offset: result.offset,
      isError: result.isError,
      provider: result.provider,
      nextCursor: result.hasMore
          ? '$index:${result.nextCursor ?? (result.offset + result.gifs.length).toString()}'
          : null,
    );

    if (cursor != null) {
      final separator = cursor.indexOf(':');
      if (separator < 1) return failure();
      final index = int.tryParse(cursor.substring(0, separator));
      if (index == null ||
          index < 0 ||
          index >= providers.length ||
          !providers[index].isAvailable) {
        return failure();
      }
      final token = cursor.substring(separator + 1);
      try {
        return wrap(
          await fetch(
            providers[index],
            token.isEmpty ? null : token,
          ).timeout(const Duration(seconds: 8)),
          index,
        );
      } catch (_) {
        return failure();
      }
    }

    GiphySearchResult? emptySuccess;
    for (var index = 0; index < providers.length; index++) {
      final provider = providers[index];
      if (!provider.isAvailable) continue;
      try {
        final result = await fetch(
          provider,
          null,
        ).timeout(const Duration(seconds: 8));
        if (result.isError) continue;
        if (result.gifs.isNotEmpty) return wrap(result, index);
        emptySuccess = result;
      } catch (_) {
        // Another configured provider may still satisfy the first-page request.
      }
    }
    return emptySuccess ?? failure();
  }
}
