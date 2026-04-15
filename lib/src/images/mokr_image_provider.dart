/// Image categories for mock content generation.
///
/// Semver contract: never remove or reorder existing values — append only.
enum MokrCategory {
  face,
  nature,
  travel,
  food,
  fashion,
  fitness,
  art,
  technology,
  office,
  abstract_,
  product,
  interior,
  architecture,
  automotive,
  pets,
}

/// Extension providing the URL keyword for each [MokrCategory].
extension MokrCategoryX on MokrCategory {
  /// The string used in Picsum seed URLs and Unsplash search queries.
  /// [abstract_] maps to `'abstract'` (no trailing underscore).
  String get keyword => switch (this) {
        MokrCategory.abstract_ => 'abstract',
        _ => name,
      };

  /// Unsplash query string — same as [keyword] for all categories.
  String get unsplashQuery => keyword;
}

/// Aspect-ratio classification derived from [MokrImageMeta.aspectRatio].
enum MokrRatio {
  landscape, // > 1.2  (e.g. 16:9, 4:3)
  portrait, //  < 0.85 (e.g. 4:5, 9:16)
  square, //    0.85 – 1.2
}

/// Avatar and image shape for [MokrAvatar].
enum MokrShape { circle, rounded, square }

/// Abstract interface for synchronous image URL construction.
///
/// All methods must:
/// - Return a valid HTTPS URL string.
/// - Never throw.
/// - Be synchronous.
///
/// Built-in implementations: [PicsumMokrImageProvider], [UnsplashMokrImageProvider].
/// Custom providers can be passed to [Mokr.init(imageProvider:)].
abstract class MokrImageProvider {
  const MokrImageProvider();

  /// Square avatar URL for [seed]. [category] is typically [MokrCategory.face].
  String avatarUrl(String seed, MokrCategory category, {int size = 80});

  /// Content image URL for [seed] and [category].
  String imageUrl(
    String seed,
    MokrCategory category, {
    int width = 800,
    int height = 600,
  });

  /// Wide banner URL for [seed] and [category].
  String bannerUrl(
    String seed,
    MokrCategory category, {
    int width = 1200,
    int height = 400,
  });

  /// Returns the aspect ratio (width / height) for images returned by
  /// [imageUrl] with default dimensions, without making a network request.
  ///
  /// Return [null] if unknown — Mokr defaults to `16/9`.
  /// - Picsum: always known (ratio = width/height baked into URL).
  /// - Unsplash: known after [Mokr.cache.warm()] completes.
  double? knownAspectRatio(String seed, MokrCategory category);
}
