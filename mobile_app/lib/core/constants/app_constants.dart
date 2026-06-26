/// App-wide constants for storage keys, sizing, and configuration.
library;

/// Storage and configuration constants.
abstract final class AppConstants {
  /// Encrypted storage key for wardrobe data.
  static const String wardrobeStorageKey = 'wardrobe_storage_v3';

  /// Minimum number of wardrobe items needed to generate outfits.
  static const int minItemsForOutfitGeneration = 2;

  /// Timer increment options (seconds).
  static const List<int> timerOptions = [0, 3, 5, 10];
}
