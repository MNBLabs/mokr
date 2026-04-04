# mokr

**Realistic mock data and images for Flutter UI development.**

Drop one line anywhere in your widget tree. Get a realistic user, post, or image — stable across hot reloads, restarts, and team members' machines. No backend. No setup beyond `await Mokr.init()`.

---

> **⚠️ Development and prototyping only.**
> mokr asserts and refuses to run in release builds.
> Do not ship it to end users or include it in production app bundles.

---

## The Problem

Building UI in Flutter means staring at placeholder boxes and `Lorem Ipsum` until your backend is ready. Once you wire up real data, everything shifts — layouts break, names are too long or too short, images never match the category you designed for.

mokr gives you realistic, deterministic mock data that behaves exactly like real data, immediately. A user always has the same name. A post always has the same caption. An image always comes from the right category. Your UI looks finished before your backend exists.

---

## Quick Start

```yaml
# pubspec.yaml
dependencies:
  mokr: ^0.1.0
```

```dart
// main.dart
void main() async {
  await Mokr.init();
  runApp(MyApp());
}
```

```dart
// Anywhere in your widget tree — no await, no FutureBuilder
MokrAvatar(seed: 'user_42', size: 48)
MokrImage(seed: 'post_1', category: MokrCategory.nature)
MokrPostCard(seed: 'feed_0')

// Or use the data directly in your own widgets
final user = Mokr.user('user_42');
Text(user.name)
Text('@${user.username}')

// URL strings for NetworkImage, CachedNetworkImage, etc.
Image.network(Mokr.avatarUrl('user_42', size: 80))
Image.network(Mokr.imageUrl('post_1', category: MokrCategory.travel))
```

---

## The Four Modes

mokr has four ways to generate data. They form a spectrum from throwaway to permanent.

```dart
// 1 — Fresh random
//     Different every call. Nothing stored. Use for quick browsing.
Mokr.randomUser()

// 2 — Slot (stable random)
//     Random once, then frozen. Stable across hot reloads and restarts.
//     Clear it when you want a new result.
Mokr.randomUser(slot: 'card_1')

// 3 — Pinned slot
//     Same as slot, but protected from Mokr.clearAll().
//     Only clears when you explicitly call Mokr.clearPin('hero').
Mokr.randomUser(slot: 'hero', pin: true)

// 4 — Deterministic
//     Seed baked into code. Same result everywhere, forever.
//     No disk, no init() dependency, no runtime state.
Mokr.user('user_42')
```

The same four modes work for posts and all widgets:

```dart
Mokr.randomPost()
Mokr.randomPost(slot: 'feed_hero', pin: true)
Mokr.post('post_seed')

MokrAvatar()                              // fresh random
MokrAvatar(slot: 'card_1')               // slot
MokrAvatar(slot: 'hero', pin: true)      // pinned slot
MokrAvatar(seed: 'user_42')              // deterministic
```

---

## The Graduation Flow

Start with `randomUser()` and browse. When you see a result you like, make it permanent.

```
Step 1 — write this, iterate fast:
  Mokr.randomUser()

Step 2 — see a user you like. Console shows:
  [mokr] 🎲 fresh → seed: 'mokr_a7Be'

Step 3 — copy the seed, freeze it forever:
  Mokr.user('mokr_a7Be')
```

Or skip step 3 and use a slot — the result stays stable without baking a seed into code:

```dart
Mokr.randomUser(slot: 'profile_card')  // frozen until you clear it
```

---

## Widgets

All mokr widgets are standard Flutter widgets. They work anywhere — inside `Card`, `ListView.builder`, `Stack`, `Expanded`, or as `child:` of any widget.

### MokrAvatar

```dart
// Circle (default), rounded, or square
MokrAvatar(seed: 'user_42', size: 48)
MokrAvatar(seed: 'user_42', size: 48, shape: MokrShape.rounded)
MokrAvatar(seed: 'user_42', size: 48, shape: MokrShape.square)

// With border
MokrAvatar(seed: 'user_42', size: 48, borderWidth: 2)

// Custom loading / error states
MokrAvatar(
  seed: 'user_42',
  size: 48,
  loadingBuilder: (context) => MyShimmer(),
  errorBuilder: (context) => MyFallback(),
)

// Slot and fresh random work too
MokrAvatar(slot: 'sidebar_user', size: 40)
MokrAvatar(size: 40)  // fresh random
```

### MokrImage

```dart
// Fixed size
MokrImage(
  seed: 'post_1',
  category: MokrCategory.nature,
  width: 400,
  height: 300,
)

// Fill parent (inside Expanded, AspectRatio, SizedBox.expand, etc.)
MokrImage(
  seed: 'banner',
  category: MokrCategory.architecture,
  width: double.infinity,
  height: 200,
)

// With border radius
MokrImage(
  seed: 'card_image',
  category: MokrCategory.food,
  width: 300,
  height: 200,
  borderRadius: BorderRadius.circular(12),
)
```

### MokrPostCard

```dart
// Full post card — avatar, image, caption, like/comment/share counts
MokrPostCard(seed: 'feed_0')
MokrPostCard(slot: 'featured')
MokrPostCard(slot: 'featured', pin: true)
MokrPostCard()  // fresh random
```

### MokrUserTile

