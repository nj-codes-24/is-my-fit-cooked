/// FitCheck screen — camera capture and AI outfit analysis.
library;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/fit_check/presentation/widgets/capture_controls.dart';
import 'package:is_my_fit_cooked/features/fit_check/presentation/widgets/result_card.dart';
import 'package:is_my_fit_cooked/features/fit_check/providers/fit_check_provider.dart';

/// Main screen for the FitCheck feature.
///
/// Pure presentation — all business logic lives in [FitCheckNotifier].
class FitCheckScreen extends ConsumerWidget {
  const FitCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitCheckProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          if (!state.hasImage)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Semantics(
                header: true,
                child: const Text(
                  'fit check',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Offstage(
                  offstage: state.hasImage,
                  child: _CameraView(state: state, ref: ref),
                ),
                if (state.hasImage)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppTheme.background,
                      child: _PostCaptureView(state: state, ref: ref),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView({required this.state, required this.ref});

  final FitCheckState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(fitCheckProvider.notifier);
    final controller = notifier.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: AppTheme.surfaceElevated,
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Camera preview
            if (state.isCameraInitialized && controller != null)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: kIsWeb
                        ? (controller.value.previewSize?.width ?? 640)
                        : (controller.value.previewSize?.height ?? 1),
                    height: kIsWeb
                        ? (controller.value.previewSize?.height ?? 480)
                        : (controller.value.previewSize?.width ?? 1),
                    child: CameraPreview(controller),
                  ),
                ),
              )
            else if (state.cameraError)
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.camera_off,
                          color: AppTheme.textTertiary,
                          size: 48,
                          semanticLabel: 'Camera unavailable',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera Unavailable',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.cameraErrorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Countdown overlay
            if (state.countdown != null)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: Center(
                    child: Text(
                      '${state.countdown}',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 20),
                        ],
                      ),
                    )
                        .animate(key: ValueKey(state.countdown))
                        .scale(begin: const Offset(0.5, 0.5))
                        .fadeIn(),
                  ),
                ),
              ),

            // Controls
            CaptureControls(
              timerSeconds: state.timerSeconds,
              onCapture: notifier.handleCapture,
              onUpload: notifier.pickFromGallery,
              onTimerTap: notifier.cycleTimer,
              onSwitchCamera: () async => notifier.switchCamera(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _PostCaptureView extends StatelessWidget {
  const _PostCaptureView({required this.state, required this.ref});

  final FitCheckState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(fitCheckProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: 'Go back to camera',
                child: Tooltip(
                  message: 'Retake photo',
                  child: GestureDetector(
                    onTap: notifier.retake,
                    child: Container(
                      width: AppTheme.minTouchTarget,
                      height: AppTheme.minTouchTarget,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        LucideIcons.chevron_left,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Captured image
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: state.result != null ? 220 : screenWidth - 32,
            height: state.result != null
                ? 220
                : (screenWidth - 32) * 16 / 9,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(state.result != null ? 24 : 32),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: state.imageBytes != null
                ? Semantics(
                    image: true,
                    label: 'Captured outfit photo',
                    child: Image.memory(
                      state.imageBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.image_off,
                              color: AppTheme.textTertiary,
                              size: 48,
                              semanticLabel: 'Image failed to load',
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image preview',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // Analyze button
          if (state.result == null && !state.isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Semantics(
                button: true,
                label: 'Analyze outfit with AI',
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await notifier.analyzeOutfit();
                    } on Exception catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to analyze outfit. Check API key.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(220, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.sparkles, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Analyze Outfit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading state
          if (state.isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.activity,
                    color: Colors.white,
                    size: 32,
                    semanticLabel: 'Analyzing',
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3),
                  const SizedBox(height: 16),
                  const Text(
                    'Stylist is thinking...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3),
                ],
              ),
            ),

          // Results
          if (state.result != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                children: [
                  ResultCard(
                    title: 'Style Analysis',
                    icon: LucideIcons.layers,
                    items: List<String>.from(
                      state.result!['feedback'] as List<dynamic>,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ResultCard(
                    title: 'Smart Upgrades',
                    icon: LucideIcons.sparkles,
                    items: List<String>.from(
                      state.result!['upgrades'] as List<dynamic>,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }
}
