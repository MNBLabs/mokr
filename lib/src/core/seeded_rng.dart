import 'dart:math' as math;

import 'seed_hash.dart';

/// A seeded pseudo-random number generator.
///
/// Wraps [dart:math Random] with a [SeedHash]-derived seed so that the same
/// string input always produces the same sequence of values.
///
/// **Consumption order matters.** Callers must consume values in a fixed,
/// documented order. Inserting or removing a draw changes all subsequent
/// values for that seed — a breaking change in user-visible output.
///
/// ```dart
/// final rng = SeededRng('user_42');
/// final nameIdx = rng.nextInt(300);  // always the same index
/// ```
final class SeededRng {
  SeededRng(String seed) : _rng = math.Random(SeedHash.hash(seed));

  final math.Random _rng;

  /// Returns a non-negative integer in [0, max).
  int nextInt(int max) {
    assert(max > 0, 'max must be positive, got $max');
    return _rng.nextInt(max);
  }

  /// Returns an integer in [min, max).
  int nextIntInRange(int min, int max) {
    assert(max > min, 'max must be greater than min');
    return min + _rng.nextInt(max - min);
  }

  /// Returns a double in [0.0, 1.0).
  double nextDouble() => _rng.nextDouble();

  /// Returns true with the given [probability] (0.0–1.0).
  bool nextBool({double probability = 0.5}) {
    assert(probability >= 0.0 && probability <= 1.0);
    return nextDouble() < probability;
  }

  /// Picks one item from [list] deterministically.
  T pick<T>(List<T> list) {
    assert(list.isNotEmpty, 'Cannot pick from an empty list.');
    return list[nextInt(list.length)];
  }

  /// Picks [count] unique items from [list] using a partial Fisher-Yates shuffle.
  ///
  /// Consumes exactly [count] RNG draws. The result order is deterministic.
  List<T> pickMany<T>(List<T> list, int count) {
    assert(count >= 0, 'count must be non-negative.');
    assert(count <= list.length,
        'count ($count) exceeds list length (${list.length}).');
    if (count == 0) return [];
    final copy = List<T>.from(list);
    for (var i = 0; i < count; i++) {
      final j = i + nextInt(copy.length - i);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy.sublist(0, count);
  }
}
