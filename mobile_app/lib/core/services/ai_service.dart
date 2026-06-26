/// AI service for outfit analysis and generation via Gemini API.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:is_my_fit_cooked/features/closet/domain/outfit.dart';

/// Provider for the [AIService]. Requires API key via `--dart-define`.
///
/// Build with: `flutter run --dart-define=GEMINI_API_KEY=your_key_here`
final aiServiceProvider = Provider<AIService>((ref) {
  return const AIService();
});

/// Encapsulates all Gemini AI interactions.
///
/// API key is injected at compile time via `--dart-define=GEMINI_API_KEY=...`
/// and is never stored in source code or version control.
class AIService {
  const AIService();

  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );

  static GenerativeModel get _model => GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

  /// Validates that the API key has been provided.
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Analyzes an outfit image and returns structured feedback.
  ///
  /// [imageBytes] must be raw JPEG/PNG bytes (not base64-encoded).
  /// Base64 encoding is performed in a background isolate.
  ///
  /// Returns a map with `feedback` (`List<String>`) and
  /// `upgrades` (`List<String>`).
  ///
  /// Throws [Exception] if the API returns an empty response.
  Future<Map<String, dynamic>> analyzeOutfit(Uint8List imageBytes) async {
    if (!isConfigured) {
      throw Exception(
        'GEMINI_API_KEY not set. '
        'Build with: flutter run --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    // Offload base64 encoding to background isolate for large images.
    final base64Image = await compute(base64Encode, imageBytes);

    const prompt =
        "Act as a high-end personal stylist. Analyze this outfit's "
        'color palette, fit, and style. Provide 3 bullet points of '
        'constructive feedback and suggest 2 smart, actionable upgrades '
        'to elevate the look.';

    final imageParts = [
      DataPart('image/jpeg', base64Decode(base64Image)),
    ];

    final response = await _model.generateContent(
      [
        Content.multi([TextPart(prompt), ...imageParts]),
      ],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'feedback': Schema.array(
              items: Schema.string(),
              description: '3 bullet points of constructive feedback.',
            ),
            'upgrades': Schema.array(
              items: Schema.string(),
              description:
                  '2 smart, actionable upgrades to elevate the look.',
            ),
          },
          requiredProperties: ['feedback', 'upgrades'],
        ),
      ),
    );

    if (response.text != null) {
      return jsonDecode(response.text!) as Map<String, dynamic>;
    }
    throw Exception('Empty response from AI');
  }

  /// Generates outfit combinations from wardrobe item metadata.
  ///
  /// Requires at least 2 items. Returns a list of [Outfit] objects.
  Future<List<Outfit>> generateOutfits(
    List<Map<String, dynamic>> itemsMetadata,
  ) async {
    if (!isConfigured) {
      throw Exception(
        'GEMINI_API_KEY not set. '
        'Build with: flutter run --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final metadataJson = await compute(jsonEncode, itemsMetadata);

    final prompt = 'You are a high-end personal stylist. Based on the '
        "following metadata of the user's clothing items, generate 3 "
        'complete, segregated outfit combinations (e.g., Casual, Formal, '
        'Streetwear) based on color theory and current trends.\n\n'
        "User's Wardrobe Items:\n$metadataJson";

    final response = await _model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'outfits': Schema.array(
              items: Schema.object(
                properties: {
                  'style': Schema.string(
                    description: 'e.g., Casual, Formal, Streetwear',
                  ),
                  'description': Schema.string(
                    description: 'A brief description of the overall look.',
                  ),
                  'itemIds': Schema.array(
                    items: Schema.string(),
                    description:
                        'The IDs of the items used in this outfit.',
                  ),
                },
                requiredProperties: ['style', 'description', 'itemIds'],
              ),
            ),
          },
          requiredProperties: ['outfits'],
        ),
      ),
    );

    if (response.text != null) {
      final decoded = jsonDecode(response.text!) as Map<String, dynamic>;
      final outfitsList = decoded['outfits'] as List<dynamic>;
      return outfitsList
          .map(
            (e) => Outfit.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    throw Exception('Empty response from AI');
  }
}
