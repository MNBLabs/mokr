import 'package:flutter/widgets.dart';

import '../core/mokr_base.dart';
import '../data/models/mock_post.dart';

/// Gives a [MockPost] to your own widget via a builder callback.
///
/// The primary way to use Mokr with your custom post cards — no Mokr widget
/// adoption required:
///
/// ```dart
/// MokrPostBuilder(
///   seed: 'post_1',
///   builder: (context, post) => YourPostCard(
///     avatar: post.author.avatarProvider,
///     name: post.author.name,
///     caption: post.caption,
///     image: post.imageMeta,        // provider + aspectRatio in one object
///     likes: post.formattedLikes,
///   ),
/// )
/// ```
///
/// **Seed mode** — deterministic [MockPost]:
/// ```dart
/// MokrPostBuilder(seed: 'post_1', builder: ...)
/// ```
///
/// **Slot mode** — stable random [MockPost]:
/// ```dart
/// MokrPostBuilder(slot: 'feed_hero', builder: ...)
/// ```
///
/// **Fresh mode** — new random [MockPost] each build:
/// ```dart
/// MokrPostBuilder(builder: ...)
/// ```
class MokrPostBuilder extends StatelessWidget {
  const MokrPostBuilder({
    super.key,
    this.seed,
    this.slot,
    required this.builder,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  /// Deterministic seed — same post on every call.
  final String? seed;

  /// Slot key — stable random post, re-generates only after [MokrSlots.clear].
  final String? slot;

  /// Receives the resolved [MockPost] and returns your widget.
  final Widget Function(BuildContext context, MockPost post) builder;

  @override
  Widget build(BuildContext context) {
    final post = seed != null ? Mokr.post(seed!) : Mokr.random.post(slot: slot);
    return builder(context, post);
  }
}
