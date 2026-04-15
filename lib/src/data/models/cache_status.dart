import 'package:flutter/foundation.dart';

/// Snapshot of the Unsplash image cache state for one [MokrCategory].
///
/// Obtained via [Mokr.cache.status()].
@immutable
class CacheStatus {
  const CacheStatus({
    required this.urlCount,
    this.lastWarmed,
    required this.isStale,
  });

  /// Number of cached image URLs available for this category.
  final int urlCount;

  /// When this category's cache was last populated. `null` if never warmed.
  final DateTime? lastWarmed;

  /// `true` if the cache is older than 24 hours, or has never been warmed.
  final bool isStale;

  @override
  String toString() =>
      'CacheStatus(urlCount: $urlCount, lastWarmed: $lastWarmed, isStale: $isStale)';
}
