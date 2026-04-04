import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

import '../main.dart' show providerVersion;

/// Use case: "I need a category-filtered image grid."
///
/// Demonstrates:
/// - All 15 [MokrCategory] values as filter chips
/// - [MokrImage] reacting to category changes via widget keys
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  MokrCategory _selected = MokrCategory.nature;
  static const _gridCount = 20;

  @override
  void initState() {
    super.initState();
    // Rebuild grid when the active image provider changes (Settings screen).
    providerVersion.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    providerVersion.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Explore'), floating: true, snap: true),

        // ── Category chips ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: MokrCategory.values.length,
              itemBuilder: (context, i) {
                final cat = MokrCategory.values[i];
                final selected = cat == _selected;
                return FilterChip(
                  label: Text(_labelFor(cat)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = cat),
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                );
              },
            ),
          ),
        ),

        // ── Image grid ─────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: _gridCount,
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // Key forces MokrImage to rebuild (new initState) when
                // the category changes, generating a new URL.
                child: MokrImage(
                  key: ValueKey('explore_${i}_${_selected.name}_${providerVersion.value}'),
                  seed: 'explore_$i',
                  category: _selected,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _labelFor(MokrCategory cat) {
    // Capitalise and strip trailing underscore from abstract_.
    final name = cat.name.replaceAll('_', '');
    return name[0].toUpperCase() + name.substring(1);
  }
}
