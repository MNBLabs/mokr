import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

/// Example of using Mokr's **data API** directly in your own widget.
///
/// Receives a [MockPost] and renders it with standard Flutter widgets —
/// no MokrPostCard involved. The only mokr widget used is [MokrAvatar]
/// for the author image, demonstrating both APIs in one card.
///
/// Compare with [MokrPostCard], which handles seed resolution internally.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final MockPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Author row (widget API: MokrAvatar) ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                // Widget API — let MokrAvatar handle image loading & fallback.
                MokrAvatar(seed: post.author.seed, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.author.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        post.author.username,
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  post.relativeTime,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),

          // ── Post image (data API: Image.network from post.imageUrl) ────
          if (post.hasImage)
            Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: const Color(0xFFE0E0E0),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, _, __) => Container(
                height: 200,
                color: const Color(0xFFEEEEEE),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFFBDBDBD),
                    size: 32,
                  ),
                ),
              ),
            ),

          // ── Caption ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              post.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),

          // ── Hashtags ─────────────────────────────────────────────────
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                post.tags.map((t) => '#$t').join(' '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Action row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
            child: Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: post.isLiked ? Colors.red : muted,
                ),
                const SizedBox(width: 4),
                Text(
                  post.formattedLikes,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: muted),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, size: 16, color: muted),
                const SizedBox(width: 4),
                Text(
                  '${post.shareCount}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
