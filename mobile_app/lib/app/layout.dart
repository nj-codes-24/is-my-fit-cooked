/// App shell layout with glassmorphic bottom navigation.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/closet/presentation/closet_screen.dart';
import 'package:is_my_fit_cooked/features/explore/presentation/explore_screen.dart';
import 'package:is_my_fit_cooked/features/fit_check/presentation/fit_check_screen.dart';

/// Current tab index provider.
final tabProvider = StateProvider<int>((ref) => 0);

/// Root layout widget with [IndexedStack] tab persistence and
/// glassmorphic bottom navigation respecting safe areas.
class AppLayout extends ConsumerWidget {
  const AppLayout({super.key});

  static const _screens = [
    FitCheckScreen(),
    ClosetScreen(),
    ExploreScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabProvider);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    /// iOS industry-standard tab bar height.
    const double navActiveHeight = 44;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // IndexedStack preserves state across tabs.
          Positioned.fill(
            bottom: navActiveHeight + bottomPadding,
            child: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
          ),

          // Glassmorphic bottom navigation — strictly 60px usable area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: navActiveHeight + bottomPadding,
                  decoration: const BoxDecoration(
                    color: Color(0x991C1C1E),
                    border: Border(
                      top: BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  // Safe-area inset as padding, not height inflation
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _NavItem(
                        ref: ref,
                        currentIndex: currentIndex,
                        index: 0,
                        icon: LucideIcons.camera,
                        label: 'FIT CHECK',
                      ),
                      _NavItem(
                        ref: ref,
                        currentIndex: currentIndex,
                        index: 1,
                        icon: LucideIcons.layers,
                        label: 'CLOSET',
                      ),
                      _NavItem(
                        ref: ref,
                        currentIndex: currentIndex,
                        index: 2,
                        icon: LucideIcons.compass,
                        label: 'EXPLORE',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.ref,
    required this.currentIndex,
    required this.index,
    required this.icon,
    required this.label,
  });

  final WidgetRef ref;
  final int currentIndex;
  final int index;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return Semantics(
      button: true,
      selected: isActive,
      label: '$label tab',
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: () => ref.read(tabProvider.notifier).state = index,
          behavior: HitTestBehavior.opaque,
          // Zero extra vertical margin — icon wrapper is display:flex + center
          child: SizedBox(
            width: 64,
            height: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  size: 22,
                  shadows: isActive
                      ? const [
                          Shadow(
                            color: AppTheme.textTertiary,
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
