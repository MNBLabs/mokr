import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/seed_hash.dart';
import 'cache/image_cache.dart';
import 'mokr_image_provider.dart';
import 'picsum_provider.dart';

/// Opt-in image provider backed by the Unsplash API.
///
/// Activate via `Mokr.init(unsplashKey: 'your_access_key')`.
///
/// On pre-warm, fetches up to 50 CDN URLs per [MokrCategory] using
/// `dart:io` [HttpClient]. All subsequent URL lookups are synchronous reads
/// from [MokrImageCache].
///
/// Falls back to [PicsumMokrImageProvider] for any category not in the cache.
class UnsplashMokrImageProvider extends MokrImageProvider {
  const UnsplashMokrImageProvider();

  static const _picsum = PicsumMokrImageProvider();

  /// Pre-warms [MokrImageCache] by fetching photo URLs from the Unsplash API.
  ///
  /// Returns the number of categories successfully warmed (0–15).
  Future<int> prewarm(String apiKey) async {
    var successCount = 0;
    for (final category in MokrCategory.values) {
      final photos = <CachedPhoto>[];
      for (var batch = 0; batch < 2 && photos.length < 50; batch++) {
        try {
          final fetched = await _fetchBatch(apiKey, category, count: 30);
          photos.addAll(fetched);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[mokr] ⚠️  unsplash failed: ${category.keyword} — $e');
          }
          break;
        }
      }
      if (photos.isNotEmpty) {
        MokrImageCache.instance.setPhotos(category, photos.take(50).toList());
        successCount++;
      } else if (kDebugMode) {
        debugPrint(
            '[mokr] ⚠️  unsplash failed: ${category.keyword} — falling back to Picsum');
      }
    }
    MokrImageCache.instance.markWarmed();
    return successCount;
  }

  @override
  String avatarUrl(String seed, MokrCategory category, {int size = 80}) {
    assert(size > 0);
    final photos = MokrImageCache.instance.getPhotos(MokrCategory.face);
    if (photos == null || photos.isEmpty) {
      return _picsum.avatarUrl(seed, category, size: size);
    }
    return photos[SeedHash.hash(seed) % photos.length].url;
  }

  @override
  String imageUrl(
    String seed,
    MokrCategory category, {
    int width = 800,
    int height = 600,
  }) {
    assert(width > 0);
    assert(height > 0);
    final photos = MokrImageCache.instance.getPhotos(category);
    if (photos == null || photos.isEmpty) {
      return _picsum.imageUrl(seed, category, width: width, height: height);
    }
    return photos[SeedHash.hash(seed) % photos.length].url;
  }

  @override
  String bannerUrl(
    String seed,
    MokrCategory category, {
    int width = 1200,
    int height = 400,
  }) {
    assert(width > 0);
    assert(height > 0);
    final photos = MokrImageCache.instance.getPhotos(category);
    if (photos == null || photos.isEmpty) {
      return _picsum.bannerUrl(seed, category, width: width, height: height);
    }
    return photos[SeedHash.hash(seed) % photos.length].url;
  }

  @override
  double? knownAspectRatio(String seed, MokrCategory category) {
    final photos = MokrImageCache.instance.getPhotos(category);
    if (photos == null || photos.isEmpty) return null;
    return photos[SeedHash.hash(seed) % photos.length].aspectRatio;
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<List<CachedPhoto>> _fetchBatch(
    String apiKey,
    MokrCategory category, {
    required int count,
  }) async {
    final uri = Uri.https('api.unsplash.com', '/photos/random', {
      'client_id': apiKey,
      'query': category.unsplashQuery,
      'count': '$count',
      'orientation': category == MokrCategory.face ? 'squarish' : 'landscape',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers
        ..set('Accept', 'application/json')
        ..set('Accept-Version', 'v1');
      final response = await request.close();
      if (response.statusCode != 200) return [];
      final body = await response.transform(const Utf8Decoder()).join();
      final items = jsonDecode(body) as List<dynamic>;
      return items.map((p) {
        final map = p as Map<String, dynamic>;
        final url = map['urls']['regular'] as String;
        final w = (map['width'] as num?)?.toDouble();
        final h = (map['height'] as num?)?.toDouble();
        final ratio = (w != null && h != null && h > 0) ? w / h : null;
        return CachedPhoto(url: url, aspectRatio: ratio);
      }).toList();
    } finally {
      client.close();
    }
  }
}
