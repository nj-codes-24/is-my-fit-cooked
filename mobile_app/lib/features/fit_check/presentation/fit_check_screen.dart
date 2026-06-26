/// FitCheck screen — camera capture and AI outfit analysis.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/core/theme/app_theme.dart';
import 'package:is_my_fit_cooked/features/fit_check/presentation/widgets/capture_controls.dart';
import 'package:is_my_fit_cooked/features/fit_check/providers/fit_check_provider.dart';

/// Main screen for the FitCheck feature.
///
/// Pure presentation — all business logic lives in [FitCheckNotifier].
class FitCheckScreen extends ConsumerWidget {
  const FitCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fitCheckProvider);

    // When an image is captured/uploaded, show the full-screen post-capture
    // overlay. Otherwise, show the camera layout.
    if (state.hasImage) {
      return _PostCaptureView(state: state, ref: ref);
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Spacer(),
          Semantics(
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
          const Spacer(),
          Expanded(
            flex: 14,
            child: _CameraView(state: state, ref: ref),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera View
// ---------------------------------------------------------------------------

class _CameraView extends StatelessWidget {
  const _CameraView({required this.state, required this.ref});

  final FitCheckState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(fitCheckProvider.notifier);
    final controller = notifier.controller;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.70),
          child: AspectRatio(
            aspectRatio: 9 / 16,
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
                  // Camera preview (live)
                  if (state.isCameraActive &&
                      state.isCameraInitialized &&
                      controller != null)
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
                  // Dormant state — camera not yet activated
                  else if (!state.isCameraActive && !state.cameraError)
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.camera,
                                color: AppTheme.textTertiary.withOpacity(0.5),
                                size: 56,
                                semanticLabel: 'Camera dormant',
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Activate camera by pressing\nthe shutter button',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      AppTheme.textTertiary.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Error state
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
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

// ---------------------------------------------------------------------------
// Post-Capture View — Siri AI-inspired overlay
// ---------------------------------------------------------------------------

class _PostCaptureView extends ConsumerStatefulWidget {
  const _PostCaptureView({required this.state, required this.ref});

  final FitCheckState state;
  final WidgetRef ref;

  @override
  ConsumerState<_PostCaptureView> createState() => _PostCaptureViewState();
}

class _PostCaptureViewState extends ConsumerState<_PostCaptureView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.ref.read(fitCheckProvider.notifier);
    final state = widget.state;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final hasResult = state.result != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable content (only active/used when there are results)
            SingleChildScrollView(
              controller: _scrollController,
              physics: hasResult
                  ? const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics())
                  : const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.viewPaddingOf(context).top -
                      MediaQuery.viewPaddingOf(context).bottom,
                  minWidth: screenWidth,
                ),
                child: Column(
                  mainAxisAlignment: hasResult
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!hasResult) ...[
                      // Pre-analysis: centered photo + analyze button
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _Photo(
                            imageBytes: state.imageBytes,
                            width: screenWidth * 0.75,
                            height: screenWidth * 0.75 * 16 / 9,
                            maxHeight: screenHeight * 0.60,
                            borderRadius: 32,
                          ),
                          // Overlay loading animation when analyzing
                          if (state.isAnalyzing)
                            Positioned.fill(
                              child: _GeminiMeshLoader(
                                borderRadius: 32,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Analyze button (hides when analyzing)
                      if (!state.isAnalyzing)
                        _AnalyzeButton(notifier: notifier),
                      
                      // Extra padding to balance vertical centering
                      const SizedBox(height: 40),
                    ],

                    if (hasResult) ...[
                      const SizedBox(height: 60), // Space for top padding

                      // Post-analysis: dynamic photo expansion + AI results
                      AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          // Calculate overscroll (negative offset)
                          final offset = _scrollController.hasClients
                              ? _scrollController.offset
                              : 0.0;
                          final overscroll = offset < 0 ? -offset : 0.0;
                          
                          // Map 0 -> 100px of overscroll to 0.0 -> 1.0 expansion
                          // (Industry standard pull-to-expand behavior)
                          final expansion = (overscroll / 100.0).clamp(0.0, 1.0);

                          final targetWidth = screenWidth * 0.75;
                          final targetHeight = targetWidth * 16 / 9;

                          final currentWidth =
                              lerpDouble(80, targetWidth, expansion)!;
                          final currentHeight =
                              lerpDouble(80, targetHeight, expansion)!;
                          final currentRadius =
                              lerpDouble(20, 32, expansion)!;

                          // Fade text out quickly as it expands
                          final textOpacity = lerpDouble(
                              1.0, 0.0, (expansion * 2).clamp(0.0, 1.0))!;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Photo(
                                  imageBytes: state.imageBytes,
                                  width: currentWidth,
                                  height: currentHeight,
                                  maxHeight: screenHeight * 0.60,
                                  borderRadius: currentRadius,
                                ),
                                const SizedBox(width: 16),
                                if (textOpacity > 0)
                                  Expanded(
                                    child: Opacity(
                                      opacity: textOpacity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Style Analysis',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Here\'s what I think',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.textTertiary
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Feedback
                      if (state.result!['feedback'] != null)
                        _ResultSection(
                          icon: LucideIcons.message_circle,
                          title: 'Feedback',
                          items: List<String>.from(
                            state.result!['feedback'] as List<dynamic>,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Upgrades
                      if (state.result!['upgrades'] != null)
                        _ResultSection(
                          icon: LucideIcons.sparkles,
                          title: 'Smart Upgrades',
                          items: List<String>.from(
                            state.result!['upgrades'] as List<dynamic>,
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ],
                ),
              ),
            ),

            // Floating close button
            Positioned(
              top: 8,
              left: 16,
              child: GestureDetector(
                onTap: notifier.retake,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Reusable photo container with animated size transitions.
class _Photo extends StatelessWidget {
  const _Photo({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.maxHeight,
    required this.borderRadius,
  });

  final Uint8List? imageBytes;
  final double width;
  final double height;
  final double maxHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      width: width,
      height: height.clamp(0.0, maxHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageBytes != null
          ? Image.memory(imageBytes!, fit: BoxFit.cover)
          : const ColoredBox(color: AppTheme.surfaceElevated),
    );
  }
}

/// Gemini-style fluid gradient mesh loader.
/// Acts as an elevated skeleton screen masked to the photo container.
class _GeminiMeshLoader extends StatefulWidget {
  const _GeminiMeshLoader({required this.borderRadius});

  final double borderRadius;

  @override
  State<_GeminiMeshLoader> createState() => _GeminiMeshLoaderState();
}

class _GeminiMeshLoaderState extends State<_GeminiMeshLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          // Mild blur for the underlying photo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ColoredBox(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          // Orbital fluid nodes (blurred themselves, not blurring the background)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value * 2 * math.pi;

                  return Stack(
                    children: [
                      // Node 1: Vibrant Magenta
                      _buildOrbitalNode(
                        color: const Color(0xFFFF2A85).withOpacity(0.4),
                        size: 250,
                        xOffset: math.sin(t) * 80,
                        yOffset: math.cos(t * 1.5) * 60,
                        scale: 1.0 + math.sin(t * 2) * 0.2,
                      ),
                      // Node 2: Soft Cosmic Pink
                      _buildOrbitalNode(
                        color: const Color(0xFF8A2387).withOpacity(0.4),
                        size: 300,
                        xOffset: math.cos(t * 0.8) * 100,
                        yOffset: math.sin(t * 1.2) * 90,
                        scale: 1.0 + math.cos(t * 1.8) * 0.3,
                      ),
                      // Node 3: Cyan/Teal
                      _buildOrbitalNode(
                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                        size: 200,
                        xOffset: math.sin(t * 1.3 + math.pi) * 120,
                        yOffset: math.cos(t * 0.9) * 100,
                        scale: 1.0 + math.sin(t * 1.5) * 0.25,
                      ),
                      // Node 4: Warm Amber Flare
                      _buildOrbitalNode(
                        color: const Color(0xFFFFC371).withOpacity(0.2),
                        size: 150,
                        xOffset: math.cos(t * 1.7) * 70,
                        yOffset: math.sin(t * 2.1) * 110,
                        scale: 1.0 + math.cos(t * 2.5) * 0.4,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Optional: Subtle grain or overlay text
          Positioned.fill(
            child: Center(
              child: const Text(
                'Analyzing your fit...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 12),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.4, end: 1.0, duration: 1500.ms),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildOrbitalNode({
    required Color color,
    required double size,
    required double xOffset,
    required double yOffset,
    required double scale,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(xOffset, yOffset),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped white analyze button.
class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({required this.notifier});

  final FitCheckNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await notifier.analyzeOutfit();
        } on Exception catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to analyze outfit. Check API key.'),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.sparkles, color: Colors.black, size: 18),
            SizedBox(width: 10),
            Text(
              'Analyze Fit',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}

/// Siri-style glass result section.
class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFA29BFE), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7, right: 10),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA29BFE).withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary.withOpacity(0.9),
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
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 100))
        .slideY(begin: 0.05, duration: const Duration(milliseconds: 400));
  }
}
