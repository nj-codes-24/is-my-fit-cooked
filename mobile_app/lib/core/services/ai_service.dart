/// AI service for outfit analysis and generation via OpenAI-compatible REST API.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:is_my_fit_cooked/features/closet/domain/outfit.dart';

/// Provider for the [AIService]. Requires API key via `--dart-define`.
///
/// Build with: `flutter run --dart-define=AI_API_KEY=your_key_here`
final aiServiceProvider = Provider<AIService>((ref) {
  return const AIService();
});

/// Encapsulates AI interactions using standard OpenAI chat completions format.
///
/// Configuration is injected at compile time via `--dart-define`.
/// This allows plugging in any open-source provider (Groq, OpenRouter, etc.).
class AIService {
  const AIService();

  static const String _apiKey = String.fromEnvironment('AI_API_KEY');
  static const String _baseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://api.groq.com/openai/v1',
  );
  static const String _modelName = String.fromEnvironment(
    'AI_MODEL_NAME',
    defaultValue: 'llama-3.2-90b-vision-preview',
  );

  /// Validates that the API key has been provided.
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Analyzes an outfit image and returns structured feedback.
  ///
  /// Uses OpenAI vision payload format `data:image/jpeg;base64,...`.
  /// Returns a map with `feedback` (`List<String>`) and `upgrades` (`List<String>`).
  Future<Map<String, dynamic>> analyzeOutfit(Uint8List imageBytes) async {
    if (!isConfigured) {
      throw Exception(
        'AI_API_KEY not set. '
        'Build with: flutter run --dart-define=AI_API_KEY=your_key',
      );
    }

    // Offload base64 encoding to background isolate for large images.
    final base64Image = await compute(base64Encode, imageBytes);
    final dataUri = 'data:image/jpeg;base64,$base64Image';

    const systemPrompt =
        'You are a high-end personal stylist. Analyze the provided outfit image. '
        'You MUST respond with a raw JSON object containing exactly two keys: '
        '"feedback" (an array of 3 string bullet points with constructive feedback) '
        'and "upgrades" (an array of 2 smart, actionable string upgrades).';

    final payload = {
      'model': _modelName,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {
                'url': dataUri,
              },
            }
          ],
        },
      ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('AI API Error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Empty response from AI');
    }

    final firstChoice = choices.first as Map<String, dynamic>;
    final message = firstChoice['message'] as Map<String, dynamic>;
    final content = message['content'] as String?;
    
    if (content == null) {
      throw Exception('Empty content from AI');
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// Generates outfit combinations from wardrobe item metadata.
  ///
  /// Requires at least 2 items. Returns a list of [Outfit] objects.
  Future<List<Outfit>> generateOutfits(
    List<Map<String, dynamic>> itemsMetadata,
  ) async {
    if (!isConfigured) {
      throw Exception(
        'AI_API_KEY not set. '
        'Build with: flutter run --dart-define=AI_API_KEY=your_key',
      );
    }

    final metadataJson = await compute(jsonEncode, itemsMetadata);

    const systemPrompt =
        'You are a high-end personal stylist. You will be provided with JSON '
        "metadata of the user's wardrobe items. You MUST respond with a raw JSON "
        'object containing a single key "outfits". The value of "outfits" must be '
        'an array of exactly 3 objects. Each object must have "style" (string, e.g. Casual), '
        '"description" (string), and "itemIds" (an array of string IDs representing the items used).';

    final payload = {
      'model': _modelName,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': metadataJson,
        },
      ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('AI API Error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Empty response from AI');
    }

    final firstChoice = choices.first as Map<String, dynamic>;
    final message = firstChoice['message'] as Map<String, dynamic>;
    final content = message['content'] as String?;
    
    if (content == null) {
      throw Exception('Empty content from AI');
    }

    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final outfitsList = decoded['outfits'] as List<dynamic>;
    
    return outfitsList
        .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
