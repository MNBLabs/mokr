import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show providerVersion, kUnsplashPrefKey;

const _kPrefKey = kUnsplashPrefKey;

/// Settings screen — switch between Picsum (default) and Unsplash providers.
///
/// Uses [Mokr.useUnsplash] / [Mokr.usePicsum] — no side effects on slot state.
/// The key is persisted via SharedPreferences so it survives app restarts.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  _Status? _status;
  bool _usingUnsplash = false;

  @override
  void initState() {
    super.initState();
    _loadSavedKey();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPrefKey);
    if (saved != null && mounted) {
      // Populate the text field. The actual Unsplash warm-up was already
      // kicked off in main() — we just reflect the saved state here.
      setState(() {
        _controller.text = saved;
        _usingUnsplash = true;
        _status = _Status.info(
          'Restoring Unsplash from saved key (${saved.substring(0, 6)}…). '
          'Explore will update automatically when ready.',
        );
      });
    }
  }

  Future<void> _apply() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _loading = true;
      _status = null;
    });

    final count = await Mokr.useUnsplash(key);

    if (!mounted) return;

    if (count == 0) {
      setState(() {
        _loading = false;
        _usingUnsplash = false;
        _status = const _Status.error(
          'No photos loaded. Check the access key and try again.\n'
          'Tip: use the Access Key from your Unsplash app dashboard '
          '(not the Secret Key).',
        );
      });
      return;
    }

    // Persist for next app launch.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, key);

    providerVersion.value++; // triggers Explore + other screens to rebuild

    setState(() {
      _loading = false;
      _usingUnsplash = true;
      _status = _Status.success(
        'Unsplash active — $count/15 categories loaded. '
        'Go to Explore to see real photos.',
      );
    });
  }

  Future<void> _resetToPicsum() async {
    Mokr.usePicsum();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefKey);

    providerVersion.value++;

    setState(() {
      _usingUnsplash = false;
      _controller.clear();
      _status = const _Status.info('Switched back to Picsum (default).');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Settings'), floating: true, snap: true),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProviderBadge(usingUnsplash: _usingUnsplash),
                const SizedBox(height: 24),

                Text(
                  'Unsplash API Key',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Replace Picsum with category-filtered real photos.\n'
                  'Use the Access Key from your app at unsplash.com/developers.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),

                // Key field
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Access Key',
                    hintText: 'Paste your Unsplash access key here',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _apply(),
                ),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _loading
                              ? 'Loading 15 categories…'
                              : 'Apply Unsplash Key',
                        ),
                        onPressed: _loading || _controller.text.trim().isEmpty
                            ? null
                            : _apply,
                      ),
                    ),
                    if (_usingUnsplash) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _loading ? null : _resetToPicsum,
                        child: const Text('Reset'),
                      ),
                    ],
                  ],
                ),

                if (_status != null) ...[
                  const SizedBox(height: 12),
                  _StatusBanner(status: _status!),
                ],

                const SizedBox(height: 32),
                _InfoCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Status model ─────────────────────────────────────────────────────────────

enum _StatusKind { success, error, info }

class _Status {
  const _Status._(this.kind, this.message);
  const _Status.success(String message) : this._(_StatusKind.success, message);
  const _Status.error(String message) : this._(_StatusKind.error, message);
  const _Status.info(String message) : this._(_StatusKind.info, message);

  final _StatusKind kind;
  final String message;
}

// ─── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final _Status status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg, icon) = switch (status.kind) {
      _StatusKind.success => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.check_circle_outline,
        ),
      _StatusKind.error => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          Icons.error_outline,
        ),
      _StatusKind.info => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurface,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.message,
              style: theme.textTheme.bodySmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Provider badge ───────────────────────────────────────────────────────────

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.usingUnsplash});
  final bool usingUnsplash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg, label) = usingUnsplash
        ? (
            theme.colorScheme.primaryContainer,
            theme.colorScheme.onPrimaryContainer,
            'Provider: Unsplash',
          )
        : (
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.onSurfaceVariant,
            'Provider: Picsum (default)',
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 16, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _bullet(
              theme,
              'Access Key',
              'The key from your Unsplash app dashboard. '
                  'Application ID and Secret Key are not used.',
            ),
            const SizedBox(height: 6),
            _bullet(
              theme,
              'Warm-up',
              'On apply, mokr fetches up to 60 photo URLs per category '
                  '(30 total API requests). After that, all URL lookups are instant.',
            ),
            const SizedBox(height: 6),
            _bullet(
              theme,
              'In your app',
              "final n = await Mokr.useUnsplash('key');\n"
                  "// n == 0 → key invalid or network error",
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(ThemeData theme, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label — ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
