import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/download_record.dart';
import '../providers/download_provider.dart';

class DownloadButton extends ConsumerWidget {
  const DownloadButton({
    super.key,
    required this.titleId,
    required this.name,
    this.episodeId,
  });
  final String titleId, name;
  final String? episodeId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = episodeId ?? titleId;
    final record = ref.watch(downloadsProvider)[key];
    final active = record?.status == DownloadStatus.downloading;
    final done = record?.status == DownloadStatus.complete;
    return TextButton.icon(
      onPressed: done
          ? null
          : () {
              final controller = ref.read(downloadsProvider.notifier);
              if (active) {
                controller.cancel(key);
              } else {
                controller.start(titleId, name, episodeId: episodeId);
              }
            },
      icon: Icon(
        done
            ? Icons.download_done
            : active
            ? Icons.close
            : Icons.download_outlined,
      ),
      label: Text(
        done
            ? 'Downloaded'
            : active
            ? record!.total > 0
                  ? '${(record.received / record.total * 100).floor()}% · Cancel'
                  : 'Downloading · Cancel'
            : record?.status == DownloadStatus.failed
            ? 'Retry download'
            : 'Download',
      ),
    );
  }
}
