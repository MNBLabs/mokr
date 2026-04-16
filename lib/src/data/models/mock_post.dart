import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../images/image_namespace.dart';
import '../../images/mokr_image_provider.dart';
import 'mock_user.dart';
import 'mokr_image_meta.dart';

/// An immutable mock post generated from a seed.
///
/// All fields are deterministic for a given seed — same seed always produces
/// the same post across hot reloads, restarts, and app reinstalls.
///
/// Obtain via [Mokr.post] or [MokrRandom.post].
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

  // ─── Image getters — only meaningful when [hasImage] is true ────────────

  /// Image URL. Delegates to the active [MokrImageProvider].
  String get imageUrl => activeMokrProvider.imageUrl(seed, category);

  /// [ImageProvider] for use with `Image(image: post.imageProvider)`.
  ImageProvider get imageProvider => NetworkImage(imageUrl);

  /// Full [MokrImageMeta] — provider, URL, and aspect ratio together.
  MokrImageMeta get imageMeta {
    final u = imageUrl;
    final ar = activeMokrProvider.knownAspectRatio(seed, category) ?? (16 / 9);
    return MokrImageMeta(
      provider: NetworkImage(u),
      url: u,
      aspectRatio: ar,
      ratio: MokrImageMeta.ratioFrom(ar),
      seed: seed,
      category: category,
    );
  }

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