```dart
// User list tile — avatar, name, username, optional trailing widget
MokrUserTile(seed: 'user_42')
MokrUserTile(
  seed: 'user_42',
  trailing: FilledButton(onPressed: () {}, child: const Text('Follow')),
)
MokrUserTile(slot: 'suggestion_1')
```

---

## Data API

Use the data API when you want to feed mock data into your own widgets.

### Users

```dart
final user = Mokr.user('user_42');

user.name           // 'Jordan Rivera'
user.username       // 'jordanrivera'
user.bio            // 'Outdoor photographer and trail runner.'
user.seed           // 'user_42'
user.followerCount  // 4_821
user.followingCount // 312
user.postCount      // 87
user.initials       // 'JR'
```

### Posts

```dart
final post = Mokr.post('post_1');

post.caption        // 'Golden hour at the summit. Worth every step. 🌄'
post.likeCount      // 1_203
post.commentCount   // 48
post.shareCount     // 19
post.formattedLikes // '1.2K'
post.hasImage       // true
post.imageUrl       // category-aware URL string
post.author         // MockUser
post.createdAt      // DateTime (recent, realistic)
post.relativeTime   // '3h ago'
```

### Feeds

```dart
// Same seed + same page → same posts, always
final page0 = Mokr.feedPage('home_feed', page: 0, pageSize: 20);
final page1 = Mokr.feedPage('home_feed', page: 1, pageSize: 20);

// Infinite scroll example:
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, i) => PostCard(post: posts[i]),
)
```

### String extensions

```dart
'user_42'.asMockUser   // same as Mokr.user('user_42')
'post_0'.asMockPost    // same as Mokr.post('post_0')
'user_42'.asAvatarUrl  // same as Mokr.avatarUrl('user_42')
```

---

## Image Categories

15 categories for every part of your UI:

| Category | Use for |
|---|---|
| `MokrCategory.face` | Avatars, profile photos |
| `MokrCategory.nature` | Landscape posts, banners |
| `MokrCategory.travel` | Destination cards, explore grids |
| `MokrCategory.food` | Restaurant apps, recipe cards |
| `MokrCategory.fashion` | Product listings, lookbooks |
| `MokrCategory.fitness` | Workout apps, progress cards |
| `MokrCategory.art` | Creative platforms, galleries |
| `MokrCategory.technology` | Tech blogs, device mockups |
| `MokrCategory.office` | B2B dashboards, productivity apps |
| `MokrCategory.abstract_` | Backgrounds, decorative images |
| `MokrCategory.product` | E-commerce, lifestyle photography |
| `MokrCategory.interior` | Real estate, home decor |
| `MokrCategory.architecture` | Property apps, city guides |
| `MokrCategory.automotive` | Car listings, transport apps |
| `MokrCategory.pets` | Pet apps, community feeds |

Note: `abstract_` has a trailing underscore because `abstract` is a Dart keyword.

---

## Slot Management

```dart
// Clear a single unpinned slot — re-randomises on next call
await Mokr.clearSlot('card_1');

// Clear a pinned slot — requires explicit intent
await Mokr.clearPin('hero');

// Clear all unpinned slots — pinned slots survive
await Mokr.clearAll();
```

A common pattern for pull-to-refresh:

```dart
Future<void> onRefresh() async {
  await Mokr.clearAll();  // wipe unpinned slots — fresh randoms next build
  setState(() => _session++);  // new seed → feedPage returns new posts
}
```

---

## Unsplash Images (opt-in)

By default, mokr uses [Picsum](https://picsum.photos) — no API key required.

To get real, category-filtered images from [Unsplash](https://unsplash.com/developers):

```dart
// At startup:
await Mokr.init(unsplashKey: 'your_access_key');

// Or switch at runtime (e.g. from a dev settings screen):
final count = await Mokr.useUnsplash('your_access_key');
// count == 0  → key invalid or network unavailable
// count 1–15  → categories loaded successfully (rest fall back to Picsum)

// Switch back to Picsum:
Mokr.usePicsum();
```

Use the **Access Key** from your Unsplash app dashboard — not the Secret Key or Application ID.

mokr pre-warms a URL cache at startup (2 requests × 15 categories = 30 total).
After warm-up, all `imageUrl`, `avatarUrl`, and `bannerUrl` calls are instant and synchronous.
Categories that fail to warm fall back to Picsum transparently.

---

## Custom Image Provider

Plug in any image source by implementing `MokrImageProvider`:

```dart
class MyImageProvider extends MokrImageProvider {
  @override
  String avatarUrl(String seed, MokrCategory category, {int size = 80}) {
    return 'https://my-cdn.com/avatars/$seed?size=$size';
  }

  @override
  String imageUrl(String seed, MokrCategory category,
      {int width = 400, int height = 300}) {
    return 'https://my-cdn.com/images/${category.keyword}/$seed'
        '?w=$width&h=$height';
  }

  @override
  String bannerUrl(String seed, MokrCategory category,
      {int width = 800, int height = 300}) {
    return 'https://my-cdn.com/banners/$seed?w=$width&h=$height';
  }
}

// Activate:
await Mokr.init(imageProvider: MyImageProvider());
```

---

## License

MIT — see [LICENSE](LICENSE).

Images are sourced from [Picsum Photos](https://picsum.photos) (default) and
[Unsplash](https://unsplash.com) (opt-in). Refer to their respective terms when using
Unsplash images. mokr is a development tool — do not use it to serve images to end users.
