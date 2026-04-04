# API Contracts — mokr

Full public API surface. Implementation must conform exactly to these signatures.
Every method documented as the developer will see it in their IDE.

---

## Setup

```dart
/// Initialises mokr. Call once in [main()] before [runApp()].
///
/// Loads persisted slot seeds from disk.
/// Asserts in release mode — mokr is for development only.
///
/// ```dart
/// // Zero config — uses Picsum (no auth required):
/// void main() async {
///   await Mokr.init();
///   runApp(MyApp());
/// }
///
/// // With Unsplash API key — real category-filtered images:
/// void main() async {
///   await Mokr.init(unsplashKey: 'your_api_key');
///   runApp(MyApp());
/// }
/// ```
///
/// Resolution order: [imageProvider] (explicit) → [unsplashKey] (Unsplash) → Picsum (default).
static Future<void> init({
  String? unsplashKey,
  MokrImageProvider? imageProvider,
})
```

---

## Data Methods

### Users

```dart
/// Returns a deterministic [MockUser] for the given seed.
///
/// Same seed always produces the same user — across hot reloads,
/// hot restarts, and app reinstalls.
///
/// ```dart
/// final user = Mokr.user('user_42');
/// print(user.name); // always "Sofia Nakamura"
/// ```
static MockUser user(String seed)


/// Returns a [MockUser] based on the current random mode.
///
/// **No parameters** — fresh random. Different result every call.
/// ```dart
/// Mokr.randomUser()
/// ```
///
/// **[slot]** — stable random, persisted to disk.
/// First call generates a random seed and stores it.
/// Every subsequent call returns the same user.
/// ```dart
/// Mokr.randomUser(slot: 'card_1')
/// ```
///
/// **[slot] + [pin: true]** — same as slot, but protected.
/// Survives [Mokr.clearAll()]. Only removable via [Mokr.clearPin()].
/// ```dart
/// Mokr.randomUser(slot: 'hero', pin: true)
/// ```
///
/// Tip: the returned [MockUser.seed] tells you which seed was used.
/// Copy it to graduate to fully deterministic: [Mokr.user(seed)].
static MockUser randomUser({String? slot, bool pin = false})
```

### Posts

```dart
/// Returns a deterministic [MockPost] for the given seed.
///
/// ```dart
/// final post = Mokr.post('post_feed_0');
/// ```
static MockPost post(String seed)


/// Returns a [MockPost] based on the current random mode.
/// See [Mokr.randomUser] for slot/pin documentation — same behaviour.
///
/// ```dart
/// Mokr.randomPost()
/// Mokr.randomPost(slot: 'feed_hero')
/// Mokr.randomPost(slot: 'feed_hero', pin: true)
/// ```
static MockPost randomPost({String? slot, bool pin = false})
```

### Feeds

```dart
/// Returns a deterministic page of [MockPost] items.
///
/// Same seed + same page always returns the same posts.
/// Use for simulating paginated feeds, infinite scroll, etc.
///
/// ```dart
/// // Page 0
/// final posts = Mokr.feedPage('home_feed', page: 0, pageSize: 20);
///
/// // Next page — different posts, same stability guarantee
/// final more = Mokr.feedPage('home_feed', page: 1, pageSize: 20);
/// ```
static List<MockPost> feedPage(
  String seed, {
  int page = 0,
  int pageSize = 20,
})
```

---

## URL Methods

All return a `String`. All are synchronous. All can be used inline in `build()`.

```dart
/// Returns a deterministic avatar image URL.
///
/// Images sourced from Unsplash. For development only.
///
/// ```dart
/// Image.network(Mokr.avatarUrl('user_42'))
/// Image.network(Mokr.avatarUrl('user_42', size: 120))
/// CircleAvatar(backgroundImage: NetworkImage(Mokr.avatarUrl('u1')))
/// ```
static String avatarUrl(String seed, {int size = 80})


