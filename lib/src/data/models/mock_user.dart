import 'package:flutter/foundation.dart';

/// An immutable mock user generated from a seed.
///
/// All fields are deterministic for a given seed — same seed always
/// produces the same user across hot reloads, restarts, and reinstalls.
///
/// Obtain via [Mokr.user], [Mokr.randomUser], or `'seed'.asMockUser`
/// (see [MokrStringExt]).
@immutable
class MockUser {
  const MockUser({
    required this.seed,
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.isVerified,
    required this.joinedAt,
  });

  /// The seed used to generate this user. Store this to reproduce the result.
  final String seed;

  /// Short stable ID derived from [seed]. e.g. `'usr_a7f3'`
  final String id;

  /// Full display name. e.g. `'Sofia Nakamura'`
  final String name;

  /// @-prefixed username. e.g. `'@sofia.nakamura'`
  final String username;

  /// 1–3 sentence bio.
  final String bio;

  /// Avatar image URL. Deterministic for this seed and the active provider.
  final String avatarUrl;

  /// Follower count. Power-law distribution — most users have few.
  final int followerCount;

  /// Following count.
  final int followingCount;

  /// Post count.
  final int postCount;

  /// Whether this user has a verified badge. Approximately 4% probability.
  final bool isVerified;

  /// Account creation date. Deterministic — relative to a fixed reference date.
  final DateTime joinedAt;

  // ─── Computed ─────────────────────────────────────────────────────────────

  /// Initials from [name]. e.g. `'SN'`
  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Human-readable follower count. e.g. `'1.2k'`, `'45.3k'`, `'1.2M'`
  String get formattedFollowers => _formatCount(followerCount);

  /// Human-readable following count.
  String get formattedFollowing => _formatCount(followingCount);

  /// True when [followerCount] exceeds 10,000.
  bool get hasLargeFollowing => followerCount > 10000;

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
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
