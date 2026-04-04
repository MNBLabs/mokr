import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/core/seeded_rng.dart';

void main() {
  group('SeededRng', () {
    test('same seed produces same sequence', () {
      final a = SeededRng('test_seed');
      final b = SeededRng('test_seed');
      for (var i = 0; i < 20; i++) {
        expect(a.nextInt(1000), equals(b.nextInt(1000)));
      }
    });

    test('different seeds produce different sequences', () {
      final a = SeededRng('seed_a');
      final b = SeededRng('seed_b');
      final aVals = List.generate(10, (_) => a.nextInt(100000));
      final bVals = List.generate(10, (_) => b.nextInt(100000));
      expect(aVals, isNot(equals(bVals)));
    });

    test('nextInt returns value in [0, max)', () {
      final rng = SeededRng('range_test');
      for (var i = 0; i < 100; i++) {
        final v = rng.nextInt(10);
        expect(v, greaterThanOrEqualTo(0));
        expect(v, lessThan(10));
      }
    });

    test('nextIntInRange returns value in [min, max)', () {
      final rng = SeededRng('range_test');
      for (var i = 0; i < 100; i++) {
        final v = rng.nextIntInRange(5, 15);
        expect(v, greaterThanOrEqualTo(5));
        expect(v, lessThan(15));
      }
    });

    test('nextDouble returns value in [0.0, 1.0)', () {
      final rng = SeededRng('double_test');
      for (var i = 0; i < 100; i++) {
        final v = rng.nextDouble();
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThan(1.0));
      }
    });

    test('nextBool respects probability', () {
      // With p=1.0 always true, p=0.0 always false
      final rng1 = SeededRng('bool_always_true');
      for (var i = 0; i < 20; i++) {
        expect(rng1.nextBool(probability: 1.0), isTrue);
      }
      final rng2 = SeededRng('bool_always_false');
      for (var i = 0; i < 20; i++) {
        expect(rng2.nextBool(probability: 0.0), isFalse);
      }
    });

    test('pick selects from list deterministically', () {
      final list = ['a', 'b', 'c', 'd', 'e'];
      final a = SeededRng('pick_test');
      final b = SeededRng('pick_test');
      expect(a.pick(list), equals(b.pick(list)));
    });

    test('pick always returns a list element', () {
      final list = [1, 2, 3, 4, 5];
      final rng = SeededRng('pick_elem');
      for (var i = 0; i < 20; i++) {
        expect(list, contains(rng.pick(list)));
      }
    });

    test('pickMany returns correct count', () {
      final list = List.generate(50, (i) => i);
      final rng = SeededRng('pickMany_test');
      final picked = rng.pickMany(list, 5);
      expect(picked.length, equals(5));
    });

    test('pickMany returns unique elements', () {
      final list = List.generate(50, (i) => i);
      final rng = SeededRng('pickMany_unique');
      final picked = rng.pickMany(list, 10);
      expect(picked.toSet().length, equals(10));
    });

    test('pickMany is deterministic', () {
      final list = List.generate(50, (i) => i);
      final a = SeededRng('pickMany_det');
      final b = SeededRng('pickMany_det');
      expect(a.pickMany(list, 5), equals(b.pickMany(list, 5)));
    });

    test('pickMany(list, 0) returns empty', () {
      final rng = SeededRng('pickMany_zero');
      expect(rng.pickMany([1, 2, 3], 0), isEmpty);
    });
  });
}
