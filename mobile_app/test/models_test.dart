import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:is_my_fit_cooked/features/closet/domain/outfit.dart';
import 'package:is_my_fit_cooked/features/closet/domain/wardrobe_item.dart';

void main() {
  group('WardrobeItem', () {
    test('fromJson/toJson roundtrip preserves all fields', () {
      final original = WardrobeItem(
        id: 'test-id-123',
        category: 'Shirts',
        color: 'Blue',
        image: 'https://example.com/shirt.jpg',
        imageBytes: Uint8List.fromList([1, 2, 3, 4]),
        addedAt: 1700000000000,
      );

      final json = original.toJson();
      final restored = WardrobeItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.category, equals(original.category));
      expect(restored.color, equals(original.color));
      expect(restored.image, equals(original.image));
      expect(restored.imageBytes, equals(original.imageBytes));
      expect(restored.addedAt, equals(original.addedAt));
    });

    test('fromJson handles missing fields gracefully', () {
      final item = WardrobeItem.fromJson(const <String, dynamic>{});

      expect(item.id, isEmpty);
      expect(item.category, isEmpty);
      expect(item.color, isEmpty);
      expect(item.image, isNull);
      expect(item.imageBytes, isNull);
      expect(item.addedAt, isZero);
    });

    test('fromJson decodes base64 imageBytes correctly', () {
      final bytes = Uint8List.fromList([10, 20, 30, 40, 50]);
      final encoded = base64Encode(bytes);

      final item = WardrobeItem.fromJson({
        'id': 'abc',
        'category': 'Pants',
        'color': 'Black',
        'imageBytes': encoded,
        'addedAt': 123,
      });

      expect(item.imageBytes, equals(bytes));
    });

    test('toJson encodes imageBytes to base64', () {
      final bytes = Uint8List.fromList([5, 10, 15]);
      final item = WardrobeItem(
        id: 'x',
        category: 'Shoes',
        color: 'White',
        imageBytes: bytes,
        addedAt: 0,
      );

      final json = item.toJson();
      expect(json['imageBytes'], equals(base64Encode(bytes)));
    });

    test('toJson sets imageBytes to null when absent', () {
      const item = WardrobeItem(
        id: 'y',
        category: 'Hat',
        color: 'Red',
        addedAt: 0,
      );

      expect(item.toJson()['imageBytes'], isNull);
    });

    test('copyWith creates a new instance with replaced fields', () {
      const original = WardrobeItem(
        id: 'orig',
        category: 'Shirts',
        color: 'Blue',
        addedAt: 100,
      );

      final copied = original.copyWith(category: 'Pants', color: 'Black');

      expect(copied.id, equals('orig'));
      expect(copied.category, equals('Pants'));
      expect(copied.color, equals('Black'));
      expect(copied.addedAt, equals(100));
    });

    test('equality is based on id', () {
      const item1 = WardrobeItem(
        id: 'same-id',
        category: 'A',
        color: 'B',
        addedAt: 1,
      );
      const item2 = WardrobeItem(
        id: 'same-id',
        category: 'C',
        color: 'D',
        addedAt: 2,
      );
      const item3 = WardrobeItem(
        id: 'different-id',
        category: 'A',
        color: 'B',
        addedAt: 1,
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
      expect(item1.hashCode, equals(item2.hashCode));
    });
  });

  group('Outfit', () {
    test('fromJson/toJson roundtrip preserves all fields', () {
      const original = Outfit(
        style: 'Casual',
        description: 'A relaxed everyday look.',
        itemIds: ['item-1', 'item-2', 'item-3'],
      );

      final json = original.toJson();
      final restored = Outfit.fromJson(json);

      expect(restored.style, equals(original.style));
      expect(restored.description, equals(original.description));
      expect(restored.itemIds, equals(original.itemIds));
    });

    test('fromJson handles missing fields gracefully', () {
      final outfit = Outfit.fromJson(<String, dynamic>{});

      expect(outfit.style, equals('Outfit'));
      expect(outfit.description, isEmpty);
      expect(outfit.itemIds, isEmpty);
    });

    test('fromJson handles null itemIds', () {
      final outfit = Outfit.fromJson({
        'style': 'Formal',
        'description': 'Business wear',
        'itemIds': null,
      });

      expect(outfit.itemIds, isEmpty);
    });

    test('copyWith creates a new instance with replaced fields', () {
      const original = Outfit(
        style: 'Streetwear',
        description: 'Urban look',
        itemIds: ['a', 'b'],
      );

      final copied = original.copyWith(
        style: 'Formal',
        itemIds: ['c', 'd', 'e'],
      );

      expect(copied.style, equals('Formal'));
      expect(copied.description, equals('Urban look'));
      expect(copied.itemIds, equals(['c', 'd', 'e']));
    });
  });
}
