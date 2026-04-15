import 'package:flutter/foundation.dart';

import '../data/models/cache_status.dart';
import '../images/cache/image_cache.dart';
import '../images/mokr_image_provider.dart';
import '../images/unsplash_provider.dart';

// ─── Package-internal state ───────────────────────────────────────────────────

/// Stores the Unsplash API key set via [Mokr.init]. Package-internal only.
String? _mokrUnsplashKey;

/// Sets the active Unsplash API key. Called only by [Mokr.init].
///
/// Package-internal — do NOT export.
void setMokrUnsplashKey(String? key) => _mokrUnsplashKey = key;

// ─── Public namespace ─────────────────────────────────────────────────────────

/// `Mokr.cache` — Unsplash image cache lifecycle management.
///
/// ```dart
/// await Mokr.cache.warm();           // force re-warm from Unsplash
/// await Mokr.cache.clear();          // wipe disk cache
/// final status = Mokr.cache.status(); // debug: inspect per-category status
/// ```
///
/// Cache is automatically warmed at [Mokr.init] when an `unsplashKey` is
/// provided. Manual [warm] is only needed if you want to force a refresh.
final class MokrCache {
  const MokrCache();

  /// Re-warms the Unsplash image cache for all [MokrCategory] values.
  ///
  /// No-op if no Unsplash key was provided to [Mokr.init].
  /// Logs the result at debug level.
  Future<void> warm() async {
    final key = _mokrUnsplashKey;
    if (key == null || key.isEmpty) return;
    final count = await const UnsplashMokrImageProvider().prewarm(key);
    if (kDebugMode) {
      debugPrint('[mokr] ✅  unsplash warmed — $count/15 categories');
    }
    await MokrImageCache.instance.save();
  }

  /// Deletes the on-disk image cache and clears in-memory state.
  ///
  /// Next [warm] or [Mokr.init] with an `unsplashKey` will re-fetch.
  Future<void> clear() => MokrImageCache.instance.clear();

  /// Returns a [CacheStatus] snapshot for every [MokrCategory].
  ///
  /// Intended for debug / dev-settings screens only.
  Map<MokrCategory, CacheStatus> status() =>
      MokrImageCache.instance.statusMap();
}
