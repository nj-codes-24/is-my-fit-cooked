/// Link input overlay for importing items via URL.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// Modal overlay for pasting a product URL.
class LinkInputOverlay extends StatelessWidget {
  const LinkInputOverlay({
    required this.controller,
    required this.onClose,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Semantics(
              label: 'Dismiss dialog',
              child: Container(color: Colors.black45),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width - 48,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xCC1E1E1E),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Import via Link',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Close dialog',
                        child: Tooltip(
                          message: 'Close',
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: AppTheme.minTouchTarget,
                              height: AppTheme.minTouchTarget,
                              decoration: const BoxDecoration(
                                color: Color(0x1AFFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.x,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Paste product URL from any store',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https://...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textDisabled,
                      ),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.glassBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.glassBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Fetch Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
