import 'package:flutter/widgets.dart';

import '../core/mokr_base.dart';
import '../data/models/mock_post.dart';

/// Gives a page of [MockPost] items to your own widget via a builder callback.
///
/// Single-page, no state management. The post list is deterministic for a
/// given [feedSeed] + [page] — same result on every build.
///
/// ```dart
/// MokrFeedBuilder(
///   feedSeed: 'home_feed',
///   pageSize: 20,
///   builder: (context, posts) => ListView.builder(
///     itemCount: posts.length,
///     itemBuilder: (_, i) => YourPostCard.fromPost(posts[i]),
///   ),
/// )
/// ```
///
/// For infinite scroll, call [Mokr.feed] directly and manage page state in
/// your own widget — [MokrFeedBuilder] intentionally has no pagination state.
class MokrFeedBuilder extends StatelessWidget {
  const MokrFeedBuilder({
    super.key,
    required this.feedSeed,
    this.page = 0,
    this.pageSize = 20,
    required this.builder,
  });

  /// Seed for the feed. Same seed + page → same list of posts, always.
  final String feedSeed;

  /// Page index (zero-based). Combine with [Mokr.feed] for manual pagination.
  final int page;

  /// Number of posts per page.
  final int pageSize;

  /// Receives the resolved list of [MockPost] items and returns your widget.
  final Widget Function(BuildContext context, List<MockPost> posts) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Mokr.feed(feedSeed, page: page, pageSize: pageSize),
    );
  }
}
