import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/download_record.dart';
import '../providers/download_provider.dart';

class DownloadsView extends ConsumerWidget {
  const DownloadsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(downloadsProvider).values.toList();
    final controller = ref.read(downloadsProvider.notifier);
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 48, color: Colors.white38),
              SizedBox(height: 16),
              Text('Your cinema, wherever you go.'),
              SizedBox(height: 8),
              Text(
                'Download a movie or episode to watch without internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Keep Luma open while downloading.',
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 16),
        ...records.map(
          (r) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name.replaceAll('\n', ' '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.status == DownloadStatus.complete
                        ? 'Available offline · ${(r.total / 1048576).toStringAsFixed(1)} MB'
                        : r.status == DownloadStatus.failed
                        ? r.message ?? 'Tap retry to download again.'
                        : '${(r.received / 1048576).toStringAsFixed(1)} MB downloaded',
                  ),
                  if (r.status == DownloadStatus.downloading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(
                        value: r.total > 0
                            ? (r.received / r.total).clamp(0, 1)
                            : null,
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    children: [
                      if (r.status == DownloadStatus.complete)
                        TextButton.icon(
                          onPressed: () async {
                            final available = await controller.available(r.key);
                            if (context.mounted && available) {
                              context.push(
                                '/play/${r.titleId}?offline=1${r.episodeId == null ? '' : '&episode=${r.episodeId}'}',
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Watch offline'),
                        ),
                      if (r.status == DownloadStatus.failed)
                        TextButton(
                          onPressed: () => controller.start(
                            r.titleId,
                            r.name,
                            episodeId: r.episodeId,
                          ),
                          child: const Text('Retry'),
                        ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await controller.remove(r.key);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not remove this download. Try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          r.status == DownloadStatus.downloading
                              ? 'Cancel'
                              : 'Remove',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
