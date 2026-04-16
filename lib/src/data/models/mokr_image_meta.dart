import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../images/mokr_image_provider.dart';

/// Full image meta object: provider, URL, and aspect ratio in one shot.
///
/// Use when your widget must reserve layout space before the image loads,
/// preventing the layout jump that `Image.network` alone would cause:
///
/// ```dart
/// final img = Mokr.image.meta('post_1', category: MokrCategory.food);
///
/// AspectRatio(
///   aspectRatio: img.aspectRatio,  // known synchronously, before network
///   child: Image(image: img.provider, fit: BoxFit.cover),
/// )
/// ```
///
/// Obtain via [MokrImageNamespace.meta], [MokrImageNamespace.avatarMeta],
/// [MockUser.avatarMeta], or [MockPost.imageMeta].
@immutable
class MokrImageMeta {
  const MokrImageMeta({
    required this.provider,
    required this.url,
    required this.aspectRatio,
    required this.ratio,
    required this.seed,
    required this.category,
  });

  /// For use with `Image(image: img.provider, ...)`.
  final ImageProvider provider;

  /// Escape hatch — for `CachedNetworkImage(imageUrl: img.url)` etc.
  final String url;

  /// `width / height` — always known synchronously before the image loads.
  ///
  /// - Picsum: derived from dimensions baked into the URL.
  /// - Unsplash: derived from the pre-warm API response.
  /// - Fallback: `16 / 9` when the provider has no prior knowledge.
  final double aspectRatio;

  /// Classified ratio bucket derived from [aspectRatio].
  final MokrRatio ratio;

  /// The seed used to generate this image.
  final String seed;

  /// The category used to select the image.
  final MokrCategory category;

  /// Classifies a numeric aspect ratio into a [MokrRatio] bucket.
  ///
  /// - `> 1.2`  → [MokrRatio.landscape]
  /// - `< 0.85` → [MokrRatio.portrait]
  /// - otherwise → [MokrRatio.square]
  static MokrRatio ratioFrom(double r) {
    if (r > 1.2) return MokrRatio.landscape;
    if (r < 0.85) return MokrRatio.portrait;
    return MokrRatio.square;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MokrImageMeta &&
          runtimeType == other.runtimeType &&
          seed == other.seed &&
          category == other.category;

  @override
  int get hashCode => Object.hash(seed, category);

  @override
  String toString() =>
      'MokrImageMeta(seed: $seed, category: ${category.keyword}, '
      'aspectRatio: ${aspectRatio.toStringAsFixed(2)}, ratio: $ratio)';
}
