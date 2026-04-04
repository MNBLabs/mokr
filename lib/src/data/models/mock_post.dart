import 'package:flutter/foundation.dart';

import '../../mokr_enums.dart';
import 'mock_user.dart';

/// An immutable mock post generated from a seed.
///
/// All fields are deterministic for a given seed — same seed always
/// produces the same post across hot reloads, restarts, and reinstalls.
///
/// Obtain via [Mokr.post], [Mokr.randomPost], [Mokr.feedPage], or [asMockPost].
@immutable
class MockPost {
  const MockPost({
    required this.seed,
    required this.id,
    required this.author,
    required this.caption,
    required this.imageUrl,
    required this.imageCategory,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.createdAt,
    required this.tags,
    required this.isLiked,
  });

  /// The seed used to generate this post.
  final String seed;

  /// Short stable ID derived from [seed]. e.g. `'pst_b2e9'`
  final String id;

  /// The post author. Generated deterministically from `'${seed}_author'`.
  final MockUser author;

  /// Post caption (1–4 phrases joined).
  final String caption;

  /// Image URL. Null for text-only posts (~20% probability).
  final String? imageUrl;

  /// Image category. Set even for text-only posts — used for URL construction.
  final MokrCategory? imageCategory;

  /// Like count. Triangle distribution (0–10k, peak ~5k).
  final int likeCount;

  /// Comment count.
  final int commentCount;

  /// Share count.
  final int shareCount;

  /// Post creation date. Deterministic — relative to a fixed reference date.
  final DateTime createdAt;

  /// List of hashtags (0–5). Without the `#` prefix.
  final List<String> tags;

  /// Whether the current user has liked this post. ~30% probability.
  final bool isLiked;

  // ─── Computed ─────────────────────────────────────────────────────────────

  /// True when [imageUrl] is non-null.
  bool get hasImage => imageUrl != null;

  /// Human-readable like count. e.g. `'1.2k'`
  String get formattedLikes => _formatCount(likeCount);

  /// Relative time string based on [createdAt] vs [DateTime.now()].
  ///
  /// Uses [DateTime.now()] for display only — [createdAt] itself is deterministic.
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
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
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
