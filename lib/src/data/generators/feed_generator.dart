import '../models/mock_post.dart';
import 'post_generator.dart';

/// Generates deterministic pages of [MockPost] items.
///
/// Each page position gets a stable seed derived from the feed seed, page number,
/// and item index. Same inputs always produce the same page.
final class FeedGenerator {
  FeedGenerator._();

  /// Returns [pageSize] posts for page [page] of feed [seed].
  ///
  /// ```dart
  /// // Page 0
  /// final posts = FeedGenerator.page('home_feed', 0, 20);
  ///
  /// // Next page — different posts, same stability guarantee
  /// final more = FeedGenerator.page('home_feed', 1, 20);
  /// ```
  ///
  /// Each post seed is `'${seed}_p${page}_i${itemIndex}'`, giving stable,
  /// non-overlapping seeds across pages and feeds.
  static List<MockPost> page(String seed, int page, int pageSize) {
    assert(seed.isNotEmpty, 'Seed cannot be empty.');
    assert(page >= 0, 'page must be non-negative, got $page');
    assert(pageSize >= 0, 'pageSize must be non-negative, got $pageSize');

    if (pageSize == 0) return const [];

    return List.generate(pageSize, (i) {
      final postSeed = '${seed}_p${page}_i$i';
      return PostGenerator.generate(postSeed);
    });
  }
}
