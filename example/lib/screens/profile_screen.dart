// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

/// Use case: "I'm building a profile page. Give me a user and their posts."
///
/// Demonstrates:
/// - [Mokr.user] for deterministic user data
/// - [Mokr.feedPage] for a deterministic post grid
/// - [MokrImage] for banner and post grid images
/// - [MokrAvatar] overlaid on the banner
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _user = Mokr.user('profile_demo');
  static final _posts = Mokr.feedPage('profile_demo_posts', pageSize: 9);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return CustomScrollView(
      slivers: [
        // ── App bar with banner ────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          title: Text(_user.name),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Banner image
                MokrImage(
                  seed: 'profile_banner',
                  category: MokrCategory.nature,
                  width: double.infinity,
                  height: 200,
                ),
                // Gradient scrim so the AppBar title stays readable
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Colors.transparent],
                      stops: [0.0, 0.6],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Profile header ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar floated up
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                        ),
                        child: MokrAvatar(seed: 'profile_demo', size: 72),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Edit Profile'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Name + verified + username
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _user.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_user.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: Color(0xFF1DA1F2),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _user.username,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user.bio,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                            value: _user.formattedFollowers,
                            label: 'Followers',
                          ),
                          const SizedBox(width: 24),
                          _StatChip(
                            value: _user.formattedFollowing,
                            label: 'Following',
                          ),
                          const SizedBox(width: 24),
                          _StatChip(
                            value: '${_user.postCount}',
                            label: 'Posts',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Post grid ──────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _posts.length,
            itemBuilder: (context, i) {
              final post = _posts[i];
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: post.hasImage
                    ? MokrImage(
                        seed: post.seed,
                        category: post.imageCategory!,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Text(
                            'T',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
