# /widgets — Widget Layer

Core implementation must be complete and passing tests before starting this phase.
Read `.claude/context/api-contracts.md` widget section in full.

---

## Internal Shimmer First
`lib/src/widgets/internal/mokr_shimmer.dart`

StatefulWidget. AnimationController-based shimmer. Not exported.
Used by MokrAvatar and MokrImage as their default loading state.
Accepts a `child` so it can wrap any shape/size.
No external shimmer package — pure Flutter animation.

---

## MokrAvatar
`lib/src/widgets/mokr_avatar.dart`

StatefulWidget (needs to manage image loading state).

Internal resolution logic:
```dart
String _resolveSeed() {
  if (widget.seed != null) return widget.seed!;
  if (widget.slot != null) return MokrImpl.instance.slotRegistry.getOrCreate(widget.slot!);
  return MokrImpl.instance.generateFreshSeed();  // logs to console
}
```

Rendering:
- Load state → `widget.loadingBuilder?(context)` OR `MokrShimmer` of the same size/shape
- Loaded → `Image.network(...)` clipped to shape (ClipOval / ClipRRect / none)
- Error → `widget.errorBuilder?(context)` OR initials on coloured background
  - Background colour: deterministic from seed (`Color(SeedHash.hash(seed) | 0xFF000000)`, muted)
  - Initials: from `MockUser.initials` for the resolved seed

Constructor assert:
```dart
assert(seed == null || slot == null, 'Provide seed or slot, not both.')
```

---

## MokrImage
`lib/src/widgets/mokr_image.dart`

StatefulWidget.

Same seed resolution pattern as MokrAvatar.
Uses `Mokr.imageUrl(resolvedSeed, category: category, width: ..., height: ...)`.
Renders with `Image.network` + `BoxFit.cover` by default.
Loading: `MokrShimmer` sized to width×height.
Error: solid muted background + camera icon (from Flutter Icons, not an asset).
Respects `borderRadius` via `ClipRRect`.

---

## MokrPostCard
`lib/src/widgets/mokr_post_card.dart`

StatelessWidget (delegates loading to MokrImage internally).

Layout:
```
[Avatar 40px] [Name + @username]     [relativeTime]
[Post image — full width, 200px height, if post.hasImage]
[Caption text — max 3 lines]
[❤️ likeCount  💬 commentCount  ↗️ shareCount]
```

All data from `Mokr.post(resolvedSeed)` or `Mokr.randomPost(slot:, pin:)`.
Uses `MokrAvatar` internally for the author avatar — consistent.
Formatted counts: `formattedLikes` getter on `MockPost`.

---

## MokrUserTile
`lib/src/widgets/mokr_user_tile.dart`

StatelessWidget.

Standard list tile:
```
[MokrAvatar 48px] [Name (bold) + @username (muted)]   [trailing widget]
```

`trailing` is optional — developer provides their own (Follow button, etc.).
Uses `MokrAvatar` internally — consistent avatar rendering.

---

## Widget Composability Tests
Every widget must render without error inside:
- `Container(child: widget)` — basic child
- `ListView.builder(itemBuilder: (ctx, i) => widget)` — list context
- `Stack(children: [widget])` — overlay context
- `Expanded(child: widget)` — flex context

Run with `flutter test test/widgets/` using `pumpWidget` + `tester.pump()`.

---

## Export Checklist
`lib/mokr.dart` must export:
- [ ] `MokrAvatar`
- [ ] `MokrImage`
- [ ] `MokrPostCard`
- [ ] `MokrUserTile`
- [ ] `MokrShape`
- [ ] `MokrCategory`
- Must NOT export `MokrShimmer` (internal)
