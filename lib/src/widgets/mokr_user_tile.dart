import 'package:flutter/material.dart';

import '../core/mokr_base.dart';
import '../data/models/mock_user.dart';
import 'mokr_avatar.dart';

/// A list tile showing avatar, name, handle, and an optional trailing widget.
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
    this.trailing,
    this.onTap,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  final String? seed;
  final String? slot;
  final Widget? trailing;
  final VoidCallback? onTap;

  MockUser _resolveUser() {
    // Phase 2 will wire Mokr.random.user(slot:) here.
    if (seed != null) return Mokr.user(seed!);
    if (slot != null) return Mokr.user(slot!);
    return Mokr.user('default');
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
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
        user.handle,
        style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
      ),
      trailing: trailing,
    );
  }
}
