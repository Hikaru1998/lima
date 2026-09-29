# Connecting real titles

The TMDB catalog adapter is implemented but intentionally not active: no API credential or video provider has been configured. The existing preview therefore still uses the local catalog.

## Required account setup

1. Create a TMDB account at https://www.themoviedb.org/signup.
2. Request developer API access under account Settings → API: https://www.themoviedb.org/settings/api.
3. Store the API Read Access Token in local configuration, not chat, source code or Git. Once available, wire TmdbCatalogRepository into catalogRepositoryProvider. For release builds use a server-side metadata integration rather than shipping a private provider secret in the app.
4. Before activating the integration, add an approved TMDB logo and the required notice to About: “This product uses the TMDB API but is not endorsed or certified by TMDB.” See https://developer.themoviedb.org/docs/faq and https://www.themoviedb.org/about/logos-attribution.

The adapter fetches the first page of popular movies and TV series and maps their real names, dates, descriptions, posters and backdrops. Search pagination, full details and season/episode API loading are the next integration steps after credentials are available. No live TMDB request has been tested yet. Unit tests exercise response mapping and prevent sample playback for real metadata IDs.

## Playback is a separate service

TMDB is a metadata catalog, not a source of full movie streams. Choose a licensed catalog provider or use movies you own or have permission to distribute. A video host stores/transcodes those supplied videos; it does not supply a movie library. No OnStream server, undocumented endpoint, or credentials are configured.

The playback provider must map each catalog ID (for example tmdb-movie-11 or tmdb-tv-11 plus season/episode) to the corresponding authorized HLS/MP4 URL, audio/subtitle information and download permission. IDs with no match remain unavailable. Stream bytes go directly from the CDN to the player, not through the metadata API.

No production backend has been created, consistent with the frontend-first scope.
