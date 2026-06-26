/// Provides available cameras as a Riverpod provider.
library;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Async provider that discovers available cameras on device.
///
/// Returns an empty list if no cameras are available or if
/// camera discovery fails (e.g., missing permissions).
final cameraListProvider =
    FutureProvider<List<CameraDescription>>((ref) async {
  try {
    return await availableCameras();
  } on Exception catch (e) {
    debugPrint('Camera discovery failed: $e');
    return [];
  }
});
