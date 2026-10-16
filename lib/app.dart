import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'shared/widgets/responsive_scaffold.dart';

/// SthitaprajnaApp configures the root application widget.
/// Enforces Dark Mode Only, zero telemetry, and rapid startup time (<100ms).
class SthitaprajnaApp extends StatelessWidget {
  const SthitaprajnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sthitaprajna',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const ResponsiveScaffold(),
    );
  }
}
