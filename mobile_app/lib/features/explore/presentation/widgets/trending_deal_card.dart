/// Trending deal card widget for the Explore feature.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// A horizontally-scrollable deal card with background image.
class TrendingDealCard extends StatelessWidget {
  const TrendingDealCard({required this.deal, super.key});

  final Map<String, dynamic> deal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${deal['brand']} deal: ${deal['offer']}',
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: deal['image'] as String,
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
              // Gradient overlay (decorative)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (deal['brand'] as String).toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        letterSpacing: 2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal['offer'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.2,
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
