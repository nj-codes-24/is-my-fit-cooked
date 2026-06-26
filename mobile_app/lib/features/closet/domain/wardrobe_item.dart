/// Domain model for a single clothing item in the wardrobe.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Immutable representation of a wardrobe item.
///
/// Supports both local image bytes and remote URLs for display.
@immutable
class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.category,
    required this.color,
    required this.addedAt,
    this.image,
    this.imageBytes,
  });

  /// Deserializes from a JSON map.
  ///
  /// Gracefully handles missing or malformed fields with defaults.
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      image: json['image'] as String?,
      imageBytes: json['imageBytes'] != null
          ? base64Decode(json['imageBytes'] as String)
          : null,
      addedAt: json['addedAt'] as int? ?? 0,
    );
  }

  final String id;
  final String category;
  final String color;

  /// Remote URL for the item image (legacy or web).
  final String? image;

  /// Local image data as raw bytes.
  final Uint8List? imageBytes;

  /// Timestamp (milliseconds since epoch) when item was added.
  final int addedAt;

  /// Creates a copy with the given fields replaced.
  WardrobeItem copyWith({
    String? id,
    String? category,
    String? color,
    String? image,
    Uint8List? imageBytes,
    int? addedAt,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      category: category ?? this.category,
      color: color ?? this.color,
      image: image ?? this.image,
      imageBytes: imageBytes ?? this.imageBytes,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Serializes to a JSON-compatible map.
  ///
  /// Image bytes are base64-encoded for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'color': color,
      'image': image,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'addedAt': addedAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
