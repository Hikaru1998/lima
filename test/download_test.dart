import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:luma/models/playback_source.dart';
import 'package:luma/models/download_record.dart';
import 'package:luma/providers/download_provider.dart';
import 'package:luma/providers/library_provider.dart';
import 'package:luma/providers/playback_provider.dart';
import 'package:luma/repositories/playback_repository.dart';
import 'package:luma/services/download_storage_io.dart';
import 'package:luma/services/buffer_status.dart';

class LocalRepository implements PlaybackRepository {
  LocalRepository(this.url);
  final String url;
  @override
  Future<List<PlaybackSource>> sources(
    String titleId,
    String? episodeId,
  ) async => [
    PlaybackSource(url: url, label: 'Local fixture', downloadable: true),
  ];
}

void main() {
  test(
    'Completed downloads persist, work with server offline, and can be removed',
    () async {
      final root = await Directory.systemTemp.createTemp('luma_download_test');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final bytes = [
        0,
        0,
        0,
        24,
        ...ascii.encode('ftypisom'),
        ...List.filled(1024, 0),
      ];
      server.listen((request) async {
        request.response.contentLength = bytes.length;
        request.response.add(bytes);
        await request.response.close();
      });
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = DownloadStorage(directory: () async => root);
      final overrides = [
        preferencesProvider.overrideWithValue(prefs),
        downloadStorageProvider.overrideWithValue(storage),
        playbackRepositoryProvider.overrideWithValue(
          LocalRepository('http://127.0.0.1:${server.port}/video.mp4'),
        ),
      ];
      final first = ProviderContainer(overrides: overrides);
      await first
          .read(downloadsProvider.notifier)
          .start('ocean', 'Ocean episode', episodeId: 'ocean-s1e1');
      expect(
        first.read(downloadsProvider)['ocean-s1e1']!.status,
        DownloadStatus.complete,
      );
      first.dispose();
      await server.close(force: true);
      final second = ProviderContainer(overrides: overrides);
      expect(
        await second.read(downloadsProvider.notifier).available('ocean-s1e1'),
        true,
      );
      final player = await storage.controller('ocean-s1e1');
      expect(player.dataSourceType, DataSourceType.file);
      expect(second.read(downloadsProvider)['ocean-s1e1']!.total, bytes.length);
      await second.read(downloadsProvider.notifier).remove('ocean-s1e1');
      expect(await storage.exists('ocean-s1e1', bytes.length), false);
      expect(second.read(downloadsProvider), isEmpty);
      second.dispose();
      await root.delete(recursive: true);
    },
  );
  test(
    'Invalid responses and cancelled downloads never become offline files',
    () async {
      final root = await Directory.systemTemp.createTemp('luma_invalid_test');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.write('<html>denied</html>');
        await request.response.close();
      });
      final storage = DownloadStorage(directory: () async => root);
      final url = 'http://127.0.0.1:${server.port}/video.mp4';
      await expectLater(
        storage.download('bad', url, CancelToken(), (_, _) {}),
        throwsFormatException,
      );
      expect(await storage.exists('bad', 0), false);
      final token = CancelToken()..cancel();
      await expectLater(
        storage.download('cancelled', url, token, (_, _) {}),
        throwsA(isA<DioException>()),
      );
      expect(await storage.exists('cancelled', 0), false);
      expect(
        await File('${root.path}/downloads/cancelled.mp4.part').exists(),
        false,
      );
      await server.close(force: true);
      await root.delete(recursive: true);
    },
  );
  test('Interrupted downloads restore as retryable rather than complete', () {
    final record = DownloadRecord.fromJson({
      'key': 'wild',
      'titleId': 'wild',
      'name': 'Wild',
      'status': 'downloading',
      'received': 10,
      'total': 100,
    });
    expect(record.status, DownloadStatus.failed);
  });
  test('Buffer indicator excludes disconnected ranges', () {
    final value = VideoPlayerValue(
      duration: const Duration(minutes: 20),
      position: const Duration(minutes: 1),
      buffered: [
        DurationRange(Duration.zero, const Duration(minutes: 4)),
        DurationRange(const Duration(minutes: 8), const Duration(minutes: 10)),
      ],
    );
    expect(bufferedUntil(value) - value.position, const Duration(minutes: 3));
  });
}
