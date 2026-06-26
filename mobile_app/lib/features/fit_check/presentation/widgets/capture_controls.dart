/// Camera controls: shutter, timer, upload, switch camera.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// Bottom overlay with camera capture controls.
class CaptureControls extends StatelessWidget {
  const CaptureControls({
    required this.timerSeconds,
    required this.onCapture,
    required this.onUpload,
    required this.onTimerTap,
    required this.onSwitchCamera,
    super.key,
  });

  final int timerSeconds;
  final VoidCallback onCapture;
  final VoidCallback onUpload;
  final VoidCallback onTimerTap;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Timer Control (Top Left)
          Positioned(
            top: 24,
            left: 24,
            child: _CircleButton(
              onTap: onTimerTap,
              semanticLabel: timerSeconds > 0
                  ? 'Timer: $timerSeconds seconds. Tap to change.'
                  : 'Timer off. Tap to enable.',
              child: Center(
                child: timerSeconds > 0
                    ? Text(
                        '${timerSeconds}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(
                        LucideIcons.timer,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),

          // Primary Action Bar (Bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Column: Upload Button
                  _CircleButton(
                    onTap: onUpload,
                    semanticLabel: 'Upload image from gallery',
                    child: const Icon(
                      LucideIcons.upload,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  // Center Column: Shutter Button (Main focal point)
                  Semantics(
                    button: true,
                    label: 'Take photo',
                    child: GestureDetector(
                      onTap: onCapture,
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.textTertiary,
                            width: 3,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right Column: Camera Flip Button
                  _CircleButton(
                    onTap: onSwitchCamera,
                    semanticLabel: 'Switch camera',
                    child: const Icon(
                      LucideIcons.switch_camera,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A 48×48 lp circular button (WCAG minimum touch target) with glassmorphism.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.onTap,
    required this.child,
    required this.semanticLabel,
  });

  final VoidCallback onTap;
  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(color: Colors.white24),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
