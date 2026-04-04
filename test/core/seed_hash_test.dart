import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/core/seed_hash.dart';

void main() {
  group('SeedHash', () {
    test('same input always returns same output', () {
      expect(SeedHash.hash('user_42'), equals(SeedHash.hash('user_42')));
      expect(SeedHash.hash(''), equals(SeedHash.hash('')));
      expect(SeedHash.hash('mokr_a7Be'), equals(SeedHash.hash('mokr_a7Be')));
    });

    test('different inputs return different outputs', () {
      expect(SeedHash.hash('user_0'), isNot(equals(SeedHash.hash('user_1'))));
      expect(SeedHash.hash('abc'), isNot(equals(SeedHash.hash('abd'))));
      expect(SeedHash.hash('a'), isNot(equals(SeedHash.hash('b'))));
    });

    test('always returns non-negative value', () {
      const seeds = ['', 'a', 'user_0', 'mokr_ZZZZ', 'feed_hero_p99_i999'];
      for (final s in seeds) {
        expect(SeedHash.hash(s), isNonNegative, reason: 'failed for "$s"');
      }
    });

    test('handles long strings without overflow', () {
      final h = SeedHash.hash('a' * 10000);
      expect(h, isNonNegative);
      expect(h, lessThanOrEqualTo(0xFFFFFFFF));
    });

    test('low collision rate across 10000 sequential keys', () {
      final hashes = <int>{};
      var collisions = 0;
      for (var i = 0; i < 10000; i++) {
        final h = SeedHash.hash('user_$i');
        if (!hashes.add(h)) collisions++;
      }
      // FNV-1a 32-bit: expect < 0.1% collision rate for 10k sequential keys
      expect(collisions, lessThan(10));
    });

    test('result fits in 32 bits', () {
      for (var i = 0; i < 100; i++) {
        final h = SeedHash.hash('seed_$i');
        expect(h, lessThanOrEqualTo(0xFFFFFFFF));
      }
    });
  });
}
