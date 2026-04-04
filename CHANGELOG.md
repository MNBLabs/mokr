# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-04-05

### Added

- **Four generation modes** — deterministic (seed in code), slot (stable random on disk),
  pinned slot (survives `clearAll`), and fresh random with console seed logging
- **`Mokr.user(seed)`** and **`Mokr.randomUser({slot, pin})`** — generate realistic `MockUser`
  objects with name, username, bio, follower/following counts, and post count
- **`Mokr.post(seed)`** and **`Mokr.randomPost({slot, pin})`** — generate `MockPost` objects
  with caption, like/comment/share counts, timestamp, and image URL
- **`Mokr.feedPage(seed, {page, pageSize})`** — stable paginated post lists; same seed + page
  always returns the same posts
- **`Mokr.avatarUrl`**, **`Mokr.imageUrl`**, **`Mokr.bannerUrl`** — synchronous URL methods
  safe to call directly in `build()`
- **Slot management** — `Mokr.clearSlot`, `Mokr.clearPin`, `Mokr.clearAll`
- **`MokrAvatar`** — circle/rounded/square avatar widget with shimmer loading and
  initials fallback
- **`MokrImage`** — category-aware image widget with shimmer loading and error state
- **`MokrPostCard`** — full post card widget (avatar, image, caption, engagement counts)
- **`MokrUserTile`** — user list tile with optional trailing widget
- **15 image categories** via `MokrCategory` enum: face, nature, travel, food, fashion,
  fitness, art, technology, office, abstract, product, interior, architecture,
  automotive, pets
- **Picsum** default image provider — no API key required
- **Unsplash** opt-in provider — `Mokr.init(unsplashKey: ...)` or `Mokr.useUnsplash(key)`
  at runtime; pre-warms a URL cache per category; returns a count of warmed categories
- **`Mokr.usePicsum()`** — switch back to Picsum at runtime without reinitialising slot state
- **String extensions** — `'seed'.asMockUser`, `'seed'.asMockPost`, `'seed'.asAvatarUrl`
- **Production guard** — `assert` prevents mokr from running in release builds
- **FNV-1a 32-bit hash** engine for VM-stable determinism across hot reloads and restarts
- **SharedPreferences** slot persistence — slot seeds survive hot restarts and phone restarts
