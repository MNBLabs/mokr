import 'package:flutter/material.dart';

import '../core/slot_registry.dart';
import '../mokr_enums.dart';
import '../mokr_impl.dart';
import '../mokr_public.dart';
import 'internal/mokr_shimmer.dart';

/// A content image backed by mock data.
///
/// ```dart
/// MokrImage(seed: 'post_1', category: MokrCategory.nature)
/// MokrImage(slot: 'feed_hero', category: MokrCategory.travel, height: 200)
/// MokrImage(category: MokrCategory.food)  // fresh random
/// ```
///
/// Supports custom loading and error states:
/// ```dart
/// MokrImage(
///   seed: 'post_1',
///   loadingBuilder: (context) => MyShimmer(),
///   errorBuilder: (context) => MyErrorTile(),
/// )
/// ```
class MokrImage extends StatefulWidget {
  const MokrImage({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.category = MokrCategory.nature,
    this.width,
    this.height = 200.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingBuilder,
    this.errorBuilder,
  })  : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        ),
        assert(
          !pin || slot != null,
          'pin requires a slot name.',
        );

  /// Deterministic seed. Provide [seed] or [slot], not both.
  final String? seed;

  /// Slot name for stable-random mode. Persisted across restarts.
  final String? slot;

  /// When true, this slot survives [Mokr.clearAll]. Requires [slot].
  final bool pin;

  /// Image subject category. Defaults to [MokrCategory.nature].
  final MokrCategory category;

  /// Width in logical pixels. `null` means fill available space.
  final double? width;

  /// Height in logical pixels. Defaults to `200`.
  final double height;

  /// How the image is inscribed into its box. Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Optional corner rounding applied via [ClipRRect].
  final BorderRadius? borderRadius;

  /// Custom loading widget. Defaults to [MokrShimmer].
  final WidgetBuilder? loadingBuilder;

  /// Custom error widget. Defaults to a muted background with a camera icon.
  final WidgetBuilder? errorBuilder;

  @override
  State<MokrImage> createState() => _MokrImageState();
}

class _MokrImageState extends State<MokrImage> {
  late final String _url;

  @override
  void initState() {
    super.initState();
    final seed = _resolveSeed();
    // Both width and height may be double.infinity when used inside
    // unconstrained parents (e.g. SliverGrid with childAspectRatio).
    // Fall back to sensible URL dimensions in those cases.
    final finiteHeight =
        widget.height.isFinite ? widget.height : 400.0;
    final urlWidth = (widget.width != null && widget.width!.isFinite)
        ? widget.width!.round().clamp(1, 8192)
        : (finiteHeight * 2).round().clamp(1, 8192);
    final urlHeight = finiteHeight.round().clamp(1, 8192);
    _url = Mokr.imageUrl(
      seed,
      category: widget.category,
      width: urlWidth,
      height: urlHeight,
    );
  }

  String _resolveSeed() {
    if (widget.seed != null) return widget.seed!;
    if (widget.slot != null) {
      final s = SlotRegistry.instance.getOrCreate(
        widget.slot!,
        generateSeed: MokrImpl.generateFreshSeed,
      );
      if (widget.pin) SlotRegistry.instance.pin(widget.slot!);
      return s;
    }
    return MokrImpl.generateFreshSeed();
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) return widget.loadingBuilder!(context);
    return MokrShimmer(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: const ColoredBox(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    if (widget.errorBuilder != null) return widget.errorBuilder!(context);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const ColoredBox(
        color: Color(0xFFEEEEEE),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFBDBDBD),
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      _url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _buildLoading(context);
      },
      errorBuilder: (context, _, __) => _buildError(context),
    );

    if (widget.borderRadius != null) {
      image = ClipRRect(borderRadius: widget.borderRadius!, child: image);
    }

    return image;
  }
}
