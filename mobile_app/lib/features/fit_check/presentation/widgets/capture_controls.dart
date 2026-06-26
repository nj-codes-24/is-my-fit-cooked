/// Camera controls: shutter, timer, upload, switch camera.
library;

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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0x99000000),
              Color(0x33000000),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Upload button
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _CircleButton(
                  onTap: onUpload,
                  semanticLabel: 'Upload image from gallery',
                  child: const Icon(
                    LucideIcons.upload,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Shutter button
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

            // Timer + Switch camera
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CircleButton(
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
                  const SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }
}

/// A 48×48 lp circular button (WCAG minimum touch target).
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
          child: Container(
            width: AppTheme.minTouchTarget,
            height: AppTheme.minTouchTarget,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: Colors.white24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