/// Returns a deterministic image URL for the given category.
///
/// Images sourced from Unsplash. For development only.
///
/// ```dart
/// Image.network(Mokr.imageUrl('post_1', category: MokrCategory.nature))
/// Image.network(Mokr.imageUrl('post_1',
///   category: MokrCategory.food,
///   width: 600,
///   height: 400,
/// ))
/// ```
static String imageUrl(
  String seed, {
  MokrCategory category = MokrCategory.nature,
  int width = 400,
  int height = 300,
})


/// Returns a deterministic wide banner image URL.
///
/// ```dart
/// Image.network(Mokr.bannerUrl('profile_42'))
/// ```
static String bannerUrl(String seed, {int width = 800, int height = 300})
```

---

## Slot Management

```dart
/// Removes a single unpinned slot. It will re-randomise on next call.
///
/// No-op if the slot is pinned — use [Mokr.clearPin] instead.
///
/// ```dart
/// Mokr.clearSlot('card_1');
/// ```
static Future<void> clearSlot(String slot)


/// Removes a pinned slot. Requires explicit intent.
///
/// ```dart
/// Mokr.clearPin('hero');
/// ```
static Future<void> clearPin(String slot)


/// Removes all unpinned slots. Pinned slots are unaffected.
///
/// Useful during development to browse new random results
/// while keeping your favourite slots stable.
///
/// ```dart
/// Mokr.clearAll();
/// ```
static Future<void> clearAll()
```

---

## Models

### MockUser

```dart
@immutable
class MockUser {
  final String seed;           // The seed used to generate this user
  final String id;             // Stable short ID derived from seed e.g. 'usr_a7f3'
  final String name;           // Full name e.g. 'Sofia Nakamura'
  final String username;       // e.g. '@sofia.nakamura'
  final String bio;            // 1–3 sentence bio
  final String avatarUrl;      // Unsplash face URL (sync, 80×80)
  final int followerCount;     // Power-law distribution
  final int followingCount;
  final int postCount;
  final bool isVerified;       // ~4% probability
  final DateTime joinedAt;

  // Computed
  String get initials;                // 'SN'
  String get formattedFollowers;      // '1.2k', '45.3k', '1.2M'
  bool get hasLargeFollowing;         // followerCount > 10,000
}
```

### MockPost

```dart
@immutable
class MockPost {
  final String seed;
  final String id;
  final MockUser author;
  final String caption;
  final String? imageUrl;            // null for text-only posts (~20%)
  final MokrCategory? imageCategory;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final List<String> tags;           // 0–5 hashtags
  final bool isLiked;                // deterministic 'liked' state (~30%)

  // Computed
  String get relativeTime;           // '2h ago', '3d ago', 'just now'
  String get formattedLikes;         // '1.2k'
  bool get hasImage;
}
```

---

## Widgets

### MokrAvatar

```dart
/// A circular (or shaped) avatar image backed by a mock user.
///
/// Behaviour is determined by which parameter you pass:
///
/// **Deterministic** — same seed, same face, always.
/// ```dart
/// MokrAvatar(seed: 'user_42', size: 48)
/// ```
///
/// **Slot** — random once, stable to this slot.
/// ```dart
/// MokrAvatar(slot: 'sidebar_user', size: 48)
/// MokrAvatar(slot: 'sidebar_user', pin: true, size: 48)
/// ```
///
/// **Fresh random** — different every rebuild.
/// ```dart
/// MokrAvatar(size: 48)
/// ```
///
/// Works as [child:] in any widget.
/// ```dart
/// Container(child: MokrAvatar(seed: 'u1', size: 20))
/// ListTile(leading: MokrAvatar(slot: 'item_$index', size: 40))
/// ```
class MokrAvatar extends StatelessWidget {
  const MokrAvatar({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.size = 48.0,
    this.shape = MokrShape.circle,
    this.border,
    this.onTap,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
         seed == null || slot == null,
         'Provide either seed or slot, not both.',
       ),
       assert(
         !pin || slot != null,
         'pin requires a slot name.',
       );

  final String? seed;
  final String? slot;
  final bool pin;
  final double size;
  final MokrShape shape;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
}
```

### MokrImage

```dart
/// A content image backed by mock data.
///
/// ```dart
/// MokrImage(seed: 'post_1', category: MokrCategory.nature)
/// MokrImage(slot: 'feed_hero', category: MokrCategory.travel, height: 200)
/// MokrImage(category: MokrCategory.food)  // fresh random
/// ```
///
/// Supports custom loading and error states:
/// ```dart
/// MokrImage(
///   seed: 'post_1',
///   loadingBuilder: (context) => MyShimmer(),
///   errorBuilder: (context) => MyErrorTile(),
/// )
/// ```
class MokrImage extends StatelessWidget {
  const MokrImage({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.category = MokrCategory.nature,
    this.width,
    this.height = 200.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
         seed == null || slot == null,
         'Provide either seed or slot, not both.',
       ),
       assert(
         !pin || slot != null,
         'pin requires a slot name.',
       );

  final String? seed;
  final String? slot;
  final bool pin;
  final MokrCategory category;
  final double? width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
}
```

### MokrPostCard

```dart
/// A full post card widget — author row, image, caption, action row.
///
/// ```dart
/// MokrPostCard(seed: 'post_0')
/// MokrPostCard(slot: 'feed_hero', pin: true)
/// ```
class MokrPostCard extends StatelessWidget {
  const MokrPostCard({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.onTap,
  }) : assert(
         seed == null || slot == null,
         'Provide either seed or slot, not both.',
       ),
       assert(
         !pin || slot != null,
         'pin requires a slot name.',
       );

