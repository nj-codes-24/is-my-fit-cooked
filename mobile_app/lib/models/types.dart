import 'dart:convert';
import 'dart:typed_data';

class WardrobeItem {
  final String id;
  final String category;
  final String color;
  final String? image; // legacy or web url
  final Uint8List? imageBytes; // base64 encoded bytes
  final int addedAt;

  const WardrobeItem({
    required this.id,
    required this.category,
    required this.color,
    this.image,
    this.imageBytes,
    required this.addedAt,
  });

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

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      image: json['image'] as String?,
      imageBytes: json['imageBytes'] != null ? base64Decode(json['imageBytes'] as String) : null,
      addedAt: json['addedAt'] as int? ?? 0,
    );
  }
}

class Outfit {
  final String style;
  final String description;
  final List<String> itemIds;

  const Outfit({
    required this.style,
    required this.description,
    required this.itemIds,
  });

  Outfit copyWith({
    String? style,
    String? description,
    List<String>? itemIds,
  }) {
    return Outfit(
      style: style ?? this.style,
      description: description ?? this.description,
      itemIds: itemIds ?? this.itemIds,
    );
  }

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      style: json['style'] as String? ?? 'Outfit',
      description: json['description'] as String? ?? '',
      itemIds: List<String>.from(json['itemIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style': style,
      'description': description,
      'itemIds': itemIds,
    };
  }
}
