import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../models/playback_source.dart';
import '../models/title.dart';
import '../providers/catalog_provider.dart';
import '../providers/library_provider.dart';
import '../providers/playback_provider.dart';
import '../providers/download_provider.dart';
import '../services/player_service.dart';
import '../services/buffer_status.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
    required this.id,
    this.episodeId,
    this.offlineOnly = false,
  });
  final bool offlineOnly;
  final String id;
  final String? episodeId;
  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  final service = PlayerService();
  List<PlaybackSource> sources = [];
  CatalogTitle? title;
  String? episodeId, error;
  bool offline = false;
  bool loading = true,
      captions = false,
      controls = true,
      advancing = false,
      pip = false;
  int sourceIndex = 0, lastSaved = -1;
  Timer? hideTimer;
  String get progressKey => episodeId ?? widget.id;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    unawaited(initialize());
  }

  Future<void> initialize() async {
    try {
      final catalog = await ref.read(catalogProvider.future);
      if (!mounted) return;
      title = catalog.firstWhere((t) => t.id == widget.id);
      episodeId =
          episodeId ??
          widget.episodeId ??
          (title!.episodes.isEmpty ? null : title!.episodes.first.id);
      if (episodeId != null && !title!.episodes.any((e) => e.id == episodeId)) {
        throw StateError('Episode unavailable');
      }
      offline = await ref
          .read(downloadsProvider.notifier)
          .available(progressKey);
      if (!mounted) return;
      if (widget.offlineOnly && !offline) {
        throw StateError('Download unavailable');
      }
      sourceIndex = 0;
      sources = offline
          ? [const PlaybackSource(url: '', label: 'Offline')]
          : await ref
                .read(playbackRepositoryProvider)
                .sources(widget.id, episodeId);
      if (mounted) await open();
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'This video could not load. Check your connection or downloads and try again.';
        });
      }
    }
  }

  Future<void> open({Duration? position}) async {
    if (!mounted) return;
    save();
    service.controller?.removeListener(tick);
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await service.open(
        sources[sourceIndex],
        position ??
            Duration(
              seconds: (ref.read(libraryProvider).progress[progressKey] ?? 0)
                  .floor(),
            ),
        localController: offline
            ? await ref.read(downloadStorageProvider).controller(progressKey)
            : null,
      );
      if (!mounted) {
        await service.dispose();
        return;
      }
      service.controller!.addListener(tick);
      setState(() => loading = false);
      scheduleHide();
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Playback is unavailable. Retry or choose another source.';
        });
      }
    }
  }

  void tick() {
    if (!mounted) return;
    final v = service.controller!.value;
    if (v.hasError && error == null) {
      setState(() => error = 'The stream stopped. Try loading it again.');
    }
    if (v.position.inSeconds ~/ 5 != lastSaved && v.isInitialized) {
      lastSaved = v.position.inSeconds ~/ 5;
      save();
    }
    if (v.isCompleted &&
        !advancing &&
        nextEpisode != null &&
        ref.read(libraryProvider).autoplay) {
      unawaited(next());
    }
  }

  Episode? get nextEpisode {
    final episodes = title?.episodes ?? [];
    final i = episodes.indexWhere((e) => e.id == episodeId);
    return i >= 0 && i + 1 < episodes.length ? episodes[i + 1] : null;
  }

  Future<void> next() async {
    final e = nextEpisode;
    if (e == null) return;
    advancing = true;
    save();
    service.controller?.removeListener(tick);
    await service.dispose();
    if (!mounted) return;
    episodeId = e.id;
    lastSaved = -1;
    offline = await ref.read(downloadsProvider.notifier).available(progressKey);
    if (!mounted) return;
    if (widget.offlineOnly && !offline) {
      setState(() {
        loading = false;
        error = 'Download the next episode to watch it offline.';
      });
      advancing = false;
      return;
    }
    sources = offline
        ? [const PlaybackSource(url: '', label: 'Offline')]
        : await ref
              .read(playbackRepositoryProvider)
              .sources(widget.id, episodeId);
    sourceIndex = 0;
    await open(position: Duration.zero);
    advancing = false;
  }

  void save() {
    final c = service.controller;
    if (c != null && c.value.isInitialized) {
      ref
          .read(libraryProvider.notifier)
          .remember(progressKey, c.value.position.inSeconds.toDouble());
    }
  }

  void scheduleHide() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && service.controller?.value.isPlaying == true) {
        setState(() => controls = false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !pip) {
      service.controller?.pause();
      save();
    }
    if (state == AppLifecycleState.resumed) pip = false;
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    service.controller?.removeListener(tick);
    unawaited(service.dispose());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  String time(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  Future<void> options() async {
    hideTimer?.cancel();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Playback settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Playback source'),
                ...sources.asMap().entries.map(
                  (e) => ListTile(
                    title: Text(e.value.label),
                    subtitle: Text(
                      e.value.hls
                          ? 'Adaptive HLS · Apple test pattern'
                          : 'Big Buck Bunny · Blender Foundation',
                    ),
                    trailing: sourceIndex == e.key
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      sourceIndex = e.key;
                      unawaited(open(position: Duration.zero));
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('Subtitles'),
                  subtitle: Text(
                    sources[sourceIndex].subtitles == null
                        ? 'No sidecar captions on this source'
                        : 'English',
                  ),
                  value: captions,
                  onChanged: sources[sourceIndex].subtitles == null
                      ? null
                      : (v) {
                          setState(() => captions = v);
                          Navigator.pop(sheetContext);
                        },
                ),
                const ListTile(
                  title: Text('Audio · Original'),
                  subtitle: Text('No alternate audio tracks available.'),
                ),
                const Text(
                  'Streaming quality adapts automatically to your connection.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final c = service.controller;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) save();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            setState(() => controls = !controls);
            scheduleHide();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (c != null && !loading && error == null)
                Center(
                  child: AspectRatio(
                    aspectRatio: c.value.aspectRatio,
                    child: VideoPlayer(c),
                  ),
                ),
              if (loading) const Center(child: CircularProgressIndicator()),
              if (error != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: initialize,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              if (c != null && captions && !loading)
                Positioned(
                  bottom: 95,
                  left: 40,
                  right: 40,
                  child: ValueListenableBuilder(
                    valueListenable: c,
                    builder: (_, value, child) =>
                        ClosedCaption(text: value.caption.text),
                  ),
                ),
              if (controls || error != null || loading)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              if (controls || error != null || loading)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Close player',
                              onPressed: () {
                                save();
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/');
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title?.name.replaceAll('\n', ' ') ??
                                        'Luma player',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Picture in picture',
                              onPressed: () async {
                                pip = true;
                                final entered = await service
                                    .pictureInPicture();
                                if (!entered) {
                                  pip = false;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Picture in picture requires a supported Android device.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.picture_in_picture_alt),
                            ),
                            IconButton(
                              tooltip: 'Playback settings',
                              onPressed: sources.isEmpty ? null : options,
                              icon: const Icon(Icons.tune),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (c != null && !loading && error == null)
                          ValueListenableBuilder(
                            valueListenable: c,
                            builder: (_, v, child) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Back 10 seconds',
                                  iconSize: 36,
                                  onPressed: () => service.seekBy(-10),
                                  icon: const Icon(Icons.replay_10),
                                ),
                                const SizedBox(width: 30),
                                IconButton.filled(
                                  tooltip: v.isPlaying ? 'Pause' : 'Play',
                                  iconSize: 48,
                                  onPressed: () {
                                    v.isPlaying ? c.pause() : c.play();
                                    scheduleHide();
                                  },
                                  icon: Icon(
                                    v.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                IconButton(
                                  tooltip: 'Forward 10 seconds',
                                  iconSize: 36,
                                  onPressed: () => service.seekBy(10),
                                  icon: const Icon(Icons.forward_10),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        if (c != null && !loading && error == null)
                          ValueListenableBuilder(
                            valueListenable: c,
                            builder: (_, v, child) => Column(
                              children: [
                                if (v.isBuffering)
                                  const LinearProgressIndicator(minHeight: 2),
                                Row(
                                  children: [
                                    Text(
                                      time(v.position),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        secondaryTrackValue: bufferedUntil(v)
                                            .inMilliseconds
                                            .toDouble()
                                            .clamp(
                                              0,
                                              v.duration.inMilliseconds
                                                  .toDouble()
                                                  .clamp(1, double.infinity),
                                            ),
                                        value: v.position.inMilliseconds
                                            .toDouble()
                                            .clamp(
                                              0,
                                              v.duration.inMilliseconds
                                                  .toDouble(),
                                            ),
                                        max: v.duration.inMilliseconds
                                            .toDouble()
                                            .clamp(1, double.infinity),
                                        onChanged: (ms) {
                                          c.seekTo(
                                            Duration(milliseconds: ms.floor()),
                                          );
                                          scheduleHide();
                                        },
                                      ),
                                    ),
                                    Text(
                                      time(v.duration),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      offline
                                          ? 'Available offline'
                                          : '${time(bufferedUntil(v) - v.position)} buffered ahead',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (nextEpisode != null)
                                      TextButton.icon(
                                        onPressed: next,
                                        icon: const Icon(Icons.skip_next),
                                        label: const Text('Next episode'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
