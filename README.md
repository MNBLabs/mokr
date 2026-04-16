# mokr

Realistic mock data and images for Flutter UI development.

---

> **⚠️ Development only.** mokr refuses to run in release builds.

---

## Install

```yaml
# pubspec.yaml
dependencies:
  mokr: ^1.0.0
```

---

## Quick Start

`Mokr.init()` must be called once in `main()`, before `runApp()`. It loads slot
state from disk and optionally warms the image cache. Every other Mokr call is
synchronous — no `await`, no `FutureBuilder` anywhere in your widgets.

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Mokr.init();   // call once here — never inside a widget
  runApp(const MyApp());
}
```

```dart
// Anywhere in your widget tree — sync, no await needed
Mokr.user('u1').name                                              // → 'Jordan Rivera'
Mokr.image.meta('p1', category: MokrCategory.food).aspectRatio   // → 1.33
```

---

## Feed Example

```dart
MokrFeedBuilder(
  feedSeed: 'home_feed',
  pageSize: 20,
  builder: (context, posts) => ListView.builder(
    itemCount: posts.length,
    itemBuilder: (_, i) => ListTile(
      leading: Image(image: posts[i].author.avatarProvider),
      title: Text(posts[i].author.name),
      subtitle: Text(posts[i].caption),
    ),
  ),
)
```

`MokrFeedBuilder` resolves the post list synchronously and passes it straight
to your builder. You own the layout entirely.

---

## Your Widget, Mokr's Data

Mokr adapts to whatever your widget already accepts — `ImageProvider` for `Image`,
`double` for `AspectRatio`, plain `String` for `Text`. You don't need to adopt any
Mokr widget to use the data.

```dart
class MyPostCard extends StatelessWidget {
  const MyPostCard({super.key, required this.post});
  final MockPost post;

  @override
  Widget build(BuildContext context) {
    // imageMeta bundles provider + url + aspectRatio — all synchronous
    final meta = post.imageMeta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // avatarProvider is a plain ImageProvider — pass it straight to Image
        Image(
          image: post.author.avatarProvider,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          frameBuilder: (_, child, frame, __) =>
              frame == null ? const MyShimmer() : child,  // your own shimmer
        ),

        // aspectRatio is known before the image loads — no layout jump
        AspectRatio(
          aspectRatio: meta.aspectRatio,
          child: Image(
            image: meta.provider,
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, __) =>
                frame == null ? const MyShimmer() : child,
          ),
        ),

        // Plain string — no model needed if you only want text
        Text(Mokr.text.caption('post_seed')),
      ],
    );
  }
}
```

---

## Three Modes

| Mode | Call | Persists? |
|---|---|---|
| Deterministic | `Mokr.user('seed')` | No — seed is in your code, nothing written to disk |
| Stable slot | `Mokr.random.user(slot: 'x')` | Yes — random once, frozen until you clear it |
| Fresh random | `Mokr.random.user()` | No — new result every call |

All three modes work for users, posts, and feeds:

```dart
Mokr.user('profile_hero')               // deterministic
Mokr.random.user(slot: 'sidebar_card')  // stable slot
Mokr.random.user()                      // fresh random

Mokr.post('featured')
Mokr.random.post(slot: 'feed_hero')
Mokr.random.post()

Mokr.feed('home_feed', page: 0, pageSize: 20)
```

---

## Image Access Levels

Choose the level that matches what your widget accepts:

| Level | Returns | Use when |
|---|---|---|
| URL | `String` | You're using `Image.network` or `CachedNetworkImage` |
| Provider | `ImageProvider` | You're using `Image(image: ...)` |
| Meta | `MokrImageMeta` | You need `aspectRatio` too (prevents layout jump) |

```dart
// URL
final url = Mokr.image.url('p1', category: MokrCategory.travel);

// ImageProvider
final provider = Mokr.image.provider('p1', category: MokrCategory.food);
Image(image: provider, fit: BoxFit.cover)

// MokrImageMeta — provider + url + aspectRatio in one object
final meta = Mokr.image.meta('p1', category: MokrCategory.nature);
AspectRatio(
  aspectRatio: meta.aspectRatio,   // known before image loads
  child: Image(image: meta.provider, fit: BoxFit.cover),
)

