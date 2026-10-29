# Week 5: Offline-first notes

Flutter sample demonstrating local SQLite storage, cache-first API reads, and
simulated synchronization of dirty notes.

## Features

- The **Posts API** tab reads `cached_posts` from SQLite first, then fetches
  `GET /posts` from JSONPlaceholder in the background and replaces the cache.
  If the request fails, cached results remain visible and the error is shown.
- The **Catatan** tab supports creating, editing, and deleting local notes.
  New and edited notes are marked dirty.
- The **Simulasi offline** switch forces the app to serve cached posts and
  prevents dirty notes from being synchronized until online mode is restored.
- **Sinkronkan catatan** simulates a server upload with a one-second delay,
  then marks dirty notes as synced. This exercise does not configure a write
  backend.

See [screenshots/offline-sync-observation.md](screenshots/offline-sync-observation.md)
for the manual offline/online exercise and observation checklist.

Run the app from this directory with `flutter pub get` followed by
`flutter run`. Run checks with `flutter analyze` and `flutter test`.
