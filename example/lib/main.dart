import 'package:flutter/material.dart';
import 'package:mokr/mokr.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/explore_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/playground_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

/// Last [mokr] debug log line — updated by overriding [debugPrint].
final mokrLastLog = ValueNotifier<String>('');

/// Incremented when the active image provider changes.
/// Watched by screens that need to rebuild their images (e.g. ExploreScreen).
final providerVersion = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture [mokr] debug output for the Playground console display.
  final originalPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.startsWith('[mokr]')) {
      mokrLastLog.value = message;
    }
    originalPrint(message, wrapWidth: wrapWidth);
  };

  await Mokr.init();
  runApp(const MokrExampleApp());

  // Restore Unsplash provider from previous session — non-blocking so the
  // app renders immediately. When warm-up completes, providerVersion signals
  // Explore (and any other listener) to rebuild with real images.
  _restoreUnsplash();
}

/// SharedPreferences key for the saved Unsplash access key.
const kUnsplashPrefKey = 'mokr_example_unsplash_key';

Future<void> _restoreUnsplash() async {
  final prefs = await SharedPreferences.getInstance();
  final key = prefs.getString(kUnsplashPrefKey);
  if (key == null) return;
  final count = await Mokr.useUnsplash(key);
  if (count > 0) providerVersion.value++;
}

class MokrExampleApp extends StatelessWidget {
  const MokrExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mokr example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
      home: const _RootNav(),
    );
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav();

  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;

  static const _screens = [
    FeedScreen(),
    ExploreScreen(),
    ProfileScreen(),
    PlaygroundScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screen States alive — navigating away and back
      // does not dispose/recreate State objects, so form fields and status
      // messages are preserved.
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Playground',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
