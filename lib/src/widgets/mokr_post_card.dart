import 'package:flutter/material.dart';

import '../core/mokr_base.dart';
import '../data/models/mock_post.dart';
import 'mokr_avatar.dart';
import 'mokr_image.dart';

/// A full post card — author row, optional image, caption, action row.
///
/// ```dart
/// MokrPostCard(seed: 'post_0')
/// MokrPostCard(slot: 'feed_hero')
/// MokrPostCard(seed: 'feed_$i')  // inside ListView.builder
/// ```
class MokrPostCard extends StatelessWidget {
  const MokrPostCard({
    super.key,
    this.seed,
    this.slot,
    this.onTap,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  final String? seed;
  final String? slot;
  final VoidCallback? onTap;

  MockPost _resolvePost() {
    if (seed != null) return Mokr.post(seed!);
    return Mokr.random.post(slot: slot); // slot == null → fresh random
  }

  @override
  Widget build(BuildContext context) {
    final post = _resolvePost();
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Author row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  MokrAvatar(seed: post.author.seed, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.author.name,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (post.author.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: Color(0xFF1DA1F2),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          post.author.handle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    post.relativeTime,
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            // Post image
            if (post.hasImage)
              MokrImage(
                seed: post.seed,
                category: post.category,
                width: double.infinity,
                height: 200,
              ),
            // Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                post.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            // Action row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
              child: Row(
                children: [
                  Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: post.isLiked ? Colors.red : mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.formattedLikes,
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline, size: 16, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.share_outlined, size: 16, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(
                    '${post.shareCount}',
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
