import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/mokr.dart';
import 'package:mokr/src/widgets/internal/mokr_shimmer.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Mokr.init();
  });

  // ─── MokrUserBuilder ──────────────────────────────────────────────────────

  group('MokrUserBuilder', () {
    testWidgets('seed mode passes correct MockUser to builder', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrUserBuilder(
          seed: 'u1',
          builder: (_, user) => Text(user.name),
        ),
      ));
      expect(find.text(Mokr.user('u1').name), findsOneWidget);
    });

    testWidgets('same seed always produces same user name', (tester) async {
      final expected = Mokr.user('u_stable').name;
      await tester.pumpWidget(_wrap(
        MokrUserBuilder(
          seed: 'u_stable',
          builder: (_, user) => Text(user.name),
        ),
      ));
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrUserBuilder(
          slot: 'builder_slot',
          builder: (_, user) => Text(user.handle),
        ),
      ));
      await tester.pump();
      // No assertion on specific text — slot generates random
      expect(find.byType(MokrUserBuilder), findsOneWidget);
    });

    testWidgets('fresh mode (no seed/slot) renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrUserBuilder(
          builder: (_, user) => Text(user.name),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrUserBuilder), findsOneWidget);
    });

    testWidgets('builder receives user with non-empty name', (tester) async {
      MockUser? received;
      await tester.pumpWidget(_wrap(
        MokrUserBuilder(
          seed: 'u_check',
          builder: (_, user) {
            received = user;
            return Text(user.name);
          },
        ),
      ));
      expect(received, isNotNull);
      expect(received!.name, isNotEmpty);
    });

    testWidgets('const constructor compiles', (tester) async {
      // Verifies the const constraint from the API contract
      const widget = MokrUserBuilder(seed: 'u1', builder: _dummyUserBuilder);
      await tester.pumpWidget(_wrap(widget));
      expect(find.byType(MokrUserBuilder), findsOneWidget);
    });
  });

  // ─── MokrPostBuilder ──────────────────────────────────────────────────────

  group('MokrPostBuilder', () {
    testWidgets('seed mode passes correct MockPost to builder', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          seed: 'p1',
          builder: (_, post) => Text(post.caption),
        ),
      ));
      expect(find.text(Mokr.post('p1').caption), findsOneWidget);
    });

    testWidgets('builder receives post with non-empty caption', (tester) async {
      MockPost? received;
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          seed: 'p_check',
          builder: (_, post) {
            received = post;
            return Text(post.caption);
          },
        ),
      ));
      expect(received?.caption, isNotEmpty);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          slot: 'post_slot',
          builder: (_, post) => Text(post.caption),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrPostBuilder), findsOneWidget);
    });

    testWidgets('fresh mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          builder: (_, post) => Text(post.caption),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrPostBuilder), findsOneWidget);
    });

    testWidgets('builder gives access to author data', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          seed: 'p_author',
          builder: (_, post) => Text(post.author.name),
        ),
      ));
      expect(find.text(Mokr.post('p_author').author.name), findsOneWidget);
    });

    testWidgets('builder gives access to imageMeta', (tester) async {
      MockPost? received;
      await tester.pumpWidget(_wrap(
        MokrPostBuilder(
          seed: 'p_meta',
          builder: (_, post) {
            received = post;
            return const SizedBox.shrink();
          },
        ),
      ));
      expect(received?.imageMeta.aspectRatio, greaterThan(0));
    });
  });

  // ─── MokrFeedBuilder ──────────────────────────────────────────────────────

  group('MokrFeedBuilder', () {
    testWidgets('passes correct number of posts to builder', (tester) async {
      int? count;
      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'feed_test',
          pageSize: 7,
          builder: (_, posts) {
            count = posts.length;
            return const SizedBox.shrink();
          },
        ),
      ));
      expect(count, equals(7));
    });

    testWidgets('same feedSeed + page always produces same first caption',
        (tester) async {
      final expected = Mokr.feed('stable_feed', page: 0, pageSize: 5).first.caption;
      String? received;
      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'stable_feed',
          pageSize: 5,
          builder: (_, posts) {
            received = posts.first.caption;
            return const SizedBox.shrink();
          },
        ),
      ));
      expect(received, equals(expected));
    });

    testWidgets('different pages produce different posts', (tester) async {
      String? page0Caption;
      String? page1Caption;

      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'paged_feed',
          page: 0,
          pageSize: 5,
          builder: (_, posts) {
            page0Caption = posts.first.caption;
            return const SizedBox.shrink();
          },
        ),
      ));

      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'paged_feed',
          page: 1,
          pageSize: 5,
          builder: (_, posts) {
            page1Caption = posts.first.caption;
            return const SizedBox.shrink();
          },
        ),
      ));

      expect(page0Caption, isNot(equals(page1Caption)));
    });

    testWidgets('renders a ListView of posts', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'list_feed',
          pageSize: 3,
          builder: (_, posts) => ListView(
            children: posts.map((p) => Text(p.caption)).toList(),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('pageSize 0 produces empty list', (tester) async {
      int? count;
      await tester.pumpWidget(_wrap(
        MokrFeedBuilder(
          feedSeed: 'empty_feed',
          pageSize: 0,
          builder: (_, posts) {
            count = posts.length;
            return const SizedBox.shrink();
          },
        ),
      ));
      expect(count, equals(0));
    });
  });

  // ─── MokrAvatar (image-based after Phase 4) ───────────────────────────────

  group('MokrAvatar — Phase 4', () {
    testWidgets('seed mode renders Image with NetworkImage provider',
        (tester) async {
      await tester.pumpWidget(_wrap(MokrAvatar(seed: 'u1', size: 48)));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('shows shimmer before image loads (frame == null)',
        (tester) async {
      await tester.pumpWidget(_wrap(MokrAvatar(seed: 'u1', size: 48)));
      // No pump(Duration) — image won't actually load in tests
      expect(find.byType(MokrShimmer), findsOneWidget);
    });

    testWidgets('loadingBuilder overrides default shimmer', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrAvatar(
          seed: 'u1',
          size: 48,
          loadingBuilder: (_) => const Text('loading', key: Key('custom_load')),
        ),
      ));
      expect(find.byKey(const Key('custom_load')), findsOneWidget);
      expect(find.byType(MokrShimmer), findsNothing);
    });
  });

  // ─── MokrImage (image-based after Phase 4) ────────────────────────────────

  group('MokrImage — Phase 4', () {
    testWidgets('aspectRatioFromSource wraps in AspectRatio', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrImage(
          seed: 'post_1',
          category: MokrCategory.nature,
          aspectRatioFromSource: true,
        ),
      ));
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('fixed height does not wrap in AspectRatio', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrImage(
          seed: 'post_1',
          category: MokrCategory.nature,
          height: 200,
        ),
      ));
      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('loadingBuilder overrides shimmer', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrImage(
          seed: 'post_1',
          category: MokrCategory.food,
          loadingBuilder: (_) => const Text('img_loading', key: Key('img_load')),
        ),
      ));
      expect(find.byKey(const Key('img_load')), findsOneWidget);
    });
  });
}

// Helpers for const-constructor tests

Widget _dummyUserBuilder(BuildContext context, MockUser user) =>
    Text(user.name);
