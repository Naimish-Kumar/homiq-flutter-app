import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/design_model.dart';

/// Caches design history locally for offline access.
class DesignCacheService {
  static const String _cacheKey = 'cached_designs';
  static const String _cacheTimestampKey = 'cached_designs_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Save designs to local cache.
  static Future<void> cacheDesigns(List<DesignModel> designs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = designs.map((d) => d.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
    await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Retrieve cached designs. Returns null if cache is expired or doesn't exist.
  static Future<List<DesignModel>?> getCachedDesigns() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    final timestamp = prefs.getInt(_cacheTimestampKey);

    if (cached == null || timestamp == null) return null;

    // Check cache expiry
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cachedAt) > _cacheExpiry) {
      await clearCache();
      return null;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(cached);
      return jsonList
          .map((json) => DesignModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await clearCache();
      return null;
    }
  }

  /// Clear the design cache.
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }

  /// Cache a single design (e.g., after generation).
  static Future<void> addDesignToCache(DesignModel design) async {
    final existing = await getCachedDesigns() ?? [];
    // Replace if exists, otherwise prepend
    final updated = existing.where((d) => d.id != design.id).toList();
    updated.insert(0, design);
    await cacheDesigns(updated);
  }

  /// Remove a design from cache.
  static Future<void> removeFromCache(String designId) async {
    final existing = await getCachedDesigns() ?? [];
    final updated = existing.where((d) => d.id != designId).toList();
    await cacheDesigns(updated);
  }
}
