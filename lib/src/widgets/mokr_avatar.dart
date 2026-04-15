import 'package:flutter/material.dart';

import '../core/mokr_base.dart';
import '../images/mokr_image_provider.dart';
import '../slots/slot_registry.dart';
import 'internal/mokr_shimmer.dart';

/// A circular (or shaped) avatar widget backed by a mock image.
///
/// **Seed mode** — deterministic, same image every time:
/// ```dart
/// MokrAvatar(seed: 'user_42', size: 48)
/// ```
///
/// **Slot mode** — stable random, persists across hot restarts:
/// ```dart
/// MokrAvatar(slot: 'sidebar_hero', size: 48)
/// ```
///
/// **Fresh mode** — new random avatar every build (use sparingly):
/// ```dart
/// MokrAvatar(size: 48)
/// ```
///
/// The image loads via [NetworkImage] and shows a shimmer while loading.
/// Override with [loadingBuilder] to supply your own loading widget.
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

  /// Deterministic seed — same avatar on every call.
  final String? seed;

  /// Slot key — stable random avatar, re-generates only after [Mokr.slots.clear].
  final String? slot;

  /// Width and height of the avatar in logical pixels.
  final double size;

  /// Clipping shape: circle (default), rounded rectangle, or unclipped square.
  final MokrShape shape;

  /// Optional border painted around the avatar.
  final BoxBorder? border;

  /// Called when the avatar is tapped.
  final VoidCallback? onTap;

  /// Override the default shimmer shown while the image loads.
  /// Receives [BuildContext]; return any widget.
  final WidgetBuilder? loadingBuilder;

  /// Override the default placeholder shown on image error.
  /// Receives [BuildContext]; return any widget.
  final WidgetBuilder? errorBuilder;

  String _resolveSeed() {
    if (seed != null) return seed!;
    if (slot != null) return SlotRegistry.resolve(slot!);
    return SlotRegistry.generateSeed();
  }

  Widget _shimmer(BuildContext context) =>
      loadingBuilder?.call(context) ??
      MokrShimmer(
        child: SizedBox.square(
          dimension: size,
          child: const ColoredBox(color: Color(0xFFE0E0E0)),
        ),
      );

  Widget _error(BuildContext context) =>
      errorBuilder?.call(context) ?? MokrAvatarError(size: size);

  @override
  Widget build(BuildContext context) {
    final resolvedSeed = _resolveSeed();

    Widget content = Image(
      image: Mokr.image.avatarProvider(resolvedSeed, size: size.toInt()),
      width: size,
      height: size,
      fit: BoxFit.cover,
      frameBuilder: (ctx, child, frame, _) =>
          frame == null ? _shimmer(ctx) : child,
      errorBuilder: (ctx, _, __) => _error(ctx),
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
