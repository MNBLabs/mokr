// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

import '../widgets/post_card.dart';

/// Use case: "I'm building a social feed. Give me paginated posts."
///
/// Demonstrates:
/// - [Mokr.feedPage] for stable paginated data
/// - Pinned slot via [Mokr.randomPost] with [pin: true] for the featured card
/// - Pull-to-refresh with [Mokr.clearAll] — randoms regenerate, pinned card stays
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const _pageSize = 10;

  late List<MockPost> _posts;
  int _currentPage = 0;
  int _session = 0; // increments on each refresh → new feed seed → new posts
  bool _isLoadingMore = false;
  late MockPost _featuredPost;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitial() {
    // Pinned slot: this post survives pull-to-refresh.
    _featuredPost = Mokr.randomPost(slot: 'featured_card', pin: true);
    _currentPage = 0;
    // Each session gets a different seed → different posts on refresh.
    _posts = Mokr.feedPage('home_feed_$_session', page: 0, pageSize: _pageSize);
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final more = Mokr.feedPage('home_feed_$_session',
        page: nextPage, pageSize: _pageSize);
    setState(() {
      _posts = [..._posts, ...more];
      _currentPage = nextPage;
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    // clearAll wipes unpinned slots — the featured card (pinned) survives.
    await Mokr.clearAll();
    _session++; // new seed → feedPage returns a fresh set of posts
    setState(_loadInitial);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          title: const Text('Feed'),
          floating: true,
          snap: true,
        ),

        // Pull-to-refresh
        SliverToBoxAdapter(
          child: RefreshIndicator.adaptive(
            onRefresh: _onRefresh,
            child: const SizedBox.shrink(),
          ),
        ),

        // Featured / pinned card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.push_pin, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned — survives pull-to-refresh',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                PostCard(post: _featuredPost),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Feed — ${_posts.length} posts loaded',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),

        // Feed posts
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: _posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => PostCard(post: _posts[i]),
          ),
        ),

        // Loading indicator / end cap
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator.adaptive()
                  : TextButton(
                      onPressed: _loadMore,
                      child: const Text('Load more'),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
