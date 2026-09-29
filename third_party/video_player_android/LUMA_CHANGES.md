# Local buffering patch

Vendored from Flutter video_player_android 2.12.2 under its retained BSD license.
Both texture and platform-view ExoPlayer builders use a 300,000 ms minimum and
600,000 ms maximum forward-buffer target, 1,500 ms initial playback threshold,
5,000 ms rebuffer threshold, and 96 MiB target allocation. Size takes precedence
over time to limit memory use. At higher bitrates the time buffered can be lower.
This is a streaming memory buffer, not persistent offline storage. Live streams
can only buffer what the server has published. iOS/web retain platform defaults.

Reapply and test this small Java patch when upgrading the pinned plugin.
