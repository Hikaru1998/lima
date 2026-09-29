import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

class LibraryState {
  const LibraryState({
    this.saved = const [],
    this.progress = const {},
    this.recent = const [],
    this.autoplay = true,
  });
  final List<String> saved, recent;
  final Map<String, double> progress;
  final bool autoplay;
}

final libraryProvider = NotifierProvider<LibraryController, LibraryState>(
  LibraryController.new,
);

class LibraryController extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    final p = ref.read(preferencesProvider);
    Map<String, double> progress = {};
    try {
      progress =
          (jsonDecode(p.getString('progress') ?? '{}') as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      /* Recover a corrupt cache. */
    }
    return LibraryState(
      saved: p.getStringList('saved') ?? [],
      progress: progress,
      recent: p.getStringList('recent') ?? [],
      autoplay: p.getBool('autoplay') ?? true,
    );
  }

  void toggle(String id) {
    final saved = [...state.saved];
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    state = LibraryState(
      saved: saved,
      progress: state.progress,
      recent: state.recent,
      autoplay: state.autoplay,
    );
    ref.read(preferencesProvider).setStringList('saved', saved);
  }

  void remember(String key, double seconds) {
    state = LibraryState(
      saved: state.saved,
      progress: {...state.progress, key: seconds},
      recent: state.recent,
      autoplay: state.autoplay,
    );
    ref
        .read(preferencesProvider)
        .setString('progress', jsonEncode(state.progress));
  }

  void search(String query) {
    if (query.trim().isEmpty) return;
    final recent = [
      query.trim(),
      ...state.recent.where((e) => e != query.trim()),
    ].take(6).toList();
    state = LibraryState(
      saved: state.saved,
      progress: state.progress,
      recent: recent,
      autoplay: state.autoplay,
    );
    ref.read(preferencesProvider).setStringList('recent', recent);
  }

  void autoplay(bool value) {
    state = LibraryState(
      saved: state.saved,
      progress: state.progress,
      recent: state.recent,
      autoplay: value,
    );
    ref.read(preferencesProvider).setBool('autoplay', value);
  }

  void clearHistory() {
    state = LibraryState(
      saved: state.saved,
      recent: state.recent,
      autoplay: state.autoplay,
    );
    ref.read(preferencesProvider).remove('progress');
  }
}
