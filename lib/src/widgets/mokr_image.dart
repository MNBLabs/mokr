import 'package:flutter/material.dart';

import '../images/mokr_image_provider.dart';
import 'internal/mokr_shimmer.dart';

/// A content image widget backed by mock data.
///
/// Phase 1 stub — renders a shimmer placeholder.
/// Full implementation (NetworkImage, aspectRatioFromSource) added in Phase 4.
///
/// ```dart
/// MokrImage(seed: 'post_1', category: MokrCategory.nature, height: 200)
/// MokrImage(slot: 'feed_hero', category: MokrCategory.travel)
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

  final String? seed;
  final String? slot;
  final MokrCategory category;
  final double? width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool aspectRatioFromSource;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    Widget w = loadingBuilder != null
        ? loadingBuilder!(context)
        : MokrShimmer(
            child: SizedBox(
              width: width,
              height: height,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          );

    if (borderRadius != null) {
      w = ClipRRect(borderRadius: borderRadius!, child: w);
    }
    return w;
  }
}
