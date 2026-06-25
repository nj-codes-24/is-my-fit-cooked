import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/types.dart';

class AIService {
  // Ideally this should come from flutter_dotenv or env vars
  static const String _apiKey = 'API_KEY';
  
  static final _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
  );

  static Future<Map<String, dynamic>> analyzeOutfit(String base64Image) async {
    try {
      const prompt = 'Act as a high-end personal stylist. Analyze this outfit\'s color palette, fit, and style. Provide 3 bullet points of constructive feedback and suggest 2 smart, actionable upgrades to elevate the look.';
      
      final imageParts = [
        DataPart('image/jpeg', base64Decode(base64Image)),
      ];

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), ...imageParts])
      ], generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'feedback': Schema.array(items: Schema.string(), description: "3 bullet points of constructive feedback."),
            'upgrades': Schema.array(items: Schema.string(), description: "2 smart, actionable upgrades to elevate the look."),
          },
          requiredProperties: ['feedback', 'upgrades']
        ),
      ));

      if (response.text != null) {
        return jsonDecode(response.text!) as Map<String, dynamic>;
      }
      throw Exception('Empty response from AI');
    } catch (e) {
      debugPrint('Error in analyzeOutfit: \$e');
      rethrow;
    }
  }

  static Future<List<Outfit>> generateOutfits(List<WardrobeItem> items) async {
    try {
      final itemsMetadata = items.map((i) => {'id': i.id, 'category': i.category, 'color': i.color}).toList();
      
      final prompt = '''You are a high-end personal stylist. Based on the following metadata of the user's clothing items, generate 3 complete, segregated outfit combinations (e.g., Casual, Formal, Streetwear) based on color theory and current trends.
      
      User's Wardrobe Items:
      ${jsonEncode(itemsMetadata)}
      ''';

      final response = await _model.generateContent([
        Content.text(prompt)
      ], generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'outfits': Schema.array(
              items: Schema.object(
                properties: {
                  'style': Schema.string(description: "e.g., Casual, Formal, Streetwear"),
                  'description': Schema.string(description: "A brief description of the overall look."),
                  'itemIds': Schema.array(items: Schema.string(), description: "The IDs of the items used in this outfit.")
                },
                requiredProperties: ['style', 'description', 'itemIds']
              )
            )
          },
          requiredProperties: ['outfits']
        ),
      ));

      if (response.text != null) {
        final decoded = jsonDecode(response.text!) as Map<String, dynamic>;
        final outfitsList = decoded['outfits'] as List;
        return outfitsList.map((e) => Outfit.fromJson(e)).toList();
      }
      throw Exception('Empty response from AI');
    } catch (e) {
      debugPrint('Error in generateOutfits: \$e');
      rethrow;
    }
  }
}
