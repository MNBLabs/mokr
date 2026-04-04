import 'package:flutter/material.dart';

import '../core/seed_hash.dart';
import '../mokr_enums.dart';
import '../mokr_impl.dart';
import '../mokr_public.dart';
import 'internal/mokr_shimmer.dart';

/// A circular (or shaped) avatar image backed by a mock user.
///
/// Behaviour is determined by which parameter you pass:
///
/// **Deterministic** — same seed, same face, always.
/// ```dart
/// MokrAvatar(seed: 'user_42', size: 48)
/// ```
///
/// **Slot** — random once, stable to this slot.
/// ```dart
/// MokrAvatar(slot: 'sidebar_user', size: 48)
/// MokrAvatar(slot: 'sidebar_user', pin: true, size: 48)
/// ```
///
/// **Fresh random** — different every rebuild.
/// ```dart
/// MokrAvatar(size: 48)
/// ```
///
/// Works as `child:` in any widget:
/// ```dart
/// Container(child: MokrAvatar(seed: 'u1', size: 20))
/// ListTile(leading: MokrAvatar(slot: 'item_$index', size: 40))
/// ```
class MokrAvatar extends StatefulWidget {
  const MokrAvatar({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.size = 48.0,
    this.shape = MokrShape.circle,
    this.border,
    this.onTap,
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

  /// Diameter of the avatar in logical pixels. Defaults to `48`.
  final double size;

  /// Shape of the avatar clipping. Defaults to [MokrShape.circle].
  final MokrShape shape;

  /// Optional border drawn over the avatar.
  final BoxBorder? border;

  /// Called when the avatar is tapped.
  final VoidCallback? onTap;

  /// Custom loading widget. Defaults to [MokrShimmer].
  final WidgetBuilder? loadingBuilder;

  /// Custom error widget. Defaults to initials on a muted background.
  final WidgetBuilder? errorBuilder;

  @override
  State<MokrAvatar> createState() => _MokrAvatarState();
}

class _MokrAvatarState extends State<MokrAvatar> {
  late final String _seed;
  late final String _initials;
  late final Color _fallbackColor;
  late final String _url;

  // 12 muted Material-palette colours, indexed by hash for determinism.
  static const _palette = [
    Color(0xFF78909C), // blue grey
    Color(0xFF7986CB), // indigo
    Color(0xFF4DB6AC), // teal
    Color(0xFF81C784), // green
    Color(0xFFFFB74D), // orange
    Color(0xFFF06292), // pink
    Color(0xFF64B5F6), // blue
    Color(0xFFBA68C8), // purple
    Color(0xFFFF8A65), // deep orange
    Color(0xFF4DD0E1), // cyan
    Color(0xFFA1887F), // brown
    Color(0xFF90A4AE), // blue grey light
  ];

  @override
  void initState() {
    super.initState();
    final user = MokrImpl.resolveUser(
      seed: widget.seed,
      slot: widget.slot,
      pin: widget.pin,
    );
    _seed = user.seed;
    _initials = user.initials;
    _fallbackColor = _palette[SeedHash.hash(_seed) % _palette.length];
    _url = Mokr.avatarUrl(_seed, size: widget.size.round().clamp(1, 4096));
  }

  Widget _clip(Widget child) {
    return switch (widget.shape) {
      MokrShape.circle => ClipOval(child: child),
      MokrShape.rounded => ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 4),
          child: child,
        ),
      MokrShape.square => child,
    };
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) return widget.loadingBuilder!(context);
    return _clip(
      MokrShimmer(
        child: SizedBox.square(
          dimension: widget.size,
          child: const ColoredBox(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    if (widget.errorBuilder != null) return widget.errorBuilder!(context);
    return _clip(
      SizedBox.square(
        dimension: widget.size,
        child: ColoredBox(
          color: _fallbackColor,
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.size * 0.38,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = SizedBox.square(
      dimension: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _url,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return _clip(child);
              return _buildLoading(context);
            },
            errorBuilder: (context, _, __) => _buildError(context),
          ),
          if (widget.border != null)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: widget.shape == MokrShape.circle
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: widget.shape == MokrShape.rounded
                    ? BorderRadius.circular(widget.size / 4)
                    : null,
                border: widget.border,
              ),
            ),
        ],
      ),
    );

    if (widget.onTap != null) {
      avatar = GestureDetector(onTap: widget.onTap, child: avatar);
    }

    return avatar;
  }
}
