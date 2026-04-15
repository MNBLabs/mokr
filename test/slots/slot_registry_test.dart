import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/slots/slot_registry.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // Reset slot state before each test so tests are isolated.
  setUp(() async {
    await SlotRegistry.clearAll();
  });

  group('SlotRegistry — seed format', () {
    test('generateSeed returns mokr_ prefix + 4 chars', () {
      final seed = SlotRegistry.generateSeed();
      expect(seed, startsWith('mokr_'));
      expect(seed.length, equals(9)); // 'mokr_' (5) + 4 chars
    });

    test('generateSeed chars are alphanumeric', () {
      for (var i = 0; i < 20; i++) {
        final seed = SlotRegistry.generateSeed();
        final suffix = seed.substring(5);
        expect(RegExp(r'^[A-Za-z0-9]{4}$').hasMatch(suffix), isTrue,
            reason: 'suffix "$suffix" has non-alphanumeric chars');
      }
    });

    test('generateSeed produces different values (probabilistic)', () {
      final seeds = List.generate(20, (_) => SlotRegistry.generateSeed()).toSet();
      // Collisions possible but extremely unlikely with 14M+ space
      expect(seeds.length, greaterThan(15));
    });
  });

  group('SlotRegistry — resolve', () {
    test('first resolve generates and stores a seed', () {
      expect(SlotRegistry.contains('new_slot'), isFalse);
      final seed = SlotRegistry.resolve('new_slot');
      expect(seed, startsWith('mokr_'));
      expect(SlotRegistry.contains('new_slot'), isTrue);
    });

    test('second resolve returns same seed (slot hit)', () {
      final seed1 = SlotRegistry.resolve('stable_slot');
      final seed2 = SlotRegistry.resolve('stable_slot');
      expect(seed1, equals(seed2));
    });

    test('different slot names get different seeds (probabilistic)', () {
      final a = SlotRegistry.resolve('slot_a');
      final b = SlotRegistry.resolve('slot_b');
      // Collision is theoretically possible but negligible
      expect(a, isNot(equals(b)));
    });
  });

  group('SlotRegistry — contains', () {
    test('returns false for unknown slot', () {
      expect(SlotRegistry.contains('ghost'), isFalse);
    });

    test('returns true after resolve', () {
      SlotRegistry.resolve('existing');
      expect(SlotRegistry.contains('existing'), isTrue);
    });
  });

  group('SlotRegistry — clear', () {
    test('clear removes specific slot', () async {
      SlotRegistry.resolve('to_clear');
      SlotRegistry.resolve('to_keep');
      await SlotRegistry.clear('to_clear');
      expect(SlotRegistry.contains('to_clear'), isFalse);
      expect(SlotRegistry.contains('to_keep'), isTrue);
    });

    test('clear on unknown slot is a no-op', () async {
      await expectLater(SlotRegistry.clear('never_existed'), completes);
    });

    test('after clear, next resolve generates a new seed', () async {
      final first = SlotRegistry.resolve('resettable');
      await SlotRegistry.clear('resettable');
      final second = SlotRegistry.resolve('resettable');
      // Different seeds (probabilistically — collision is negligible)
      expect(first, isNot(equals(second)));
    });
  });

  group('SlotRegistry — clearAll', () {
    test('clearAll empties the map', () async {
      SlotRegistry.resolve('x');
      SlotRegistry.resolve('y');
      await SlotRegistry.clearAll();
      expect(SlotRegistry.list(), isEmpty);
    });
  });

  group('SlotRegistry — list', () {
    test('list returns all active slots', () {
      SlotRegistry.resolve('alpha');
      SlotRegistry.resolve('beta');
      final map = SlotRegistry.list();
      expect(map.containsKey('alpha'), isTrue);
      expect(map.containsKey('beta'), isTrue);
      expect(map.length, equals(2));
    });

    test('list is unmodifiable', () {
      SlotRegistry.resolve('slot');
      final map = SlotRegistry.list();
      expect(() => (map as dynamic)['new_key'] = 'val', throwsUnsupportedError);
    });
  });
}
