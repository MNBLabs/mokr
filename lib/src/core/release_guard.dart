import 'package:flutter/foundation.dart';

/// Asserts that mokr is not running in a release build.
///
/// Call once at the top of [Mokr.init()].
/// The assert is stripped in release mode — this file has zero runtime cost
/// in production (and init() would never be called anyway).
void assertNotRelease() {
  assert(!kReleaseMode, 'mokr must not be used in production builds.');
}
