/// Item detail modal in the closet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/closet/domain/wardrobe_item.dart';

/// Full-screen modal displaying wardrobe item details with delete option.
class ItemDetailsModal extends StatelessWidget {
  const ItemDetailsModal({
    required this.item,
    required this.onClose,
    required this.onDelete,
    required this.imageBuilder,
    super.key,
  });

  final WardrobeItem item;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final Widget Function() imageBuilder;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Semantics(
              label: 'Dismiss item details',
              child: Container(color: Colors.black87),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width - 64,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: Semantics(
                      image: true,
                      label: '${item.category} item photo',
                      child: Stack(
                        children: [
                          Positioned.fill(child: imageBuilder()),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Semantics(
                              button: true,
                              label: 'Close item details',
                              child: Tooltip(
                                message: 'Close',
                                child: GestureDetector(
                                  onTap: onClose,
                                  child: Container(
                                    width: AppTheme.minTouchTarget,
                                    height: AppTheme.minTouchTarget,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.x,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Details
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Added ${DateTime.fromMillisecondsSinceEpoch(item.addedAt).toString().split(' ')[0]}',
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: Semantics(
                            button: true,
                            label: 'Delete ${item.category} from closet',
                            child: ElevatedButton(
                              onPressed: onDelete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red.withValues(alpha: 0.1),
                                foregroundColor: Colors.red,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color:
                                        Colors.red.withValues(alpha: 0.2),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Delete Item',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
          ),
        ],
      ),
    );
  }
}
