import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/data/generators/feed_generator.dart';
import 'package:mokr/src/images/picsum_provider.dart';
import 'package:mokr/src/images/provider_registry.dart';

void main() {
  setUpAll(() {
    setActiveImageProvider(const PicsumMokrImageProvider());
  });

  group('FeedGenerator', () {
    test('same seed + page always returns same posts', () {
      final a = FeedGenerator.page('home_feed', 0, 20);
      final b = FeedGenerator.page('home_feed', 0, 20);
      expect(a.length, equals(b.length));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].seed, equals(b[i].seed));
        expect(a[i].caption, equals(b[i].caption));
      }
    });

    test('different pages return different posts', () {
      final page0 = FeedGenerator.page('test_feed', 0, 20);
      final page1 = FeedGenerator.page('test_feed', 1, 20);
      expect(page0.first.seed, isNot(equals(page1.first.seed)));
    });

    test('different feeds return different posts for same page', () {
      final feedA = FeedGenerator.page('feed_a', 0, 10);
      final feedB = FeedGenerator.page('feed_b', 0, 10);
      expect(feedA.first.seed, isNot(equals(feedB.first.seed)));
    });

    test('returns correct page size', () {
      expect(FeedGenerator.page('feed', 0, 5).length, equals(5));
      expect(FeedGenerator.page('feed', 0, 20).length, equals(20));
      expect(FeedGenerator.page('feed', 0, 1).length, equals(1));
    });

    test('pageSize 0 returns empty list', () {
      expect(FeedGenerator.page('feed', 0, 0), isEmpty);
    });

    test('post seeds follow the pattern', () {
      const feedSeed = 'pattern_feed';
      final posts = FeedGenerator.page(feedSeed, 2, 3);
      expect(posts[0].seed, equals('${feedSeed}_p2_i0'));
      expect(posts[1].seed, equals('${feedSeed}_p2_i1'));
      expect(posts[2].seed, equals('${feedSeed}_p2_i2'));
    });

    test('no duplicate seeds within a page', () {
      final posts = FeedGenerator.page('dedup_feed', 0, 50);
      final seeds = posts.map((p) => p.seed).toSet();
      expect(seeds.length, equals(50));
    });

    test('no overlap between consecutive pages', () {
      final page0Seeds = FeedGenerator.page('overlap_feed', 0, 20)
          .map((p) => p.seed)
          .toSet();
      final page1Seeds = FeedGenerator.page('overlap_feed', 1, 20)
          .map((p) => p.seed)
          .toSet();
      expect(page0Seeds.intersection(page1Seeds), isEmpty);
    });
  });
}
