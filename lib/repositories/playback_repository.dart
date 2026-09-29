import '../models/playback_source.dart';

abstract interface class PlaybackRepository {
  Future<List<PlaybackSource>> sources(String titleId, String? episodeId);
}

class SamplePlaybackRepository implements PlaybackRepository {
  @override
  Future<List<PlaybackSource>> sources(
    String titleId,
    String? episodeId,
  ) async {
    // Metadata IDs must never fall through to unrelated demonstration media.
    if (titleId.startsWith('tmdb-')) return const [];
    return const [
      PlaybackSource(
        url: 'https://media.w3.org/2010/05/bunny/trailer.mp4',
        label: 'Standard',
        downloadable: true,
        subtitles: '1\n00:00:00,000 --> 00:00:06,000\nBig Buck Bunny — Blender Foundation\n\n2\n00:00:06,000 --> 00:00:12,000\nBig Buck Bunny — Blender Foundation\n',
      ),
      PlaybackSource(
        url: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
        label: 'Adaptive',
        hls: true,
      ),
    ];
  }
}
