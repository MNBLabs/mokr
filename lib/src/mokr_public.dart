import 'core/slot_registry.dart';
import 'data/generators/feed_generator.dart';
import 'data/models/mock_post.dart';
import 'data/models/mock_user.dart';
import 'images/mokr_image_provider.dart';
import 'images/provider_registry.dart';
import 'mokr_enums.dart';
import 'mokr_impl.dart';

/// The mokr entry point. All methods are static.
///
/// Import via:
/// ```dart
/// import 'package:mokr/mokr.dart';
/// ```
final class Mokr {
  Mokr._(); // Not instantiable.

  // ─── Setup ────────────────────────────────────────────────────────────────

  /// Initialises mokr. Call once in `main()` before `runApp()`.
  ///
  /// Loads persisted slot seeds from disk and sets the image provider.
  /// Asserts in release mode — mokr is for development only.
  ///
  /// ```dart
  /// // Zero config — uses Picsum (no API key required):
  /// void main() async {
  ///   await Mokr.init();
  ///   runApp(MyApp());
  /// }
  ///
  /// // With Unsplash API key (real category-filtered images):
  /// void main() async {
  ///   await Mokr.init(unsplashKey: 'your_api_key');
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Resolution order: [imageProvider] → [unsplashKey] → Picsum (default).
  static Future<void> init({
    String? unsplashKey,
    MokrImageProvider? imageProvider,
  }) =>
      MokrImpl.init(unsplashKey: unsplashKey, imageProvider: imageProvider);

  // ─── Data methods — Users ─────────────────────────────────────────────────

