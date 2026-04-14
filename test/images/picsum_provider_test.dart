import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/images/mokr_image_provider.dart';
import 'package:mokr/src/images/picsum_provider.dart';

void main() {
  const provider = PicsumMokrImageProvider();

  group('PicsumMokrImageProvider', () {
    test('avatarUrl returns valid HTTPS Picsum URL with default size', () {
      final url = provider.avatarUrl('user_42', MokrCategory.face);
      expect(url, startsWith('https://picsum.photos/seed/'));
      expect(url, contains('80/80'));
    });

    test('avatarUrl respects custom size', () {
      final url = provider.avatarUrl('user_42', MokrCategory.face, size: 120);
      expect(url, contains('120/120'));
    });

    test('avatarUrl encodes category keyword in seed', () {
      final url = provider.avatarUrl('user_42', MokrCategory.face);
      expect(url, contains(MokrCategory.face.keyword));
    });

    test('imageUrl returns valid HTTPS Picsum URL with v1 defaults', () {
      final url = provider.imageUrl('post_1', MokrCategory.nature);
      expect(url, startsWith('https://picsum.photos/seed/'));
      expect(url, contains('800/600')); // v1 defaults
    });

    test('imageUrl respects custom dimensions', () {
      final url = provider.imageUrl('post_1', MokrCategory.nature,
          width: 400, height: 300);
      expect(url, contains('400/300'));
    });

    test('bannerUrl returns valid HTTPS Picsum URL with v1 defaults', () {
      final url = provider.bannerUrl('profile_42', MokrCategory.nature);
      expect(url, startsWith('https://picsum.photos/seed/'));
      expect(url, contains('1200/400')); // v1 defaults
    });

    test('bannerUrl respects custom dimensions', () {
      final url = provider.bannerUrl('profile_42', MokrCategory.nature,
          width: 800, height: 300);
      expect(url, contains('800/300'));
    });

    test('different seeds produce different URLs', () {
      final a = provider.imageUrl('seed_a', MokrCategory.food);
      final b = provider.imageUrl('seed_b', MokrCategory.food);
      expect(a, isNot(equals(b)));
    });

    test('different categories produce different URLs for same seed', () {
      final a = provider.imageUrl('same_seed', MokrCategory.nature);
      final b = provider.imageUrl('same_seed', MokrCategory.food);
      expect(a, isNot(equals(b)));
    });

    test('same inputs always produce same URL', () {
      final a = provider.imageUrl('deterministic', MokrCategory.travel);
      final b = provider.imageUrl('deterministic', MokrCategory.travel);
      expect(a, equals(b));
    });

    test('abstract_ category uses "abstract" keyword (no trailing underscore)',
        () {
      final url = provider.imageUrl('seed', MokrCategory.abstract_);
      expect(url, contains('abstract'));
      expect(url, isNot(contains('abstract_')));
    });

    test('all 15 categories produce valid URLs', () {
      for (final cat in MokrCategory.values) {
        final url = provider.imageUrl('cat_test', cat);
        expect(url, startsWith('https://picsum.photos/seed/'),
            reason: 'Failed for category ${cat.name}');
      }
    });

    test('knownAspectRatio returns positive value', () {
      final ratio = provider.knownAspectRatio('seed', MokrCategory.nature);
      expect(ratio, isNotNull);
      expect(ratio!, greaterThan(0));
    });
  });
}
