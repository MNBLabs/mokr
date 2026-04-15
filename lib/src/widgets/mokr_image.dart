import 'package:flutter/material.dart';

import '../core/mokr_base.dart';
import '../images/mokr_image_provider.dart';
import '../slots/slot_registry.dart';
import 'internal/mokr_shimmer.dart';

/// A content image widget backed by a mock image URL.
///
/// **Seed mode** — deterministic, same image every time:
/// ```dart
/// MokrImage(seed: 'post_1', category: MokrCategory.food, height: 200)
/// ```
///
/// **Slot mode** — stable random, persists across hot restarts:
/// ```dart
/// MokrImage(slot: 'feed_hero', category: MokrCategory.travel)
/// ```
///
/// **Aspect ratio from source** — height is derived from the image's natural
/// ratio (no layout jump):
/// ```dart
/// MokrImage(
///   seed: 'post_1',
///   category: MokrCategory.nature,
///   aspectRatioFromSource: true,
/// )
/// ```
class MokrImage extends StatelessWidget {
  const MokrImage({
    super.key,
    this.seed,
    this.slot,
    this.category = MokrCategory.nature,
    this.width,
    this.height = 200.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.aspectRatioFromSource = false,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  /// Deterministic seed — same image on every call.
  final String? seed;

  /// Slot key — stable random image, re-generates only after [Mokr.slots.clear].
  final String? slot;

  /// Image category — controls which type of photo is returned.
  final MokrCategory category;

  /// Width in logical pixels. `null` means unconstrained.
  final double? width;

  /// Height in logical pixels. Ignored when [aspectRatioFromSource] is `true`.
  final double height;

  /// How the image is inscribed into the available space.
  final BoxFit fit;

  /// Clip the image with rounded corners.
  final BorderRadius? borderRadius;

  /// When `true`, wraps the image in [AspectRatio] derived from the image's
  /// known ratio (e.g. 800/600 for Picsum). Overrides [height].
  final bool aspectRatioFromSource;

  /// Override the shimmer shown while the image loads.
  final WidgetBuilder? loadingBuilder;

  /// Override the placeholder shown on image error.
  final WidgetBuilder? errorBuilder;

  String _resolveSeed() {
    if (seed != null) return seed!;
    if (slot != null) return SlotRegistry.resolve(slot!);
    return SlotRegistry.generateSeed();
  }

  Widget _shimmer(BuildContext context) =>
      loadingBuilder?.call(context) ??
      MokrShimmer(
        child: SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(color: Color(0xFFEEEEEE)),
        ),
      );

  Widget _error(BuildContext context) =>
      errorBuilder?.call(context) ?? MokrImageError(width: width, height: height);

  @override
  Widget build(BuildContext context) {
    final resolvedSeed = _resolveSeed();

    if (aspectRatioFromSource) {
      final meta = Mokr.image.meta(resolvedSeed, category: category);
      Widget img = Image(
        image: meta.provider,
        width: width,
        fit: fit,
        frameBuilder: (ctx, child, frame, _) =>
            frame == null ? _shimmer(ctx) : child,
        errorBuilder: (ctx, _, __) => _error(ctx),
      );
      if (borderRadius != null) {
        img = ClipRRect(borderRadius: borderRadius!, child: img);
      }
      return AspectRatio(aspectRatio: meta.aspectRatio, child: img);
    }

    Widget img = Image(
      image: Mokr.image.provider(resolvedSeed, category: category),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (ctx, child, frame, _) =>
          frame == null ? _shimmer(ctx) : child,
      errorBuilder: (ctx, _, __) => _error(ctx),
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
