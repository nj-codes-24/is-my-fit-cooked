import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'screens/fitcheck.dart';
import 'screens/closet.dart';
import 'screens/explore.dart';

final tabProvider = StateProvider<int>((ref) => 0);

class AppLayout extends ConsumerWidget {
  const AppLayout({super.key});

  final List<Widget> _screens = const [
    FitCheckScreen(),
    ClosetScreen(),
    ExploreScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // bg-zinc-950
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            bottom: 80,
            child: _screens[currentIndex],
          ),
          
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0x991C1C1E), // bg-[#1C1C1E]/60
                    border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // pb-safe approx
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildNavItem(ref, currentIndex, 0, LucideIcons.camera, 'FIT CHECK'),
                        _buildNavItem(ref, currentIndex, 1, LucideIcons.layers, 'CLOSET'),
                        _buildNavItem(ref, currentIndex, 2, LucideIcons.compass, 'EXPLORE'),
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

  Widget _buildNavItem(WidgetRef ref, int currentIndex, int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(tabProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white38,
              size: 24,
              shadows: isActive ? [const Shadow(color: Colors.white54, blurRadius: 8)] : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
