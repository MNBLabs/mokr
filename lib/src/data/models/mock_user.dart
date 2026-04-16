import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../images/image_namespace.dart';
import '../../images/mokr_image_provider.dart';
import 'mokr_image_meta.dart';

/// An immutable mock user generated from a seed.
///
/// All fields are deterministic for a given seed — same seed always produces
/// the same user across hot reloads, restarts, and app reinstalls.
///
/// Obtain via [Mokr.user] or [MokrRandom.user].
@immutable
class MockUser {
  const MockUser({
    required this.seed,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.isVerified,
    required this.joinedAt,
  });

  /// The seed used to generate this user.
  final String seed;

  /// Short stable ID derived from [seed]. e.g. `'usr_a7f3'`
  final String id;

  /// Given name. e.g. `'Sofia'`
  final String firstName;

  /// Family name. e.g. `'Nakamura'`
  final String lastName;

  /// Lowercase username without `@` prefix. e.g. `'sofianakamura'`
  /// Use [handle] to get the `@`-prefixed version.
  final String username;

  /// 1–3 sentence bio.
  final String bio;

  /// Follower count. Power-law distribution — most users have few.
  final int followerCount;

  /// Following count. Uniform in [0, 5000).
  final int followingCount;

  /// Post count. Uniform in [0, 1000).
  final int postCount;

  /// Whether this user has a verified badge. ~4% probability.
  final bool isVerified;

  /// Account creation date. Deterministic — relative to a fixed reference date.
  final DateTime joinedAt;

  // ─── Computed getters ─────────────────────────────────────────────────────

  /// Full display name. e.g. `'Sofia Nakamura'`
  String get name => '$firstName $lastName';

  /// `@`-prefixed handle. e.g. `'@sofianakamura'`
  String get handle => '@$username';

  /// Initials from first and last name. e.g. `'SN'`
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  /// Human-readable follower count. e.g. `'4.8K'`, `'1.2M'`
  String get formattedFollowers => _formatCount(followerCount);

  /// `'Joined Month Year'` string. e.g. `'Joined March 2024'`
  String get relativeJoinDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Joined ${months[joinedAt.month - 1]} ${joinedAt.year}';
  }

  // ─── Image getters ────────────────────────────────────────────────────────

  /// Square avatar URL. Delegates to the active [MokrImageProvider].
  String get avatarUrl => activeMokrProvider.avatarUrl(seed, MokrCategory.face);

  /// [ImageProvider] for use with `Image(image: user.avatarProvider)`.
  ImageProvider get avatarProvider => NetworkImage(avatarUrl);

  /// Full [MokrImageMeta] for the avatar — provider, URL, and aspect ratio.
  /// Avatar aspect ratio is always `1.0` (square).
  MokrImageMeta get avatarMeta => MokrImageMeta(
        provider: avatarProvider,
        url: avatarUrl,
        aspectRatio: 1.0,
        ratio: MokrRatio.square,
        seed: seed,
        category: MokrCategory.face,
      );

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockUser &&
          runtimeType == other.runtimeType &&
          seed == other.seed;

  @override
  int get hashCode => seed.hashCode;

  @override
  String toString() => 'MockUser(id: $id, name: $name, seed: $seed)';
}
