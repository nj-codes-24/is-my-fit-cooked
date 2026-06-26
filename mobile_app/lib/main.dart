/// Application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:is_my_fit_cooked/app/app.dart';

/// Entry point — no global mutable state.
///
/// Camera list is now a `FutureProvider` (see `cameraListProvider`).
/// API key is injected at build time via `--dart-define=AI_API_KEY=...`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: IsMyFitCookedApp(),
    ),
  );
}
