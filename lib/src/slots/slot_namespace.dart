import 'slot_registry.dart';

/// `Mokr.slots` — slot lifecycle management.
///
/// ```dart
/// await Mokr.slots.clear('card_1');   // next call re-generates
/// await Mokr.slots.clearAll();         // wipe all slots
/// final map = Mokr.slots.list();       // debug: inspect active slots
/// ```
final class MokrSlots {
  const MokrSlots();

  /// Clears [slot] from the registry and persists.
  /// The next `Mokr.random.*({slot: '...'})` call for this slot
  /// will generate a new seed.
  Future<void> clear(String slot) => SlotRegistry.clear(slot);

  /// Clears all slots and persists.
  Future<void> clearAll() => SlotRegistry.clearAll();

  /// Returns an unmodifiable map of all active slots.
  /// Intended for debug/dev-settings screens only.
  Map<String, String> list() => SlotRegistry.list();
}
