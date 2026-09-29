import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/download_record.dart';
import '../services/download_storage.dart';
import '../services/download_store.dart';
import 'library_provider.dart';
import 'playback_provider.dart';

final downloadStorageProvider = Provider<DownloadStore>(
  (ref) => DownloadStorage(),
);
final downloadsProvider =
    NotifierProvider<DownloadsController, Map<String, DownloadRecord>>(
      DownloadsController.new,
    );

class DownloadsController extends Notifier<Map<String, DownloadRecord>> {
  final _tokens = <String, CancelToken>{};
  bool _disposed = false;
  @override
  Map<String, DownloadRecord> build() {
    ref.onDispose(() {
      _disposed = true;
      for (final token in _tokens.values) {
        token.cancel();
      }
    });
    try {
      final list = jsonDecode(
        ref.read(preferencesProvider).getString('downloads') ?? '[]',
      ) as List;
      return {
        for (final json in list)
          (json as Map<String, dynamic>)['key'] as String:
              DownloadRecord.fromJson(json),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _persist() async {
    await ref
        .read(preferencesProvider)
        .setString(
          'downloads',
          jsonEncode(state.values.map((e) => e.toJson()).toList()),
        );
  }

  Future<void> start(String titleId, String name, {String? episodeId}) async {
    final key = episodeId ?? titleId;
    if (_tokens.containsKey(key) ||
        state[key]?.status == DownloadStatus.complete) {
      return;
    }
    final storage = ref.read(downloadStorageProvider);
    final repository = ref.read(playbackRepositoryProvider);
    final token = CancelToken();
    _tokens[key] = token;
    state = {
      ...state,
      key: DownloadRecord(
        key: key,
        titleId: titleId,
        name: name,
        episodeId: episodeId,
      ),
    };
    try {
      await _persist();
      if (!storage.supported) {
        throw UnsupportedError('Downloads are available in the mobile app.');
      }
      final sources = await repository.sources(titleId, episodeId);
      if (token.isCancelled) {
        throw token.cancelError!;
      }
      final eligible = sources.where((s) => s.downloadable && !s.hls);
      if (eligible.isEmpty) {
        throw UnsupportedError('This video is not available for download.');
      }
      var lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
      await storage.download(key, eligible.first.url, token, (received, total) {
        if (_disposed || token.isCancelled) return;
        final now = DateTime.now();
        if (received != total &&
            now.difference(lastUpdate).inMilliseconds < 250) {
          return;
        }
        lastUpdate = now;
        state = {
          ...state,
          key: state[key]!.withState(
            DownloadStatus.downloading,
            received: received,
            total: total,
          ),
        };
      });
      if (_disposed) return;
      if (token.isCancelled) {
        await storage.remove(key);
        state = {...state}..remove(key);
        return;
      }
      state = {...state, key: state[key]!.withState(DownloadStatus.complete)};
    } catch (error) {
      if (_disposed) return;
      if (token.isCancelled) {
        state = {...state}..remove(key);
      } else {
        state = {
          ...state,
          key: state[key]!.withState(
            DownloadStatus.failed,
            message: error is UnsupportedError ? error.message : 'Download stopped. Check your connection and free space, then retry.',
          ),
        };
      }
    } finally {
      _tokens.remove(key);
      if (!_disposed) await _persist();
    }
  }

  void cancel(String key) => _tokens[key]?.cancel();
  Future<void> remove(String key) async {
    if (_tokens.containsKey(key)) {
      cancel(key);
      return;
    }
    await ref.read(downloadStorageProvider).remove(key);
    state = {...state}..remove(key);
    await _persist();
  }

  Future<bool> available(String key) async {
    final record = state[key];
    if (record?.status != DownloadStatus.complete) return false;
    if (await ref.read(downloadStorageProvider).exists(key, record!.total)) {
      return true;
    }
    if (!_disposed) {
      state = {
        ...state,
        key: record.withState(
          DownloadStatus.failed,
          message: 'Local file is missing. Download it again.',
        ),
      };
      await _persist();
    }
    return false;
  }
}
