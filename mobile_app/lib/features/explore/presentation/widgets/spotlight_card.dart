/// Brand spotlight card widget for the Explore feature.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// A full-width spotlight card for brand features.
class SpotlightCard extends StatelessWidget {
  const SpotlightCard({required this.spotlight, super.key});

  final Map<String, dynamic> spotlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Semantics(
        label: '${spotlight['brand']} spotlight: ${spotlight['title']}',
        child: Container(
          decoration: AppTheme.glassDecoration,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: spotlight['image'] as String,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                          color: AppTheme.surfaceElevated,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: AppTheme.surfaceElevated,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppTheme.textTertiary,
                              semanticLabel: 'Image failed to load',
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Semantics(
                        button: true,
                        label:
                            'Save ${spotlight['brand']} to favorites',
                        child: Tooltip(
                          message: 'Save to favorites',
                          child: Container(
                            width: AppTheme.minTouchTarget,
                            height: AppTheme.minTouchTarget,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.glassBorder,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.heart,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (spotlight['brand'] as String).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            letterSpacing: 2,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const ExcludeSemantics(
                          child: Icon(
                            LucideIcons.arrow_up_right,
                            color: AppTheme.textDisabled,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spotlight['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spotlight['description'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
