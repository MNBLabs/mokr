import 'package:flutter/foundation.dart';

import '../data/generators/feed_generator.dart';
import '../data/generators/post_generator.dart';
import '../data/generators/user_generator.dart';
import '../data/models/mock_post.dart';
import '../data/models/mock_user.dart';
import '../images/cache/image_cache.dart';
import '../images/image_namespace.dart';
import '../images/mokr_image_provider.dart';
import '../images/unsplash_provider.dart';
import '../namespaces/cache_namespace.dart';
import '../namespaces/random_namespace.dart';
import '../namespaces/text_namespace.dart';
import '../slots/slot_namespace.dart';
import '../slots/slot_registry.dart';
import 'release_guard.dart';

/// The primary entry point for the mokr package.
///
/// Call [Mokr.init] once in `main()` before [runApp]:
/// ```dart
/// void main() async {
///   await Mokr.init();
///   runApp(const MyApp());
/// }
/// ```
///
/// Then access mock data anywhere — sync, no awaiting:
/// ```dart
/// final user  = Mokr.user('profile_hero');
/// final name  = Mokr.text.name('profile_hero');
/// final rando = Mokr.random.user(slot: 'card_1');
/// final img   = Mokr.image.meta('post_1', category: MokrCategory.food);
/// ```
final class Mokr {
  Mokr._();

  static bool _initialised = false;

  // ─── Namespaces ─────────────────────────────────────────────────────────

  /// Deterministic text strings without the full model.
  /// ```dart
  /// Mokr.text.name('seed')    // 'Jordan Rivera'
  /// Mokr.text.handle('seed')  // '@jordanrivera'
  /// ```
  static const MokrText text = MokrText();

  /// Random data with optional slot stability.
  /// ```dart
  /// Mokr.random.user()                 // fresh every call
  /// Mokr.random.user(slot: 'hero')     // stable after first call
  /// ```
  static const MokrRandom random = MokrRandom();

  /// Slot lifecycle management.
  /// ```dart
  /// await Mokr.slots.clear('hero');
  /// await Mokr.slots.clearAll();
  /// ```
  static const MokrSlots slots = MokrSlots();

  /// Three-level image access: URL, ImageProvider, or MokrImageMeta.
  /// ```dart
  /// Mokr.image.url('post_1', category: MokrCategory.food)
  /// Mokr.image.provider('post_1', category: MokrCategory.food)
  /// Mokr.image.meta('post_1', category: MokrCategory.food)
  /// Mokr.image.avatar('user_42')
  /// ```
  static const MokrImageNamespace image = MokrImageNamespace();

  /// Unsplash image cache lifecycle.
  /// ```dart
  /// await Mokr.cache.warm();
  /// await Mokr.cache.clear();
  /// Mokr.cache.status();
  /// ```
  static const MokrCache cache = MokrCache();

  // ─── Initialisation ──────────────────────────────────────────────────────

  /// Initialises mokr. Call once before any other Mokr method.
  ///
  /// - Asserts debug-only execution (`kReleaseMode` guard).
  /// - Loads the slot registry from disk.
  /// - If [imageProvider] is supplied: installs it as the active provider.
  /// - If [unsplashKey] is supplied: installs [UnsplashMokrImageProvider] and
  ///   pre-warms the URL cache (skipped if the disk cache is still fresh).
  ///   Falls back to Picsum per category on any Unsplash failure.
  static Future<void> init({
    String? unsplashKey,
    MokrImageProvider? imageProvider,
  }) async {
    assertNotRelease();
    await SlotRegistry.load();

    // Store key for Mokr.cache.warm() calls after init.
    setMokrUnsplashKey(unsplashKey);

    if (imageProvider != null) {
      // Custom provider — use it directly, skip Unsplash.
      setActiveMokrProvider(imageProvider);
    } else if (unsplashKey != null) {
      // Unsplash path: load disk cache, re-warm if stale.
      await MokrImageCache.instance.load();
      final unsplash = const UnsplashMokrImageProvider();
      if (MokrImageCache.instance.isStale) {
        if (kDebugMode) {
          debugPrint('[mokr] 🕐  image cache stale — re-warming in background');
        }
        final count = await unsplash.prewarm(unsplashKey);
        if (kDebugMode) {
          debugPrint('[mokr] ✅  unsplash warmed — $count/15 categories');
        }
        MokrImageCache.instance.save(); // fire-and-forget
      }
      setActiveMokrProvider(unsplash);
    }
    // else: default PicsumMokrImageProvider is already active.

    _initialised = true;
  }

  // ─── Direct data methods ─────────────────────────────────────────────────

  /// Returns a deterministic [MockUser] for [seed].
  ///
  /// Same seed → identical result on every call, everywhere, forever.
  static MockUser user(String seed) {
    assert(_initialised, 'Call Mokr.init() before using Mokr.');
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return UserGenerator.generate(seed);
  }

  /// Returns a deterministic [MockPost] for [seed].
  static MockPost post(String seed) {
    assert(_initialised, 'Call Mokr.init() before using Mokr.');
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return PostGenerator.generate(seed);
  }

  /// Returns a deterministic page of [MockPost] items.
  ///
  /// Same seed + page always returns the same list.
  /// Returns `[]` when [pageSize] is 0.
  static List<MockPost> feed(
    String seed, {
    int page = 0,
    int pageSize = 20,
  }) {
    assert(_initialised, 'Call Mokr.init() before using Mokr.');
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    assert(page >= 0, 'page cannot be negative.');
    assert(pageSize >= 0, 'pageSize cannot be negative.');
    return FeedGenerator.page(seed, page, pageSize);
  }
}
