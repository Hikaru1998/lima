import 'package:video_player/video_player.dart';

/// Only contiguous data ahead of the playhead counts as usable buffering.
Duration bufferedUntil(VideoPlayerValue value) {
  var end = value.position;
  final ranges = [...value.buffered]
    ..sort((a, b) => a.start.compareTo(b.start));
  for (final range in ranges) {
    if (range.start <= end && range.end > end) end = range.end;
  }
  return end > value.duration ? value.duration : end;
}
