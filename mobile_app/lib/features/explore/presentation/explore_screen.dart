/// Explore screen — curated fashion deals and brand spotlights.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/explore/domain/explore_data.dart';
import 'package:is_my_fit_cooked/features/explore/presentation/widgets/spotlight_card.dart';
import 'package:is_my_fit_cooked/features/explore/presentation/widgets/trending_deal_card.dart';

/// Explore screen with curated deals and brand spotlights.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Curated fashion & offers',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Trending Deals
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.flame,
                            color: Colors.orange,
                            size: 18,
                            semanticLabel: 'Trending',
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Trending Deals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 210,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: trendingDeals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 16),
                        itemBuilder: (_, index) => TrendingDealCard(
                          deal: trendingDeals[index],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Brand Spotlights
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        ExcludeSemantics(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.textDisabled,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(width: 6, height: 6),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Brand Spotlight',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...spotlights
                        .map(
                          (spotlight) =>
                              SpotlightCard(spotlight: spotlight),
                        )
                        ,
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
