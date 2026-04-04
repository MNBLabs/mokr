import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _kSlotsKey = 'mokr_slots';
const _kPinsKey = 'mokr_pins';

/// Internal singleton that persists slot → seed mappings across runs.
///
/// Backed by [SharedPreferences]. All reads are in-memory (synchronous)
/// after [init] completes. All writes are async and fire-and-forget —
/// the in-memory state is always authoritative.
///
/// Thread safety: all Flutter UI work runs on the main isolate. [getOrCreate]
/// and all mutating methods are synchronous — no concurrent access is possible.
class SlotRegistry {
  SlotRegistry._();

  static SlotRegistry? _instance;

  /// The singleton instance. Throws if [init] has not been called.
  static SlotRegistry get instance {
    assert(_instance != null,
        'SlotRegistry not initialized. Call Mokr.init() first.');
    return _instance!;
  }

  // In-memory state — authoritative after init().
  final Map<String, String> _map = {};
  final Set<String> _pins = {};

  /// Loads persisted slot/pin data from [SharedPreferences].
  /// Called once during [Mokr.init()].
  static Future<void> init() async {
    final registry = SlotRegistry._();
    final prefs = await SharedPreferences.getInstance();

    final slotsJson = prefs.getString(_kSlotsKey);
    if (slotsJson != null) {
      final decoded = jsonDecode(slotsJson) as Map<String, dynamic>;
      registry._map.addAll(decoded.map((k, v) => MapEntry(k, v as String)));
    }

    final pinsJson = prefs.getString(_kPinsKey);
    if (pinsJson != null) {
      final decoded = jsonDecode(pinsJson) as List<dynamic>;
      registry._pins.addAll(decoded.cast<String>());
    }

    _instance = registry;
  }

  /// Returns the seed stored for [slot], or generates and stores a new one.
  ///
  /// The generated seed uses the caller-supplied [freshSeed] (produced by
  /// [_MokrImpl]) to keep seed generation logic in one place.
  String getOrCreate(String slot, {required String Function() generateSeed}) {
    if (_map.containsKey(slot)) return _map[slot]!;
    final seed = generateSeed();
    _map[slot] = seed;
    unawaited(_persist());
    return seed;
  }

  /// Adds [slot] to the pinned set. Idempotent.
  void pin(String slot) {
    if (!_pins.contains(slot)) {
      _pins.add(slot);
      unawaited(_persist());
    }
  }

  /// Returns whether [slot] is pinned.
  bool isPinned(String slot) => _pins.contains(slot);

  /// Removes [slot] from the map if it is not pinned.
  ///
  /// No-op if [slot] does not exist or is pinned.
  Future<void> clear(String slot) async {
    if (_pins.contains(slot)) return; // pinned — silently no-op
    _map.remove(slot);
    await _persist();
  }

  /// Removes [slot] from both the map and the pinned set.
  ///
  /// No-op if [slot] does not exist.
  Future<void> clearPin(String slot) async {
    _map.remove(slot);
    _pins.remove(slot);
    await _persist();
  }

  /// Removes all unpinned slots. Pinned slots are untouched.
  Future<void> clearAll() async {
    _map.removeWhere((slot, _) => !_pins.contains(slot));
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSlotsKey, jsonEncode(_map));
    await prefs.setString(_kPinsKey, jsonEncode(_pins.toList()));
  }

  /// Resets in-memory state and singleton. For testing only.
  // ignore: invalid_use_of_visible_for_testing_member
  static void resetForTesting() {
    _instance?._map.clear();
    _instance?._pins.clear();
    _instance = null;
  }
}
