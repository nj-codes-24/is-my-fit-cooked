/// Domain model for a generated outfit combination.
library;

/// Represents a curated outfit composed of wardrobe items.
class Outfit {
  const Outfit({
    required this.style,
    required this.description,
    required this.itemIds,
  });

  /// Deserializes from a JSON map.
  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      style: json['style'] as String? ?? 'Outfit',
      description: json['description'] as String? ?? '',
      itemIds: List<String>.from(json['itemIds'] as List<dynamic>? ?? []),
    );
  }

  /// The outfit style category (e.g., "Casual", "Formal", "Streetwear").
  final String style;

  /// A brief description of the overall look.
  final String description;

  /// IDs of the wardrobe items composing this outfit.
  final List<String> itemIds;

  /// Creates a copy with the given fields replaced.
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

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'style': style,
      'description': description,
      'itemIds': itemIds,
    };
  }
}
