import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'layout.dart';
import 'theme.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Failed to load cameras: $e");
  }
  runApp(
    const ProviderScope(
      child: IsMyFitCookedApp(),
    ),
  );
}

class IsMyFitCookedApp extends StatelessWidget {
  const IsMyFitCookedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Is My Fit Cooked',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppLayout(),
    );
  }
}
