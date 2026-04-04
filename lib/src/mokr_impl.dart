import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'core/slot_registry.dart';
import 'data/generators/post_generator.dart';
import 'data/generators/user_generator.dart';
import 'data/models/mock_post.dart';
import 'data/models/mock_user.dart';
import 'images/mokr_image_provider.dart';
import 'images/picsum_provider.dart';
import 'images/provider_registry.dart';
import 'images/unsplash_provider.dart';

/// Internal singleton. Not exported.
///
/// Holds initialisation state and implements the four-mode resolution logic
/// for [MockUser] and [MockPost].
class MokrImpl {
  MokrImpl._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Initialises mokr. Called once by [Mokr.init].
  static Future<void> init({
    String? unsplashKey,
    MokrImageProvider? imageProvider,
  }) async {
    assert(
      !kReleaseMode,
      'mokr must not be used in production. '
      'Remove Mokr.init() and all mokr calls before releasing.',
    );

    // Resolve image provider: explicit > unsplashKey > Picsum default
    final MokrImageProvider provider;
    if (imageProvider != null) {
      provider = imageProvider;
    } else if (unsplashKey != null) {
      final unsplash = UnsplashMokrImageProvider();
      await unsplash.warmUp(unsplashKey);
      provider = unsplash;
    } else {
      provider = const PicsumMokrImageProvider();
    }
    setActiveImageProvider(provider);

    await SlotRegistry.init();
    _initialized = true;
  }

  /// Resolves a [MockUser] for the given mode parameters.
  static MockUser resolveUser({
    String? seed,
    String? slot,
    bool pin = false,
  }) {
    assert(_initialized, 'Call await Mokr.init() in main() before using mokr.');

    if (seed != null) {
      return UserGenerator.generate(seed);
    }

    if (slot != null) {
      final resolvedSeed = SlotRegistry.instance
          .getOrCreate(slot, generateSeed: _generateFreshSeed);
      final wasNew = !SlotRegistry.instance.isPinned(slot);

      if (pin) {
        SlotRegistry.instance.pin(slot);
        _debugLog("🔒 pin:'$slot' → seed: '$resolvedSeed' (protected)");
      } else if (!wasNew) {
        _debugLog("📌 slot:'$slot' → seed: '$resolvedSeed' (from disk)");
      } else {
        _debugLog(
            "🎲 fresh → seed: '$resolvedSeed'  (randomUser, slot:'$slot')");
      }
      return UserGenerator.generate(resolvedSeed);
    }

    // Fresh random
    final freshSeed = _generateFreshSeed();
    _debugLog("🎲 fresh → seed: '$freshSeed'  (randomUser)");
    return UserGenerator.generate(freshSeed);
  }

  /// Resolves a [MockPost] for the given mode parameters.
  static MockPost resolvePost({
    String? seed,
    String? slot,
    bool pin = false,
  }) {
    assert(_initialized, 'Call await Mokr.init() in main() before using mokr.');

    if (seed != null) {
      return PostGenerator.generate(seed);
    }

    if (slot != null) {
      final resolvedSeed = SlotRegistry.instance
          .getOrCreate(slot, generateSeed: _generateFreshSeed);
      final wasNew = !SlotRegistry.instance.isPinned(slot);

      if (pin) {
        SlotRegistry.instance.pin(slot);
        _debugLog("🔒 pin:'$slot' → seed: '$resolvedSeed' (protected)");
      } else if (!wasNew) {
        _debugLog("📌 slot:'$slot' → seed: '$resolvedSeed' (from disk)");
      } else {
        _debugLog(
            "🎲 fresh → seed: '$resolvedSeed'  (randomPost, slot:'$slot')");
      }
      return PostGenerator.generate(resolvedSeed);
    }

    // Fresh random
    final freshSeed = _generateFreshSeed();
    _debugLog("🎲 fresh → seed: '$freshSeed'  (randomPost)");
    return PostGenerator.generate(freshSeed);
  }

  /// Generates a random `mokr_XXXX` seed using non-seeded [Random].
  ///
  /// This is the ONLY place in mokr where non-deterministic randomness is used.
  /// Exposed for widget seed resolution (MokrImage, etc.).
  static String generateFreshSeed() => _generateFreshSeed();

  static String _generateFreshSeed() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = math.Random(); // intentionally non-seeded
    return 'mokr_${List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join()}';
  }

  static void _debugLog(String message) {
    if (kDebugMode) debugPrint('[mokr] $message');
  }

  /// Resets initialisation state. For testing only.
  @visibleForTesting
  static Future<void> resetForTesting() async {
    _initialized = false;
    setActiveImageProvider(const PicsumMokrImageProvider());
    SlotRegistry.resetForTesting();
  }
}
