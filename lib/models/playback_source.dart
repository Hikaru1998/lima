class PlaybackSource {
  const PlaybackSource({
    required this.url,
    required this.label,
    this.hls = false,
    this.downloadable = false,
    this.subtitles,
    this.audioTracks = const ['Original'],
  });
  final String url, label;
  final bool hls;
  final bool downloadable;
  final String? subtitles;
  final List<String> audioTracks;
}
