# Luma

Android-first Flutter streaming UI prototype. Fictional catalog, dark cinematic UI, no production backend.

## Run

```sh
flutter pub get
flutter run
# Browser UI preview (MP4 supported; HLS depends on browser)
flutter run -d chrome
# Android installable debug package
flutter build apk --debug
```

Requires Flutter 3.47 / Dart 3.13 or compatible SDK. iOS scaffolding is included; building iOS requires macOS and Xcode.

## Structure

- `lib/models`: catalog, episodes, playback descriptors
- `lib/repositories`: abstract catalog/playback contracts and replaceable mocks
- `lib/providers`: Riverpod dependency wiring and persistent library state
- `lib/services`: Dio metadata client and video-player adapter
- `lib/screens`: Home, Search, library, profile, details, player
- `lib/widgets`: artwork caching, poster cards, hero, catalog sections
- `lib/routing`, `lib/theme`: navigation shell and design system

Replace `catalogRepositoryProvider` and `playbackRepositoryProvider` with REST-backed implementations. The API should return catalog metadata and authorized CDN URLs, never proxy video bytes. `ApiService` is a transport foundation only; no server or invented API endpoints are used.

## Implemented

Home shelves, featured hero, cached remote art with fallbacks, search/type filters and recent queries (submit with Enter), movie/series details, season/episode selection, persistent watchlist/history/progress, autoplay preference, fullscreen native playback, ±10-second seek, scrubber, sample sidecar subtitles, next episode, MP4/HLS sample selection, and Android PiP bridge.

The official video_player Android implementation uses Media3 ExoPlayer; iOS uses AVFoundation. HLS selects quality adaptively. Manual rendition/embedded subtitle/audio track selection requires extending or replacing `PlayerService`; the settings sheet shows automatic quality and original audio. PiP requires Android 8+ with device support and has not been verified on a physical device. iOS PiP is not implemented. Trailer and account features remain placeholders. Downloads are implemented for permitted MP4 sources. UI catalog runtime is fictional and differs from sample duration.

## Sample media and artwork

- Big Buck Bunny by Blender Foundation, CC BY 3.0: https://peach.blender.org/about/ — https://media.w3.org/2010/05/bunny/trailer.mp4
- Apple HLS developer test stream: https://developer.apple.com/streaming/examples/ — https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8
- Landscape artwork is remotely loaded from images.unsplash.com; IDs are in the mock repository. Use owned/licensed production assets before release.
- Captions are explicitly demo captions, not a movie transcript. Fictional titles do not imply access to commercial movies.

## Checks

```sh
flutter analyze
flutter test
```

Tests cover persistent library data, search filters, series navigation, watchlist interactions and phone layout. Native playback, PiP, interruptions and iOS playback still require device validation.

## Offline downloads and buffering

Movies and individual episodes offer Download. My List → Downloads shows byte progress, cancellation, retry, removal, and Watch offline. Completed MP4 files are stored in app-private support storage, validated before finalization, and survive restarts. Offline playback selects a file controller without resolving the remote source. Missing files become retryable. Interrupted downloads restart on retry; keep the app open during transfer. This is not an OS background download service. Files are removed when the app is uninstalled.

Only sources explicitly marked downloadable are eligible. The current catalog offers the authorized Blender MP4; downloading segmented HLS/DRM packages is not implemented. The browser preview explains that downloads require the mobile app. iOS file download support is included but untested on a device.

Android uses a small pinned video_player_android fork in third_party. Both player render paths target 5–10 minutes of forward buffering with a 96 MiB allocation target, 1.5 second initial start, and 5 second recovery threshold. High bitrate, short videos, slow connections and live-stream availability can reduce the buffer. It does not promise stall-free playback and does not persist the streaming buffer. iOS/web retain platform defaults. The scrubber shows the contiguous buffered range and time ahead.

Tests additionally cover local HTTP download finalization, rejection of invalid responses, cancellation cleanup, persistence with the server offline, missing/interrupted download handling, and buffer-range calculations. A physical-device airplane-mode playback test remains necessary before release.

