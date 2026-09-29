import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';

import 'download_store.dart';

class DownloadStorage implements DownloadStore {
  @override
  bool get supported => false;
  @override
  Future<void> download(
    String key,
    String url,
    CancelToken token,
    void Function(int, int) progress,
  ) async =>
      throw UnsupportedError('Use the Android or iOS app to download videos.');
  @override
  Future<bool> exists(String key, int expectedBytes) async => false;
  @override
  Future<void> remove(String key) async {}
  @override
  Future<VideoPlayerController> controller(String key) async =>
      throw UnsupportedError('Offline playback requires the mobile app.');
}
