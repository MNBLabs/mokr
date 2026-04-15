import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/data/generators/user_generator.dart';
import 'package:mokr/src/data/generators/post_generator.dart';
import 'package:mokr/src/namespaces/text_namespace.dart';

void main() {
  const text = MokrText();

  group('MokrText — determinism', () {
    test('name is deterministic', () {
      expect(text.name('u1'), equals(text.name('u1')));
    });

    test('firstName is deterministic', () {
      expect(text.firstName('u1'), equals(text.firstName('u1')));
    });

    test('lastName is deterministic', () {
      expect(text.lastName('u1'), equals(text.lastName('u1')));
    });

    test('username is deterministic', () {
      expect(text.username('u1'), equals(text.username('u1')));
    });

    test('handle is deterministic', () {
      expect(text.handle('u1'), equals(text.handle('u1')));
    });

    test('bio is deterministic', () {
      expect(text.bio('u1'), equals(text.bio('u1')));
    });

    test('caption is deterministic', () {
      expect(text.caption('p1'), equals(text.caption('p1')));
    });

    test('comment is deterministic', () {
      expect(text.comment('c1'), equals(text.comment('c1')));
    });

    test('initials is deterministic', () {
      expect(text.initials('u1'), equals(text.initials('u1')));
    });
  });

  group('MokrText — format', () {
    test('name contains a space (first + last)', () {
      expect(text.name('u1'), contains(' '));
    });

    test('firstName has no spaces', () {
      expect(text.firstName('u1'), isNot(contains(' ')));
    });

    test('lastName has no spaces', () {
      expect(text.lastName('u1'), isNot(contains(' ')));
    });

    test('username is lowercase', () {
      final u = text.username('u1');
      expect(u, equals(u.toLowerCase()));
    });

    test('username has no @ prefix', () {
      expect(text.username('u1'), isNot(startsWith('@')));
    });

    test('handle starts with @', () {
      expect(text.handle('u1'), startsWith('@'));
    });

    test('handle equals @username', () {
      expect(text.handle('u1'), equals('@${text.username('u1')}'));
    });

    test('bio is non-empty', () {
      expect(text.bio('u1'), isNotEmpty);
    });

    test('caption is non-empty', () {
      expect(text.caption('p1'), isNotEmpty);
    });

    test('comment is non-empty', () {
      expect(text.comment('c1'), isNotEmpty);
    });

    test('initials are two uppercase chars', () {
      final i = text.initials('u1');
      expect(i.length, equals(2));
      expect(i, equals(i.toUpperCase()));
    });
  });

  group('MokrText — matches MockUser / MockPost for same seed', () {
    test('name matches MockUser.name', () {
      const seed = 'match_test';
      final user = UserGenerator.generate(seed);
      expect(text.name(seed), equals(user.name));
    });

    test('firstName matches MockUser.firstName', () {
      const seed = 'first_test';
      final user = UserGenerator.generate(seed);
      expect(text.firstName(seed), equals(user.firstName));
    });

    test('lastName matches MockUser.lastName', () {
      const seed = 'last_test';
      final user = UserGenerator.generate(seed);
      expect(text.lastName(seed), equals(user.lastName));
    });

    test('username matches MockUser.username', () {
      const seed = 'uname_test';
      final user = UserGenerator.generate(seed);
      expect(text.username(seed), equals(user.username));
    });

    test('handle matches MockUser.handle', () {
      const seed = 'handle_test';
      final user = UserGenerator.generate(seed);
      expect(text.handle(seed), equals(user.handle));
    });

    test('bio matches MockUser.bio', () {
      const seed = 'bio_test';
      final user = UserGenerator.generate(seed);
      expect(text.bio(seed), equals(user.bio));
    });

    test('caption matches MockPost.caption', () {
      const seed = 'caption_test';
      final post = PostGenerator.generate(seed);
      expect(text.caption(seed), equals(post.caption));
    });

    test('initials match MockUser.initials', () {
      const seed = 'initials_test';
      final user = UserGenerator.generate(seed);
      expect(text.initials(seed), equals(user.initials));
    });
  });

  group('MokrText — variation across seeds', () {
    test('different seeds produce different names (probabilistic)', () {
      final names = List.generate(20, (i) => text.name('seed_$i')).toSet();
      expect(names.length, greaterThan(10));
    });

    test('different seeds produce different bios', () {
      final bios = List.generate(20, (i) => text.bio('seed_$i')).toSet();
      expect(bios.length, greaterThan(5));
    });
  });
}
