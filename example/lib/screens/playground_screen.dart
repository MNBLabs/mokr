// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';

import '../main.dart' show mokrLastLog;

/// Flagship demo — shows exactly how the four modes work.
///
/// Each section is interactive and labelled so developers understand
/// what to expect when they adopt each mode in their own code.
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  // Section 1 — Fresh Random: key forces new initState on each regenerate.
  int _freshKey = 0;

  // Section 2 — Slot: key forces new initState after clearSlot.
  int _slotKey = 0;

  // Section 3 — Pinned Slot: key forces rebuild to verify pin survived.
  int _pinKey = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        const SizedBox(height: 8),
        _header(theme),
        const SizedBox(height: 16),

        // ── Section 1: Fresh Random ──────────────────────────────────────
        _Section(
          number: '1',
          title: 'Fresh Random',
          code: 'MokrAvatar(size: 80)',
          description: 'No seed, no slot. Changes every rebuild. '
              'Use for quick throwaway prototyping.',
          avatar: MokrAvatar(key: ValueKey('fresh_$_freshKey'), size: 80),
          actions: [
            FilledButton.icon(
              icon: const Icon(Icons.shuffle, size: 16),
              label: const Text('Regenerate'),
              onPressed: () => setState(() => _freshKey++),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Section 2: Slot ───────────────────────────────────────────────
        _Section(
          number: '2',
          title: 'Slot Mode',
          code: "MokrAvatar(slot: 'my_slot', size: 80)",
          description: 'Random once, then stable. Persisted to disk. '
              'Survives hot reload and app restarts. '
              'Clear the slot to pick a new random.',
          avatar: MokrAvatar(
            key: ValueKey('slot_$_slotKey'),
            slot: 'playground_slot',
            size: 80,
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Slot'),
              onPressed: () async {
                await Mokr.clearSlot('playground_slot');
                setState(() => _slotKey++);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Section 3: Pinned Slot ────────────────────────────────────────
        _Section(
          number: '3',
          title: 'Pinned Slot',
          code: "MokrAvatar(slot: 'hero', pin: true, size: 80)",
          description: 'Same as slot, but protected. Survives clearAll(). '
              'Only removable via clearPin().',
          avatar: MokrAvatar(
            key: ValueKey('pin_$_pinKey'),
            slot: 'playground_pin',
            pin: true,
            size: 80,
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.cleaning_services_outlined, size: 16),
              label: const Text('Try clearAll()'),
              onPressed: () async {
                await Mokr.clearAll(); // pinned slot survives
                setState(() => _pinKey++); // force rebuild to confirm
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.lock_open_outlined, size: 16),
              label: const Text('Clear Pin'),
              onPressed: () async {
                await Mokr.clearPin('playground_pin');
                setState(() => _pinKey++);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Section 4: Deterministic ──────────────────────────────────────
        _Section(
          number: '4',
          title: 'Deterministic',
          code: "MokrAvatar(seed: 'demo_user_permanent', size: 80)",
          description: 'Seed baked into code. No disk, no init() required. '
              'Same across installs, devices, and forever.',
          avatar: const MokrAvatar(seed: 'demo_user_permanent', size: 80),
          extra: _SeedDisplay(seed: 'demo_user_permanent'),
          actions: const [],
        ),
        const SizedBox(height: 20),

        // ── Console log display ────────────────────────────────────────────
        _ConsoleDisplay(),
      ],
    );
  }

  Widget _header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 52),
        Text('Playground', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Interact with each section to see how the four modes behave.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.number,
    required this.title,
    required this.code,
    required this.description,
    required this.avatar,
    required this.actions,
    this.extra,
  });

  final String number;
  final String title;
  final String code;
  final String description;
  final Widget avatar;
  final List<Widget> actions;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    final onSurface = theme.colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Avatar + content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code snippet
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(description, style: theme.textTheme.bodySmall),
                      if (extra != null) ...[
                        const SizedBox(height: 6),
                        extra!,
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Seed display for deterministic section ───────────────────────────────────

class _SeedDisplay extends StatelessWidget {
  const _SeedDisplay({required this.seed});
  final String seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Mokr.user(seed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.name, style: theme.textTheme.bodySmall),
        Row(
          children: [
            const Icon(Icons.key, size: 12),
            const SizedBox(width: 4),
            Text(
              seed,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Console log display ──────────────────────────────────────────────────────

class _ConsoleDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Text(
                  'Debug console',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: mokrLastLog,
              builder: (context, log, _) {
                final display = log.isEmpty ? '(no mokr logs yet)' : log;
                return Text(
                  display,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF89D185),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
