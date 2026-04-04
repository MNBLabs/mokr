import 'package:flutter/material.dart';

import '../data/models/mock_user.dart';
import '../mokr_public.dart';
import 'mokr_avatar.dart';

/// A list tile showing avatar, name, username, and optional trailing widget.
///
/// ```dart
/// MokrUserTile(seed: 'user_42')
/// MokrUserTile(slot: 'follower_$index')
/// MokrUserTile(
///   seed: 'user_42',
///   trailing: ElevatedButton(onPressed: () {}, child: Text('Follow')),
/// )
/// ```
class MokrUserTile extends StatelessWidget {
  const MokrUserTile({
    super.key,
    this.seed,
    this.slot,
    this.pin = false,
    this.trailing,
    this.onTap,
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

  /// Optional widget shown at the end of the tile (e.g. a Follow button).
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  MockUser _resolveUser() {
    if (seed != null) return Mokr.user(seed!);
    if (slot != null) return Mokr.randomUser(slot: slot!, pin: pin);
    return Mokr.randomUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = _resolveUser();
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return ListTile(
      onTap: onTap,
      leading: MokrAvatar(seed: user.seed, size: 48),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              user.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: Color(0xFF1DA1F2)),
          ],
        ],
      ),
      subtitle: Text(
        user.username,
        style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
      ),
      trailing: trailing,
    );
  }
}
