import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/seed_hash.dart';
import '../mokr_enums.dart';
import 'mokr_image_provider.dart';
import 'picsum_provider.dart';

/// Opt-in image provider backed by the Unsplash API.
///
/// Requires a free Unsplash API key. Activated via:
/// ```dart
/// await Mokr.init(unsplashKey: 'your_api_key');
/// ```
///
/// **Pre-warming:** On [warmUp], this provider fetches ~50 CDN image URLs per
/// [MokrCategory] from the Unsplash API (30 HTTP requests at init time).
/// After [warmUp] completes, all URL construction is synchronous.
///
/// **Cache miss:** If a category has no warmed URLs (e.g. network error during
/// pre-warm), the call falls back to [PicsumMokrImageProvider] transparently.
///
/// Images are sourced from Unsplash (https://unsplash.com).
/// For development and prototyping only.
/// Do not use in production apps or ship to end users.
class UnsplashMokrImageProvider extends MokrImageProvider {
  UnsplashMokrImageProvider();

  final Map<MokrCategory, List<String>> _cache = {};
  final _picsum = const PicsumMokrImageProvider();

  /// Pre-warms the cache by fetching CDN URLs from the Unsplash API.
  ///
  /// Makes 2 batch requests per category (15 categories × 2 = 30 requests).
  /// Each request fetches up to 30 random photos. Deduplicates and stores
  /// up to 50 URLs per category in memory.
  ///
  /// Network failures for individual categories are silently swallowed —
  /// those categories fall back to Picsum at URL lookup time.
  /// Pre-warms the URL cache.
  ///
  /// Returns the number of categories successfully warmed (0–15).
  /// A return of 0 means the key is invalid or all requests failed.
  Future<int> warmUp(String apiKey) async {
    var successCount = 0;
    for (final category in MokrCategory.values) {
      final urls = <String>{};
      for (var batch = 0; batch < 2 && urls.length < 50; batch++) {
        try {
          final fetched = await _fetchBatch(apiKey, category, count: 30);
          urls.addAll(fetched);
        } catch (e) {
          debugPrint('[mokr] Unsplash fetch error (${category.name}): $e');
          break;
        }
      }
      if (urls.isNotEmpty) {
        _cache[category] = urls.take(50).toList();
        successCount++;
      }
    }
    return successCount;
  }

  Future<List<String>> _fetchBatch(
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

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Accept-Version': 'v1',
    });

    if (response.statusCode != 200) return [];

    final photos = jsonDecode(response.body) as List<dynamic>;
    return photos
        .map((p) => (p as Map<String, dynamic>)['urls']['regular'] as String)
        .toList();
  }

  @override
  String avatarUrl(String seed, MokrCategory category, {int size = 80}) {
    assert(size > 0, 'size must be positive');
    final urls = _cache[MokrCategory.face];
    if (urls == null || urls.isEmpty) {
      return _picsum.avatarUrl(seed, category, size: size);
    }
    return urls[SeedHash.hash(seed) % urls.length];
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
    final urls = _cache[category];
    if (urls == null || urls.isEmpty) {
      return _picsum.imageUrl(seed, category, width: width, height: height);
    }
    return urls[SeedHash.hash(seed) % urls.length];
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
    final urls = _cache[category];
    if (urls == null || urls.isEmpty) {
      return _picsum.bannerUrl(seed, category, width: width, height: height);
    }
    return urls[SeedHash.hash(seed) % urls.length];
  }
}
