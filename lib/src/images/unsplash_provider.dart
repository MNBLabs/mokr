import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/seed_hash.dart';
import 'mokr_image_provider.dart';
import 'picsum_provider.dart';

/// Opt-in image provider backed by the Unsplash API.
///
/// Requires a free Unsplash access key. Activate via:
/// ```dart
/// await Mokr.init(unsplashKey: 'your_access_key');
/// ```
///
/// On pre-warm, fetches ~50 CDN URLs per [MokrCategory] using `dart:io`
/// [HttpClient]. After warm-up, all URL lookups are synchronous.
///
/// Falls back to [PicsumMokrImageProvider] for any category with no cached URLs.
///
/// For development and prototyping only — do not ship to end users.
class UnsplashMokrImageProvider extends MokrImageProvider {
  UnsplashMokrImageProvider();

  final Map<MokrCategory, List<String>> _urlCache = {};
  final Map<MokrCategory, double?> _ratioCache = {};
  final _picsum = const PicsumMokrImageProvider();

  /// Pre-warms the URL cache by fetching CDN URLs from the Unsplash API.
  ///
  /// Returns the number of categories successfully warmed (0–15).
  /// A return of 0 means the key is invalid or all requests failed.
  Future<int> warmUp(String apiKey) async {
    var successCount = 0;
    for (final category in MokrCategory.values) {
      final urls = <String>{};
      final ratios = <double>[];
      for (var batch = 0; batch < 2 && urls.length < 50; batch++) {
        try {
          final result = await _fetchBatch(apiKey, category, count: 30);
          for (final item in result) {
            urls.add(item.url);
            if (item.ratio != null) ratios.add(item.ratio!);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[mokr] ⚠️  unsplash failed: ${category.keyword} — $e');
          }
          break;
        }
      }
      if (urls.isNotEmpty) {
        _urlCache[category] = urls.take(50).toList();
        if (ratios.isNotEmpty) {
          _ratioCache[category] = ratios.reduce((a, b) => a + b) / ratios.length;
        }
        successCount++;
      }
    }
    return successCount;
  }

  Future<List<_UnsplashPhoto>> _fetchBatch(
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
      final photos = jsonDecode(body) as List<dynamic>;
      return photos.map((p) {
        final map = p as Map<String, dynamic>;
        final url = map['urls']['regular'] as String;
        final w = (map['width'] as num?)?.toDouble();
        final h = (map['height'] as num?)?.toDouble();
        final ratio = (w != null && h != null && h > 0) ? w / h : null;
        return _UnsplashPhoto(url: url, ratio: ratio);
      }).toList();
    } finally {
      client.close();
    }
  }

  @override
  String avatarUrl(String seed, MokrCategory category, {int size = 80}) {
    assert(size > 0);
    final urls = _urlCache[MokrCategory.face];
    if (urls == null || urls.isEmpty) {
      return _picsum.avatarUrl(seed, category, size: size);
    }
    return urls[SeedHash.hash(seed) % urls.length];
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
    final urls = _urlCache[category];
    if (urls == null || urls.isEmpty) {
      return _picsum.imageUrl(seed, category, width: width, height: height);
    }
    return urls[SeedHash.hash(seed) % urls.length];
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
    final urls = _urlCache[category];
    if (urls == null || urls.isEmpty) {
      return _picsum.bannerUrl(seed, category, width: width, height: height);
    }
    return urls[SeedHash.hash(seed) % urls.length];
  }

  @override
  double? knownAspectRatio(String seed, MokrCategory category) {
    return _ratioCache[category];
  }
}

class _UnsplashPhoto {
  const _UnsplashPhoto({required this.url, this.ratio});
  final String url;
  final double? ratio;
}
