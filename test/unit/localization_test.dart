import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sthitaprajna/core/localization/app_localizations.dart';
import 'package:sthitaprajna/core/localization/locale_controller.dart';

void main() {
  group('AppLocalizations Bilingual Tests', () {
    test('English localization provides high-register Stoic terminology', () {
      final locEn = AppLocalizations(const Locale('en'));

      expect(locEn.isHindi, isFalse);
      expect(locEn.appTitle, equals('Sthitaprajna'));
      expect(locEn.brandMarker, equals('STHITAPRAJNA'));
      expect(locEn.sosShieldTitle, equals('Emergency Composure / Grounding'));
      expect(locEn.sosShieldSub, contains('Tactical De-escalation'));
      expect(locEn.adrenalineAgitation, equals('Adrenaline / Agitation'));
      expect(locEn.composure, equals('Composure'));
      expect(locEn.microIgnitionTitle, equals('5-Min Micro-Ignition'));
      expect(locEn.microIgnitionAnchor, equals('Done is better than perfect.'));
      expect(locEn.characterLedgerTitle, equals('Character Ledger'));
      expect(locEn.virtueMagnanimity, equals('Magnanimity'));
      expect(locEn.virtueGravitas, contains('Gravitas'));
      expect(locEn.virtueJoy, contains('Genuine Joy'));
      expect(locEn.virtueRestraint, equals('Tactical Restraint'));
      expect(locEn.executionChimesTitle, equals('Execution Chimes'));
      expect(locEn.joyReservoirTitle, equals('Joy Reservoir'));
      expect(locEn.navDashboard, equals('Dashboard'));
      expect(locEn.navDebrief, equals('Debrief'));
      expect(locEn.navVault, equals('Vault'));
      expect(locEn.navSettings, equals('Settings'));
    });

    test('Hindi localization provides polished authentic terminology', () {
      final locHi = AppLocalizations(const Locale('hi'));

      expect(locHi.isHindi, isTrue);
      expect(locHi.appTitle, equals('स्थितप्रज्ञ'));
      expect(locHi.brandMarker, equals('स्थितप्रज्ञ'));
      expect(locHi.sosShieldTitle, equals('आपातकालीन स्थिरता व लंगर'));
      expect(locHi.sosShieldSub, contains('रणनीतिक शांति'));
      expect(locHi.adrenalineAgitation, equals('उद्वेग व तनाव'));
      expect(locHi.composure, equals('मानसिक स्थिरता'));
      expect(locHi.microIgnitionTitle, equals('5-मिनट कार्य-आरंभ (सूक्ष्म गति)'));
      expect(locHi.microIgnitionAnchor, equals('अपूर्ण कर्म भी निष्कर्मता से श्रेष्ठ है।'));
      expect(locHi.characterLedgerTitle, equals('गांभीर्य एवं सद्गुण बही'));
      expect(locHi.virtueMagnanimity, equals('उदारता'));
      expect(locHi.virtueGravitas, equals('गांभीर्य'));
      expect(locHi.virtueJoy, equals('प्रसन्नता'));
      expect(locHi.virtueRestraint, equals('संयम'));
      expect(locHi.executionChimesTitle, equals('कर्म-घोष (संकल्प नाद)'));
      expect(locHi.joyReservoirTitle, equals('आनंद कोष'));
      expect(locHi.navDashboard, equals('कमांड केंद्र'));
      expect(locHi.navDebrief, equals('दैनिक समीक्षा'));
      expect(locHi.navVault, equals('प्रज्ञा कोष'));
      expect(locHi.navSettings, equals('सेटिंग्स'));
    });

    test('Bilingual Stoic rules map authentic aphorisms and tactical directives', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      // Rule 1: The 4-Second Pause
      expect(locEn.getRuleTitle(1, 'THE 4-SECOND TACTICAL PAUSE'), equals('THE 4-SECOND TACTICAL PAUSE'));
      expect(locHi.getRuleTitle(1, 'Fallback'), equals('४-सेकंड रणनीतिक मौन (विराम)'));
      expect(locHi.getRuleAphorism(1, 'Fallback'), contains('कटु वचन या प्रहार'));
      expect(locHi.getRuleTacticalAction(1, 'Fallback'), contains('४ सेकंड प्रतीक्षा करें'));

      // Rule 8: Sthitaprajna
      expect(locHi.getRuleTitle(8, 'Fallback'), equals('स्थितप्रज्ञ (अटल प्रज्ञा)'));
      expect(locHi.getRuleAphorism(8, 'Fallback'), contains('दुःखेष्वनुद्विग्नमनाः'));
    });

    test('Daily Debrief & Evening Audit bilingual terms provide distinct English and Hindi strings', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      expect(locEn.eveningLogBadge, equals('60-SECOND EVENING LOG'));
      expect(locHi.eveningLogBadge, equals('६०-सेकंड संध्या समीक्षा'));

      expect(locEn.dailyClosureTitle, equals('Daily Closure (Evening Audit)'));
      expect(locHi.dailyClosureTitle, equals('दैनिक हिसाब (Daily Closure)'));

      expect(locEn.index01Question, equals('How composed was your mind under provocation today?'));
      expect(locHi.index01Question, equals('आज उकसावे पर चित्त कितना स्थिर रहा?'));

      expect(locEn.reactionScoreLabel(4), contains('High Poise'));
      expect(locHi.reactionScoreLabel(4), contains('पूर्ण नियंत्रण'));

      expect(locEn.boundaryYesButton, contains('YES'));
      expect(locHi.boundaryYesButton, contains('हाँ'));

      expect(locEn.index03OutputQuestion, contains('Today\'s single most solid'));
      expect(locHi.index03OutputQuestion, contains('आज का सबसे ठोस'));

      expect(locEn.lockDayButton, equals('Lock Daily Debrief'));
      expect(locHi.lockDayButton, contains('हिसाब बंद करें'));
    });

    test('Delegate supports en and hi locales', () {
      const delegate = AppLocalizationsDelegate();
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('hi')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });

  group('LocaleController Tests', () {
    test('LocaleController toggles between English and Hindi with listener notification', () async {
      final controller = LocaleController.instance;

      int notifyCount = 0;
      void listener() => notifyCount++;
      controller.addListener(listener);

      await controller.setLocale(const Locale('en'));
      expect(controller.locale.languageCode, equals('en'));
      expect(controller.isHindi, isFalse);

      await controller.toggleLanguage();
      expect(controller.locale.languageCode, equals('hi'));
      expect(controller.isHindi, isTrue);

      await controller.toggleLanguage();
      expect(controller.locale.languageCode, equals('en'));
      expect(controller.isHindi, isFalse);

      expect(notifyCount, greaterThanOrEqualTo(2));
      controller.removeListener(listener);
    });
  });
}
