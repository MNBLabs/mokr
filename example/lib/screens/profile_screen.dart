import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

/// Demonstrates the data API + [MokrAvatar] + [MokrImage] together.
///
/// Seed: `'demo_profile'` — deterministic user and posts on every run.
/// The post grid uses [MokrImage] with [aspectRatioFromSource] so each
/// cell fills its space without a fixed height.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _user = Mokr.user('demo_profile');
  static final _posts = Mokr.feed('demo_profile_posts', pageSize: 9);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      appBar: AppBar(title: Text(_user.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + stats row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const MokrAvatar(seed: 'demo_profile', size: 80),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(_user.formattedFollowers, 'Followers'),
                        _Stat('${_user.followingCount}', 'Following'),
                        _Stat('${_user.postCount}', 'Posts'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Name, handle, bio ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_user.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(_user.handle,
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: muted)),
                  const SizedBox(height: 4),
                  Text(_user.bio, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            // ── 3-column post grid ─────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(1),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
              ),
              itemCount: _posts.length,
              itemBuilder: (_, i) => MokrImage(
                seed: _posts[i].seed,
                category: _posts[i].category,
                height: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
