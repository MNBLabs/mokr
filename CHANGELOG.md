# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0

### Breaking Changes

- `Mokr.randomUser()` → `Mokr.random.user()`
- `Mokr.randomPost()` → `Mokr.random.post()`
- `Mokr.feedPage()` → `Mokr.feed()`
- `Mokr.avatarUrl()` → `Mokr.image.avatar()`
- `Mokr.imageUrl()` → `Mokr.image.url()`
- `Mokr.bannerUrl()` → `Mokr.image.banner()`
- `Mokr.clearSlot()` → `Mokr.slots.clear()`
- `Mokr.clearAll()` → `Mokr.slots.clearAll()`
- `pin` parameter removed — use deterministic seeds instead (`Mokr.user('my_seed')` never clears)
- `shared_preferences` dependency removed; `path_provider` added

### Fixed
- Unsplash prewarm now fires in background — `init()` returns immediately

### New

- `Mokr.text.*` namespace — `name`, `handle`, `bio`, `caption`, `comment`, `initials`, and more
- `Mokr.image.provider()`, `Mokr.image.meta()` — `ImageProvider` and `MokrImageMeta` access levels
- `MokrImageMeta.aspectRatio` — synchronous, known before image loads; eliminates layout jumps
- `MokrUserBuilder`, `MokrPostBuilder`, `MokrFeedBuilder` — builder widgets for total layout freedom
- `MokrImage.aspectRatioFromSource` — wraps image in `AspectRatio` using source dimensions
- `Mokr.cache.*` namespace — `warm()`, `clear()`, `status()` for Unsplash URL cache lifecycle
- `MockUser.avatarProvider`, `MockPost.imageMeta` — `ImageProvider` and `MokrImageMeta` on models directly

## 0.1.0 — 2025-04-05

### Added

- Four generation modes: deterministic, slot, pinned slot, fresh random
- `Mokr.user()`, `Mokr.randomUser()`, `Mokr.post()`, `Mokr.randomPost()`, `Mokr.feedPage()`
- `Mokr.avatarUrl()`, `Mokr.imageUrl()`, `Mokr.bannerUrl()`
- `MokrAvatar`, `MokrImage`, `MokrPostCard`, `MokrUserTile` widgets
- 15 image categories via `MokrCategory`
- Picsum default provider; Unsplash opt-in via `Mokr.init(unsplashKey:)`
- Slot persistence via `shared_preferences`
- FNV-1a 32-bit hash for determinism across hot reloads and restarts
