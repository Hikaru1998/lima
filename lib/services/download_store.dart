import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';

abstract interface class DownloadStore {
  bool get supported;
  Future<void> download(
    String key,
    String url,
    CancelToken token,
    void Function(int, int) progress,
  );
  Future<bool> exists(String key, int expectedBytes);
  Future<void> remove(String key);
  Future<VideoPlayerController> controller(String key);
}
