import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mokr/mokr.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Mokr.init();
  });

  // ─── MokrAvatar ──────────────────────────────────────────────────────────

  group('MokrAvatar', () {
    testWidgets('renders in Container', (tester) async {
      await tester.pumpWidget(_wrap(
        Container(child: MokrAvatar(seed: 'u1', size: 48)),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('renders in ListView.builder', (tester) async {
      await tester.pumpWidget(_wrap(
        ListView.builder(
          itemCount: 3,
          itemBuilder: (ctx, i) => MokrAvatar(seed: 'u$i', size: 40),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsWidgets);
    });

    testWidgets('renders in Stack', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [MokrAvatar(seed: 'u1', size: 48)]),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('renders in Row with Expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        Row(children: [Expanded(child: MokrAvatar(seed: 'u1', size: 48))]),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrAvatar(slot: 'test_slot', size: 48),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('circle shape clips with ClipOval', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrAvatar(seed: 'u1', size: 48, shape: MokrShape.circle),
      ));
      await tester.pump();
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('rounded shape uses ClipRRect', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrAvatar(seed: 'u1', size: 48, shape: MokrShape.rounded),
      ));
      await tester.pump();
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('square shape renders without clip', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrAvatar(seed: 'u1', size: 48, shape: MokrShape.square),
      ));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('onTap callback wires up GestureDetector', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MokrAvatar(seed: 'u1', size: 48, onTap: () => tapped = true),
      ));
      await tester.pump();
      await tester.tap(find.byType(MokrAvatar));
      expect(tapped, isTrue);
    });
  });

  // ─── MokrImage ───────────────────────────────────────────────────────────

  group('MokrImage', () {
    testWidgets('renders in Container', (tester) async {
      await tester.pumpWidget(_wrap(
        Container(
          child: MokrImage(
            seed: 'post_1',
            category: MokrCategory.nature,
            height: 200,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrImage), findsOneWidget);
    });

    testWidgets('renders in ListView.builder', (tester) async {
      await tester.pumpWidget(_wrap(
        ListView.builder(
          itemCount: 3,
          itemBuilder: (ctx, i) => MokrImage(
            seed: 'img_$i',
            category: MokrCategory.nature,
            height: 200,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrImage), findsWidgets);
    });

    testWidgets('renders in Stack', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(
          children: [
            MokrImage(seed: 'post_1', category: MokrCategory.food, height: 200),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrImage), findsOneWidget);
    });

    testWidgets('renders in Expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        Row(
          children: [
            Expanded(
              child: MokrImage(
                seed: 'post_1',
                category: MokrCategory.travel,
                height: 200,
              ),
            ),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrImage), findsOneWidget);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrImage(slot: 'img_slot', category: MokrCategory.art, height: 150),
      ));
      await tester.pump();
      expect(find.byType(MokrImage), findsOneWidget);
    });

    testWidgets('borderRadius applies ClipRRect', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrImage(
          seed: 'rounded_img',
          category: MokrCategory.nature,
          height: 200,
          borderRadius: BorderRadius.circular(12),
        ),
      ));
      await tester.pump();
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('all categories render without throwing', (tester) async {
      for (final cat in MokrCategory.values) {
        await tester.pumpWidget(_wrap(
          MokrImage(seed: 'cat_test', category: cat, height: 100),
        ));
        await tester.pump();
        expect(find.byType(MokrImage), findsOneWidget,
            reason: 'Failed for ${cat.name}');
      }
    });
  });

  // ─── MokrPostCard ─────────────────────────────────────────────────────────

  group('MokrPostCard', () {
    testWidgets('renders in Container', (tester) async {
      await tester.pumpWidget(_wrap(
        Container(child: MokrPostCard(seed: 'post_0')),
      ));
      await tester.pump();
      expect(find.byType(MokrPostCard), findsOneWidget);
    });

    testWidgets('renders in ListView.builder', (tester) async {
      await tester.pumpWidget(_wrap(
        ListView.builder(
          itemCount: 5,
          itemBuilder: (ctx, i) => MokrPostCard(seed: 'feed_$i'),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrPostCard), findsWidgets);
    });

    testWidgets('renders in Stack', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(children: [
          SizedBox(
            width: 400,
            child: MokrPostCard(seed: 'post_stack'),
          ),
        ]),
      ));
      await tester.pump();
      expect(find.byType(MokrPostCard), findsOneWidget);
    });

    testWidgets('renders in Expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        Row(
          children: [Expanded(child: MokrPostCard(seed: 'post_expanded'))],
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrPostCard), findsOneWidget);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrPostCard(slot: 'card_slot'),
      ));
      await tester.pump();
      expect(find.byType(MokrPostCard), findsOneWidget);
    });

    testWidgets('contains MokrAvatar for author', (tester) async {
      await tester.pumpWidget(_wrap(MokrPostCard(seed: 'post_0')));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('onTap fires when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MokrPostCard(seed: 'post_tap', onTap: () => tapped = true),
      ));
      await tester.pump();
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });
  });

  // ─── MokrUserTile ─────────────────────────────────────────────────────────

  group('MokrUserTile', () {
    testWidgets('renders in Container', (tester) async {
      await tester.pumpWidget(_wrap(
        Container(child: MokrUserTile(seed: 'u1')),
      ));
      await tester.pump();
      expect(find.byType(MokrUserTile), findsOneWidget);
    });

    testWidgets('renders in ListView.builder', (tester) async {
      await tester.pumpWidget(_wrap(
        ListView.builder(
          itemCount: 5,
          itemBuilder: (ctx, i) => MokrUserTile(seed: 'user_$i'),
        ),
      ));
      await tester.pump();
      expect(find.byType(MokrUserTile), findsWidgets);
    });

    testWidgets('slot mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrUserTile(slot: 'user_slot'),
      ));
      await tester.pump();
      expect(find.byType(MokrUserTile), findsOneWidget);
    });

    testWidgets('trailing widget is rendered', (tester) async {
      await tester.pumpWidget(_wrap(
        MokrUserTile(
          seed: 'u1',
          trailing: const Text('Follow', key: Key('follow')),
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('follow')), findsOneWidget);
    });

    testWidgets('contains MokrAvatar as leading', (tester) async {
      await tester.pumpWidget(_wrap(MokrUserTile(seed: 'u1')));
      await tester.pump();
      expect(find.byType(MokrAvatar), findsOneWidget);
    });

    testWidgets('onTap fires when tile is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        MokrUserTile(seed: 'u1', onTap: () => tapped = true),
      ));
      await tester.pump();
      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });
  });
}
