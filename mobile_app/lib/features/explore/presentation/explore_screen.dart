library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/closet/presentation/widgets/closet_popover.dart';
import 'package:is_my_fit_cooked/features/explore/providers/explore_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _showPopover = false;
  bool _isUploading = false;

  Future<void> _handleImageSource(ImageSource source) async {
    setState(() {
      _showPopover = false;
      _isUploading = true;
    });

    try {
      final file = await _picker.pickImage(source: source);
      if (file != null) {
        final bytes = await file.readAsBytes();
        await ref.read(exploreProvider.notifier).validatePurchase(bytes);
        _showValidationVerdict();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load image.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showValidationVerdict() {
    final state = ref.read(exploreProvider);
    if (state.validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.validationError!)),
      );
      return;
    }

    if (state.validationResult != null) {
      final verdict = state.validationResult!['verdict'] as String? ?? 'MAYBE';
      final reason = state.validationResult!['reason'] as String? ?? '';
      final idea = state.validationResult!['outfitIdea'] as String? ?? '';

      Color verdictColor;
      if (verdict.toUpperCase() == 'BUY') {
        verdictColor = Colors.greenAccent;
      } else if (verdict.toUpperCase() == 'SKIP') {
        verdictColor = Colors.redAccent;
      } else {
        verdictColor = Colors.orangeAccent;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            verdict.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: verdictColor,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.glassBorder),
              const SizedBox(height: 16),
              const Text(
                'Styling Idea',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                idea,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(exploreProvider.notifier).clearValidation();
                Navigator.pop(ctx);
              },
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _launchGoogleShopping(String query) async {
    final url = Uri.parse('https://www.google.com/search?tbm=shop&q=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch browser')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.read(exploreProvider.notifier).refreshGaps();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete Your Closet',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (state.gapMessage != null)
                            Text(
                              state.gapMessage!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoadingGaps)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.textTertiary),
                      ),
                    )
                  else if (state.recommendations.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.shopping_bag, size: 48, color: AppTheme.textDisabled),
                            const SizedBox(height: 16),
                            const Text(
                              'Your closet looks solid!',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => ref.read(exploreProvider.notifier).refreshGaps(),
                              child: const Text('Refresh Analysis'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final rec = state.recommendations[index];
                            return _RecommendationCard(
                              name: rec['name'] as String? ?? 'Suggested Item',
                              reason: rec['reason'] as String? ?? '',
                              onTapShop: () => _launchGoogleShopping(rec['searchQuery'] as String? ?? rec['name'] as String),
                            );
                          },
                          childCount: state.recommendations.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            
            if (_isUploading || state.isValidating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 24),
                        Text(
                          'Validating purchase...',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Checking your closet for matches',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_showPopover)
              ClosetPopover(
                onClose: () => setState(() => _showPopover = false),
                onCamera: () => _handleImageSource(ImageSource.camera),
                onGallery: () => _handleImageSource(ImageSource.gallery),
                onLink: () {
                  setState(() => _showPopover = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link import not supported for purchase validation yet.')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.name,
    required this.reason,
    required this.onTapShop,
  });

  final String name;
  final String reason;
  final VoidCallback onTapShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.sparkles, color: Colors.orangeAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reason,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTapShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent.withValues(alpha: 0.15),
                foregroundColor: Colors.indigoAccent.shade100,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.indigoAccent.withValues(alpha: 0.2)),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(LucideIcons.external_link, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
