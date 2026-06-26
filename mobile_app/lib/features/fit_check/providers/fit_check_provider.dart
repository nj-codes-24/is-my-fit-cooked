/// State and business logic for the FitCheck feature.
library;

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:is_my_fit_cooked/core/constants/app_constants.dart';
import 'package:is_my_fit_cooked/core/providers/camera_provider.dart';
import 'package:is_my_fit_cooked/core/services/ai_service.dart';
import 'package:is_my_fit_cooked/core/services/storage_service.dart';

/// State for the FitCheck feature.
class FitCheckState {
  const FitCheckState({
    this.isCameraInitialized = false,
    this.cameraError = false,
    this.cameraErrorMessage = '',
    this.isSelfieMode = true,
    this.imageBytes,
    this.isAnalyzing = false,
    this.result,
    this.timerSeconds = 0,
    this.countdown,
  });

  final bool isCameraInitialized;
  final bool cameraError;
  final String cameraErrorMessage;
  final bool isSelfieMode;
  final Uint8List? imageBytes;
  final bool isAnalyzing;
  final Map<String, dynamic>? result;
  final int timerSeconds;
  final int? countdown;

  /// Whether an image has been captured and is ready for analysis.
  bool get hasImage => imageBytes != null;

  FitCheckState copyWith({
    bool? isCameraInitialized,
    bool? cameraError,
    String? cameraErrorMessage,
    bool? isSelfieMode,
    Uint8List? imageBytes,
    bool clearImage = false,
    bool? isAnalyzing,
    Map<String, dynamic>? result,
    bool clearResult = false,
    int? timerSeconds,
    int? countdown,
    bool clearCountdown = false,
  }) {
    return FitCheckState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      cameraError: cameraError ?? this.cameraError,
      cameraErrorMessage: cameraErrorMessage ?? this.cameraErrorMessage,
      isSelfieMode: isSelfieMode ?? this.isSelfieMode,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      result: clearResult ? null : (result ?? this.result),
      timerSeconds: timerSeconds ?? this.timerSeconds,
      countdown: clearCountdown ? null : (countdown ?? this.countdown),
    );
  }
}

/// Provider for the FitCheck feature state.
final fitCheckProvider =
    NotifierProvider<FitCheckNotifier, FitCheckState>(
  FitCheckNotifier.new,
);

/// Manages FitCheck business logic: camera, capture, timer, AI analysis.
///
/// Decouples all business logic from the UI layer.
class FitCheckNotifier extends Notifier<FitCheckState> {
  CameraController? _controller;
  Timer? _countdownTimer;

  /// Exposes the camera controller for the preview widget.
  CameraController? get controller => _controller;

  @override
  FitCheckState build() {
    ref.onDispose(_dispose);
    // Initialize camera after build.
    Future.microtask(() async => initCamera());
    return const FitCheckState();
  }

  void _dispose() {
    _controller?.dispose();
    _countdownTimer?.cancel();
  }

  /// Initializes or reinitializes the camera.
  Future<void> initCamera() async {
    final camerasAsync = ref.read(cameraListProvider);
    final cameras = camerasAsync.valueOrNull ?? [];

    if (cameras.isEmpty) {
      state = state.copyWith(
        cameraError: true,
        cameraErrorMessage:
            'No cameras available. Camera access requires HTTPS or localhost.',
      );
      return;
    }

    final direction = state.isSelfieMode
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => cameras.first,
    );

    await _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      state = state.copyWith(
        isCameraInitialized: true,
        cameraError: false,
      );
    } on Exception catch (_) {
      debugPrint('Camera init error');
      state = state.copyWith(
        cameraError: true,
        cameraErrorMessage:
            'Camera access requires HTTPS or localhost.',
      );
    }
  }

  /// Toggles between front and back camera.
  Future<void> switchCamera() async {
    state = state.copyWith(
      isSelfieMode: !state.isSelfieMode,
      isCameraInitialized: false,
      cameraError: false,
    );
    await initCamera();
  }

  /// Cycles through timer options: 0 → 3 → 5 → 10 → 0.
  void cycleTimer() {
    const options = AppConstants.timerOptions;
    final currentIndex = options.indexOf(state.timerSeconds);
    final nextIndex = (currentIndex + 1) % options.length;
    state = state.copyWith(timerSeconds: options[nextIndex]);
  }

  /// Captures a photo (with optional countdown timer).
  void handleCapture() {
    if (state.countdown != null) return;

    if (state.timerSeconds > 0) {
      state = state.copyWith(countdown: state.timerSeconds);
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (state.countdown != null && state.countdown! > 1) {
            state = state.copyWith(countdown: state.countdown! - 1);
          } else {
            timer.cancel();
            state = state.copyWith(clearCountdown: true);
            _capturePhoto();
          }
        },
      );
    } else {
      _capturePhoto();
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      state = state.copyWith(imageBytes: bytes);
    } on Exception catch (_) {
      debugPrint('Capture error');
    }
  }

  /// Picks an image from the device gallery.
  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      state = state.copyWith(imageBytes: bytes);
    }
  }

  /// Sends the captured image to Gemini for outfit analysis.
  Future<void> analyzeOutfit() async {
    if (state.imageBytes == null) return;

    state = state.copyWith(isAnalyzing: true, clearResult: true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final aiService = ref.read(aiServiceProvider);

      // Upload image to Cloudflare R2
      final imageUrl = await storageService.uploadImage(state.imageBytes!);

      // Analyze via OpenRouter Vision Model
      final result = await aiService.analyzeOutfit(imageUrl);
      state = state.copyWith(result: result);
    } catch (e) {
      debugPrint('Analyze outfit failed');
      rethrow;
    } finally {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  /// Resets to camera view, clearing captured image and results.
  void retake() {
    state = state.copyWith(clearImage: true, clearResult: true);
  }
}
