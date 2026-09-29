import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'download_store.dart';

/// Files are private to the app; only finalized, validated files are playable.
class DownloadStorage implements DownloadStore {
  DownloadStorage({Dio? client, Future<Directory> Function()? directory})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 45),
            ),
          ),
      _directory = directory ?? getApplicationSupportDirectory;
  final Dio _client;
  final Future<Directory> Function() _directory;
  @override
  bool get supported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS;
  Future<File> _file(String key) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(key)) {
      throw ArgumentError('Invalid video key');
    }
    final root = await _directory();
    final folder = await Directory('${root.path}/downloads')
        .create(recursive: true);
    return File('${folder.path}/$key.mp4');
  }

  @override
  Future<void> download(
    String key,
    String url,
    CancelToken token,
    void Function(int, int) progress,
  ) async {
    final file = await _file(key);
    final partial = File('${file.path}.part');
    try {
      final response = await _client.download(
        url,
        partial.path,
        cancelToken: token,
        onReceiveProgress: progress,
        deleteOnError: true,
      );
      if (token.isCancelled) {
        throw token.cancelError!;
      }
      final size = await partial.length();
      final expected = int.tryParse(
        response.headers.value('content-length') ?? '',
      );
      if (size == 0 || (expected != null && size != expected)) {
        throw const FormatException('Incomplete video');
      }
      final handle = await partial.open();
      final header = await handle.read(12);
      await handle.close();
      if (header.length < 12 ||
          String.fromCharCodes(header.sublist(4, 8)) != 'ftyp') {
        throw const FormatException('Invalid MP4 response');
      }
      if (token.isCancelled) {
        throw token.cancelError!;
      }
      await partial.rename(file.path);
      progress(size, size);
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  @override
  Future<bool> exists(String key, int expectedBytes) async {
    final file = await _file(key);
    return await file.exists() &&
        await file.length() > 0 &&
        (expectedBytes <= 0 || await file.length() == expectedBytes);
  }

  @override
  Future<void> remove(String key) async {
    final file = await _file(key);
    for (final candidate in [file, File('${file.path}.part')]) {
      if (await candidate.exists()) await candidate.delete();
    }
  }

  @override
  Future<VideoPlayerController> controller(String key) async =>
      VideoPlayerController.file(await _file(key));
}
