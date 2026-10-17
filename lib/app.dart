import 'package:flutter/material.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/responsive_scaffold.dart';

/// SthitaprajnaApp configures the root application widget.
/// Enforces Dark Mode Only, dynamic bilingual localization (EN & HI), and rapid startup time (<100ms).
class SthitaprajnaApp extends StatelessWidget {
  const SthitaprajnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final isHindi = LocaleController.instance.isHindi;

        return MaterialApp(
          title: isHindi ? 'स्थितप्रज्ञ' : 'Sthitaprajna',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ResponsiveScaffold(),
        );
      },
    );
  }
}
