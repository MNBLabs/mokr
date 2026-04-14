import '../data/generators/feed_generator.dart';
import '../data/generators/post_generator.dart';
import '../data/generators/user_generator.dart';
import '../data/models/mock_post.dart';
import '../data/models/mock_user.dart';
import '../images/mokr_image_provider.dart';
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
/// Then access mock data anywhere:
/// ```dart
/// final user = Mokr.user('profile_hero');
/// final post = Mokr.post('feed_item_0');
/// final page = Mokr.feed('home', page: 0);
/// ```
final class Mokr {
  Mokr._();

  static bool _initialised = false;

  /// Initialises mokr. Call once before any other Mokr method.
  ///
  /// - Asserts debug-only execution (`kReleaseMode` guard).
  /// - Loads the slot registry from disk (added in Phase 2).
  /// - Pre-warms the Unsplash image cache when [unsplashKey] is provided.
  /// - Installs a custom [imageProvider] when provided.
  static Future<void> init({
    String? unsplashKey,
    MokrImageProvider? imageProvider,
  }) async {
    assertNotRelease();
    // Phase 2: slot registry load added here.
    // Phase 3: image provider + unsplash warm-up added here.
    _initialised = true;
  }

  // ─── Direct data methods ────────────────────────────────────────────────

  /// Returns a deterministic [MockUser] for [seed].
  ///
  /// Same seed always produces the same user — across hot reloads,
  /// restarts, devices, and app reinstalls.
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
  /// Returns an empty list when [pageSize] is 0.
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

  // ─── Namespace fields — wired in later phases ───────────────────────────
  // static final MokrRandom random = MokrRandom._();
  // static final TextNamespace text = TextNamespace._();
  // static final ImageNamespace image = ImageNamespace._();
  // static final SlotNamespace slots = SlotNamespace._();
  // static final CacheNamespace cache = CacheNamespace._();
}
