import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/types.dart';

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, List<WardrobeItem>>((ref) {
  return WardrobeNotifier();
});

class WardrobeNotifier extends StateNotifier<List<WardrobeItem>> {
  WardrobeNotifier() : super([]) {
    _loadItems();
  }

  static const String _storageKey = 'wardrobe_storage_v2';

  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        if (decoded.containsKey('state')) {
          final itemsJson = decoded['state']['items'] as List;
          state = itemsJson.map((e) => WardrobeItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint("Failed to load wardrobe: \$e");
    }
  }

  Future<void> _saveItems(List<WardrobeItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = items.map((e) => e.toJson()).toList();
      final encoded = jsonEncode({'state': {'items': itemsJson}});
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint("Failed to save wardrobe: \$e");
    }
  }

  void addItem(WardrobeItem item) {
    state = [item, ...state];
    _saveItems(state);
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveItems(state);
  }

  void updateItem(WardrobeItem updatedItem) {
    state = state.map((item) => item.id == updatedItem.id ? updatedItem : item).toList();
    _saveItems(state);
  }
}
