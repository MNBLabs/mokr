import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/src/core/mokr_base.dart';
import 'package:mokr/src/data/models/mokr_image_meta.dart';
import 'package:mokr/src/images/image_namespace.dart';
import 'package:mokr/src/images/mokr_image_provider.dart';

void main() {
  const ns = MokrImageNamespace();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Mokr.init();
  });

  group('MokrImageNamespace — url()', () {
    test('returns Picsum URL by default', () {
      final url = ns.url('p1', category: MokrCategory.food);
      expect(url, contains('picsum.photos'));
    });

    test('contains default dimensions 800×600', () {
      final url = ns.url('p1', category: MokrCategory.nature);
      expect(url, contains('800/600'));
    });

    test('respects custom width and height', () {
      final url =
          ns.url('p1', category: MokrCategory.nature, width: 400, height: 300);
      expect(url, contains('400/300'));
    });

    test('is deterministic — same inputs produce same URL', () {
      final a = ns.url('seed_x', category: MokrCategory.travel);
      final b = ns.url('seed_x', category: MokrCategory.travel);
      expect(a, equals(b));
    });

    test('different seeds produce different URLs', () {
      final a = ns.url('seed_a', category: MokrCategory.food);
      final b = ns.url('seed_b', category: MokrCategory.food);
      expect(a, isNot(equals(b)));
    });

    test('different categories produce different URLs for same seed', () {
      final a = ns.url('same', category: MokrCategory.nature);
      final b = ns.url('same', category: MokrCategory.food);
      expect(a, isNot(equals(b)));
    });

    test('all 15 categories return non-empty URLs', () {
      for (final cat in MokrCategory.values) {
        expect(ns.url('seed', category: cat), isNotEmpty,
            reason: 'Failed for ${cat.name}');
      }
    });
  });

  group('MokrImageNamespace — provider()', () {
    test('returns NetworkImage', () {
      final p = ns.provider('p1', category: MokrCategory.food);
      expect(p, isA<NetworkImage>());
    });

    test('NetworkImage URL matches url()', () {
      final url = ns.url('p1', category: MokrCategory.food);
      final p = ns.provider('p1', category: MokrCategory.food) as NetworkImage;
      expect(p.url, equals(url));
    });
  });

  group('MokrImageNamespace — meta()', () {
    test('returns MokrImageMeta', () {
      final m = ns.meta('p1', category: MokrCategory.food);
      expect(m, isA<MokrImageMeta>());
    });

    test('aspectRatio is positive and finite', () {
      final m = ns.meta('p1', category: MokrCategory.food);
      expect(m.aspectRatio, greaterThan(0));
      expect(m.aspectRatio.isFinite, isTrue);
    });

    test('url matches url()', () {
      final url = ns.url('p1', category: MokrCategory.food);
      final m = ns.meta('p1', category: MokrCategory.food);
      expect(m.url, equals(url));
    });

    test('provider is NetworkImage', () {
      final m = ns.meta('p1', category: MokrCategory.food);
      expect(m.provider, isA<NetworkImage>());
    });

    test('url contains picsum.photos (default provider)', () {
      final m = ns.meta('p1', category: MokrCategory.food);
      expect(m.url, contains('picsum.photos'));
    });

    test('default aspectRatio for Picsum is 800/600', () {
      final m = ns.meta('p1', category: MokrCategory.nature);
      expect(m.aspectRatio, closeTo(800 / 600, 0.001));
    });

    test('ratio is landscape for 800×600', () {
      final m = ns.meta('p1', category: MokrCategory.nature);
      expect(m.ratio, equals(MokrRatio.landscape));
    });

    test('seed and category fields are stored', () {
      final m = ns.meta('myseed', category: MokrCategory.pets);
      expect(m.seed, equals('myseed'));
      expect(m.category, equals(MokrCategory.pets));
    });
  });

  group('MokrImageNamespace — avatar()', () {
    test('returns Picsum URL', () {
      expect(ns.avatar('u1'), contains('picsum.photos'));
    });

    test('contains default size 80', () {
      expect(ns.avatar('u1'), contains('80/80'));
    });

    test('respects custom size', () {
      expect(ns.avatar('u1', size: 120), contains('120/120'));
    });

    test('is deterministic', () {
      expect(ns.avatar('u1'), equals(ns.avatar('u1')));
    });

    test('avatarProvider returns NetworkImage', () {
      expect(ns.avatarProvider('u1'), isA<NetworkImage>());
    });

    test('avatarProvider URL matches avatar()', () {
      final url = ns.avatar('u1');
      final p = ns.avatarProvider('u1') as NetworkImage;
      expect(p.url, equals(url));
    });
  });

  group('MokrImageNamespace — avatarMeta()', () {
    test('aspectRatio is 1.0 (square)', () {
      final m = ns.avatarMeta('u1');
      expect(m.aspectRatio, equals(1.0));
    });

    test('ratio is MokrRatio.square', () {
      final m = ns.avatarMeta('u1');
      expect(m.ratio, equals(MokrRatio.square));
    });

    test('category is MokrCategory.face', () {
      final m = ns.avatarMeta('u1');
      expect(m.category, equals(MokrCategory.face));
    });

    test('url matches avatar()', () {
      expect(ns.avatarMeta('u1').url, equals(ns.avatar('u1')));
    });

    test('provider is NetworkImage', () {
      expect(ns.avatarMeta('u1').provider, isA<NetworkImage>());
    });
  });

  group('MokrImageNamespace — banner()', () {
    test('returns non-empty URL', () {
      expect(ns.banner('u1'), isNotEmpty);
    });

    test('contains default banner dimensions 1200×400', () {
      expect(ns.banner('u1'), contains('1200/400'));
    });
  });

  group('MokrRatio.fromRatio (via MokrImageMeta.ratioFrom)', () {
    test('> 1.2 is landscape', () {
      expect(MokrImageMeta.ratioFrom(1.5), MokrRatio.landscape);
      expect(MokrImageMeta.ratioFrom(1.21), MokrRatio.landscape);
    });

    test('< 0.85 is portrait', () {
      expect(MokrImageMeta.ratioFrom(0.5), MokrRatio.portrait);
      expect(MokrImageMeta.ratioFrom(0.84), MokrRatio.portrait);
    });

    test('0.85–1.2 is square', () {
      expect(MokrImageMeta.ratioFrom(1.0), MokrRatio.square);
      expect(MokrImageMeta.ratioFrom(0.85), MokrRatio.square);
      expect(MokrImageMeta.ratioFrom(1.2), MokrRatio.square);
    });
  });

  group('MockUser image getters', () {
    test('avatarUrl is non-empty', () {
      final user = Mokr.user('u1');
      expect(user.avatarUrl, isNotEmpty);
    });

    test('avatarProvider is NetworkImage', () {
      final user = Mokr.user('u1');
      expect(user.avatarProvider, isA<NetworkImage>());
    });

    test('avatarMeta.aspectRatio is 1.0', () {
      final user = Mokr.user('u1');
      expect(user.avatarMeta.aspectRatio, equals(1.0));
    });

    test('avatarMeta URL contains picsum.photos', () {
      final user = Mokr.user('u1');
      expect(user.avatarMeta.url, contains('picsum.photos'));
    });
  });

  group('MockPost image getters', () {
    test('imageUrl is non-empty', () {
      final post = Mokr.post('p1');
      expect(post.imageUrl, isNotEmpty);
    });

    test('imageProvider is NetworkImage', () {
      final post = Mokr.post('p1');
      expect(post.imageProvider, isA<NetworkImage>());
    });

    test('imageMeta.aspectRatio is positive and finite', () {
      final post = Mokr.post('p1');
      expect(post.imageMeta.aspectRatio, greaterThan(0));
      expect(post.imageMeta.aspectRatio.isFinite, isTrue);
    });

    test('imageMeta URL matches imageUrl', () {
      final post = Mokr.post('p1');
      expect(post.imageMeta.url, equals(post.imageUrl));
    });
  });
}
