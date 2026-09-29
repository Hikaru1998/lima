import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/playback_source.dart';

/// Adapter boundary for future native track selection / DRM implementations.
/// video_player_android uses Media3; AVFoundation is selected on iOS.
class PlayerService {
  VideoPlayerController? controller;
  Future<void> open(
    PlaybackSource source,
    Duration resume, {
    VideoPlayerController? localController,
  }) async {
    final previous = controller;
    controller = null;
    await previous?.dispose();
    final next =
        localController ??
        VideoPlayerController.networkUrl(
          Uri.parse(source.url),
          formatHint: source.hls ? VideoFormat.hls : null,
          closedCaptionFile: source.subtitles == null
              ? null
              : Future.value(SubRipCaptionFile(source.subtitles!)),
        );
    controller = next;
    await next.initialize();
    if (resume < next.value.duration) await next.seekTo(resume);
    await next.play();
  }

  Future<void> seekBy(int seconds) async {
    final c = controller;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(
      Duration(
        milliseconds: (c.value.position.inMilliseconds + seconds * 1000).clamp(
          0,
          c.value.duration.inMilliseconds,
        ),
      ),
    );
  }

  Future<bool> pictureInPicture() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await const MethodChannel('luma/pip')
              .invokeMethod<bool>('enter') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> dispose() async {
    await controller?.dispose();
    controller = null;
  }
}
