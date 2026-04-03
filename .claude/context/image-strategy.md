# Image Strategy — mokr

## Primary Source: Unsplash Source API

No API key required. No auth.

```
https://source.unsplash.com/{width}x{height}/?{keywords}&sig={int}
```

### The `sig` Parameter

`sig` is the determinism hook. Unsplash uses it to select consistently from the matched result set.

- Same `sig` → same image from the matched set ✓
- Different `sig` → different image
- `sig` is derived from seed: `sig = SeedHash.hash(seed) % 9999`
- Range: 0–9999 gives sufficient variation across all categories

### Category → Keyword Mapping

```dart
enum MokrCategory {
  face        → 'face'
  nature      → 'nature,landscape'
  travel      → 'travel,city'
  food        → 'food,meal'
  fashion     → 'fashion,style'
  fitness     → 'fitness,sport'
  art         → 'art,creative'
  technology  → 'technology,computer'
  office      → 'office,workspace'
  abstract_   → 'abstract,texture'
  product     → 'product,lifestyle'
  interior    → 'interior,room'
  architecture → 'architecture,building'
  automotive  → 'car,automotive'
  pets        → 'pets,animals'
}
```

### URL Construction Examples

```dart
// Avatar — square crop, face category
'https://source.unsplash.com/80x80/?face&sig=7423'

// Post image — nature
'https://source.unsplash.com/400x300/?nature,landscape&sig=1829'

// Banner — wide
'https://source.unsplash.com/800x300/?travel,city&sig=4421'
```

### Construction is Always Sync
```dart
// ✓ Correct — pure string construction
String avatarUrl(String seed, {int size = 80}) {
  final sig = SeedHash.hash(seed) % 9999;
  return 'https://source.unsplash.com/${size}x${size}/?face&sig=$sig';
}

// ✗ Wrong — never, under any circumstances
Future<String> avatarUrl(String seed) async { ... }
```

---

## Fallback Source: Picsum Photos

When Unsplash is unreachable or throttled:

```
https://picsum.photos/seed/{seed_string}/{width}/{height}
```

Picsum has native seed support in the URL — no `sig` hack needed.
Limitation: no category filtering. Accepts any seed string directly.

```dart
'https://picsum.photos/seed/user_42/80/80'
'https://picsum.photos/seed/post_1/400/300'
```

---

## Abstract Interface

```dart
abstract class MokrImageProvider {
  /// Always sync. Always returns a valid URL string. Never throws.
  String avatarUrl(String seed, {int size = 80});
  String imageUrl(String seed, MokrCategory category, {int width = 400, int height = 300});
  String bannerUrl(String seed, {int width = 800, int height = 300});
}
```

Default: `UnsplashMokrImageProvider`
Built-in fallback: `PicsumMokrImageProvider`
Custom: inject via `Mokr.init(imageProvider: MyProvider())`

---

## Sizing Reference

| Use | Size |
|---|---|
| Avatar small | 40×40 |
| Avatar medium | 80×80 |
| Avatar large | 120×120 |
| Feed post (square) | 400×400 |
| Feed post (landscape) | 400×300 |
| Story | 200×350 |
| Banner | 800×300 |

---

## Copyright Notice in Code

Every image URL method must have this dartdoc comment:
```dart
/// Images are sourced from Unsplash's public API.
/// For development and prototyping only.
/// Do not use in production apps or ship to end users.
```
