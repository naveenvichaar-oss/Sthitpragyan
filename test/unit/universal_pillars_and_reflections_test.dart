import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sthitaprajna/core/database/hive_storage.dart';
import 'package:sthitaprajna/core/localization/app_localizations.dart';
import 'package:sthitaprajna/features/cognition_vault/data/models/fallacy_and_model.dart';
import 'package:sthitaprajna/features/journal/data/models/reflection_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sthitaprajna_pillars_test_');

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    Hive.init(tempDir.path);
    await HiveStorage().init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Pillar 3: ReflectionEntry Model & Serialization Tests', () {
    test('Creates and serializes ReflectionEntry across all 4 categories', () {
      final now = DateTime.now();

      final entry1 = ReflectionEntry(
        id: 'ref_1',
        title: 'Daily Closure',
        content: 'Completed high-priority engine refactoring.',
        category: ReflectionCategory.dailyReview,
        createdAt: now,
        reactionScore: 5,
        boundaryMaintained: true,
        distractionAvoided: 'Turned off notifications during focus block.',
        audioMemoPath: '/path/to/memo.m4a',
        videoReflectionPath: '/path/to/drill.mp4',
        tags: const ['deep_work', 'focus'],
      );

      final map = entry1.toMap();
      expect(map['id'], equals('ref_1'));
      expect(map['category'], equals('dailyReview'));
      expect(map['reactionScore'], equals(5));
      expect(map['boundaryMaintained'], isTrue);
      expect(map['distractionAvoided'], equals('Turned off notifications during focus block.'));

      final restored = ReflectionEntry.fromMap(map);
      expect(restored.id, equals(entry1.id));
      expect(restored.title, equals(entry1.title));
      expect(restored.content, equals(entry1.content));
      expect(restored.category, equals(ReflectionCategory.dailyReview));
      expect(restored.reactionScore, equals(5));
      expect(restored.boundaryMaintained, isTrue);
      expect(restored.audioMemoPath, equals('/path/to/memo.m4a'));
      expect(restored.videoReflectionPath, equals('/path/to/drill.mp4'));
      expect(restored.tags, contains('deep_work'));
    });

    test('matchesQuery accurately searches titles, contents, tags and distraction text', () {
      final entry = ReflectionEntry(
        id: 'ref_search',
        title: 'Stoic Perspective',
        content: 'Remaining calm amidst workplace storms.',
        category: ReflectionCategory.selfTalk,
        createdAt: DateTime.now(),
        distractionAvoided: 'Ignored hostile email prompt',
        tags: const ['equanimity', 'mantra'],
      );

      expect(entry.matchesQuery('stoic'), isTrue);
      expect(entry.matchesQuery('calm'), isTrue);
      expect(entry.matchesQuery('hostile'), isTrue);
      expect(entry.matchesQuery('equanimity'), isTrue);
      expect(entry.matchesQuery('nonexistent_keyword'), isFalse);
    });

    test('copyWith updates fields immutably', () {
      final original = ReflectionEntry(
        id: 'ref_copy',
        title: 'Draft',
        content: 'Original thoughts',
        category: ReflectionCategory.personalJournal,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Refined Title',
        content: 'Deep insights',
      );

      expect(updated.id, equals('ref_copy'));
      expect(updated.title, equals('Refined Title'));
      expect(updated.content, equals('Deep insights'));
      expect(updated.category, equals(ReflectionCategory.personalJournal));
    });

    test('Creates and serializes 1:3 Input-Output ReflectionEntry with 3 structured takeaways', () {
      final now = DateTime.now();

      final ioEntry = ReflectionEntry(
        id: 'io_123',
        title: 'Book: Thinking Fast and Slow',
        content: 'Application: Pause for 3 seconds before making critical judgements.',
        category: ReflectionCategory.inputOutput1to3,
        createdAt: now,
        sourceTitle: 'Thinking, Fast and Slow (Daniel Kahneman)',
        takeaway1: 'System 1 is fast, emotional, and prone to cognitive illusions.',
        takeaway2: 'System 2 is effortful, rational, but inherently lazy.',
        takeaway3: 'Framing biases dictate risk-seeking vs risk-averse behavior.',
        tags: const ['1:3 आउटपुट', 'चिंतन'],
      );

      final map = ioEntry.toMap();
      expect(map['category'], equals('inputOutput1to3'));
      expect(map['sourceTitle'], equals('Thinking, Fast and Slow (Daniel Kahneman)'));
      expect(map['takeaway1'], contains('System 1'));
      expect(map['takeaway2'], contains('System 2'));
      expect(map['takeaway3'], contains('Framing biases'));

      final restored = ReflectionEntry.fromMap(map);
      expect(restored.category, equals(ReflectionCategory.inputOutput1to3));
      expect(restored.sourceTitle, equals(ioEntry.sourceTitle));
      expect(restored.takeaway1, equals(ioEntry.takeaway1));
      expect(restored.takeaway2, equals(ioEntry.takeaway2));
      expect(restored.takeaway3, equals(ioEntry.takeaway3));
      expect(restored.matchesQuery('Kahneman'), isTrue);
      expect(restored.matchesQuery('emotional'), isTrue);
    });
  });

  group('HiveStorage Pillar 3 & Vault CRUD Tests', () {
    test('Saves, retrieves, and deletes ReflectionEntry in Hive', () async {
      final storage = HiveStorage();
      final now = DateTime.now();

      final ref = ReflectionEntry(
        id: 'hive_ref_test',
        title: 'Strategic Roadmap',
        content: '3 milestones for Q4 launch.',
        category: ReflectionCategory.planning,
        createdAt: now,
        tags: const ['strategy', 'milestone'],
      );

      await storage.saveReflection(ref);

      final allReflections = storage.getAllReflections();
      expect(allReflections.any((r) => r.id == 'hive_ref_test'), isTrue);

      final planningOnly = storage.getAllReflections(category: ReflectionCategory.planning);
      expect(planningOnly.any((r) => r.id == 'hive_ref_test'), isTrue);

      final searchResult = storage.getAllReflections(searchQuery: 'milestones');
      expect(searchResult.any((r) => r.id == 'hive_ref_test'), isTrue);

      await storage.deleteReflection('hive_ref_test');
      final remaining = storage.getAllReflections();
      expect(remaining.any((r) => r.id == 'hive_ref_test'), isFalse);
    });

    test('Saves, retrieves, and deletes CognitionItem in Hive with attachments', () async {
      final storage = HiveStorage();

      const customModel = CognitionItem(
        id: 'custom_first_principles',
        type: CognitionType.mentalModel,
        title: 'First Principles Thinking',
        subtitle: 'Deconstruct to fundamental truths',
        latinName: 'Ratio Fundamentalis',
        definition: 'Boiling a problem down to the most fundamental truths and reasoning up.',
        corporateManifestation: 'Questioning existing assumptions rather than copying competitors.',
        antidoteProtocol: 'Identify assumptions, break down into fundamentals, reconstruct logic.',
        quickMaxim: 'Reason from first principles, not by analogy.',
        tags: ['strategy', 'reasoning'],
        audioAttachmentPath: '/path/to/explainer.m4a',
        isCustom: true,
      );

      await storage.saveCognitionItem(customModel);

      final items = storage.getAllCognitionItems(type: CognitionType.mentalModel);
      expect(items.any((i) => i.id == 'custom_first_principles'), isTrue);

      final item = items.firstWhere((i) => i.id == 'custom_first_principles');
      expect(item.audioAttachmentPath, equals('/path/to/explainer.m4a'));
      expect(item.isCustom, isTrue);

      await storage.deleteCognitionItem('custom_first_principles');
      final remaining = storage.getAllCognitionItems();
      expect(remaining.any((i) => i.id == 'custom_first_principles'), isFalse);
    });
  });

  group('3 Core Universal Pillars Localization Contract Tests', () {
    test('Validates 3 Core Universal Pillars navigation labels', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      // Tab 1: ठहराव / SOS
      expect(locEn.navSos, equals('SOS'));
      expect(locHi.navSos, equals('ठहराव'));

      // Tab 2: प्रारंभ / Dashboard
      expect(locEn.navDashboard, equals('Dashboard'));
      expect(locHi.navDashboard, equals('प्रारंभ'));

      // Tab 3: कोष / Vault
      expect(locEn.navVault, equals('Vault'));
      expect(locHi.navVault, equals('कोष'));

      // Tab 4: संज्ञान / Cognition
      expect(locEn.navCognition, equals('Cognition'));
      expect(locHi.navCognition, equals('संज्ञान'));
    });

    test('Validates Pillar 1 & 2 Framework Localizations', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      // Morning Grounding
      expect(locHi.morningGroundingTime, equals('05:30 - 07:00 AM'));
      expect(locEn.morningGroundingTime, equals('05:30 - 07:00 AM'));
      expect(locHi.pauseRuleTitle, contains('3-सेकंड'));
      expect(locHi.unapologeticNoTitle, contains('संकोचहीन'));
      expect(locEn.pauseRuleTitle, contains('3-Second'));
      expect(locEn.unapologeticNoTitle, contains('Unapologetic No'));

      // Day Focus Block
      expect(locHi.dayFocusTimeBadge, equals('09:30 AM'));
      expect(locHi.fiveMinKickstart, equals('5-मिनट शुरुआत'));
      expect(locEn.dayFocusTimeBadge, equals('09:30 AM'));
      expect(locEn.fiveMinKickstart, equals('5-Min Kickstart'));

      // Night Debrief
      expect(locHi.nightDebriefTime, equals('09:30 - 10:30 PM'));
      expect(locHi.stoicQ1Header, contains('1. उकसावे/प्रलोभन पर प्रतिक्रिया?'));
      expect(locHi.stoicQ2Header, contains('2. व्यर्थ सफाई या शिकायत?'));
      expect(locHi.stoicQ3Header, contains('3. आज का सबसे तार्किक निर्णय / मुख्य कार्य?'));

      // Case Studies & 1:3 Output
      expect(locHi.filterCaseStudies, equals('केस स्टडीज'));
      expect(locHi.catInputOutput1to3, equals('1:3 आउटपुट'));
    });

    test('Validates Pillar 1 Morning Grounding Protocol Localizations', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));

      // Header
      expect(locHi.morningGroundingHeaderTitle, equals('प्रातः कालीन प्रक्रम (05:30 – 07:00 AM) • ग्राउंडिंग फेज़'));
      expect(locEn.morningGroundingHeaderTitle, equals('Morning Grounding Routine (05:30 – 07:00 AM)'));

      // Core Neuro-Protocol Banner
      expect(locHi.morningNeuroProtocolBanner, contains('आज की घटनाओं पर मेरा वश हो न हो'));
      expect(locHi.morningNeuroProtocolBanner, contains('मेरी प्रतिक्रिया पर मेरा शत-प्रतिशत नियंत्रण है'));
      expect(locEn.morningNeuroProtocolBanner, contains('Events may be outside my control'));

      // 3 Steps
      expect(locHi.morningStep1Title, equals('डिजिटल स्क्रीन वर्जित (0–15 मिनट)'));
      expect(locHi.morningStep1Desc, contains('बालकनी/खिड़की'));
      expect(locHi.morningStep2Title, equals('बाह्य भ्रमण व सॉक्रेटिक संवाद (15 मिनट)'));
      expect(locHi.morningStep2Desc, contains('तेज चाल'));
      expect(locHi.morningStep3Title, equals('द एंकर ऑफ काम (चाय का समय)'));
      expect(locHi.morningStep3Desc, contains('पूर्ण उपस्थिति'));
    });

    test('Validates Morning Grounding Protocol Persistence in HiveStorage (morning_routine_box)', () async {
      final storage = HiveStorage();

      // Step check-offs
      await storage.setMorningRoutineStepCompleted(1, true);
      await storage.setMorningRoutineStepCompleted(2, true);
      await storage.setMorningRoutineStepCompleted(3, false);

      expect(storage.isMorningRoutineStepCompleted(1), isTrue);
      expect(storage.isMorningRoutineStepCompleted(2), isTrue);
      expect(storage.isMorningRoutineStepCompleted(3), isFalse);
      expect(storage.getCompletedMorningStepsCount(), equals(2));

      await storage.setMorningRoutineStepCompleted(3, true);
      expect(storage.getCompletedMorningStepsCount(), equals(3));

      // Reset
      await storage.setMorningRoutineStepCompleted(1, false);
      await storage.setMorningRoutineStepCompleted(2, false);
      await storage.setMorningRoutineStepCompleted(3, false);
      expect(storage.getCompletedMorningStepsCount(), equals(0));

      // Collapse state
      await storage.setMorningRoutineCollapsed(true);
      expect(storage.isMorningRoutineCollapsed(), isTrue);
      await storage.setMorningRoutineCollapsed(false);
      expect(storage.isMorningRoutineCollapsed(), isFalse);
    });

    test('Validates Morning Grounding Persistence in HiveStorage', () async {
      final storage = HiveStorage();

      await storage.setTodayPauseRuleCommitted(true);
      expect(storage.isTodayPauseRuleCommitted(), isTrue);

      await storage.setTodayPauseRuleCommitted(false);
      expect(storage.isTodayPauseRuleCommitted(), isFalse);

      await storage.setTodayUnapologeticNoCommitted(true);
      expect(storage.isTodayUnapologeticNoCommitted(), isTrue);

      await storage.setTodayUnapologeticNoCommitted(false);
      expect(storage.isTodayUnapologeticNoCommitted(), isFalse);
    });

    test('Validates 4-Tab Bottom Navigation & Tab 1 (ठहराव / SOS) Somatic Protocols', () {
      final locHi = AppLocalizations(const Locale('hi'));
      final locEn = AppLocalizations(const Locale('en'));

      // 4 Tabs in exact order
      // Tab 1: ठहराव / SOS
      // Tab 2: प्रारंभ / Dashboard
      // Tab 3: कोष / Vault
      // Tab 4: संज्ञान / Cognition
      expect(locHi.navSos, equals('ठहराव'));
      expect(locEn.navSos, equals('SOS'));
      expect(locHi.navDashboard, equals('प्रारंभ'));
      expect(locEn.navDashboard, equals('Dashboard'));
      expect(locHi.navVault, equals('कोष'));
      expect(locEn.navVault, equals('Vault'));
      expect(locHi.navCognition, equals('संज्ञान'));
      expect(locEn.navCognition, equals('Cognition'));

      // Step 1: Immediate instruction banner
      expect(locHi.somaticInstructionBanner, equals('जीभ को तालू से सटाएं और जबड़ा ढीला छोड़ें।'));
      expect(locEn.somaticInstructionBanner, contains('Press tongue to roof of mouth'));

      // Step 3: Core armor rule
      expect(locHi.coreArmorRuleText, equals('प्रतिक्रिया देकर अपनी शक्ति मत गंवाओ। मौन ही तुम्हारा नियंत्रण है।'));
      expect(locEn.coreArmorRuleText, contains('Do not surrender your power by reacting'));

      // 4-4-4-4 Box Breathing
      expect(locHi.boxBreathingSectionTitle, equals('4-4-4-4 श्वास चक्र'));
      expect(locEn.boxBreathingSectionTitle, equals('4-4-4-4 Box Breathing'));
      expect(locHi.boxBreathInhaleVisual, contains('4'));
      expect(locHi.boxBreathHoldFullVisual, contains('4'));
      expect(locHi.boxBreathExhaleVisual, contains('4'));
      expect(locHi.boxBreathHoldEmptyVisual, contains('4'));
    });

    test('Validates saveToVault (सामग्री संचयन) category & localization replacement of planning/self-talk', () {
      final locHi = AppLocalizations(const Locale('hi'));
      final locEn = AppLocalizations(const Locale('en'));

      expect(locHi.catSaveToVault, equals('सामग्री संचयन'));
      expect(locEn.catSaveToVault, equals('Save to Vault'));
      expect(locHi.catSaveToVaultDesc, contains('कोषों में सहेजें'));

      final saveEntry = ReflectionEntry(
        id: 'save_test_01',
        title: 'Stoic Dialectic on YouTube',
        content: '[RECOVERY REFERENCE] https://youtube.com/watch?v=123',
        category: ReflectionCategory.saveToVault,
        createdAt: DateTime.now(),
        tags: const ['De-Escalation', 'recoveryReference'],
      );

      final map = saveEntry.toMap();
      expect(map['category'], equals('saveToVault'));

      final restored = ReflectionEntry.fromMap(map);
      expect(restored.category, equals(ReflectionCategory.saveToVault));
      expect(restored.title, equals('Stoic Dialectic on YouTube'));
    });

    test('Validates defensive category localization and action notices', () {
      final locHi = AppLocalizations(const Locale('hi'));
      final locEn = AppLocalizations(const Locale('en'));

      expect(locHi.scriptRemovedNotice, equals('रक्षात्मक सूत्र हटा दिया गया है।'));
      expect(locEn.scriptRemovedNotice, equals('Script removed from Sanctuary.'));
      expect(locHi.logIncidentAction, equals('डायरी में दर्ज करें'));
      expect(locEn.logIncidentAction, equals('Log Incident'));

      expect(locHi.getDefensiveCategoryName('All'), equals('सभी'));
      expect(locHi.getDefensiveCategoryName('Pinned'), equals('पिन किए गए'));
      expect(locHi.getDefensiveCategoryName('Unjust Accusation'), equals('झूठा आरोप'));
      expect(locHi.getDefensiveCategoryName('Intimidation'), equals('धौंस / दबदबा'));
      expect(locHi.getDefensiveCategoryName('Impossible Deadlines'), equals('असंभव डेडलाइन'));

      expect(locEn.getDefensiveCategoryName('All'), equals('All'));
      expect(locEn.getDefensiveCategoryName('Pinned'), equals('Pinned'));
      expect(locEn.getDefensiveCategoryName('Unjust Accusation'), equals('Unjust Accusation'));
    });
  });
}
