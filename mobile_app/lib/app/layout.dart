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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // IndexedStack preserves state across tabs.
          Positioned.fill(
            bottom: 64 + bottomPadding,
            child: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
          ),

          // Glassmorphic bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64 + bottomPadding,
                  decoration: const BoxDecoration(
                    color: Color(0x991C1C1E),
                    border: Border(
                      top: BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  size: 24,
                  shadows: isActive
                      ? const [
                          Shadow(
                            color: AppTheme.textTertiary,
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