  final String? seed;
  final String? slot;
  final bool pin;
  final VoidCallback? onTap;
}
```

### MokrUserTile

```dart
/// A list tile showing avatar, name, username, and optional trailing widget.
///
/// ```dart
/// MokrUserTile(seed: 'user_42')
/// MokrUserTile(slot: 'follower_$index')
/// ```
class MokrUserTile extends StatelessWidget {
  const MokrUserTile({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.trailing,
    this.onTap,
  }) : assert(
         seed == null || slot == null,
         'Provide either seed or slot, not both.',
       ),
       assert(
         !pin || slot != null,
         'pin requires a slot name.',
       );

  final String? seed;
  final String? slot;
  final bool pin;
  final Widget? trailing;
  final VoidCallback? onTap;
}
```

---

## Enums

```dart
enum MokrShape { circle, rounded, square }

enum MokrCategory {
  face,
  nature,
  travel,
  food,
  fashion,
  fitness,
  art,
  technology,
  office,
  abstract_,   // 'abstract' is a Dart keyword
  product,
  interior,
  architecture,
  automotive,
  pets,
}
```

---

## Image Provider Interface

```dart
/// Abstract interface for image URL construction.
///
/// Implement this to use a custom image source.
/// The interface is sync — all methods return [String], not [Future].
///
/// Built-in implementations:
/// - [PicsumMokrImageProvider] — default, zero-config, category via seed
/// - [UnsplashMokrImageProvider] — opt-in, requires API key, real categories
abstract class MokrImageProvider {
  /// Returns a square avatar image URL.
  /// [category] is typically [MokrCategory.face] for avatars.
  String avatarUrl(String seed, MokrCategory category, {int size = 80});

  /// Returns a content image URL.
  String imageUrl(String seed, MokrCategory category, {int width = 400, int height = 300});

  /// Returns a wide banner image URL.
  String bannerUrl(String seed, MokrCategory category, {int width = 800, int height = 300});
}
```

Note: The public `Mokr.avatarUrl(seed, {size})` method internally passes
`MokrCategory.face` to the provider. Users don't need to specify category for avatars.

---

## Extension Methods

```dart
extension MokrStringExt on String {
  /// Shorthand for [Mokr.user(this)]
  /// ```dart
  /// 'user_42'.asMockUser.name
  /// ```
  MockUser get asMockUser => Mokr.user(this);

  /// Shorthand for [Mokr.post(this)]
  MockPost get asMockPost => Mokr.post(this);

  /// Shorthand for [Mokr.avatarUrl(this)]
  String get asAvatarUrl => Mokr.avatarUrl(this);
}
```
