import 'package:flutter/foundation.dart';

import '../data/generators/feed_generator.dart';
import '../data/generators/post_generator.dart';
import '../data/generators/user_generator.dart';
import '../data/models/mock_post.dart';
import '../data/models/mock_user.dart';
import '../slots/slot_registry.dart';

/// `Mokr.random` — random data with optional slot stability.
///
/// Two behaviours per method:
///
/// **No slot — fresh random every call.**
/// Prints a copy-pasteable seed to console so you can graduate to deterministic:
/// ```
/// [mokr] 🎲  mokr_a7Be — copy to: Mokr.user('mokr_a7Be')
/// ```
///
/// **With slot — stable after the first call.**
/// First call generates and persists the seed. All subsequent calls return
/// the same result. Survives hot reload, hot restart, and reinstall.
/// ```dart
/// Mokr.random.user(slot: 'profile_hero')  // always the same user
/// ```
///
/// Graduation flow (zero friction):
/// ```
/// Step 1: Mokr.random.user()
///   → console: [mokr] 🎲  mokr_a7Be — copy to: Mokr.user('mokr_a7Be')
/// Step 2: Replace with: Mokr.user('mokr_a7Be')
/// Done.
/// ```
final class MokrRandom {
  const MokrRandom();

  /// Returns a [MockUser].
  ///
  /// Without [slot]: fresh random every call.
  /// With [slot]: stable random — same result after first call.
  MockUser user({String? slot}) {
    assert(slot == null || slot.isNotEmpty, 'slot name cannot be empty.');
    final seed = _resolveSeed(slot, caller: "Mokr.user");
    return UserGenerator.generate(seed);
  }

  /// Returns a [MockPost].
  MockPost post({String? slot}) {
    assert(slot == null || slot.isNotEmpty, 'slot name cannot be empty.');
    final seed = _resolveSeed(slot, caller: "Mokr.post");
    return PostGenerator.generate(seed);
  }

  /// Returns a page of [MockPost] items.
  ///
  /// Without [slot]: fresh random feed seed every call.
  /// With [slot]: stable feed seed across calls.
  List<MockPost> feed({
    String? slot,
    int page = 0,
    int pageSize = 20,
  }) {
    assert(slot == null || slot.isNotEmpty, 'slot name cannot be empty.');
    assert(page >= 0, 'page cannot be negative.');
    assert(pageSize >= 0, 'pageSize cannot be negative.');
    final seed = _resolveSeed(slot, caller: "Mokr.feed");
    return FeedGenerator.page(seed, page, pageSize);
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  String _resolveSeed(String? slot, {required String caller}) {
    if (slot != null) {
      final isHit = SlotRegistry.contains(slot);
      final seed = SlotRegistry.resolve(slot);
      if (kDebugMode) {
        if (isHit) {
          debugPrint("[mokr] 📌  slot:'$slot' → $seed");
        } else {
          debugPrint("[mokr] 🎲  $seed → slot:'$slot'");
        }
      }
      return seed;
    }

    // Fresh random — generate, log, return.
    final seed = SlotRegistry.generateSeed();
    if (kDebugMode) {
      debugPrint("[mokr] 🎲  $seed — copy to: $caller('$seed')");
    }
    return seed;
  }
}
