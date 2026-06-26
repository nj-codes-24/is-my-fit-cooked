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
    defaultValue: 'https://openrouter.ai/api/v1',
  );

  /// Validates that the API key has been provided.
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Analyzes an outfit image and returns structured feedback.
  ///
  /// Uses OpenAI vision payload format with a public image URL.
  /// Returns a map with `feedback` (`List<String>`) and `upgrades` (`List<String>`).
  Future<Map<String, dynamic>> analyzeOutfit(String imageUrl) async {
    if (!isConfigured) {
      throw Exception(
        'AI_API_KEY not set. '
        'Build with: flutter run --dart-define=AI_API_KEY=your_key',
      );
    }

    const systemPrompt =
        'You are a high-end personal stylist. Analyze the provided outfit image. '
        'You MUST respond with a raw JSON object containing exactly two keys: '
        '"feedback" (an array of 3 string bullet points with constructive feedback) '
        'and "upgrades" (an array of 2 smart, actionable string upgrades).';

    final payload = {
      'models': [
        'google/gemma-4-31b-it:free',
        'nvidia/nemotron-nano-12b-v2-vl:free',
        'openrouter/free',
      ],
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
                'url': imageUrl,
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
      debugPrint('AI API Error: HTTP ${response.statusCode}');
      throw Exception('Failed to connect to the styling service. Please try again later.');
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

  /// Extracts tags (color, style, category) from an image URL.
  Future<Map<String, dynamic>> extractTags(String imageUrl) async {
    if (!isConfigured) {
      throw Exception('AI_API_KEY not set.');
    }

    const systemPrompt =
        'You are a high-end personal stylist. Analyze the provided clothing item image. '
        'You MUST respond with a raw JSON object containing exactly two string keys: '
        '"color" (e.g. Navy Blue) and "category" (e.g. Shirt, Pants).';

    final payload = {
      'models': [
        'google/gemma-4-31b-it:free',
        'nvidia/nemotron-nano-12b-v2-vl:free',
        'openrouter/free',
      ],
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
                'url': imageUrl,
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
      debugPrint('AI API Error: HTTP ${response.statusCode}');
      throw Exception('Failed to connect to the styling service. Please try again later.');
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
      'models': [
        'openai/gpt-oss-120b:free',
        'meta-llama/llama-3.3-70b-instruct:free',
        'qwen/qwen3-coder:free',
        'openrouter/free',
      ],
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
      debugPrint('AI API Error: HTTP ${response.statusCode}');
      throw Exception('Failed to connect to the styling service. Please try again later.');
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
