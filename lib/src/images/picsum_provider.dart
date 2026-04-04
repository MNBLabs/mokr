import '../mokr_enums.dart';
import 'mokr_image_provider.dart';

/// Default image provider backed by Picsum Photos.
///
/// Zero configuration required — works without any API key.
/// Category filtering is achieved by folding the category name into the seed
/// string: `'${seed}_${category.keyword}'`. Picsum serves different images for
/// different seed strings, providing consistent per-category visual variation.
///
/// URL pattern: `https://picsum.photos/seed/{categorySeed}/{width}/{height}`
///
/// Picsum responds with a 302 redirect to a Fastly CDN URL. Flutter's
/// [Image.network] follows redirects automatically.
///
/// Images are sourced from Picsum Photos (https://picsum.photos).
/// For development and prototyping only.
/// Do not use in production apps or ship to end users.
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
    int width = 400,
    int height = 300,
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
    int width = 800,
    int height = 300,
  }) {
    assert(width > 0, 'width must be positive');
    assert(height > 0, 'height must be positive');
    final s = Uri.encodeComponent('${seed}_${category.keyword}');
    return 'https://picsum.photos/seed/$s/$width/$height';
  }
}
