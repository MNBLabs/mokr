import 'mokr_image_provider.dart';
import 'picsum_provider.dart';

/// Internal registry for the active [MokrImageProvider].
///
/// Package-private — not exported from `mokr.dart`.
/// Set once during [Mokr.init()]. Read by generators during URL construction.
MokrImageProvider _activeProvider = const PicsumMokrImageProvider();

/// Returns the currently active image provider.
///
/// Defaults to [PicsumMokrImageProvider] before [Mokr.init()] is called,
/// so URL construction works even in pure deterministic mode.
MokrImageProvider get activeImageProvider => _activeProvider;

/// Sets the active image provider. Called by [MokrImpl] during init.
void setActiveImageProvider(MokrImageProvider provider) {
  _activeProvider = provider;
}
