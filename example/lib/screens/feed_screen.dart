import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

import '../widgets/post_card.dart';

/// Demonstrates [MokrFeedBuilder] — data API driving a social feed UI.
///
/// Each post renders as a full [PostCard]: avatar, large image, caption,
/// and like/comment/share counts.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: MokrFeedBuilder(
        feedSeed: 'demo_feed',
        pageSize: 20,
        builder: (context, posts) => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostCard(post: posts[i]),
          ),
        ),
      ),
    );
  }
}
