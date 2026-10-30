import 'package:flutter/material.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/responsive_scaffold.dart';

/// SthitaprajnaApp configures the root application widget.
/// Enforces Dark Mode Only, dynamic reactive bilingual localization (EN & HI),
/// and rapid startup time (<100ms).
class SthitaprajnaApp extends StatelessWidget {
  const SthitaprajnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final locale = LocaleController.instance.locale;
        final isHindi = LocaleController.instance.isHindi;

        return MaterialApp(
          navigatorKey: AppNavigator.navigatorKey,
          title: isHindi ? 'स्थितप्रज्ञ' : 'Sthitaprajna',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ResponsiveScaffold(
            key: ValueKey('scaffold_${locale.languageCode}'),
          ),
        );
      },
    );
  }
}
