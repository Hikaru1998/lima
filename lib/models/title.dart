enum TitleKind { movie, series }

class Episode {
  const Episode(this.id, this.season, this.number, this.name, this.description);
  final String id, name, description;
  final int season, number;
}

class CatalogTitle {
  const CatalogTitle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.image,
    required this.year,
    required this.genre,
    this.kind = TitleKind.movie,
    this.minutes = 12,
    this.episodes = const [],
    this.backdrop,
    this.playable = true,
  });
  final String id, name, tagline, description, image, genre;
  final int year, minutes;
  final TitleKind kind;
  final List<Episode> episodes;
  final String? backdrop;
  final bool playable;
  String get metadata => [
    if (year > 0) '$year',
    genre,
    if (kind == TitleKind.series && episodes.isNotEmpty)
      '${episodes.map((e) => e.season).toSet().length} seasons',
    if (kind == TitleKind.movie && minutes > 0) '$minutes min',
  ].join('  •  ');
}
