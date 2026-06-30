import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

class OutfitDetailsModal extends StatelessWidget {
  const OutfitDetailsModal({
    required this.images,
    required this.onClose,
    super.key,
  });

  final List<String> images;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Semantics(
              label: 'Dismiss outfit details',
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.7)),
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width - 64,
              height: MediaQuery.sizeOf(context).height * 0.85,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: images.asMap().entries.map((entry) {
                      final isLast = entry.key == images.length - 1;
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: isLast ? null : const Border(
                              bottom: BorderSide(
                                color: AppTheme.glassBorder,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Image.network(
                            entry.value,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Semantics(
                      button: true,
                      label: 'Close outfit details',
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
            ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
          ),
        ],
      ),
    );
  }
}
