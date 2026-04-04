import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/core/distribution.dart';
import 'package:mokr/src/core/seeded_rng.dart';

void main() {
  group('powerLawInt', () {
    test('always returns value in [0, max]', () {
      for (var i = 0; i < 200; i++) {
        final rng = SeededRng('pl_$i');
        final v = powerLawInt(rng, max: 50000000);
        expect(v, greaterThanOrEqualTo(0));
        expect(v, lessThanOrEqualTo(50000000));
      }
    });

    test('is deterministic for the same rng state', () {
      final a = SeededRng('pl_det');
      final b = SeededRng('pl_det');
      expect(powerLawInt(a), equals(powerLawInt(b)));
    });

    test('respects custom max', () {
      for (var i = 0; i < 50; i++) {
        final rng = SeededRng('pl_max_$i');
        expect(powerLawInt(rng, max: 1000), lessThanOrEqualTo(1000));
      }
    });

    test('consumes exactly 2 draws', () {
      // Verify by checking that a 3rd draw after two powerLaw calls matches
      // the same position as starting without powerLaw
      final a = SeededRng('pl_draws');
      final b = SeededRng('pl_draws');
      powerLawInt(a); // consumes 2 draws
      b.nextDouble(); // draw 1
      b.nextDouble(); // draw 2
      // both should now be at the same position
      expect(a.nextInt(1000), equals(b.nextInt(1000)));
    });

    test('produces varied output across seeds', () {
      final values = <int>{};
      for (var i = 0; i < 100; i++) {
        final rng = SeededRng('variety_$i');
        values.add(powerLawInt(rng));
      }
      // Should not all be the same value
      expect(values.length, greaterThan(5));
    });
  });

  group('recencyDate', () {
    final referenceDate = DateTime.utc(2026, 1, 1);

    test('always returns date at or before reference date', () {
      for (var i = 0; i < 200; i++) {
        final rng = SeededRng('rd_$i');
        final d = recencyDate(rng, meanDays: 14, maxDays: 365);
        expect(d.isBefore(referenceDate) || d.isAtSameMomentAs(referenceDate),
            isTrue, reason: 'Date $d is after reference $referenceDate');
      }
    });

    test('never exceeds maxDays', () {
      final cutoff = referenceDate.subtract(const Duration(days: 365));
      for (var i = 0; i < 200; i++) {
        final rng = SeededRng('rd_max_$i');
        final d = recencyDate(rng, meanDays: 14, maxDays: 365);
        expect(d.isAfter(cutoff) || d.isAtSameMomentAs(cutoff), isTrue,
            reason: 'Date $d exceeds maxDays cap');
      }
    });

    test('is deterministic for the same rng state', () {
      final a = SeededRng('rd_det');
      final b = SeededRng('rd_det');
      expect(recencyDate(a, meanDays: 14, maxDays: 365),
          equals(recencyDate(b, meanDays: 14, maxDays: 365)));
    });

    test('consumes exactly 1 draw', () {
      final a = SeededRng('rd_draws');
      final b = SeededRng('rd_draws');
      recencyDate(a, meanDays: 14, maxDays: 365); // consumes 1 draw
      b.nextDouble(); // draw 1
      // both should now be at the same position
      expect(a.nextInt(1000), equals(b.nextInt(1000)));
    });
  });

  group('normalInt', () {
    test('returns non-negative value', () {
      for (var i = 0; i < 200; i++) {
        final rng = SeededRng('ni_$i');
        expect(normalInt(rng, mean: 5000, stddev: 3500), isNonNegative);
      }
    });

    test('stays within clamped range', () {
      for (var i = 0; i < 200; i++) {
        final rng = SeededRng('ni_range_$i');
        final v = normalInt(rng, mean: 5000, stddev: 3500);
        expect(v, lessThanOrEqualTo(5000 + 3500 * 3));
      }
    });

    test('is deterministic for the same rng state', () {
      final a = SeededRng('ni_det');
      final b = SeededRng('ni_det');
      expect(normalInt(a, mean: 5000, stddev: 3500),
          equals(normalInt(b, mean: 5000, stddev: 3500)));
    });

    test('consumes exactly 2 draws', () {
      final a = SeededRng('ni_draws');
      final b = SeededRng('ni_draws');
      normalInt(a, mean: 5000, stddev: 3500); // consumes 2 draws
      b.nextDouble(); // draw 1
      b.nextDouble(); // draw 2
      expect(a.nextInt(1000), equals(b.nextInt(1000)));
    });

    test('clusters around mean over many samples', () {
      var total = 0;
      const samples = 1000;
      for (var i = 0; i < samples; i++) {
        final rng = SeededRng('ni_mean_$i');
        total += normalInt(rng, mean: 5000, stddev: 1000);
      }
      final avg = total / samples;
      // Average should be within 15% of mean
      expect(avg, greaterThan(4250));
      expect(avg, lessThan(5750));
    });
  });
}