// Avatars follow the same three levels
Mokr.image.avatar('user_42')           // → URL string
Mokr.image.avatarProvider('user_42')   // → ImageProvider
Mokr.image.avatarMeta('user_42')       // → MokrImageMeta (always 1:1)
```

---

## Image Categories

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
| `MokrCategory.interior` | Real estate, home décor |
| `MokrCategory.architecture` | Property apps, city guides |
| `MokrCategory.automotive` | Car listings, transport apps |
| `MokrCategory.pets` | Pet apps, community feeds |

> `abstract_` has a trailing underscore because `abstract` is a reserved Dart keyword.

---

## Graduation Flow

Use `Mokr.random.user()` while iterating. When you find a result you want to keep,
copy the seed from the console and bake it into your code permanently.

**Step 1** — write this and run the app:
```dart
Mokr.random.user()
```

**Step 2** — mokr prints the seed to the debug console:
```
[mokr] 🎲  mokr_a7Be — copy to: Mokr.user('mokr_a7Be')
```

**Step 3** — paste the seed. That user is now frozen forever:
```dart
Mokr.user('mokr_a7Be')   // no disk, no init() dependency, same on every device
```

The deterministic form never writes to disk and has no dependency on `Mokr.init()`
completing — it works the same on every device, forever.

---

## Slot Management

Slots let you freeze a random result across hot reloads and app restarts without
baking a seed into your code.

```dart
// Freeze a random user to a named slot — same result until you clear it
Mokr.random.user(slot: 'profile_card')

// Clear a single slot — next call picks a new random
await Mokr.slots.clear('profile_card');

// Clear all slots at once
await Mokr.slots.clearAll();

// Inspect what slots are currently stored
final map = Mokr.slots.list();  // → {'profile_card': 'mokr_a7Be', ...}
```

---

## Text Namespace

Generate individual strings without a full model:

```dart
Mokr.text.name('seed')       // → 'Jordan Rivera'
Mokr.text.handle('seed')     // → '@jordanrivera'
Mokr.text.bio('seed')        // → 'Trail runner and outdoor photographer.'
Mokr.text.caption('seed')    // → 'Golden hour at the summit. Worth every step.'
Mokr.text.comment('seed')    // → 'This is exactly what I needed today.'
Mokr.text.initials('seed')   // → 'JR'
```

All strings are deterministic — same seed, same output, always.

---

## Unsplash Images (opt-in)

By default mokr uses [Picsum Photos](https://picsum.photos) — no API key required.
To get real, category-filtered images from [Unsplash](https://unsplash.com/developers),
pass your access key to `Mokr.init()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Mokr.init(unsplashKey: 'your_access_key');
  runApp(const MyApp());
}
```

At startup mokr fetches up to 60 photo URLs per category (30 total API requests) and
caches them to disk with a 24-hour TTL. After that, all image URL calls are instant and
synchronous. Categories that fail to load fall back to Picsum transparently.

Use the **Access Key** from your Unsplash app dashboard — not the Secret Key or Application ID.

You can also warm the cache on demand (e.g. from a dev settings screen):

```dart
// Warm or re-warm at runtime — returns the number of categories loaded (0–15)
final count = await Mokr.cache.warm();
// count == 0  → key not set or network unavailable
// count 1–15  → categories loaded (rest fall back to Picsum)

// Inspect cache state per category
final status = Mokr.cache.status();
// → {MokrCategory.food: CacheStatus(urlCount: 60, isStale: false), ...}

// Wipe the disk cache
await Mokr.cache.clear();
```

---

## Convenience Widgets

For when you don't need full control over layout:

```dart
// Circle avatar (also: MokrShape.rounded, MokrShape.square)
MokrAvatar(seed: 'user_42', size: 48)
MokrAvatar(slot: 'sidebar_user', size: 40)

// Category-aware image with shimmer loading
MokrImage(seed: 'post_1', category: MokrCategory.nature, height: 200)

// Wrap in AspectRatio sized to the actual source image
MokrImage(
  seed: 'post_1',
  category: MokrCategory.food,
  aspectRatioFromSource: true,
)

// Full post card — avatar + image + caption + engagement counts
MokrPostCard(seed: 'feed_0')
MokrPostCard(slot: 'featured')

// User list tile with optional trailing widget
MokrUserTile(seed: 'user_42')
MokrUserTile(
  seed: 'user_42',
  trailing: FilledButton(onPressed: () {}, child: const Text('Follow')),
)
```

All widgets accept a custom `loadingBuilder` and `errorBuilder` so you can plug in
your own shimmer and fallback states.

---

## License

MIT — see [LICENSE](LICENSE).

Images sourced from [Picsum Photos](https://picsum.photos) (default, no key required)
and [Unsplash](https://unsplash.com) (opt-in).
mokr is a development tool — do not use it to serve images to end users.
