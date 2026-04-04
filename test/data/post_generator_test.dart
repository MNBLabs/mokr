import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/data/generators/post_generator.dart';
import 'package:mokr/src/images/picsum_provider.dart';
import 'package:mokr/src/images/provider_registry.dart';

void main() {
  setUpAll(() {
    setActiveImageProvider(const PicsumMokrImageProvider());
  });

  group('PostGenerator', () {
    test('same seed always produces same post', () {
      const seed = 'post_42';
      final a = PostGenerator.generate(seed);
      final b = PostGenerator.generate(seed);
      expect(a.seed, equals(b.seed));
      expect(a.id, equals(b.id));
      expect(a.caption, equals(b.caption));
      expect(a.imageUrl, equals(b.imageUrl));
      expect(a.likeCount, equals(b.likeCount));
      expect(a.commentCount, equals(b.commentCount));
      expect(a.shareCount, equals(b.shareCount));
      expect(a.isLiked, equals(b.isLiked));
      expect(a.createdAt, equals(b.createdAt));
      expect(a.tags, equals(b.tags));
      expect(a.author.seed, equals(b.author.seed));
    });

    test('different seeds produce different posts', () {
      final a = PostGenerator.generate('post_aaa');
      final b = PostGenerator.generate('post_bbb');
      // At least one field should differ
      final different = a.caption != b.caption ||
          a.likeCount != b.likeCount ||
          a.commentCount != b.commentCount;
      expect(different, isTrue);
    });

    test('id has correct format', () {
      final post = PostGenerator.generate('test_post');
      expect(post.id, startsWith('pst_'));
      expect(post.id.length, equals(8)); // 'pst_' + 4 hex chars
    });

    test('caption is non-empty', () {
      for (var i = 0; i < 30; i++) {
        final post = PostGenerator.generate('cap_$i');
        expect(post.caption, isNotEmpty);
      }
    });

    test('likeCount is non-negative', () {
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('likes_$i');
        expect(post.likeCount, isNonNegative);
      }
    });

    test('commentCount is in [0, 500)', () {
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('comments_$i');
        expect(post.commentCount, isNonNegative);
        expect(post.commentCount, lessThan(500));
      }
    });

    test('shareCount is in [0, 200)', () {
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('shares_$i');
        expect(post.shareCount, isNonNegative);
        expect(post.shareCount, lessThan(200));
      }
    });

    test('tags is a list of 0–5 items', () {
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('tags_$i');
        expect(post.tags.length, greaterThanOrEqualTo(0));
        expect(post.tags.length, lessThanOrEqualTo(5));
      }
    });

    test('imageUrl is non-null when hasImage is true', () {
      var hasImageCount = 0;
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('img_$i');
        if (post.hasImage) {
          expect(post.imageUrl, isNotNull);
          expect(post.imageUrl, isNotEmpty);
          hasImageCount++;
        } else {
          expect(post.imageUrl, isNull);
        }
      }
      // ~80% should have images; at least some should
      expect(hasImageCount, greaterThan(20));
    });

    test('imageCategory is null when hasImage is false', () {
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('cat_$i');
        if (!post.hasImage) {
          expect(post.imageCategory, isNull);
        } else {
          expect(post.imageCategory, isNotNull);
        }
      }
    });

    test('createdAt is at or before reference date', () {
      final referenceDate = DateTime.utc(2026, 1, 1);
      for (var i = 0; i < 50; i++) {
        final post = PostGenerator.generate('created_$i');
        expect(
          post.createdAt.isBefore(referenceDate) ||
              post.createdAt.isAtSameMomentAs(referenceDate),
          isTrue,
        );
      }
    });

    test('author seed is derived from post seed', () {
      const seed = 'author_link_test';
      final post = PostGenerator.generate(seed);
      expect(post.author.seed, equals('${seed}_author'));
    });

    test('author is stable across calls', () {
      const seed = 'author_stable';
      final a = PostGenerator.generate(seed);
      final b = PostGenerator.generate(seed);
      expect(a.author.name, equals(b.author.name));
    });

    test('formattedLikes is non-empty', () {
      final post = PostGenerator.generate('fmt_likes');
      expect(post.formattedLikes, isNotEmpty);
    });
  });
}
