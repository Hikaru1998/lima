enum DownloadStatus { downloading, complete, failed }

class DownloadRecord {
  const DownloadRecord({
    required this.key,
    required this.titleId,
    required this.name,
    this.episodeId,
    this.status = DownloadStatus.downloading,
    this.received = 0,
    this.total = 0,
    this.message,
  });
  final String key, titleId, name;
  final String? episodeId, message;
  final DownloadStatus status;
  final int received, total;
  DownloadRecord withState(
    DownloadStatus status, {
    int? received,
    int? total,
    String? message,
  }) => DownloadRecord(
    key: key,
    titleId: titleId,
    name: name,
    episodeId: episodeId,
    status: status,
    received: received ?? this.received,
    total: total ?? this.total,
    message: message,
  );
  Map<String, dynamic> toJson() => {
    'key': key,
    'titleId': titleId,
    'name': name,
    'episodeId': episodeId,
    'status': status.name,
    'received': received,
    'total': total,
  };
  factory DownloadRecord.fromJson(Map<String, dynamic> json) => DownloadRecord(
    key: json['key'] as String,
    titleId: json['titleId'] as String,
    name: json['name'] as String,
    episodeId: json['episodeId'] as String?,
    status: json['status'] == 'complete'
        ? DownloadStatus.complete
        : DownloadStatus.failed,
    received: (json['received'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
    message: json['status'] == 'complete'
        ? null
        : 'Download interrupted. Tap retry.',
  );
}
