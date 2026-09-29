import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/playback_repository.dart';

final playbackRepositoryProvider = Provider<PlaybackRepository>(
  (ref) => SamplePlaybackRepository(),
);
