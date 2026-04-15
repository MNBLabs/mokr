import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/namespaces/random_namespace.dart';
import 'package:mokr/src/slots/slot_registry.dart';

void main() {
  const random = MokrRandom();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    await SlotRegistry.clearAll();
  });

  group('MokrRandom — fresh random (no slot)', () {
    test('user() returns a MockUser with non-empty name', () {
      final user = random.user();
      expect(user.name, isNotEmpty);
    });

    test('post() returns a MockPost with non-empty caption', () {
      final post = random.post();
      expect(post.caption, isNotEmpty);
    });

    test('feed() returns correct page size', () {
      final posts = random.feed(pageSize: 10);
      expect(posts.length, equals(10));
    });

    test('fresh calls probabilistically differ', () {
      // Two fresh users will almost certainly differ
      final a = random.user();
      final b = random.user();
      // Seed space is 62^4 ≈ 14M — collision is negligible
      expect(a.seed, isNot(equals(b.seed)));
    });
  });

  group('MokrRandom — slot stability', () {
    test('same slot returns same user on repeated calls', () {
      final a = random.user(slot: 'hero');
      final b = random.user(slot: 'hero');
      expect(a.seed, equals(b.seed));
      expect(a.name, equals(b.name));
    });

    test('same slot returns same post on repeated calls', () {
      final a = random.post(slot: 'featured');
      final b = random.post(slot: 'featured');
      expect(a.seed, equals(b.seed));
      expect(a.caption, equals(b.caption));
    });

    test('same slot same page returns same feed', () {
      final a = random.feed(slot: 'home', page: 0, pageSize: 5);
      final b = random.feed(slot: 'home', page: 0, pageSize: 5);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].seed, equals(b[i].seed));
      }
    });

    test('different slots return different users', () {
      final a = random.user(slot: 'slot_a');
      final b = random.user(slot: 'slot_b');
      expect(a.seed, isNot(equals(b.seed)));
    });

    test('slot seed is stored in registry', () {
      final user = random.user(slot: 'stored_slot');
      expect(SlotRegistry.contains('stored_slot'), isTrue);
      expect(SlotRegistry.list()['stored_slot'], equals(user.seed));
    });

    test('after clearAll, slot generates a new user', () async {
      final before = random.user(slot: 'clearable');
      await SlotRegistry.clearAll();
      final after = random.user(slot: 'clearable');
      // Different seeds after clear (probabilistically)
      expect(before.seed, isNot(equals(after.seed)));
    });
  });

  group('MokrRandom — assertions', () {
    test('empty slot name throws assertion', () {
      expect(() => random.user(slot: ''), throwsAssertionError);
    });

    test('null slot is valid (fresh random)', () {
      expect(() => random.user(slot: null), returnsNormally);
    });
  });
}