  /// Returns a deterministic [MockUser] for the given [seed].
  ///
  /// Same seed always produces the same user — across hot reloads,
  /// hot restarts, and app reinstalls.
  ///
  /// ```dart
  /// final user = Mokr.user('user_42');
  /// print(user.name); // always the same name
  /// ```
  static MockUser user(String seed) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return MokrImpl.resolveUser(seed: seed);
  }

  /// Returns a [MockUser] based on the current mode.
  ///
  /// **No parameters** — fresh random, different each call:
  /// ```dart
  /// Mokr.randomUser()
  /// ```
  ///
  /// **[slot]** — random once, stable thereafter:
  /// ```dart
  /// Mokr.randomUser(slot: 'card_1')
  /// ```
  ///
  /// **[slot] + [pin: true]** — stable and survives [clearAll]:
  /// ```dart
  /// Mokr.randomUser(slot: 'hero', pin: true)
  /// ```
  ///
  /// Tip: the returned [MockUser.seed] shows which seed was used.
  /// Copy it to graduate to fully deterministic: `Mokr.user(seed)`.
  static MockUser randomUser({String? slot, bool pin = false}) {
    assert(!pin || slot != null, 'pin requires a slot name.');
    assert(slot == null || slot.isNotEmpty, 'Slot name cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return MokrImpl.resolveUser(slot: slot, pin: pin);
  }

  // ─── Data methods — Posts ─────────────────────────────────────────────────

  /// Returns a deterministic [MockPost] for the given [seed].
  ///
  /// ```dart
  /// final post = Mokr.post('post_feed_0');
  /// ```
  static MockPost post(String seed) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return MokrImpl.resolvePost(seed: seed);
  }

  /// Returns a [MockPost] based on the current mode.
  /// See [randomUser] for slot/pin documentation — identical behaviour.
  ///
  /// ```dart
  /// Mokr.randomPost()
  /// Mokr.randomPost(slot: 'feed_hero')
  /// Mokr.randomPost(slot: 'feed_hero', pin: true)
  /// ```
  static MockPost randomPost({String? slot, bool pin = false}) {
    assert(!pin || slot != null, 'pin requires a slot name.');
    assert(slot == null || slot.isNotEmpty, 'Slot name cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return MokrImpl.resolvePost(slot: slot, pin: pin);
  }

  // ─── Data methods — Feeds ─────────────────────────────────────────────────

  /// Returns a deterministic page of [MockPost] items.
  ///
  /// Same seed + same page always returns the same posts.
  ///
  /// ```dart
  /// final page0 = Mokr.feedPage('home_feed', page: 0, pageSize: 20);
  /// final page1 = Mokr.feedPage('home_feed', page: 1, pageSize: 20);
  /// ```
  static List<MockPost> feedPage(
    String seed, {
    int page = 0,
    int pageSize = 20,
  }) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(page >= 0, 'page must be non-negative.');
    assert(pageSize >= 0, 'pageSize must be non-negative.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return FeedGenerator.page(seed, page, pageSize);
  }

  // ─── URL methods ──────────────────────────────────────────────────────────

  /// Returns a deterministic avatar image URL.
  ///
  /// Always synchronous. Safe to call inline in `build()`.
  ///
  /// Images are sourced from Picsum or Unsplash.
  /// For development and prototyping only.
  ///
  /// ```dart
  /// Image.network(Mokr.avatarUrl('user_42'))
  /// CircleAvatar(backgroundImage: NetworkImage(Mokr.avatarUrl('u1', size: 120)))
  /// ```
  static String avatarUrl(String seed, {int size = 80}) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(size > 0, 'size must be positive.');
    return activeImageProvider.avatarUrl(seed, MokrCategory.face, size: size);
  }

  /// Returns a deterministic image URL for the given [category].
  ///
  /// Always synchronous. Safe to call inline in `build()`.
  ///
  /// Images are sourced from Picsum or Unsplash.
  /// For development and prototyping only.
  ///
  /// ```dart
  /// Image.network(Mokr.imageUrl('post_1', category: MokrCategory.nature))
  /// ```
  static String imageUrl(
    String seed, {
    MokrCategory category = MokrCategory.nature,
    int width = 400,
    int height = 300,
  }) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(width > 0, 'width must be positive.');
    assert(height > 0, 'height must be positive.');
    return activeImageProvider.imageUrl(seed, category,
        width: width, height: height);
  }

  /// Returns a deterministic wide banner image URL.
  ///
  /// Always synchronous. Safe to call inline in `build()`.
  ///
  /// Images are sourced from Picsum or Unsplash.
  /// For development and prototyping only.
  ///
  /// ```dart
  /// Image.network(Mokr.bannerUrl('profile_42'))
  /// ```
  static String bannerUrl(
    String seed, {
    MokrCategory category = MokrCategory.nature,
    int width = 800,
    int height = 300,
  }) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(width > 0, 'width must be positive.');
    assert(height > 0, 'height must be positive.');
    return activeImageProvider.bannerUrl(seed, category,
        width: width, height: height);
  }

  // ─── Slot management ──────────────────────────────────────────────────────

  /// Removes a single unpinned slot. It will re-randomise on next call.
  ///
  /// No-op if the slot is pinned — use [clearPin] instead.
  ///
  /// ```dart
  /// await Mokr.clearSlot('card_1');
  /// ```
  static Future<void> clearSlot(String slot) {
    assert(slot.isNotEmpty, 'Slot name cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return SlotRegistry.instance.clear(slot);
  }

  /// Removes a pinned slot. Requires explicit intent.
  ///
  /// No-op if the slot does not exist.
  ///
  /// ```dart
  /// await Mokr.clearPin('hero');
  /// ```
  static Future<void> clearPin(String slot) {
    assert(slot.isNotEmpty, 'Slot name cannot be empty.');
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return SlotRegistry.instance.clearPin(slot);
  }

  /// Removes all unpinned slots. Pinned slots are unaffected.
  ///
  /// ```dart
  /// await Mokr.clearAll();
  /// ```
  static Future<void> clearAll() {
    assert(MokrImpl.isInitialized,
        'Call await Mokr.init() in main() before using mokr.');
    return SlotRegistry.instance.clearAll();
  }
}

// ─── Extension Methods ────────────────────────────────────────────────────────

/// Convenience extensions on [String] for inline use.
extension MokrStringExt on String {
  /// Shorthand for `Mokr.user(this)`.
  ///
  /// ```dart
  /// 'user_42'.asMockUser.name
  /// ```
  MockUser get asMockUser => Mokr.user(this);

  /// Shorthand for `Mokr.post(this)`.
  ///
  /// ```dart
  /// 'post_0'.asMockPost.caption
  /// ```
  MockPost get asMockPost => Mokr.post(this);

  /// Shorthand for `Mokr.avatarUrl(this)`.
  ///
  /// ```dart
  /// CircleAvatar(backgroundImage: NetworkImage('u42'.asAvatarUrl))
  /// ```
  String get asAvatarUrl => Mokr.avatarUrl(this);
}
