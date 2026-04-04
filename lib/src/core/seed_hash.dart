/// FNV-1a 32-bit hash — the foundation of mokr's determinism.
///
/// Every seed string flows through this before reaching [dart:math Random].
/// The algorithm is stable across Dart VM restarts, devices, and versions.
///
/// **Never change this implementation without a major version bump.**
/// Any change breaks all existing seeds.
final class SeedHash {
  SeedHash._(); // Not instantiable.

  static const int _offsetBasis = 0x811c9dc5;
  static const int _prime = 0x01000193;
  static const int _mask32 = 0xFFFFFFFF;

  /// Hashes [input] using FNV-1a 32-bit.
  ///
  /// Returns a non-negative 32-bit integer.
  /// Same input always produces the same output — across hot reloads,
  /// hot restarts, devices, and app reinstalls.
  ///
  /// ```dart
  /// final h = SeedHash.hash('user_42');  // always 2847361029 (example)
  /// ```
  static int hash(String input) {
    var h = _offsetBasis;
    for (final byte in input.codeUnits) {
      h ^= byte;
      h = (h * _prime) & _mask32;
    }
    return h;
  }
}
