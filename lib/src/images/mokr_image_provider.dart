import '../mokr_enums.dart';

/// Abstract interface for synchronous image URL construction.
///
/// All methods must:
/// - Return a valid HTTPS URL string.
/// - Never throw.
/// - Be synchronous (return [String], not [Future<String>]).
///
/// Built-in implementations:
/// - [PicsumMokrImageProvider] — zero-config default.
/// - [UnsplashMokrImageProvider] — opt-in upgrade (requires API key + pre-warm).
///
/// Custom providers can be injected at `Mokr.init(imageProvider: ...)`.
///
/// Images are sourced from third-party APIs.
/// For development and prototyping only.
/// Do not use in production apps or ship to end users.
abstract class MokrImageProvider {
  const MokrImageProvider();

  /// Returns a square avatar image URL for [seed].
  ///
  /// [category] is typically [MokrCategory.face] for avatars.
  String avatarUrl(String seed, MokrCategory category, {int size = 80});

  /// Returns a content image URL for [seed] and [category].
  String imageUrl(
    String seed,
    MokrCategory category, {
    int width = 400,
    int height = 300,
  });

  /// Returns a wide banner image URL for [seed] and [category].
  String bannerUrl(
    String seed,
    MokrCategory category, {
    int width = 800,
    int height = 300,
  });
}
