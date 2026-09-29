import 'package:dio/dio.dart';

import '../models/title.dart';
import 'catalog_repository.dart';

/// Metadata only. TMDB identifiers never imply that a playable stream exists.
/// Kept opt-in until API credentials and attribution assets are configured.
class TmdbCatalogRepository implements CatalogRepository {
  TmdbCatalogRepository({required String readAccessToken, Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.themoviedb.org/3',
              headers: {
                'Authorization': 'Bearer $readAccessToken',
                'accept': 'application/json',
              },
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );
  final Dio _client;

  @override
  Future<List<CatalogTitle>> fetchCatalog() async {
    final responses = await Future.wait([
      _client.get<Map<String, dynamic>>(
        '/movie/popular',
        queryParameters: {'language': 'en-US', 'page': 1},
      ),
      _client.get<Map<String, dynamic>>(
        '/tv/popular',
        queryParameters: {'language': 'en-US', 'page': 1},
      ),
    ]);
    return [
      for (var i = 0; i < responses.length; i++)
        for (final item in (responses[i].data?['results'] as List? ?? []))
          if (item is Map<String, dynamic> && item['adult'] != true)
            mapTitle(item, i == 0 ? TitleKind.movie : TitleKind.series),
    ];
  }

  static CatalogTitle mapTitle(Map<String, dynamic> item, TitleKind kind) {
    final movie = kind == TitleKind.movie;
    final id = item['id'];
    if (id is! int || id <= 0)
      throw const FormatException('Invalid TMDB title ID');
    final date =
        (item[movie ? 'release_date' : 'first_air_date'] as String?) ?? '';
    final poster = item['poster_path'] as String?;
    final backdrop = item['backdrop_path'] as String?;
    return CatalogTitle(
      id: 'tmdb-${movie ? 'movie' : 'tv'}-$id',
      name: (item[movie ? 'title' : 'name'] as String?) ?? 'Untitled',
      tagline: '',
      description: (item['overview'] as String?) ?? '',
      image: poster == null ? '' : 'https://image.tmdb.org/t/p/w500$poster',
      backdrop: backdrop == null
          ? null
          : 'https://image.tmdb.org/t/p/w1280$backdrop',
      year: date.length >= 4 ? int.tryParse(date.substring(0, 4)) ?? 0 : 0,
      genre: movie ? 'Movie' : 'TV series',
      kind: kind,
      minutes: 0,
      playable: false,
    );
  }
}
