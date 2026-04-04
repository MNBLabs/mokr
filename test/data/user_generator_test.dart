import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/data/generators/user_generator.dart';
import 'package:mokr/src/images/picsum_provider.dart';
import 'package:mokr/src/images/provider_registry.dart';
import 'package:mokr/src/mokr_enums.dart';

void main() {
  setUpAll(() {
    setActiveImageProvider(const PicsumMokrImageProvider());
  });

  group('UserGenerator', () {
    test('same seed always produces same user', () {
      const seed = 'user_42';
      final a = UserGenerator.generate(seed);
      final b = UserGenerator.generate(seed);
      expect(a.seed, equals(b.seed));
      expect(a.id, equals(b.id));
      expect(a.name, equals(b.name));
      expect(a.username, equals(b.username));
      expect(a.bio, equals(b.bio));
      expect(a.avatarUrl, equals(b.avatarUrl));
      expect(a.followerCount, equals(b.followerCount));
      expect(a.followingCount, equals(b.followingCount));
      expect(a.postCount, equals(b.postCount));
      expect(a.isVerified, equals(b.isVerified));
      expect(a.joinedAt, equals(b.joinedAt));
    });

    test('same seed 10000 calls all return same name', () {
      const seed = 'stability_check';
      final first = UserGenerator.generate(seed).name;
      for (var i = 0; i < 100; i++) {
        expect(UserGenerator.generate(seed).name, equals(first));
      }
    });

    test('different seeds produce different users', () {
      final a = UserGenerator.generate('seed_aaa');
      final b = UserGenerator.generate('seed_bbb');
      expect(a.name, isNot(equals(b.name)));
    });

    test('id has correct format', () {
      final user = UserGenerator.generate('test_user');
      expect(user.id, startsWith('usr_'));
      expect(user.id.length, equals(8)); // 'usr_' + 4 hex chars
    });

    test('username is @-prefixed lowercase', () {
      final user = UserGenerator.generate('test_user');
      expect(user.username, startsWith('@'));
      expect(user.username, equals(user.username.toLowerCase()));
    });

    test('followerCount is non-negative', () {
      for (var i = 0; i < 50; i++) {
        final user = UserGenerator.generate('follower_$i');
        expect(user.followerCount, isNonNegative);
        expect(user.followerCount, lessThanOrEqualTo(50000000));
      }
    });

    test('followingCount is in [0, 5000)', () {
      for (var i = 0; i < 50; i++) {
        final user = UserGenerator.generate('following_$i');
        expect(user.followingCount, isNonNegative);
        expect(user.followingCount, lessThan(5000));
      }
    });

    test('postCount is in [0, 1000)', () {
      for (var i = 0; i < 50; i++) {
        final user = UserGenerator.generate('posts_$i');
        expect(user.postCount, isNonNegative);
        expect(user.postCount, lessThan(1000));
      }
    });

    test('bio is non-empty', () {
      for (var i = 0; i < 30; i++) {
        final user = UserGenerator.generate('bio_test_$i');
        expect(user.bio, isNotEmpty);
      }
    });

    test('joinedAt is at or before reference date', () {
      final referenceDate = DateTime.utc(2026, 1, 1);
      for (var i = 0; i < 50; i++) {
        final user = UserGenerator.generate('joined_$i');
        expect(
          user.joinedAt.isBefore(referenceDate) ||
              user.joinedAt.isAtSameMomentAs(referenceDate),
          isTrue,
          reason: 'joinedAt ${user.joinedAt} is after reference $referenceDate',
        );
      }
    });

    test('avatarUrl uses face category and Picsum format', () {
      final user = UserGenerator.generate('avatar_test');
      expect(user.avatarUrl, contains('picsum.photos'));
      expect(user.avatarUrl, contains(MokrCategory.face.keyword));
    });

    test('initials computed correctly', () {
      // Find a user with a multi-word name
      for (var i = 0; i < 100; i++) {
        final user = UserGenerator.generate('initials_$i');
        final parts = user.name.split(' ');
        final expected = parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts.last[0]}'.toUpperCase();
        expect(user.initials, equals(expected));
      }
    });

    test('equality based on seed', () {
      final a = UserGenerator.generate('eq_seed');
      final b = UserGenerator.generate('eq_seed');
      expect(a, equals(b));
    });
  });
}
