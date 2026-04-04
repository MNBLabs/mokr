import 'dart:math' show log;

import 'seeded_rng.dart';

/// Fixed reference date — the deterministic "present" for all timestamp generation.
///
/// **Never change without a major version bump.**
/// Changing this shifts every generated timestamp for every seed.
final _kReferenceDate = DateTime.utc(2026, 1, 1);

/// Tier-based power-law integer distribution.
///
/// Produces the characteristic long-tail shape of social-network follower counts:
/// most values are low, very few are extremely high.
///
/// **Consumes exactly 2 RNG draws.**
///
/// Tier probabilities (approximate):
/// - 60%: 0–999
/// - 25%: 1,000–9,999
/// - 10%: 10,000–99,999
/// - 4%: 100,000–999,999
/// - 1%: 1,000,000–[max]
int powerLawInt(SeededRng rng, {int max = 50000000, double exponent = 3.0}) {
  final tier = rng.nextDouble(); // draw 1 of 2
  final val = rng.nextDouble(); // draw 2 of 2
  if (tier < 0.60) return (val * 1000).toInt().clamp(0, max);
  if (tier < 0.85) return (1000 + val * 9000).toInt().clamp(0, max);
  if (tier < 0.95) return (10000 + val * 90000).toInt().clamp(0, max);
  if (tier < 0.99) return (100000 + val * 900000).toInt().clamp(0, max);
  return (1000000 + val * (max - 1000000).toDouble()).toInt().clamp(0, max);
}

/// Exponential recency distribution for timestamps.
///
/// Recent dates are more likely. The returned date is relative to
/// [_kReferenceDate] (not [DateTime.now]) — fully deterministic.
///
/// **Consumes exactly 1 RNG draw.**
///
/// - [meanDays]: expected days ago (exponential distribution mean)
/// - [maxDays]: hard cap on how far back to go
DateTime recencyDate(
  SeededRng rng, {
  required double meanDays,
  required int maxDays,
}) {
  final u = rng.nextDouble(); // 1 draw
  final daysAgo =
      (-log(1 - u.clamp(0.0, 0.9999)) * meanDays).round().clamp(0, maxDays);
  return _kReferenceDate.subtract(Duration(days: daysAgo));
}

/// Triangle distribution approximation for counts.
///
/// Produces a unimodal distribution centred around [mean] using the
/// average of two uniform draws (CLT approximation — tent/triangle shape).
///
/// **Consumes exactly 2 RNG draws.**
int normalInt(SeededRng rng, {required int mean, required int stddev}) {
  final u = (rng.nextDouble() + rng.nextDouble()) / 2.0; // 2 draws
  return (mean + (u - 0.5) * 2.0 * stddev).round().clamp(0, mean + stddev * 3);
}
