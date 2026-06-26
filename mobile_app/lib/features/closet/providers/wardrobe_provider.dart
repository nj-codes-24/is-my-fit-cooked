/// Wardrobe state management with encrypted persistence.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/core/constants/app_constants.dart';
import 'package:is_my_fit_cooked/core/services/ai_service.dart';
import 'package:is_my_fit_cooked/core/services/secure_storage_service.dart';
import 'package:is_my_fit_cooked/core/services/storage_service.dart';
import 'package:is_my_fit_cooked/features/closet/domain/wardrobe_item.dart';

/// Provider for wardrobe items backed by encrypted storage.
final wardrobeProvider =
    NotifierProvider<WardrobeNotifier, List<WardrobeItem>>(
  WardrobeNotifier.new,
);

/// Manages wardrobe items with encrypted persistence.
///
/// Migrated from deprecated [StateNotifier] to canonical [Notifier].
/// All persistence operations use [SecureStorageService] for GDPR
/// compliance (encrypted at rest).
class WardrobeNotifier extends Notifier<List<WardrobeItem>> {
  late final SecureStorageService _storage;

  @override
  List<WardrobeItem> build() {
    _storage = ref.read(secureStorageProvider);
    // Load persisted items on initialization.
    _loadItems();
    return [];
  }

  Future<void> _loadItems() async {
    try {
      final data = await _storage.readJson(AppConstants.wardrobeStorageKey);
      if (data != null && data.containsKey('state')) {
        final stateMap = data['state'] as Map<String, dynamic>;
        final itemsJson = stateMap['items'] as List<dynamic>;
        state = itemsJson
            .map(
              (e) => WardrobeItem.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
    } on Exception catch (_) {
      debugPrint('Failed to load wardrobe data');
    }
  }

  Future<void> _saveItems(List<WardrobeItem> items) async {
    try {
      // Serialize items — compute() offloads to isolate
      // via SecureStorageService.writeJson.
      final itemsJson = items.map((e) => e.toJson()).toList();
      await _storage.writeJson(
        AppConstants.wardrobeStorageKey,
        {'state': {'items': itemsJson}},
      );
    } on Exception catch (_) {
      debugPrint('Failed to save wardrobe data');
    }
  }

  /// Adds an item optimistically to the wardrobe.
  /// Spawns a background process to upload the image to R2 and extract AI tags.
  void addItem(WardrobeItem item) {
    state = [item, ...state];
    _saveItems(state);

    if (item.imageBytes != null && item.color.isEmpty) {
      _processImageAsync(item);
    }
  }

  Future<void> _processImageAsync(WardrobeItem item) async {
    try {
      final storage = ref.read(storageServiceProvider);
      final ai = ref.read(aiServiceProvider);

      // 1. Compress & Upload to Cloudflare R2
      final imageUrl = await storage.uploadImage(item.imageBytes!);

      // 2. Extract Tags via OpenRouter Vision AI
      final tags = await ai.extractTags(imageUrl);

      // 3. Merge extracted tags back into the optimistic item
      final updated = item.copyWith(
        color: tags['color'] as String? ?? item.color,
        category: tags['category'] as String? ?? item.category,
        image: imageUrl, // Cache the public R2 URL
      );
      
      // Update state without blocking the user
      updateItem(updated);
    } on Exception catch (e) {
      debugPrint('Background R2/AI Tagging failed: $e');
    }
  }

  /// Removes an item by ID.
  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveItems(state);
  }

  /// Updates an existing item (matched by ID).
  void updateItem(WardrobeItem updatedItem) {
    state = state
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();
    _saveItems(state);
  }

  /// Deletes all wardrobe data. GDPR right-to-erasure.
  Future<void> deleteAllData() async {
    state = [];
    await _storage.delete(AppConstants.wardrobeStorageKey);
  }
}
