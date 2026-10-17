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

  // -------------------------------------------------------------
  // Daily Journal & Evening Audit
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
