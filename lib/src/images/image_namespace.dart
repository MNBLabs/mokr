import 'package:flutter/painting.dart';

import '../data/models/mokr_image_meta.dart';
import 'mokr_image_provider.dart';
import 'picsum_provider.dart';

// ─── Package-internal provider state ─────────────────────────────────────────
//
// These top-level declarations are intentionally not exported in mokr.dart.
// They provide cross-file access without exposing internal state publicly.

/// The currently active image provider. Default: [PicsumMokrImageProvider].
///
/// Package-internal — do NOT export.
MokrImageProvider activeMokrProvider = const PicsumMokrImageProvider();

/// Sets the active image provider. Called only by [Mokr.init].
///
/// Package-internal — do NOT export.
void setActiveMokrProvider(MokrImageProvider provider) {
  activeMokrProvider = provider;
}

// ─── Public namespace ─────────────────────────────────────────────────────────

/// `Mokr.image` — three-level image access for any widget.
///
/// **Level 1 — URL string** (for `CachedNetworkImage`, etc.):
/// ```dart
/// Mokr.image.url('post_1', category: MokrCategory.food)
/// ```
///
/// **Level 2 — ImageProvider** (for `Image(image: ...)`):
/// ```dart
/// Image(image: Mokr.image.provider('post_1', category: MokrCategory.food))
/// ```
///
/// **Level 3 — MokrImageMeta** (provider + URL + aspect ratio together):
/// ```dart
/// final img = Mokr.image.meta('post_1', category: MokrCategory.food);
/// AspectRatio(
///   aspectRatio: img.aspectRatio,  // known before network call
///   child: Image(image: img.provider, fit: BoxFit.cover),
/// )
/// ```
final class MokrImageNamespace {
  const MokrImageNamespace();

  // ─── Content images ────────────────────────────────────────────────────────

  /// Returns a mock image URL for [seed] and [category].
  String url(
    String seed, {
    MokrCategory category = MokrCategory.nature,
    int width = 800,
    int height = 600,
  }) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return activeMokrProvider.imageUrl(seed, category,
        width: width, height: height);
  }

  /// Returns a [NetworkImage] for [seed] and [category].
  ///
  /// Use with `Image(image: ...)` and a `frameBuilder` for shimmer:
  /// ```dart
  /// Image(
  ///   image: Mokr.image.provider('post_1'),
  ///   frameBuilder: (ctx, child, frame, _) =>
  ///     frame == null ? const MyShimmer() : child,
  /// )
  /// ```
  ImageProvider provider(
    String seed, {
    MokrCategory category = MokrCategory.nature,
    int width = 800,
    int height = 600,
  }) {
    return NetworkImage(url(seed, category: category, width: width, height: height));
  }

  /// Returns a [MokrImageMeta] containing provider, URL, and aspect ratio.
  ///
  /// The aspect ratio is always known synchronously — use it to prevent layout
  /// jumps with [AspectRatio] before the image loads.
  MokrImageMeta meta(
    String seed, {
    MokrCategory category = MokrCategory.nature,
    int width = 800,
    int height = 600,
  }) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final u = url(seed, category: category, width: width, height: height);
    final ar =
        activeMokrProvider.knownAspectRatio(seed, category) ?? (width / height);
    return MokrImageMeta(
      provider: NetworkImage(u),
      url: u,
      aspectRatio: ar,
      ratio: MokrImageMeta.ratioFrom(ar),
      seed: seed,
      category: category,
    );
  }

  // ─── Avatars ───────────────────────────────────────────────────────────────

  /// Returns a square avatar URL for [seed].
  String avatar(String seed, {int size = 80}) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return activeMokrProvider.avatarUrl(seed, MokrCategory.face, size: size);
  }

  /// Returns a [NetworkImage] avatar for [seed].
  ImageProvider avatarProvider(String seed, {int size = 80}) {
    return NetworkImage(avatar(seed, size: size));
  }

  /// Returns a [MokrImageMeta] for the avatar of [seed].
  ///
  /// Avatars are always square — [MokrImageMeta.aspectRatio] is `1.0`.
  MokrImageMeta avatarMeta(String seed, {int size = 80}) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    final u = avatar(seed, size: size);
    return MokrImageMeta(
      provider: NetworkImage(u),
      url: u,
      aspectRatio: 1.0,
      ratio: MokrRatio.square,
      seed: seed,
      category: MokrCategory.face,
    );
  }

  // ─── Banners ───────────────────────────────────────────────────────────────

  /// Returns a wide banner URL for [seed].
  String banner(String seed, {int width = 1200, int height = 400}) {
    assert(seed.isNotEmpty, 'seed cannot be empty.');
    return activeMokrProvider.bannerUrl(seed, MokrCategory.nature,
        width: width, height: height);
  }
}
