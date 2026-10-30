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
      expect(locEn.navSos, equals('SOS'));
      expect(locEn.navDashboard, equals('Dashboard'));
      expect(locEn.navVault, equals('Vault'));
      expect(locEn.navCognition, equals('Cognition'));
      expect(locEn.somaticInstructionBanner, contains('Press tongue to roof of mouth'));
      expect(locEn.coreArmorRuleText, contains('Do not surrender your power'));
      expect(locEn.catDailyReview, equals('Daily Review'));
      expect(locEn.catPersonalJournal, equals('Personal Journal'));
      expect(locEn.catPlanning, equals('Planning'));
      expect(locEn.catSelfTalk, equals('Self-Talk'));
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
      expect(locHi.joyReservoirTitle, equals('जॉय बॉक्स'));
      expect(locHi.navSos, equals('ठहराव'));
      expect(locHi.navDashboard, equals('प्रारंभ'));
      expect(locHi.navVault, equals('कोष'));
      expect(locHi.navCognition, equals('संज्ञान'));
      expect(locHi.somaticInstructionBanner, equals('जीभ को तालू से सटाएं और जबड़ा ढीला छोड़ें।'));
      expect(locHi.coreArmorRuleText, equals('प्रतिक्रिया देकर अपनी शक्ति मत गंवाओ। मौन ही तुम्हारा नियंत्रण है।'));
      expect(locHi.catDailyReview, equals('दैनिक समीक्षा'));
      expect(locHi.catPersonalJournal, equals('व्यक्तिगत डायरी'));
      expect(locHi.catPlanning, equals('योजना व रणनीति'));
      expect(locHi.catSelfTalk, equals('आत्म-संवाद'));
    });

    test('Bilingual Stoic rules map authentic aphorisms and tactical directives', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      // Rule 1: The 4-Second Pause
      expect(locEn.getRuleTitle(1, 'THE 4-SECOND TACTICAL PAUSE'), equals('THE 4-SECOND TACTICAL PAUSE'));
      expect(locHi.getRuleTitle(1, 'Fallback'), equals('4-सेकंड रणनीतिक मौन (विराम)'));
      expect(locHi.getRuleAphorism(1, 'Fallback'), contains('कटु वचन या प्रहार'));
      expect(locHi.getRuleTacticalAction(1, 'Fallback'), contains('4 सेकंड प्रतीक्षा करें'));

      // Rule 8: Sthitaprajna
      expect(locHi.getRuleTitle(8, 'Fallback'), equals('स्थितप्रज्ञ (अटल प्रज्ञा)'));
      expect(locHi.getRuleAphorism(8, 'Fallback'), contains('दुःखेष्वनुद्विग्नमनाः'));
    });

    test('Daily Debrief & Evening Audit bilingual terms provide distinct English and Hindi strings', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      expect(locEn.eveningLogBadge, equals('60-SECOND EVENING LOG'));
      expect(locHi.eveningLogBadge, equals('60-सेकंड संध्या समीक्षा'));

      expect(locEn.dailyClosureTitle, equals('Daily Closure (Evening Audit)'));
      expect(locHi.dailyClosureTitle, equals('दैनिक हिसाब'));

      expect(locEn.index01Question, equals('How composed was your mind under provocation today?'));
      expect(locHi.index01Question, equals('आज उकसावे पर चित्त कितना स्थिर रहा?'));

      expect(locEn.reactionScoreLabel(4), contains('High Poise'));
      expect(locHi.reactionScoreLabel(4), contains('पूर्ण नियंत्रण'));

      expect(locEn.boundaryYesButton, contains('YES'));
      expect(locHi.boundaryYesButton, contains('हाँ'));

      expect(locEn.index03Badge, equals('MAIN FOCUS'));
      expect(locHi.index03Badge, equals('मुख्य लक्ष्य'));

      expect(locEn.index03Title, equals('Main Focus of the Day'));
      expect(locHi.index03Title, equals('आज का मुख्य लक्ष्य'));

      expect(locEn.index03Tag, equals('1-Liner'));
      expect(locHi.index03Tag, equals('1 पंक्ति में'));

      expect(locEn.index03OutputQuestion, equals('The single most important task to complete today:'));
      expect(locHi.index03OutputQuestion, equals('आज का सबसे ज़रूरी काम जो पूरा करना है:'));

      expect(locEn.index03OutputHint, contains('Finished presentation'));
      expect(locHi.index03OutputHint, contains('प्रेजेंटेशन तैयार की'));

      expect(locEn.index03ProvocationQuestion, equals('How you avoided distraction today (Optional):'));
      expect(locHi.index03ProvocationQuestion, equals('मन का भटकाव कैसे रोका (वैकल्पिक):'));

      expect(locEn.index03ProvocationHint, contains('Stayed off social media'));
      expect(locHi.index03ProvocationHint, contains('सोशल मीडिया नहीं चलाया'));

      expect(locEn.lockDayButton, equals('Lock Daily Debrief'));
      expect(locHi.lockDayButton, contains('हिसाब बंद करें'));
    });

    test('Purified getters contain clean Devanagari Hindi without English parentheticals or raw dual-language slashes', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      expect(locHi.virtueMagnanimityDesc, equals('क्षमा एवं उच्च दृष्टिकोण'));
      expect(locEn.virtueMagnanimityDesc, equals('Big-Hearted Composure'));

      expect(locHi.virtueGravitasDesc, equals('अचल गंभीरता व स्थिरता'));
      expect(locEn.virtueGravitasDesc, equals('Unshakable Response'));

      expect(locHi.virtueJoyDesc, equals('आंतरिक आनंद व सौम्यता'));
      expect(locEn.virtueJoyDesc, equals('Internal Grounding'));

      expect(locHi.virtueRestraintDesc, equals('रणनीतिक मौन व आत्म-नियंत्रण'));
      expect(locEn.virtueRestraintDesc, equals('Strategic Silence'));

      expect(locHi.zeroSnoozePhilosophy, equals('शून्य-विलंब संकल्प'));
      expect(locEn.zeroSnoozePhilosophy, equals('Zero-Snooze Philosophy'));

      expect(locHi.debriefLockedBadge, equals('हिसाब बंद (पूर्ण)'));
      expect(locEn.debriefLockedBadge, equals('LOCKED (DEBRIEF COMPLETED)'));

      expect(locHi.debriefPendingBadge, equals('लंबित'));
      expect(locEn.debriefPendingBadge, equals('PENDING'));

      expect(locHi.lockDayButton, equals('हिसाब बंद करें'));
      expect(locEn.lockDayButton, equals('Lock Daily Debrief'));

      expect(locHi.updateDayButton, equals('दैनिक हिसाब अपडेट करें'));
      expect(locEn.updateDayButton, equals('Update Daily Debrief'));

      expect(locHi.slipUpRecoveryButton, equals('स्खलन दर्ज करें (पुनः संतुलन)'));
      expect(locEn.slipUpRecoveryButton, equals('Log a Slip-Up & Reset'));

      expect(locHi.headlineTraitSummaryLabel, equals('शीर्षक व सद्गुण सारांश'));
      expect(locEn.headlineTraitSummaryLabel, equals('Headline & Trait Summary'));

      expect(locHi.frameworkSubtitleLabel, equals('उपशीर्षक व सार'));
      expect(locEn.frameworkSubtitleLabel, equals('Subtitle & Essence'));

      expect(locHi.frameworkMechanismLabel, equals('मूल सिद्धांत व तंत्र'));
      expect(locEn.frameworkMechanismLabel, equals('Core Principle & Mechanism'));

      expect(locHi.frameworkAntidoteLabel, equals('बचाव व समाधान (प्रति-रणनीति)'));
      expect(locEn.frameworkAntidoteLabel, equals('Counter-Strategy & Action Protocol'));
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
