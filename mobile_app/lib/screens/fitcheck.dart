import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../main.dart'; // for cameras
import '../theme.dart';
import '../services/ai.dart';

class FitCheckScreen extends StatefulWidget {
  const FitCheckScreen({super.key});

  @override
  State<FitCheckScreen> createState() => _FitCheckScreenState();
}

class _FitCheckScreenState extends State<FitCheckScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _cameraError = false;
  String _cameraErrorMessage = '';
  bool _isSelfieMode = true;
  
  String? _imagePath;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  
  int _timerSeconds = 0;
  int? _countdown;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() {
          _cameraError = true;
          _cameraErrorMessage = "No cameras available. Camera access requires HTTPS or localhost.";
        });
      }
      return;
    }
    
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == (_isSelfieMode ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );
    
    _controller = CameraController(
      camera, 
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    try {
      await _controller!.initialize();
      if (mounted) setState(() {
        _isCameraInitialized = true;
        _cameraError = false;
      });
    } catch (e) {
      debugPrint("Camera init error: \$e");
      if (mounted) {
        setState(() {
          _cameraError = true;
          _cameraErrorMessage = "Camera access requires HTTPS or localhost.";
        });
      }
    }
  }

  void _switchCamera() {
    setState(() {
      _isSelfieMode = !_isSelfieMode;
      _isCameraInitialized = false;
      _cameraError = false;
    });
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleTimerClick() {
    setState(() {
      if (_timerSeconds == 0) {
        _timerSeconds = 3;
      } else if (_timerSeconds == 3) {
        _timerSeconds = 5;
      } else if (_timerSeconds == 5) {
        _timerSeconds = 10;
      } else {
        _timerSeconds = 0;
      }
    });
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      setState(() {
        _imagePath = file.path;
        _imageBytes = bytes;
      });
    } catch (e) {
      debugPrint("Capture error: \$e");
    }
  }

  void _handleCaptureClick() {
    if (_countdown != null) return;
    
    if (_timerSeconds > 0) {
      setState(() => _countdown = _timerSeconds);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown != null && _countdown! > 1) {
          setState(() => _countdown = _countdown! - 1);
        } else {
          timer.cancel();
          setState(() => _countdown = null);
          _capture();
        }
      });
    } else {
      _capture();
    }
  }

  Future<void> _handleFileUpload() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imagePath = file.path;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _analyzeOutfit() async {
    if (_imageBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final base64Image = base64Encode(_imageBytes!);
      final result = await AIService.analyzeOutfit(base64Image);
      if (mounted) {
        setState(() => _result = result);
      }
    } catch (e) {
      debugPrint("Analyze error: \$e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to analyze outfit. Check API key.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _retake() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imagePath == null)
          const Padding(
            padding: EdgeInsets.only(top: 32, bottom: 16),
            child: Text(
              'fit check',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          
        Expanded(
          child: Stack(
            children: [
              Offstage(
                offstage: _imagePath != null,
                child: _buildCameraView(),
              ),
              if (_imagePath != null)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF09090B),
                    child: _buildPostCaptureView(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color(0xFF18181B),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (_isCameraInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: kIsWeb ? (_controller!.value.previewSize?.width ?? 640) : (_controller!.value.previewSize?.height ?? 1),
                    height: kIsWeb ? (_controller!.value.previewSize?.height ?? 480) : (_controller!.value.previewSize?.width ?? 1),
                    child: CameraPreview(_controller!),
                  ),
                ),
              )
            else if (_cameraError)
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.camera_off, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera Unavailable',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cameraErrorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
            if (_countdown != null)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                    ),
                  ).animate(key: ValueKey(_countdown)).scale(begin: const Offset(0.5, 0.5)).fadeIn(),
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left: Upload
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _handleFileUpload,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black26,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(LucideIcons.upload, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    
                    // Center: Shutter
                    GestureDetector(
                      onTap: _handleCaptureClick,
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 3),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Right: Timer & Switch
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _handleTimerClick,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black26,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Center(
                                child: _timerSeconds > 0 
                                  ? Text('${_timerSeconds}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                  : const Icon(LucideIcons.timer, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _switchCamera,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black26,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(LucideIcons.switch_camera, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildPostCaptureView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _retake,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(LucideIcons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: _result != null ? 220 : MediaQuery.of(context).size.width - 32,
            height: _result != null ? 220 : (MediaQuery.of(context).size.width - 32) * 16 / 9,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_result != null ? 24 : 32),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
            ),
            clipBehavior: Clip.antiAlias,
            child: _imageBytes != null 
                ? Image.memory(
                    _imageBytes!, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.image_off, color: Colors.white54, size: 48),
                          SizedBox(height: 16),
                          Text('Failed to load image preview', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          
          const SizedBox(height: 24),
          
          if (_result == null && !_isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _analyzeOutfit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(220, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 18),
                    SizedBox(width: 8),
                    Text('Analyze Outfit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  const Icon(LucideIcons.activity, color: Colors.white, size: 32).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.3, end: 1),
                  const SizedBox(height: 16),
                  const Text('Stylist is thinking...', style: TextStyle(color: Colors.white60)).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.3, end: 1),
                ],
              ),
            ),
            
          if (_result != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  _buildResultCard(
                    title: 'Style Analysis',
                    icon: LucideIcons.layers,
                    items: List<String>.from(_result!['feedback']),
                  ),
                  const SizedBox(height: 24),
                  _buildResultCard(
                    title: 'Smart Upgrades',
                    icon: LucideIcons.sparkles,
                    items: List<String>.from(_result!['upgrades']),
                  ),
                  const SizedBox(height: 48), // Padding for bottom nav
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildResultCard({required String title, required IconData icon, required List<String> items}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8), height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
