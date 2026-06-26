/// Popover menu for adding items to closet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// Floating popover with Camera / Gallery / Link options.
class ClosetPopover extends StatelessWidget {
  const ClosetPopover({
    required this.onClose,
    required this.onCamera,
    required this.onGallery,
    required this.onLink,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Dismiss scrim
          GestureDetector(
            onTap: onClose,
            child: Semantics(
              label: 'Dismiss menu',
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: 96,
            right: 24,
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              decoration: AppTheme.glassDecoration,
              child: Column(
                children: [
                  _PopoverOption(
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    icon: LucideIcons.camera,
                    onTap: onCamera,
                  ),
                  _divider(),
                  _PopoverOption(
                    title: 'Import Link',
                    subtitle: 'Paste a store URL',
                    icon: LucideIcons.link_2,
                    onTap: onLink,
                  ),
                  _divider(),
                  _PopoverOption(
                    title: 'Gallery',
                    subtitle: 'Choose from photos',
                    icon: LucideIcons.image,
                    onTap: onGallery,
                  ),
                ],
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  alignment: Alignment.topRight,
                )
                .fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(
          color: AppTheme.glassBorder,
          height: 1,
        ),
      );
}

class _PopoverOption extends StatelessWidget {
  const _PopoverOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppTheme.minTouchTarget,
          child: Row(
            children: [
              Container(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevron_right,
                color: AppTheme.textDisabled,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
