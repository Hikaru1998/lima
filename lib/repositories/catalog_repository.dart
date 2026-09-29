import '../models/title.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogTitle>> fetchCatalog();
}

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<CatalogTitle>> fetchCatalog() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return demoCatalog;
  }
}

// Fictional metadata; all playback is explicitly labelled as a sample.
const demoCatalog = [
  CatalogTitle(
    id: 'wild',
    name: 'THE LAST\nWILDERNESS',
    tagline: 'Some places change you forever.',
    description: 'Beyond the edge of the familiar, a photographer follows the last light into an untouched world. A quiet journey through wild landscapes and the things we leave behind.',
    image: 'photo-1464822759023-fed622ff2c3b',
    year: 2026,
    genre: 'Adventure',
  ),
  CatalogTitle(
    id: 'ocean',
    name: 'DEEP BLUE',
    tagline: 'A world beneath our own.',
    description:
        'Follow a small research crew into the mysteries of the open ocean.',
    image: 'photo-1518837695005-2083093ee35b',
    year: 2026,
    genre: 'Nature',
    kind: TitleKind.series,
    episodes: [
      Episode(
        'ocean-s1e1',
        1,
        1,
        'Into the blue',
        'The journey begins at the continental shelf.',
      ),
      Episode('ocean-s1e2', 1, 2, 'Hidden currents', 'Life below the surface.'),
      Episode(
        'ocean-s2e1',
        2,
        1,
        'The long return',
        'Following the currents home.',
      ),
    ],
  ),
  CatalogTitle(
    id: 'night',
    name: 'AFTER HOURS',
    tagline: 'The city has a story.',
    description: 'Two strangers cross paths on the last train home. An atmospheric city drama.',
    image: 'photo-1519608487953-e999c86e7455',
    year: 2025,
    genre: 'Drama',
    minutes: 10,
  ),
  CatalogTitle(
    id: 'desert',
    name: 'DUNE ROAD',
    tagline: 'Find your own way.',
    description: 'A desert journey becomes a search for belonging.',
    image: 'photo-1509316785289-025f5b846b35',
    year: 2026,
    genre: 'Adventure',
    minutes: 15,
  ),
  CatalogTitle(
    id: 'forest',
    name: 'STILL EARTH',
    tagline: 'Listen a little closer.',
    description: 'Small stories from the planet’s quietest corners.',
    image: 'photo-1441974231531-c6227db76b6e',
    year: 2025,
    genre: 'Nature',
    kind: TitleKind.series,
    episodes: [
      Episode(
        'forest-s1e1',
        1,
        1,
        'First light',
        'Morning in the ancient forest.',
      ),
      Episode('forest-s1e2', 1, 2, 'After the rain', 'The forest comes alive.'),
    ],
  ),
  CatalogTitle(
    id: 'space',
    name: 'ORBIT',
    tagline: 'Home is a distant light.',
    description: 'An explorer rethinks what it means to come home.',
    image: 'photo-1446776811953-b23d57bd21aa',
    year: 2024,
    genre: 'Sci-fi',
    minutes: 9,
  ),
];
