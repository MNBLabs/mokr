import 'package:flutter/foundation.dart';

import '../../images/mokr_image_provider.dart';
import 'mock_user.dart';

/// An immutable mock post generated from a seed.
///
/// All fields are deterministic for a given seed — same seed always produces
/// the same post across hot reloads, restarts, and app reinstalls.
///
/// Obtain via [Mokr.post] or [Mokr.random.post].
@immutable
class MockPost {
  const MockPost({
    required this.seed,
    required this.id,
    required this.author,
    required this.caption,
    required this.hasImage,
    required this.category,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    required this.createdAt,
    required this.tags,
  });

  /// The seed used to generate this post.
  final String seed;

  /// Short stable ID derived from [seed]. e.g. `'pst_b2e9'`
  final String id;

  /// Post author. Generated from `'${seed}_author'`.
  final MockUser author;

  /// Post caption (1–4 phrases joined).
  final String caption;

  /// Whether this post has an associated image. ~80% probability.
  final bool hasImage;

  /// Image category. Always set — use [hasImage] to determine visibility.
  final MokrCategory category;

  /// Like count. Triangle distribution, mean 5 000.
  final int likeCount;

  /// Comment count. Uniform in [0, 500).
  final int commentCount;

  /// Share count. Uniform in [0, 200).
  final int shareCount;

  /// Whether the current user has liked this post. ~30% probability.
  final bool isLiked;

  /// Post creation date. Deterministic — relative to a fixed reference date.
  final DateTime createdAt;

  /// Hashtags (0–5). Without the `#` prefix.
  final List<String> tags;

  // ─── Image stubs — wired in Phase 3 ──────────────────────────────────────

  /// Image URL. Returns empty string until Phase 3 wires the image namespace.
  /// Only meaningful when [hasImage] is true.
  String get imageUrl => '';

  // imageProvider and imageMeta are added in Phase 3.

  // ─── Computed getters ─────────────────────────────────────────────────────

  /// Human-readable like count. e.g. `'1.2K'`
  String get formattedLikes => _formatCount(likeCount);

  /// Relative time string for display. Uses [DateTime.now] — display only,
  /// [createdAt] itself is fully deterministic.
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockPost &&
          runtimeType == other.runtimeType &&
          seed == other.seed;

  @override
  int get hashCode => seed.hashCode;

  @override
  String toString() => 'MockPost(id: $id, seed: $seed)';
}
