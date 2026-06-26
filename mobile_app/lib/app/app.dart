/// Root MaterialApp widget.
library;

import 'package:flutter/material.dart';

import 'package:is_my_fit_cooked/app/layout.dart';
import 'package:is_my_fit_cooked/core/theme/app_theme.dart';

/// The root widget for the application.
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
