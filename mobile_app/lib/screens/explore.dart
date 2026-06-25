import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

final _trendingDeals = [
  {
    'id': 1,
    'brand': 'Acne Studios',
    'offer': 'Archive Sale — Up to 40% Off',
    'image': 'https://images.unsplash.com/photo-1550614000-4b95d4ed798a?q=80&w=2000&auto=format&fit=crop',
  },
  {
    'id': 2,
    'brand': 'SSENSE',
    'offer': 'Private Sale unlocked for you',
    'image': 'https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=2000&auto=format&fit=crop',
  }
];

final _spotlights = [
  {
    'id': 1,
    'brand': 'Aime Leon Dore',
    'title': 'Uniform Essentials II',
    'description': 'The new collection redefining everyday luxury.',
    'image': 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=2000&auto=format&fit=crop',
  },
  {
    'id': 2,
    'brand': 'Salomon',
    'title': 'XT-6 Advanced',
    'description': 'Trail running heritage meets modern aesthetic.',
    'image': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?q=80&w=2000&auto=format&fit=crop',
  }
];

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Curated fashion & offers',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Trending Deals
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.flame, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Trending Deals',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 210, // ~ 280 aspect 4/3
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _trendingDeals.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final deal = _trendingDeals[index];
                        return _buildTrendingDeal(deal);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Brand Spotlights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Brand Spotlight',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._spotlights.map((spotlight) => _buildSpotlight(spotlight)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingDeal(Map<String, dynamic> deal) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: deal['image'] as String,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
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
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      letterSpacing: 2,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal['offer'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlight(Map<String, dynamic> spotlight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        decoration: AppTheme.glassDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: spotlight['image'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(LucideIcons.heart, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (spotlight['brand'] as String).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      Icon(LucideIcons.arrow_up_right, color: Colors.white.withOpacity(0.4), size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spotlight['title'] as String,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spotlight['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
