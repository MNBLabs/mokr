import 'package:flutter/widgets.dart';

import '../core/mokr_base.dart';
import '../data/models/mock_user.dart';

/// Gives a [MockUser] to your own widget via a builder callback.
///
/// The primary way to use Mokr with your custom widgets — no Mokr widget
/// adoption required:
///
/// ```dart
/// MokrUserBuilder(
///   seed: 'user_42',
///   builder: (context, user) => YourProfileCard(
///     name: user.name,
///     handle: user.handle,
///     avatar: user.avatarProvider,
///     followers: user.formattedFollowers,
///   ),
/// )
/// ```
///
/// **Seed mode** — deterministic [MockUser]:
/// ```dart
/// MokrUserBuilder(seed: 'user_42', builder: ...)
/// ```
///
/// **Slot mode** — stable random [MockUser]:
/// ```dart
/// MokrUserBuilder(slot: 'sidebar_profile', builder: ...)
/// ```
///
/// **Fresh mode** — new random [MockUser] each build:
/// ```dart
/// MokrUserBuilder(builder: ...)
/// ```
class MokrUserBuilder extends StatelessWidget {
  const MokrUserBuilder({
    super.key,
    this.seed,
    this.slot,
    required this.builder,
  }) : assert(
          seed == null || slot == null,
          'Provide either seed or slot, not both.',
        );

  /// Deterministic seed — same user on every call.
  final String? seed;

  /// Slot key — stable random user, re-generates only after [MokrSlots.clear].
  final String? slot;

  /// Receives the resolved [MockUser] and returns your widget.
  final Widget Function(BuildContext context, MockUser user) builder;

  @override
  Widget build(BuildContext context) {
    final user = seed != null ? Mokr.user(seed!) : Mokr.random.user(slot: slot);
    return builder(context, user);
  }
}
