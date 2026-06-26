library;

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/core/services/ai_service.dart';
import 'package:is_my_fit_cooked/core/services/storage_service.dart';
import 'package:is_my_fit_cooked/features/closet/providers/wardrobe_provider.dart';

class ExploreState {
  final bool isLoadingGaps;
  final String? gapMessage;
  final List<Map<String, dynamic>> recommendations;

  final bool isValidating;
  final Map<String, dynamic>? validationResult;
  final String? validationError;

  ExploreState({
    this.isLoadingGaps = false,
    this.gapMessage,
    this.recommendations = const [],
    this.isValidating = false,
    this.validationResult,
    this.validationError,
  });

  ExploreState copyWith({
    bool? isLoadingGaps,
    String? gapMessage,
    List<Map<String, dynamic>>? recommendations,
    bool? isValidating,
    Map<String, dynamic>? validationResult,
    String? validationError,
    bool clearValidation = false,
  }) {
    return ExploreState(
      isLoadingGaps: isLoadingGaps ?? this.isLoadingGaps,
      gapMessage: gapMessage ?? this.gapMessage,
      recommendations: recommendations ?? this.recommendations,
      isValidating: isValidating ?? this.isValidating,
      validationResult: clearValidation ? null : (validationResult ?? this.validationResult),
      validationError: clearValidation ? null : (validationError ?? this.validationError),
    );
  }
}

final exploreProvider = NotifierProvider<ExploreNotifier, ExploreState>(ExploreNotifier.new);

class ExploreNotifier extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    // Initial fetch
    Future.microtask(_analyzeGaps);
    return ExploreState();
  }

  Future<void> _analyzeGaps() async {
    state = state.copyWith(isLoadingGaps: true);
    try {
      await Future<void>.delayed(const Duration(seconds: 1)); // Mock network delay
      
      final mockResult = {
        'message': 'You have great monochrome basics! Let\'s add some statement pieces and layers to elevate your everyday looks.',
        'recommendations': [
          {
            'name': 'Beige Trench Coat',
            'reason': 'A classic trench will perfectly break up your all-black outfits and add instant sophistication to your jeans.',
            'searchQuery': 'beige classic trench coat',
          },
          {
            'name': 'Silver Chain Necklace',
            'reason': 'Since you wear simple solid t-shirts, a subtle silver chain adds a much-needed focal point.',
            'searchQuery': 'minimalist silver chain necklace',
          },
          {
            'name': 'Chunky Loafers',
            'reason': 'You have standard sneakers. Chunky loafers will easily dress up your blue denim for smart-casual events.',
            'searchQuery': 'black leather chunky loafers',
          },
        ]
      };

      state = state.copyWith(
        isLoadingGaps: false,
        gapMessage: mockResult['message'] as String?,
        recommendations: List<Map<String, dynamic>>.from(mockResult['recommendations'] as List),
      );
    } catch (e) {
      debugPrint('Gap analysis failed: $e');
      state = state.copyWith(isLoadingGaps: false);
    }
  }

  /// Validates a potential purchase by uploading the image and asking the AI.
  Future<void> validatePurchase(Uint8List imageBytes) async {
    state = state.copyWith(isValidating: true, clearValidation: true);
    
    try {
      await Future<void>.delayed(const Duration(seconds: 3)); // Mock network delay

      final mockVerdict = {
        'verdict': 'SKIP',
        'reason': 'You already have 2 black t-shirts in your closet! Unless this one is completely worn out, you don\'t need another basic black shirt.',
        'outfitIdea': 'If you really want to buy it, style it exactly like your other black shirts: tucked into your Blue Denim pants with your White shoes.',
      };

      state = state.copyWith(
        isValidating: false,
        validationResult: mockVerdict,
      );
    } catch (e) {
      debugPrint('Purchase validation failed: $e');
      state = state.copyWith(
        isValidating: false,
        validationError: 'Failed to validate purchase. Please try again.',
      );
    }
  }

  void clearValidation() {
    state = state.copyWith(clearValidation: true);
  }

  void refreshGaps() {
    _analyzeGaps();
  }
}
