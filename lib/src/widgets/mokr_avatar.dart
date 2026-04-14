import 'package:flutter/material.dart';

import '../images/mokr_image_provider.dart';
import 'internal/mokr_shimmer.dart';

/// A circular (or shaped) avatar widget.
///
/// Phase 1 stub — renders a shimmer placeholder.
/// Full implementation (ImageProvider, error fallback) added in Phase 4.
///
/// ```dart
/// MokrAvatar(seed: 'user_42', size: 48)
/// MokrAvatar(slot: 'sidebar_user', size: 48)
/// ```
class MokrAvatar extends StatelessWidget {
  const MokrAvatar({
    super.key,
    this.seed,
    this.slot,
    this.size = 48.0,
    this.shape = MokrShape.circle,
    this.border,
    this.onTap,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  final String? seed;
  final String? slot;
  final double size;
  final MokrShape shape;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    Widget content = loadingBuilder != null
        ? loadingBuilder!(context)
        : MokrShimmer(
            child: SizedBox.square(
              dimension: size,
              child: const ColoredBox(color: Color(0xFFE0E0E0)),
            ),
          );

    content = switch (shape) {
      MokrShape.circle => ClipOval(child: content),
      MokrShape.rounded => ClipRRect(
          borderRadius: BorderRadius.circular(size / 4),
          child: content,
        ),
      MokrShape.square => content,
    };

    if (border != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          shape: shape == MokrShape.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == MokrShape.rounded
              ? BorderRadius.circular(size / 4)
              : null,
          border: border,
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}
