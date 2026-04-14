import 'mokr_image_provider.dart';

/// Default image provider backed by Picsum Photos (https://picsum.photos).
///
/// Zero configuration — no API key required.
/// Category filtering is achieved by folding the category keyword into the
/// seed string: `'${seed}_${category.keyword}'`.
///
/// URL pattern: `https://picsum.photos/seed/{categorySeed}/{width}/{height}`
///
/// Aspect ratio is always known synchronously: width / height from the URL.
///
/// For development and prototyping only — do not ship to end users.
class PicsumMokrImageProvider extends MokrImageProvider {
  const PicsumMokrImageProvider();

  @override
  String avatarUrl(String seed, MokrCategory category, {int size = 80}) {
    assert(size > 0, 'size must be positive');
    final s = Uri.encodeComponent('${seed}_${category.keyword}');
    return 'https://picsum.photos/seed/$s/$size/$size';
  }

  @override
  String imageUrl(
    String seed,
    MokrCategory category, {
    int width = 800,
    int height = 600,
  }) {
    assert(width > 0, 'width must be positive');
    assert(height > 0, 'height must be positive');
    final s = Uri.encodeComponent('${seed}_${category.keyword}');
    return 'https://picsum.photos/seed/$s/$width/$height';
  }

  @override
  String bannerUrl(
    String seed,
    MokrCategory category, {
    int width = 1200,
    int height = 400,
  }) {
    assert(width > 0, 'width must be positive');
    assert(height > 0, 'height must be positive');
    final s = Uri.encodeComponent('${seed}_${category.keyword}');
    return 'https://picsum.photos/seed/$s/$width/$height';
  }

  @override
  double? knownAspectRatio(String seed, MokrCategory category) {
    // Ratio is always known for Picsum: width / height from default dimensions.
    return 800 / 600;
  }
}
