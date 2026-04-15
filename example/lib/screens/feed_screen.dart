import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

/// Demonstrates [MokrFeedBuilder] — data API driving Flutter primitives.
///
/// The post list comes from [Mokr.feed] via [MokrFeedBuilder].
/// Images come from [MockPost.imageMeta] and [MockUser.avatarProvider].
/// No custom card widget needed — plain [ListTile] is enough.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: MokrFeedBuilder(
        feedSeed: 'demo_feed',
        pageSize: 20,
        builder: (context, posts) => ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, i) {
            final post = posts[i];
            return ListTile(
              leading: ClipOval(
                child: Image(
                  image: post.author.avatarProvider,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  frameBuilder: (_, child, frame, __) => frame == null
                      ? const SizedBox.square(
                          dimension: 40,
                          child: ColoredBox(color: Color(0xFFE0E0E0)),
                        )
                      : child,
                ),
              ),
              title: Text(post.author.name),
              subtitle: Text(
                post.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: post.hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image(
                        image: post.imageMeta.provider,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        frameBuilder: (_, child, frame, __) => frame == null
                            ? const SizedBox.square(
                                dimension: 56,
                                child: ColoredBox(color: Color(0xFFEEEEEE)),
                              )
                            : child,
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
