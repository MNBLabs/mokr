import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/data/generators/user_generator.dart';

void main() {
  group('UserGenerator', () {
    test('same seed always produces same user', () {
      const seed = 'user_42';
      final a = UserGenerator.generate(seed);
      final b = UserGenerator.generate(seed);
      expect(a.seed, equals(b.seed));
      expect(a.id, equals(b.id));
      expect(a.firstName, equals(b.firstName));
      expect(a.lastName, equals(b.lastName));
      expect(a.name, equals(b.name));
      expect(a.username, equals(b.username));
      expect(a.bio, equals(b.bio));
      expect(a.followerCount, equals(b.followerCount));
      expect(a.followingCount, equals(b.followingCount));
      expect(a.postCount, equals(b.postCount));
      expect(a.isVerified, equals(b.isVerified));
      expect(a.joinedAt, equals(b.joinedAt));
    });

    test('same seed 100 calls all return same name', () {
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

    test('username is lowercase with no @ prefix', () {
      final user = UserGenerator.generate('test_user');
      expect(user.username, isNot(startsWith('@')));
      expect(user.username, equals(user.username.toLowerCase()));
    });

    test('handle is @-prefixed username', () {
      final user = UserGenerator.generate('test_user');
      expect(user.handle, startsWith('@'));
      expect(user.handle, equals('@${user.username}'));
    });

    test('name combines firstName and lastName', () {
      final user = UserGenerator.generate('test_user');
      expect(user.name, equals('${user.firstName} ${user.lastName}'));
    });

    test('followerCount is non-negative and within bound', () {
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

    test('initials are two uppercase letters', () {
      for (var i = 0; i < 50; i++) {
        final user = UserGenerator.generate('initials_$i');
        expect(user.initials.length, equals(2));
        expect(user.initials, equals(user.initials.toUpperCase()));
        expect(user.initials[0], equals(user.firstName[0].toUpperCase()));
        expect(user.initials[1], equals(user.lastName[0].toUpperCase()));
      }
    });

    test('equality based on seed', () {
      final a = UserGenerator.generate('eq_seed');
      final b = UserGenerator.generate('eq_seed');
      expect(a, equals(b));
    });

    test('formattedFollowers is non-empty', () {
      final user = UserGenerator.generate('fmt_test');
      expect(user.formattedFollowers, isNotEmpty);
    });

    test('relativeJoinDate starts with Joined', () {
      final user = UserGenerator.generate('join_date_test');
      expect(user.relativeJoinDate, startsWith('Joined '));
    });
  });
}
