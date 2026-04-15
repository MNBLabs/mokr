import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/cache_status.dart';
import '../mokr_image_provider.dart';

/// A photo URL + its known aspect ratio as stored in [MokrImageCache].
class CachedPhoto {
  const CachedPhoto({required this.url, this.aspectRatio});

  final String url;
  final double? aspectRatio;

  Map<String, dynamic> toJson() => {
        'url': url,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
      };

  factory CachedPhoto.fromJson(Map<String, dynamic> json) => CachedPhoto(
        url: json['url'] as String,
        aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
      );
}

/// In-memory + disk cache for Unsplash image URLs.
///
/// Location: `{appSupportDir}/mokr/image_cache.json`
/// TTL: 24 hours — after which [isStale] returns `true`.
///
/// All writes are asynchronous and non-blocking. The in-memory map is always
/// authoritative for reads.
///
/// Access via [MokrImageCache.instance].
final class MokrImageCache {
  MokrImageCache._();

  static final MokrImageCache instance = MokrImageCache._();

  final Map<MokrCategory, List<CachedPhoto>> _map = {};
  DateTime? _warmedAt;

  static const _ttlHours = 24;

  // ─── State ────────────────────────────────────────────────────────────────

  /// `true` if the cache has never been warmed or is older than 24 hours.
  bool get isStale =>
      _warmedAt == null ||
      DateTime.now().difference(_warmedAt!).inHours >= _ttlHours;

  /// When the cache was last warmed. `null` if never.
  DateTime? get warmedAt => _warmedAt;

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns the cached photos for [category], or `null` if not yet warmed.
  List<CachedPhoto>? getPhotos(MokrCategory category) => _map[category];

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Stores photos for [category]. Called during Unsplash pre-warm.
  void setPhotos(MokrCategory category, List<CachedPhoto> photos) {
    _map[category] = photos;
  }

  /// Records the timestamp when the pre-warm completed.
  void markWarmed() => _warmedAt = DateTime.now();

  // ─── Disk ─────────────────────────────────────────────────────────────────

  /// Loads cache from disk. Silently ignores missing / corrupt files.
  /// If the cache is stale on disk, the in-memory map is left empty (trigger
  /// re-warm at [init] time).
  Future<void> load() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return;

      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final warmedAtStr = json['warmed_at'] as String?;
      if (warmedAtStr == null) return;

      _warmedAt = DateTime.parse(warmedAtStr);

      final cats = json['categories'] as Map<String, dynamic>? ?? {};
      for (final entry in cats.entries) {
        final category = MokrCategory.values.where((c) => c.keyword == entry.key).firstOrNull;
        if (category == null) continue;
        final items = (entry.value as List<dynamic>)
            .map((e) => CachedPhoto.fromJson(e as Map<String, dynamic>))
            .toList();
        _map[category] = items;
      }
    } catch (_) {
      // Corrupt or unreadable — start fresh.
      _map.clear();
      _warmedAt = null;
    }
  }

  /// Persists the current cache to disk (fire-and-forget).
  Future<void> save() async {
    try {
      final file = await _cacheFile();
      await file.parent.create(recursive: true);
      final json = <String, dynamic>{
        'warmed_at': (_warmedAt ?? DateTime.now()).toUtc().toIso8601String(),
        'categories': {
          for (final entry in _map.entries)
            entry.key.keyword: entry.value.map((p) => p.toJson()).toList(),
        },
      };
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      if (kDebugMode) debugPrint('[mokr] ⚠️  image cache save failed: $e');
    }
  }

  /// Deletes the disk cache and clears in-memory state.
  Future<void> clear() async {
    _map.clear();
    _warmedAt = null;
    try {
      final file = await _cacheFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      if (kDebugMode) debugPrint('[mokr] ⚠️  image cache clear failed: $e');
    }
  }

  // ─── Status ───────────────────────────────────────────────────────────────

  /// Returns a [CacheStatus] snapshot for every [MokrCategory].
  Map<MokrCategory, CacheStatus> statusMap() {
    return {
      for (final cat in MokrCategory.values)
        cat: CacheStatus(
          urlCount: _map[cat]?.length ?? 0,
          lastWarmed: _warmedAt,
          isStale: isStale,
        ),
    };
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  static Future<File> _cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/mokr/image_cache.json');
  }
}
