import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/title.dart';
import 'package:luma/repositories/tmdb_catalog_repository.dart';
import 'package:luma/repositories/playback_repository.dart';

void main() {
  test(
    'Real metadata uses scoped IDs, original titles and correct image URLs',
    () {
      final title = TmdbCatalogRepository.mapTitle({
        'id': 11,
        'title': 'Star Wars',
        'release_date': '1977-05-25',
        'overview': 'Overview',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
      }, TitleKind.movie);
      expect(title.id, 'tmdb-movie-11');
      expect(title.name, 'Star Wars');
      expect(title.year, 1977);
      expect(title.image, 'https://image.tmdb.org/t/p/w500/poster.jpg');
      expect(title.backdrop, 'https://image.tmdb.org/t/p/w1280/backdrop.jpg');
      expect(title.playable, false);
      expect(title.metadata.contains('0 min'), false);
    },
  );
  test(
    'Incomplete series metadata does not invent release dates or seasons',
    () {
      final title = TmdbCatalogRepository.mapTitle({
        'id': 11,
        'name': 'A series',
      }, TitleKind.series);
      expect(title.id, 'tmdb-tv-11');
      expect(title.metadata, 'TV series');
      expect(title.image, isEmpty);
      expect(title.episodes, isEmpty);
    },
  );
  test('Real title IDs cannot play an unrelated sample', () async {
    expect(
      await SamplePlaybackRepository().sources('tmdb-movie-11', null),
      isEmpty,
    );
  });
}
