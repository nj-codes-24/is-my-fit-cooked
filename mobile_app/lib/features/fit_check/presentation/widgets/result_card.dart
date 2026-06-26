/// Reusable result card for AI analysis output.
library;

import 'package:flutter/material.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// Displays a titled list of analysis results in a glass card.
class ResultCard extends StatelessWidget {
  const ResultCard({
    required this.title,
    required this.icon,
    required this.items,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: ${items.length} items',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecorationSmall(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.textDisabled,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
