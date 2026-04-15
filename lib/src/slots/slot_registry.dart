import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// In-memory slot registry, persisted to disk as JSON via `path_provider`.
///
/// Storage location: `{appSupportDir}/mokr/slots.json`
/// Format: flat `Map<String, String>` — slot name → generated seed.
///
/// No pin logic. Deterministic seeds never enter this map.
final class SlotRegistry {
  SlotRegistry._();

  static final Map<String, String> _map = {};

  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  /// Loads slot map from disk. Called once in [Mokr.init].
  /// Silently starts with an empty map on any error (corrupt file, no dir, etc.).
  static Future<void> load() async {
    try {
      final file = await _slotFile();
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString());
        _map.addAll(Map<String, String>.from(json as Map));
      }
    } catch (_) {
      // Missing or corrupt — start fresh.
    }
  }

  /// Returns the seed for [slot].
  ///
  /// **Hit:** slot exists → returns the stored seed (no log, no write).
  /// **Miss:** slot is new → generates a seed, stores it, persists async.
  static String resolve(String slot) {
    final existing = _map[slot];
    if (existing != null) return existing;

    final seed = _generateSeed();
    _map[slot] = seed;
    _persist(); // fire-and-forget
    return seed;
  }

  /// Returns true if [slot] is already in the registry.
  static bool contains(String slot) => _map.containsKey(slot);

  /// Removes [slot] and persists.
  static Future<void> clear(String slot) async {
    _map.remove(slot);
    await _persist();
  }

  /// Clears all slots and persists.
  static Future<void> clearAll() async {
    _map.clear();
    await _persist();
  }

  /// Returns an unmodifiable snapshot of the current slot map.
  static Map<String, String> list() => Map.unmodifiable(_map);

  /// Generates a fresh `mokr_XXXX` seed using a non-seeded RNG.
  ///
  /// 4 characters from `[A-Za-z0-9]` → 62^4 ≈ 14 M unique seeds.
  static String generateSeed() => _generateSeed();

  // ─── Private ───────────────────────────────────────────────────────────────

  static String _generateSeed() {
    final rng = math.Random();
    final suffix =
        List.generate(4, (_) => _chars[rng.nextInt(_chars.length)]).join();
    return 'mokr_$suffix';
  }

  static Future<void> _persist() async {
    try {
      final file = await _slotFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(Map<String, String>.from(_map)));
    } catch (e) {
      if (kDebugMode) debugPrint('[mokr] ⚠️  slots persist failed: $e');
    }
  }

  static Future<File> _slotFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/mokr/slots.json');
  }
}
