import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// AppLocalizations provides high-register, polished bilingual (English & Hindi)
/// strings across the Sthitaprajna platform.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  bool get isHindi => locale.languageCode == 'hi';

  // -------------------------------------------------------------
  // Brand & High-Status Terminology
  // -------------------------------------------------------------
  String get appTitle => isHindi ? 'स्थितप्रज्ञ' : 'Sthitaprajna';
  String get brandMarker => isHindi ? 'स्थितप्रज्ञ' : 'STHITAPRAJNA';
  String get appSubtitle => isHindi
      ? 'कार्यस्थल विषैलेपन व चिंता हेतु निष्काम कवच'
      : 'Stoic Executive Shield';
  String get zeroTelemetryNotice => isHindi
      ? 'शत-प्रतिशत ऑफ़लाइन • शून्य डेटा संचार'
      : '100% Offline • Zero Telemetry';

  // -------------------------------------------------------------
  // SOS Composure Shield
  // -------------------------------------------------------------
  String get sosShieldTitle => isHindi
      ? 'आपातकालीन स्थिरता व लंगर'
      : 'Emergency Composure / Grounding';
  String get sosShieldSub => isHindi
      ? 'रणनीतिक शांति व समगति प्राणायाम'
      : 'Tactical De-escalation & Box Breathing';
  String get sosCenterButton => isHindi
      ? 'आपातकालीन स्थिरता कवच'
      : 'SOS EQUANINITY SHIELD';
  String get sosCenterSubtitle => isHindi
      ? 'आक्रमण या घबराहट के क्षणों में दबाएं'
      : 'TAP WHEN AMBUSHED OR ANXIOUS';
  String get sosActiveTitle => isHindi
      ? 'आपातकालीन समत्व सक्रिय'
      : 'EMERGENCY EQUANINITY ACTIVE';
  String get sosActiveSubtitle => isHindi
      ? 'वाणी रोकें • ४-४-४-४ श्वास चक्र अपनाएं • आंतरिक शक्ति बनाए रखें'
      : 'Zero verbal reaction • 4-4-4-4 Box Breathing • Retain leverage';

  // -------------------------------------------------------------
  // Box Breathing Drill
  // -------------------------------------------------------------
  String get boxBreathingTitle => isHindi
      ? '४-४-४-४ समगति प्राणायाम'
      : '4-4-4-4 Box Breathing';
  String get boxBreathingSubtitle => isHindi
      ? 'नाड़ी तंत्र को शांत करने हेतु नियंत्रित श्वास'
      : 'Regulate nervous system before responding';
  String get breathInhale => isHindi ? 'श्वास लें (४ से.)' : 'Inhale (4s)';
  String get breathHold => isHindi ? 'कुंभक / रोकें (४ से.)' : 'Hold (4s)';
  String get breathExhale => isHindi ? 'श्वास छोड़ें (४ से.)' : 'Exhale (4s)';
  String get breathRest => isHindi ? 'विराम (४ से.)' : 'Rest (4s)';
  String get breathCompleted => isHindi
      ? 'प्राणायाम चक्र संपन्न'
      : 'Breathing Cycle Completed';

  // -------------------------------------------------------------
  // Sliders & Psychological Metrics
  // -------------------------------------------------------------
  String get adrenalineAgitation => isHindi
      ? 'उद्वेग व तनाव'
      : 'Adrenaline / Agitation';
  String get composure => isHindi
      ? 'मानसिक स्थिरता'
      : 'Composure';
  String get workplaceFriction => isHindi
      ? 'कार्यस्थल घर्षण व तनाव'
      : 'Workplace Friction / Toxicity';
  String get equanimityScore => isHindi
      ? 'समत्व गुणांक'
      : 'Equanimity Score';
  String get compositeEquanimity => isHindi
      ? 'समग्र समत्व'
      : 'Composite Equanimity';
  String get reactionComposure => isHindi
      ? 'प्रतिक्रिया समत्व'
      : 'Reaction Composure';
  String get boundaryDefense => isHindi
      ? 'सीमा रक्षा'
      : 'Boundary Defense';
  String get intentionalSpeech => isHindi
      ? 'मितभाषण व संयम'
      : 'Intentional Speech';

  // -------------------------------------------------------------
  // 5-Minute Micro-Ignition Timer
  // -------------------------------------------------------------
  String get microIgnitionTitle => isHindi
      ? '5-मिनट कार्य-आरंभ (सूक्ष्म गति)'
      : '5-Min Micro-Ignition';
  String get microIgnitionSubtitle => isHindi
      ? 'संकोच त्यागें। ३-२-१... आरंभ करें।'
      : 'Break hesitation. 3-2-1... Execute.';
  String get microIgnitionAnchor => isHindi
      ? 'अपूर्ण कर्म भी निष्कर्मता से श्रेष्ठ है।'
      : 'Done is better than perfect.';
  String get microIgnitionPhilosophy => isHindi
      ? 'Done is better than perfect. 3-2-1... Execute.'
      : 'Done is better than perfect. 3-2-1... Execute.';
  String get microIgnitionDesc => isHindi
      ? 'विलंबित कर्मों को बिना संकोच आरंभ करने हेतु ५-मिनट सूक्ष्म-गति उलटी गिनती।'
      : 'Single-tap friction-breaker countdown to initiate delayed tasks without hesitation.';
  String get microIgnitionStart => isHindi ? '५-मिनट आरंभ करें' : 'Start 5-Min Timer';
  String get microIgnitionReset => isHindi ? 'रीसेट करें' : 'Reset Timer';
  String get microIgnitionActive => isHindi
      ? 'गतिरोध-भंजक सक्रिय'
      : 'Friction-Breaker Active';
  String get microIgnitionDone => isHindi
      ? 'कार्य आरंभ हुआ! निरंतरता बनाए रखें।'
      : 'Task initiated! Momentum unlocked.';

  // -------------------------------------------------------------
  // Character Ledger (Virtue & Trait Journal)
  // -------------------------------------------------------------
  String get characterLedgerTitle => isHindi
      ? 'गांभीर्य एवं सद्गुण बही'
      : 'Character Ledger';
  String get characterLedgerSubtitle => isHindi
      ? 'सद्गुण व व्यक्तित्व संस्कार दैनिकी'
      : 'Virtue & Trait Journal';
  String get characterLedgerDesc => isHindi
      ? 'आकर्षण एवं गरिमामय व्यक्तिगत गुणों के निर्माण हेतु समर्पित बही।'
      : 'A structured ledger strictly focused on building magnetic, dignified personal traits.';

  String get virtueMagnanimity => isHindi ? 'उदारता' : 'Magnanimity';
  String get virtueMagnanimityDesc => isHindi
      ? 'क्षमा एवं उच्च दृष्टिकोण (Big-Hearted Composure)'
      : 'Big-Hearted Composure';

  String get virtueGravitas => isHindi ? 'गांभीर्य' : 'Gravitas & Stillness';
  String get virtueGravitasDesc => isHindi
      ? 'अचल गंभीरता व स्थिरता (Unshakable Response)'
      : 'Unshakable Response';

  String get virtueJoy => isHindi ? 'प्रसन्नता' : 'Genuine Joy & Grace';
  String get virtueJoyDesc => isHindi
      ? 'आंतरिक आनंद व सौम्यता (Internal Grounding)'
      : 'Internal Grounding';

  String get virtueRestraint => isHindi ? 'संयम' : 'Tactical Restraint';
  String get virtueRestraintDesc => isHindi
      ? 'रणनीतिक मौन व आत्म-नियंत्रण (Strategic Silence)'
      : 'Strategic Silence';

  String get addTraitEntry => isHindi
      ? 'नया सद्गुण प्रविष्टि जोड़ें'
      : 'Add Trait Entry';
  String get traitObservationNote => isHindi
      ? 'अनुभव एवं आचरण टिप्पणी'
      : 'Observation / Reflection Note';
  String get traitDictatePrompt => isHindi
      ? 'बोलकर लिखें (Voice Dictation)'
      : 'Dictate via Voice-to-Text';

  // -------------------------------------------------------------
  // Execution Triggers & Commitment Chimes
  // -------------------------------------------------------------
  String get executionChimesTitle => isHindi
      ? 'कर्म-घोष (संकल्प नाद)'
      : 'Execution Chimes';
  String get executionChimesSubtitle => isHindi
      ? 'अनिवार्य दैनिक कर्म-खंड'
      : 'Non-negotiable daily blocks';
  String get zeroSnoozePhilosophy => isHindi
      ? 'शून्य-विलंब संकल्प (Zero-Snooze)'
      : 'Zero-Snooze Philosophy';
  String get markAsExecuted => isHindi
      ? 'कर्म संपन्न अंकित करें'
      : 'Mark as Executed';
  String get executedToday => isHindi
      ? 'आज संपन्न हुआ'
      : 'Executed Today';
  String get executionGongTone => isHindi
      ? 'गहन संकल्प घंटा ध्वनि'
      : 'Deep Gong Chime';

  // -------------------------------------------------------------
  // Navigation Tabs & Screen Labels
  // -------------------------------------------------------------
  String get navDashboard => isHindi ? 'कमांड केंद्र' : 'Dashboard';
  String get navDebrief => isHindi ? 'दैनिक समीक्षा' : 'Debrief';
  String get navVault => isHindi ? 'प्रज्ञा कोष' : 'Vault';
  String get navSettings => isHindi ? 'सेटिंग्स' : 'Settings';

  // -------------------------------------------------------------
  // Cognition Vault & Sub-Tabs
  // -------------------------------------------------------------
  String get cognitionVaultTitle => isHindi ? 'प्रज्ञा कोष' : 'COGNITION VAULT';
  String get cognitionVaultSubtitle => isHindi
      ? 'मानसिक मॉडल, अध्ययन सामग्री व आनंद कोष'
      : 'Mental models, wisdom anchors & soul sanctuary';
  String get segmentFallacies => isHindi ? 'तर्क-दोष व मॉडल' : 'FALLACIES & MODELS';
  String get segmentResources => isHindi ? 'अध्ययन सामग्री' : 'RESOURCES';
  String get segmentJoy => isHindi ? 'आनंद कोष' : 'JOY RESERVOIR';
  String get segmentHtmlTools => isHindi ? 'ऑफ़लाइन टूल्स' : 'HTML TOOLS';

  // -------------------------------------------------------------
  // Joy Reservoir (Soul Sanctuary)
  // -------------------------------------------------------------
  String get joyReservoirTitle => isHindi ? 'आनंद कोष' : 'Joy Reservoir';
  String get joyReservoirSubtitle => isHindi
      ? 'आत्म-प्रसन्नता व शांति धाम'
      : 'The Things I Love / Soul Sanctuary';
  String get joyReservoirDesc => isHindi
      ? 'व्यक्तिगत प्रसन्नता, मानसिक शांति व आंतरिक शक्ति का सुरक्षित संचय।'
      : 'A dedicated space designed to house personal sources of joy, serenity, and grounding.';
  String get addJoyAnchor => isHindi ? 'आनंद लंगर जोड़ें' : 'Add Joy Anchor';

  // -------------------------------------------------------------
  // Offline HTML Tools & Dashboards
  // -------------------------------------------------------------
  String get htmlToolsTitle => isHindi
      ? 'व्यक्तिगत ऑफ़लाइन HTML टूल्स व डैशबोर्ड'
      : 'Personal HTML Tools & Dashboards';
  String get importHtmlButton => isHindi
      ? 'HTML फ़ाइल आयात करें'
      : 'Import HTML File';
  String get localHtmlSandbox => isHindi
      ? 'स्थानीय ऑफ़लाइन सैंडबॉक्स'
      : 'Local Offline Sandbox';

  // -------------------------------------------------------------
  // Post-Incident Recovery & Slip-Up Logger
  // -------------------------------------------------------------
  String get slipUpRecoveryButton => isHindi
      ? 'स्खलन / विचलन दर्ज करें (पुनः स्थिति)'
      : 'Log a Slip-Up / Reset';
  String get postIncidentRecoveryTitle => isHindi
      ? 'घटना-उपरांत मानसिक पुनर्प्राप्ति'
      : 'Post-Incident Recovery';
  String get damageControlScripts => isHindi
      ? 'रणनीतिक संकट निवारण सूत्र'
      : 'Damage Control Scripts';
  String get addDefensiveScript => isHindi
      ? 'नया रक्षात्मक सूत्र जोड़ें'
      : 'Add Defensive Script';
  String get editDefensiveScript => isHindi
      ? 'रक्षात्मक सूत्र संपादित करें'
      : 'Edit Defensive Script';
  String get deleteScript => isHindi ? 'सूत्र हटाएं' : 'Delete Script';
  String get confirmDeleteScriptMsg => isHindi
      ? 'क्या आप वाकई इस रक्षात्मक सूत्र को हटाना चाहते हैं?'
      : 'Are you sure you want to delete this defensive script?';
  String get hostileTriggerLabel => isHindi
      ? 'उकसावा अथवा आक्रामक वक्तव्य'
      : 'Hostile Trigger / Provocation';
  String get defensiveScriptLabel => isHindi
      ? 'सटीक रक्षात्मक उत्तर (सूत्र)'
      : 'Defensive Response Script';
  String get subtextLabel => isHindi
      ? 'आंतरिक मंतव्य व मनोवैज्ञानिक रणनीति'
      : 'Subtext / Tactical Rationale';
  String get toneGuidanceLabel => isHindi
      ? 'स्वर एवं शारीरिक भाव निर्देश'
      : 'Tone & Posture Guidance';
  String get resetToDefaultScripts => isHindi
      ? 'मूल फ़ैक्टरी सूत्रों पर रीसेट करें'
      : 'Reset to Factory Blueprints';

  String get postMortemAndDrills => isHindi
      ? 'घटना-समीक्षा व अभ्यास'
      : 'POST-MORTEM & DRILLS';
  String get emergencyPerspectiveTab => isHindi
      ? 'आपातकालीन दृष्टिकोण (६० से.)'
      : 'EMERGENCY PERSPECTIVE (60s)';
  String get emergencyPerspectiveBadge => isHindi
      ? '६०-सेकंड आपातकालीन दृष्टिकोण'
      : '60-SECOND EMERGENCY PERSPECTIVE';
  String get detachEgoRegainFrame => isHindi
      ? 'अहंकार-मुक्ति • मानसिक संतुलन'
      : 'DETACH EGO • REGAIN FRAME';
  String get detachEgoDescription => isHindi
      ? 'प्रशंसा व निंदा से अपने अहंकार को विलग करें। कोई भी कदम उठाने से पूर्व कालातीत प्रज्ञा में स्वयं को स्थिर करें।'
      : 'Detach your ego from praise and blame. Ground yourself in timeless stoic sovereignty before taking action.';
  String get selectEmergencyProtocol => isHindi
      ? 'आपातकालीन सूत्र चुनें'
      : 'SELECT EMERGENCY PROTOCOL';
  String get executiveTakeawayEgoDetachment => isHindi
      ? 'कार्यकारी निष्कर्ष • अहंकार-मुक्ति'
      : 'EXECUTIVE TAKEAWAY • EGO DETACHMENT';
  String get executiveActionTakeaway => isHindi
      ? 'कार्यकारी क्रियात्मक निष्कर्ष'
      : 'EXECUTIVE ACTION TAKEAWAY';
  String get boxBreathingAction => isHindi
      ? 'बॉक्स ब्रीदिंग'
      : 'BOX BREATHING';
  String get boxBreathing2M => isHindi
      ? 'बॉक्स ब्रीदिंग (२ मिनट)'
      : 'BOX BREATHING (2M)';
  String get twoMinuteBoxBreathing => isHindi
      ? '२-मिनट बॉक्स ब्रीदिंग अभ्यास'
      : '2-MINUTE BOX BREATHING DRILL';
  String get damageControl => isHindi
      ? 'संकट नियंत्रण'
      : 'DAMAGE CONTROL';
  String get damageControlScriptsOptional => isHindi
      ? 'रणनीतिक संकट निवारण सूत्र (वैकल्पिक)'
      : 'DAMAGE CONTROL SCRIPTS (OPTIONAL)';
  String get frameRestoredAction => isHindi
      ? 'संतुलन पुनर्स्थापित'
      : 'FRAME RESTORED';
  String get thirtySecondPostMortem => isHindi
      ? '१. ३०-सेकंड घटना-समीक्षा'
      : '1. 30-SECOND POST-MORTEM';
  String get prevAction => isHindi ? 'पिछला' : 'PREV';
  String get nextAction => isHindi ? 'अगला' : 'NEXT';
  String get listenToEmergencyPerspective => isHindi
      ? 'आपातकालीन दृष्टिकोण सुनें'
      : 'Listen to emergency perspective';

  // -------------------------------------------------------------
  // Daily Journal & Evening Audit (3-Index Debrief)
  // -------------------------------------------------------------
  String get dailyJournalTitle => isHindi
      ? 'त्रिसूत्री दैनिक समीक्षा'
      : '3-Index Daily Debrief';
  String get eveningAuditSubtitle => isHindi
      ? '६०-सेकंड संध्या आत्म-निरीक्षण'
      : '60s Evening Audit';
  String get saveDebriefButton => isHindi
      ? 'समीक्षा सुरक्षित करें'
      : 'Save Daily Debrief';
  String get debriefLoggedScore => isHindi
      ? 'दर्ज समत्व'
      : 'Logged Score';
  String get eveningLogBadge => isHindi
      ? '६०-सेकंड संध्या समीक्षा'
      : '60-SECOND EVENING LOG';
  String get dailyClosureTitle => isHindi
      ? 'दैनिक हिसाब (Daily Closure)'
      : 'Daily Closure (Evening Audit)';
  String get debriefLockedBadge => isHindi
      ? 'हिसाब बंद (LOCKED)'
      : 'LOCKED (DEBRIEF COMPLETED)';
  String get debriefPendingBadge => isHindi
      ? 'लंबित (PENDING)'
      : 'PENDING';
  String get dailyClosureDesc => isHindi
      ? '60 सेकंड में मानसिक शटडाउन। उकसावे पर चित्त की स्थिरता, मर्यादा की जाँच और आज का ठोस आउटपुट दर्ज करें।'
      : '60-second mental shutdown. Record reaction composure under provocation, boundary integrity, and core solid output.';
  String get tab3IndexDebrief => isHindi
      ? '३-सूत्री समीक्षा'
      : '3-INDEX DEBRIEF';
  String get tabMediaVault => isHindi
      ? 'मीडिया कोष'
      : 'MEDIA VAULT';

  // Index 01: Reaction Score
  String get index01Badge => isHindi ? 'सूचकांक ०१' : 'INDEX 01';
  String get index01Title => isHindi ? 'प्रतिक्रिया समत्व' : 'REACTION SCORE';
  String get index01Question => isHindi
      ? 'आज उकसावे पर चित्त कितना स्थिर रहा?'
      : 'How composed was your mind under provocation today?';
  String reactionScoreLabel(int score) {
    if (isHindi) {
      switch (score) {
        case 1:
          return '१: नियंत्रण खोया (भड़का)';
        case 2:
          return '२: तनाव में बोला (उद्विग्न)';
        case 3:
          return '३: तटस्थ व सामान्य';
        case 4:
          return '४: पूर्ण नियंत्रण (स्थिर चित्त)';
        case 5:
          return '५: स्थितप्रज्ञ (अचल समत्व)';
        default:
          return '३: तटस्थ व सामान्य';
      }
    } else {
      switch (score) {
        case 1:
          return '1: Lost Control (Agitated)';
        case 2:
          return '2: Under Strain (Reactive)';
        case 3:
          return '3: Neutral / Composed';
        case 4:
          return '4: High Poise (Controlled)';
        case 5:
          return '5: Absolute Stoic Poise';
        default:
          return '3: Neutral / Composed';
      }
    }
  }

  // Index 02: Boundary Integrity
  String get index02Badge => isHindi ? 'सूचकांक ०२' : 'INDEX 02';
  String get index02Title => isHindi ? 'मर्यादा व सीमा रक्षा' : 'BOUNDARY INTEGRITY';
  String get boundaryMaintainedBadge => isHindi ? 'मर्यादा सुरक्षित' : 'BOUNDARY PRESERVED';
  String get boundaryCompromisedBadge => isHindi ? 'सीमा खंडित' : 'BOUNDARY COMPROMISED';
  String get index02Question => isHindi
      ? 'क्या आज बिना सफाई दिए \'ना\' कहने की मर्यादा बची रही?'
      : 'Did you preserve dignity by saying \'No\' without over-explaining?';
  String get boundaryYesButton => isHindi
      ? 'हाँ (मर्यादा सुरक्षित)'
      : 'YES (Boundary Preserved)';
  String get boundaryNoButton => isHindi
      ? 'नहीं (समझौता हुआ)'
      : 'NO (Compromised)';

  // Index 03: Core Solid Output
  String get index03Badge => isHindi ? 'सूचकांक ०३' : 'INDEX 03';
  String get index03Title => isHindi ? 'ठोस मौलिक आउटपुट' : 'CORE SOLID OUTPUT';
  String get index03Tag => isHindi ? 'मौलिक • एक पंक्ति' : 'ZERO-AI • SINGLE-LINE';
  String get index03OutputQuestion => isHindi
      ? 'आज का सबसे ठोस, मौलिक (Zero-AI) आउटपुट:'
      : 'Today\'s single most solid, original (Zero-AI) output:';
  String get index03OutputHint => isHindi
      ? 'उदा. कॉर्पोरेट टैक्स पर 800 शब्दों का एक्सक्लूसिव विश्लेषण'
      : 'e.g. 800-word deep analytical breakdown on corporate policy';
  String get index03ProvocationQuestion => isHindi
      ? 'उकसावे का समाधान / रणनीतिक सीख (Optional 1-liner):'
      : 'Provocation resolution / Tactical insight (Optional 1-liner):';
  String get index03ProvocationHint => isHindi
      ? 'उदा. मीटिंग में 4 सेकंड पॉज देकर बात संभाली'
      : 'e.g. Took a 4-second pause before answering in the team sync';

  // Media Audit Section
  String get mediaAuditBadge => isHindi ? 'मीडिया समीक्षा' : 'MEDIA AUDIT';
  String get mediaAuditTitle => isHindi ? 'चिंतनशील मीडिया (वैकल्पिक)' : 'REFLECTIVE MEDIA (OPTIONAL)';
  String get onDeviceBadge => isHindi ? 'शत-प्रतिशत डिवाइस पर' : '100% ON-DEVICE';
  String get mediaAuditDesc => isHindi
      ? 'त्वरित मौखिक ऑडियो मेमो या 60-सेकंड का शांत भाव मुद्रा वीडियो दर्ज करें।'
      : 'Capture a discreet verbal audio memo or a 60-second front-camera composure review.';
  String get verbalMemoAttached => isHindi ? 'ऑडियो मेमो संलग्न' : 'VERBAL MEMO ATTACHED';
  String get quickAudioMemo => isHindi ? 'त्वरित ऑडियो मेमो' : 'QUICK AUDIO MEMO';
  String get audioMemoSavedSub => isHindi
      ? 'समीक्षा के साथ ऑफ़लाइन ऑडियो सुरक्षित'
      : 'Local audio note saved with audit';
  String get audioMemoRecordSub => isHindi
      ? 'शांत स्वर में आत्म-चिंतन रिकॉर्ड करें'
      : 'Record discrete spoken reflections';
  String get videoDrillSaved => isHindi ? 'वीडियो समीक्षा सुरक्षित' : 'VIDEO DRILL SAVED';
  String get videoDrillTitle => isHindi ? '६०-से. मुद्रा समीक्षा' : '60S VIDEO DRILL';
  String get videoDrillSavedSub => isHindi
      ? 'चेहरे व मुद्रा की शांत समीक्षा दर्ज'
      : 'Front-lens posture review recorded';
  String get videoDrillRecordSub => isHindi
      ? 'शारीरिक स्थिरता व जबड़े का तनाव जांचें'
      : 'Review jaw poise and physical calmness';
  String get openFullMediaVault => isHindi
      ? 'सम्पूर्ण मीडिया कोष एवं सुरक्षित संग्रह खोलें'
      : 'OPEN FULL MEDIA VAULT & STEALTH REPOSITORY';

  // Bottom Buttons
  String get lockDayButton => isHindi
      ? 'हिसाब बंद करें (Lock Day)'
      : 'Lock Daily Debrief';
  String get updateDayButton => isHindi
      ? 'हिसाब अपडेट करें (Update Lock)'
      : 'Update Daily Debrief';

  // Past Debriefs List
  String pastDebriefsCount(int count) => isHindi
      ? 'दैनिक हिसाब इतिहास ($count)'
      : 'Daily Debrief History ($count)';
  String get noPastDebriefsMsg => isHindi
      ? 'कोई पूर्व दैनिक हिसाब उपलब्ध नहीं'
      : 'No past debrief logs available yet';
  String get noPastDebriefsSub => isHindi
      ? 'आज का 60-सेकंड हिसाब ऊपर पूरा करें।'
      : 'Complete today\'s 60-second audit above to start your streak.';

  // -------------------------------------------------------------
  // Settings Screen & Notification Controls
  // -------------------------------------------------------------
  String get executiveSettings => isHindi
      ? 'कार्यकारी सेटिंग्स'
      : 'EXECUTIVE SETTINGS';
  String get shieldNotificationTiming => isHindi
      ? 'कवच एवं स्मरण समय'
      : 'Shield & Notification Timing';
  String get masterSwitchTitle => isHindi
      ? 'कार्यकारी कवच सूचनाएं'
      : 'EXECUTIVE SHIELD NOTIFICATIONS';
  String get masterSwitchSub => isHindi
      ? 'दैनिक शास्त्रीय आत्म-निरीक्षण एवं सामयिक संकेत'
      : 'Canonical daily Stoic checkpoints and situational reminders';
  String get configuredCheckpoints => isHindi
      ? 'निर्धारित समय-खंड'
      : 'CONFIGURED CHECKPOINTS';
  String get addCustomCheckpoint => isHindi
      ? 'नया समय-खंड जोड़ें'
      : 'ADD CUSTOM CHECKPOINT';
  String get resetToFactoryBlueprint => isHindi
      ? 'मूल स्वरूप में रीसेट करें (४ मुख्य स्लॉट)'
      : 'Reset to Factory Blueprint (4 Canonical Slots)';
  String get languageSectionTitle => isHindi
      ? 'भाषा एवं माध्यम'
      : 'LANGUAGE & LOCALIZATION';
  String get languageSectionSub => isHindi
      ? 'उच्च-स्तरीय अंग्रेज़ी एवं प्रामाणिक हिन्दी में से चुनें'
      : 'Toggle between high-register English and authentic Hindi';

  // -------------------------------------------------------------
  // Common Actions & Badges
  // -------------------------------------------------------------
  String get save => isHindi ? 'सुरक्षित करें' : 'Save';
  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  String get delete => isHindi ? 'हटाएं' : 'Delete';
  String get edit => isHindi ? 'संपादित करें' : 'Edit';
  String get close => isHindi ? 'बंद करें' : 'Close';
  String get done => isHindi ? 'संपन्न' : 'Done';
  String get reset => isHindi ? 'रीसेट करें' : 'Reset';
  String get share => isHindi ? 'साझा करें' : 'Share';
  String get copy => isHindi ? 'कॉपी करें' : 'Copy';
  String get search => isHindi ? 'खोजें' : 'Search';
  String get filter => isHindi ? 'फ़िल्टर' : 'Filter';
  String get all => isHindi ? 'सभी' : 'All';
  String get dayStreakLabel => isHindi
      ? 'दिवसीय समत्व शृंखला'
      : 'DAY STOIC POISE STREAK';
  String get listenWithCalmVoice => isHindi
      ? 'शांत स्वर में सुनें'
      : 'Listen with calm voice';
  String get stopNarration => isHindi
      ? 'स्वर पाठ रोकें'
      : 'Stop narration';
  String get english => 'English';
  String get hindi => 'हिन्दी';

  // -------------------------------------------------------------
  // Bilingual Stoic Rules & Aphorisms
  // -------------------------------------------------------------
  String get dailyTriggerDatasetBadge => isHindi
      ? 'दैनिक सूत्र (डेटासेट)'
      : 'DAILY TRIGGER (DATASET)';
  String get coreStoicRuleBadge => isHindi
      ? 'शास्त्रीय स्थितप्रज्ञ नियम'
      : 'CORE STOIC RULE';
  String get wisdomOfTheDayBadge => isHindi
      ? 'आज का प्रज्ञा सूत्र'
      : 'WISDOM OF THE DAY';

  /// Returns authentic high-register Hindi translation of daily rules
  String getRuleTitle(int id, String fallback) {
    if (!isHindi) return fallback;
    switch (id) {
      case 1:
        return '४-सेकंड रणनीतिक मौन (विराम)';
      case 2:
        return 'नियंत्रण का द्वैत (Locus of Control)';
      case 3:
        return 'अचल शिला (स्थिर प्रस्तर)';
      case 4:
        return 'पूर्वाभ्यास: कटुता का पूर्व-बोध';
      case 5:
        return 'पद व उपाधि से पृथक् आत्म-भाव';
      case 6:
        return 'आहत होने से प्रत्यक्ष इनकार';
      case 7:
        return 'विशाल ब्रह्मांडीय दृष्टिकोण';
      case 8:
        return 'स्थितप्रज्ञ (अटल प्रज्ञा)';
      case 9:
        return 'कठोर व्यक्तिगत सीमा रक्षा';
      case 10:
        return 'बाधा को ही मार्ग बनाना';
      case 11:
        return 'विकल्प देकर चरित्र की परीक्षा';
      default:
        return fallback;
    }
  }

  String getRuleAphorism(int id, String fallback) {
    if (!isHindi) return fallback;
    switch (id) {
      case 1:
        return 'कटु वचन या प्रहार स्वयं में अपमान नहीं हैं। अपमानजनक केवल उनके प्रति आपकी अपनी धारणा है।';
      case 2:
        return 'कुछ वस्तुएं हमारे नियंत्रण में हैं और कुछ नहीं। हमारे विचार, इच्छाएं और स्वयं के कर्म हमारे वश में हैं; बाह्य जगत नहीं।';
      case 3:
        return 'उस चट्टान के समान बनो जिससे निरंतर लहरें टकराती हैं, किंतु वह अडिग रहकर जल के उन्माद को शांत कर देती है।';
      case 4:
        return 'प्रातः जागते ही स्वयं से कहो: आज मेरा सामना कृतघ्न, अहंकारी, कुटिल, ईर्ष्यालु और असभ्य व्यक्तियों से होगा।';
      case 5:
        return 'जो पद और मान-प्रतिष्ठा से लिपटता है, उसके लुप्त होने पर वह दोहरा आघात सहता है। तुम्हारी आत्मा किसी नियोक्ता के अधीन नहीं है।';
      case 6:
        return 'आहत न होने का संकल्प लो—और तुम आहत नहीं होओगे। जब आहत अनुभव नहीं करोगे—तो कोई तुम्हारा अहित नहीं कर सकता।';
      case 7:
        return 'संपूर्ण सृष्टि के विस्तार और काल के अनन्त प्रवाह का विचार करो; उसमें तुम्हारी यह क्षुद्र उलझन कितनी नगण्य है।';
      case 8:
        return 'दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः। वीतरागभयक्रोधः स्थितधीर्मुनिरुच्यते॥ (दुःख में उद्वेग रहित, सुख की तृष्णा से मुक्त, राग-भय-क्रोध रहित मन ही स्थितप्रज्ञ है।)';
      case 9:
        return 'सब कुछ प्राप्त कर लेना किसी के हाथ में नहीं, किंतु जो नहीं है उसकी व्यर्थ कामना न करना और जो प्राप्त है उसका श्रेष्ठ उपयोग करना पूर्णतः संभव है।';
      case 10:
        return 'कार्य में आने वाली बाधा ही कर्म को आगे बढ़ाती है। जो मार्ग रोकता है, वही नया मार्ग बन जाता है।';
      case 11:
        return 'सच्चा मंतव्य उजागर करने हेतु स्पष्ट विकल्प प्रस्तुत करो—प्राथमिकताएं ही चरित्र को प्रकट करती हैं।';
      default:
        return fallback;
    }
  }

  String getRuleTacticalAction(int id, String fallback) {
    if (!isHindi) return fallback;
    switch (id) {
      case 1:
        return 'बैठक में आक्षेप होने पर बोलने से पहले पूरे ४ सेकंड प्रतीक्षा करें। मौन को उनके भावात्मक वेग को सोखने दें।';
      case 2:
        return 'पहचानें कि इस संकट में आपका वास्तविक दायित्व क्या है और नेतृत्व की घबराहट क्या। केवल अपने कर्म पर ध्यान दें, नाटक की उपेक्षा करें।';
      case 3:
        return 'सपाट एवं शांत स्वर में उत्तर दें। उच्च स्वर घबराहट दर्शाता है; धीर व गंभीर स्वर आत्म-नियंत्रण और प्रभावशीलता प्रकट करता है।';
      case 4:
        return 'दोपहर १ बजे से पहले तीन अतार्किक मांगों की पूर्व-अपेक्षा रखें। चूंकि आपने उनका पूर्वाभ्यास किया है, वे आपके तंत्रिका-तंत्र को विचलित नहीं करेंगी।';
      case 5:
        return 'स्वयं को स्मरण कराएं: आप एक संप्रभु, कुशल परामर्शदाता हैं, न कि किसी अधिकारी से कृपा या प्रशंसा के आकांक्षी बालक।';
      case 6:
        return 'आलोचनात्मक ईमेल्स को अपनी योग्यता पर आक्रमण न मानें। उन्हें केवल प्रेषक के व्यक्तिगत तनाव और चिंता के डेटा के रूप में पढ़ें।';
      case 7:
        return 'पूछें: "क्या यह छूटी हुई समय-सीमा या विलंबित प्रस्तुति ३६ महीनों बाद भी मायने रखेगी?" यदि नहीं, तो इसे ३६ सेकंड का उद्वेग भी न दें।';
      case 8:
        return 'प्रशंसा से अहंकार न बढ़ाएं; आक्षेप से हीन न हों। अपने आचरण, कोड और कर्तव्यों के वस्तुनिष्ठ सत्य में स्वयं को स्थापित रखें।';
      case 9:
        return 'निर्धारित समय के बाद कार्य-संवाद बंद करें। एक अनुत्तरित संदेश किसी की जान नहीं लेता; अत्यधिक सहज उपलब्धता आपके समत्व को समाप्त कर देती है।';
      case 10:
        return 'विषाक्त प्रबंधक को अवरोध न मानकर अपनी सीमा-रक्षा एवं संवाद-दक्षता को सुदृढ़ करने वाला प्रतिद्वंद्वी समझें।';
      case 11:
        return 'अस्पष्ट या कुटिल संवाद पर दो स्पष्ट परिचालन विकल्प दें। उनका चुनाव उनके वास्तविक उद्देश्य को लिखित रूप में सिद्ध कर देगा।';
      default:
        return fallback;
    }
  }

  // -------------------------------------------------------------
  // Comprehensive Screen-Level Localizations & Actions
  // -------------------------------------------------------------
  String get eveningDebriefStatusTitle => isHindi
      ? 'दैनिक हिसाब (संध्या समीक्षा)'
      : 'DAILY CLOSURE (EVENING LOG)';
  String get statusCompleted => isHindi ? '• पूर्ण' : '• COMPLETED';
  String get statusPending => isHindi ? '• लंबित' : '• PENDING';
  String get eveningAuditPrompt => isHindi
      ? 'उकसावे पर चित्त की स्थिरता व मर्यादा का 60-सेकंड ऑडिट करें।'
      : '60-second audit of reaction composure and boundary integrity under provocation.';
  String get viewAction => isHindi ? 'देखें' : 'VIEW';
  String get startAction => isHindi ? 'आरंभ' : 'START';

  // Wisdom of the Day Card
  String get wisdomOfTheDayTitle => isHindi ? 'आज का प्रज्ञा सूत्र' : 'WISDOM OF THE DAY';
  String get todaysAffirmationTitle => isHindi ? 'आज का संकल्प' : 'TODAY\'S AFFIRMATION';
  String get listenWisdomReadout => isHindi ? 'प्रज्ञा पाठ सुनें' : 'Listen to wisdom readout';
  String get cycleNextWisdom => isHindi ? 'अगला प्रज्ञा सूत्र देखें' : 'Cycle next wisdom';
  String get openWisdomVault => isHindi ? 'प्रज्ञा कोष खोलें' : 'Open Wisdom Vault';
  String get affirmedForToday => isHindi ? 'आज का संकल्प स्वीकृत' : 'AFFIRMED FOR TODAY';
  String get setAsTodaysAffirmation => isHindi ? 'आज का संकल्प बनाएं' : 'SET AS TODAY\'S AFFIRMATION';
  String setAffirmationSuccess(String title) => isHindi
      ? '"$title" को आज का संकल्प बनाया गया।'
      : 'Set "$title" as Today\'s Affirmation.';

  // Sovereign Traits & Micro Ignition
  String get sovereignTraitsBadge => isHindi ? 'चरित्र कोष' : 'SOVEREIGN TRAITS';
  String get microIgnitionAction => isHindi ? 'सूक्ष्म गति' : '5-MIN IGNITION';
  String get microIgnitionRule => isHindi ? 'सूक्ष्म गति • ५-मिनट नियम' : 'Micro-Ignition • 5-Min Rule';
  String get microIgnitionQuestion => isHindi
      ? 'आप अभी किस कार्य का आरंभ कर रहे हैं?'
      : 'What task are you executing right now?';
  String get microIgnitionDescription => isHindi
      ? 'मात्र ५ मिनट का संकल्प। परिणाम की चिंता त्यागें।\nगति आरंभ होते ही मानसिक प्रतिरोध समाप्त हो जाता है।'
      : 'Commit to just 5 minutes without hesitation. Done is better than perfect.\nMomentum breaks all resistance.';

  // Pulse & Box Breathing
  String get breathInhaleVisual => isHindi ? 'श्वास लें (३ से.)' : 'INHALE (3s)';
  String get breathHoldVisual => isHindi ? 'कुंभक / रोकें (३ से.)' : 'HOLD & DETACH (3s)';
  String get breathExhaleVisual => isHindi ? 'श्वास छोड़ें (३ से.)' : 'EXHALE CORTISOL (3s)';
  String get breathNavelExpand => isHindi
      ? 'नाभि नीचे • फेफड़ों का विस्तार'
      : 'Diaphragmatic expansion • Lower belly';
  String get breathSteadfastObserver => isHindi
      ? 'अचल साक्षी भाव बनाए रखें'
      : 'Maintain steadfast detached observer';
  String get breathReleaseCortisol => isHindi
      ? 'तनाव विसर्जन • कंधों को शिथिल करें'
      : 'Release cortisol • Drop shoulder tension';
  String get looseTeethInstruction => isHindi
      ? 'दाँत ढीले रखें • जीभ तालू से सटाएं • पैर जमीन पर'
      : 'Unclench jaw • Tongue to palate • Feet grounded';
  String get observeToneInstruction => isHindi
      ? 'सामने वाले की टोन और आंखों का विचलन केवल देखें।'
      : 'Observe tone and eye deflection with zero emotional absorption.';

  // Defensive Scripts
  String get addScriptAction => isHindi ? '+ नया सूत्र' : '+ Add Script';
  String get noScriptsInCategory => isHindi
      ? 'इस श्रेणी में कोई सूत्र नहीं है'
      : 'No defensive scripts in this category';
  String get tapToAddScriptHint => isHindi
      ? 'नया सूत्र जोड़ने के लिए नीचे दिए बटन पर टैप करें।'
      : 'Tap the button below to add a custom blueprint.';
  String get categoryHeaderLabel => isHindi ? 'श्रेणी' : 'CATEGORY';
  String get customCategoryOption => isHindi ? '+ अन्य श्रेणी' : '+ Custom';
  String get enterCustomCategoryHint => isHindi
      ? 'कस्टम श्रेणी का नाम दर्ज करें'
      : 'Enter custom category name';
  String get pleaseEnterCategoryError => isHindi
      ? 'कृपया श्रेणी नाम दर्ज करें'
      : 'Please enter category name';
  String get provocationExampleHint => isHindi
      ? 'उदाहरण: "इस काम में कोई दम नहीं है / Your approach makes no sense"'
      : 'e.g. "Your approach makes no sense / I need this right now"';
  String get pleaseEnterProvocationError => isHindi
      ? 'कृपया उकसावा वक्तव्य दर्ज करें'
      : 'Please enter provocation statement';
  String get scriptExactWordsHint => isHindi
      ? 'सटीक शब्द जो आपको शांति से बोलने हैं...'
      : 'Exact words to speak with unhurried poise...';
  String get pleaseEnterScriptError => isHindi
      ? 'कृपया रक्षात्मक सूत्र दर्ज करें'
      : 'Please enter defensive response script';
  String get subtextExampleHint => isHindi
      ? 'उदाहरण: "कभी सफाई न दें। गेंद उनके पाले में डालें।"'
      : 'e.g. "Never over-explain. Return the ball to their court."';
  String get toneExampleHint => isHindi
      ? 'उदाहरण: "तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।"'
      : 'e.g. "Neutral, flat monotone, zero smile, 3s eye-contact."';
  String get scriptSavedMsg => isHindi
      ? 'रक्षात्मक सूत्र सुरक्षित किया गया'
      : 'Defensive script saved.';
  String get scriptUpdatedMsg => isHindi
      ? 'रक्षात्मक सूत्र अपडेट किया गया'
      : 'Defensive script updated.';
  String get scriptDeletedMsg => isHindi
      ? 'रक्षात्मक सूत्र हटा दिया गया'
      : 'Defensive script deleted.';
  String get confirmResetAllScriptsMsg => isHindi
      ? 'क्या आप सभी रक्षात्मक सूत्रों को मूल फ़ैक्टरी स्थिति में रीसेट करना चाहते हैं?'
      : 'Reset all defensive scripts to factory blueprint?';
  String get allScriptsResetMsg => isHindi
      ? 'सभी रक्षात्मक सूत्र मूल स्थिति में रीसेट कर दिए गए'
      : 'All defensive scripts reset to factory defaults.';

  // Journal Feedback & Validations
  String get outputRequiredError => isHindi
      ? 'आउटपुट अनिवार्य है: आज का कोई एक ठोस deliverable या सीख दर्ज करें।'
      : 'Output required: Record at least one solid deliverable or key learning.';
  String debriefSavedConfirmation(int score) => isHindi
      ? 'आज का हिसाब पूरा हुआ। तनाव यहीं विसर्जित है। (समत्व: $score%)'
      : 'Daily audit locked. Stress released at the threshold. (Equanimity: $score%)';
  String get oralAudioNote => isHindi ? 'मौखिक हिसाब (Audio Note)' : 'Audio Reflection Note';
  String get physicalComposureDrill => isHindi ? 'आंगिक स्थिरता (Composure Drill)' : 'Physical Composure Video Drill';
  String get yesLabel => isHindi ? 'हाँ' : 'YES';
  String get noLabel => isHindi ? 'नहीं' : 'NO';
  String get tacticalInsightLabel => isHindi ? 'रणनीतिक सीख' : 'Tactical Insight';
  String get updateAction => isHindi ? 'बदलें' : 'UPDATE';
  String get recordAction => isHindi ? 'रिकॉर्ड' : 'RECORD';
  String get retakeAction => isHindi ? 'पुनः लें' : 'RETAKE';
  String get reviewAction => isHindi ? 'समीक्षा' : 'REVIEW';

  // Badges & Toolbars
  String get systemShareInterceptor => isHindi
      ? 'शेयर इंटरसेप्टर • सहेजें'
      : 'SYSTEM SHARE INTERCEPTOR • SAVE';
  String get offlineLocalTools => isHindi
      ? 'ऑफ़लाइन वास्तुकला • स्थानीय उपकरण'
      : 'OFFLINE ARCHITECTURE • LOCAL TOOLS';
  String get soulSanctuaryBadge => isHindi
      ? 'शांति धाम • आनंद कोष'
      : 'SOUL SANCTUARY • JOY RESERVOIR';
  String get activeLanguageLabel => isHindi
      ? 'वर्तमान भाषा: हिन्दी'
      : 'Active Language: English';
  String get wisdomCardsTab => isHindi ? 'प्रज्ञा पत्र' : 'WISDOM CARDS';
  String get resourceHubTab => isHindi ? 'अध्ययन सामग्री' : 'RESOURCE HUB';
  String get essenceTranslation => isHindi ? 'अनुवाद / सार:' : 'ESSENCE / TRANSLATION:';
  String get tacticalDirectiveLabel => isHindi ? 'रणनीतिक निर्देश:' : 'Tactical Directive:';
  String get tacticalDirectiveBadge => isHindi ? 'रणनीतिक निर्देश' : 'TACTICAL DIRECTIVE';
  String get datasetDailyReminder => isHindi
      ? 'डेटासेट से निर्धारित दैनिक स्मरण (notifications_dataset.json)'
      : 'Scheduled daily reminder from dataset (notifications_dataset.json)';
  String get cycleDatasetSlotsTooltip => isHindi
      ? 'आज के ४ डेटासेट स्लॉट में बदलें'
      : 'Cycle through today\'s 4 dataset slots';
  String get cycleStoicRuleTooltip => isHindi
      ? 'अगले स्थितप्रज्ञ नियम पर जाएं'
      : 'Cycle to next Stoic rule';
  String longestStreakDays(int days) => isHindi
      ? 'सर्वश्रेष्ठ: $days दिन'
      : 'Best: $days days';
  String dayStreak(int days) => isHindi
      ? (days == 1 ? 'दिवस समत्व' : 'दिवसीय समत्व')
      : (days == 1 ? 'DAY STREAK' : 'DAYS STREAK');
  String get commitmentChimeBadge => isHindi
      ? 'प्रतिबद्धता ध्वनि'
      : 'COMMITMENT CHIME';
  String get scoreLabel => isHindi ? 'समत्व स्कोर' : 'Score';

  // Box Breathing Drill
  String get boxBreathingInhaleTitle => isHindi ? 'श्वास लें (पूरक)' : 'INHALE';
  String get boxBreathingHoldFullTitle => isHindi ? 'कुंभक (रोकें)' : 'HOLD FULL';
  String get boxBreathingExhaleTitle => isHindi ? 'श्वास छोड़ें (रेचक)' : 'EXHALE';
  String get boxBreathingHoldEmptyTitle => isHindi ? 'रिक्त कुंभक (शून्य)' : 'HOLD EMPTY';
  String get boxBreathingInhaleGuidance => isHindi
      ? 'नासिका से गहरी उदर-श्वास अंदर लें'
      : 'Deep diaphragmatic breath in through nose';
  String get boxBreathingHoldFullGuidance => isHindi
      ? 'श्वास रोकें। जबड़ा, गर्दन व कंधे शिथिल करें'
      : 'Hold lungs full. Soften jaw, neck & shoulders';
  String get boxBreathingExhaleGuidance => isHindi
      ? 'मुख से मंद, नियंत्रित श्वास बाहर छोड़ें'
      : 'Slow, controlled exhale through mouth';
  String get boxBreathingHoldEmptyGuidance => isHindi
      ? 'शांत शून्यता में रहें। जीभ तालू से सटाएं'
      : 'Rest in stillness. Tongue on roof of mouth';

  // Character Ledger
  String get recordTraitAction => isHindi ? 'सद्गुण दर्ज करें' : 'RECORD TRAIT';
  String totalVirtueRecords(int count) => isHindi
      ? 'कुल सद्गुण प्रविष्टियाँ: $count'
      : 'TOTAL VIRTUE RECORDS: $count';
  String get sovereignEquanimityBadge => isHindi ? 'संप्रभु समत्व' : 'SOVEREIGN EQUANIMITY';
  String get virtueCustom => isHindi ? 'व्यक्तिगत गुण' : 'Custom Trait';
  String get virtueSubMagnanimity => isHindi ? 'बड़ा दिल' : 'Composure';
  String get virtueSubGravitas => isHindi ? 'अडिग भाव' : 'Stillness';
  String get virtueSubJoy => isHindi ? 'प्रसन्नता' : 'Grace';
  String get virtueSubRestraint => isHindi ? 'रणनीतिक मौन' : 'Silence';

  // Defensive Scripts Tone Default
  String get defaultNeutralTone => isHindi
      ? 'तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।'
      : 'Neutral, flat monotone, zero panic or over-explaining.';

  // Recovery Archetypes
  String get archetypeStoicSubtitle => isHindi ? 'स्थितप्रज्ञ' : 'Absolute Poise';
  String get archetypeStoicSample => isHindi
      ? 'भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए? कृपया बिंदु स्पष्ट करें।'
      : 'What specific factual adjustments are required in the formulation? Please specify the exact points.';
  String get archetypeStrategistSubtitle => isHindi ? 'रणनीतिकार' : 'Tactical Restraint';
  String get archetypeStrategistSample => isHindi
      ? 'इस दावे का आधार क्या डेटा है? जब आप बिंदुवार विश्लेषण साझा करेंगे, तब मैं समीक्षा करूँगा।'
      : 'What data substantiates this claim? Once you share the itemized breakdown, I will review it.';
  String get archetypeExecutiveSubtitle => isHindi ? 'प्रशासक' : 'Unruffled Governance';
  String get archetypeExecutiveSample => isHindi
      ? 'वितरण के संबंध में: क्षमता आवंटन से पहले लिखित में अपेक्षाओं को स्पष्ट करें।'
      : 'Regarding deliverables: let\'s calibrate milestone expectations in writing before allocating engineering capacity.';

  // Cognition Vault Descriptions
  String cognitionVaultDesc(int segment) {
    if (isHindi) {
      switch (segment) {
        case 0:
          return 'क्लासिकल स्थितप्रज्ञ श्लोक, पाश्चात्य स्टोइकिज्म एवं कार्यकारी समत्व हेतु व्यावहारिक मनोविज्ञान।';
        case 1:
          return 'सार्वजनिक साहित्य, ऑडियो/वीडियो विश्लेषण एवं आपके व्यक्तिगत Google Drive व Keep नोट्स।';
        case 2:
          return 'बोर्डरूम छल-कपट एवं तार्किक दोषों का विश्लेषण कर शास्त्रीय मॉडल द्वारा निष्प्रभावी करें।';
        case 3:
          return 'आपका व्यक्तिगत शांति धाम (आनंद कोष): उत्साहवर्धक संगीत, दृश्य लंगर, शांत स्मृतियां व सांत्वना सूत्र।';
        default:
          return 'व्यक्तिगत स्वतंत्र HTML डैशबोर्ड, निर्णय कैलकुलेटर एवं स्थानीय जावास्क्रिप्ट संचालित उपकरण।';
      }
    }
    switch (segment) {
      case 0:
        return 'Classic Sthitaprajna shlokas, Western Stoicism, and Behavioral Psychology for unflinching executive composure.';
      case 1:
        return 'Curated public-domain literature, audio/video breakdowns, and your personal Google Drive & Keep notes.';
      case 2:
        return 'Dissect boardroom manipulation tactics and deploy classical Stoic mental models to neutralize bad actors.';
      case 3:
        return 'Your personal soul sanctuary: uplifting music, visual anchors, serene memories, and comfort words.';
      default:
        return 'Personal standalone HTML dashboards, decision calculators, and interactive tools rendered with full local JavaScript.';
    }
  }

  // Settings Notification Checkpoint Names
  String getSlotDisplayName(String slotId, String fallback) {
    if (!isHindi) return fallback;
    switch (slotId) {
      case 'slot_morning':
        return 'प्रातःकालीन लंगर';
      case 'slot_work_entry':
        return 'कार्य-प्रवेश कवच';
      case 'slot_midday':
        return 'मध्याह्न आत्म-समीक्षा';
      case 'slot_night_closure':
        return 'रात्रि विश्राम व समापन';
      default:
        return fallback;
    }
  }

  // Execution Triggers
  String get actionTriggerBadge => isHindi ? 'प्रतिबद्धता ध्वनि' : 'ACTION-TRIGGER';
  String get actionTriggerTitle => isHindi ? 'प्रतिबद्धता ध्वनि' : 'EXECUTION CHIME';
  String get microIgnitionCardTitle => isHindi ? '५-मिनट सूक्ष्म गति टाइमर' : '5-Minute Micro-Ignition Timer';
  String get microIgnitionCardDesc => isHindi
      ? 'टालमटोल मात्र आरंभ बिंदु पर मानसिक प्रतिरोध है। एक टैप से ५ मिनट का काउंटडाउन शुरू करें।'
      : 'Procrastination is merely cognitive friction at the start threshold. Single-tap to begin a discrete 5-minute countdown and dissolve resistance immediately.';
  String get launchMicroIgnitionAction => isHindi
      ? '५-मिनट सूक्ष्म गति अभी आरंभ करें'
      : 'LAUNCH 5-MIN MICRO-IGNITION NOW';
}


/// AppLocalizationsDelegate loads and provides AppLocalizations instances
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Convenient extension on BuildContext to access AppLocalizations via `context.loc`
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
