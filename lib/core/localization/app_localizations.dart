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
      ? 'वाणी रोकें • 4-4-4-4 श्वास चक्र अपनाएं • आंतरिक शक्ति बनाए रखें'
      : 'Zero verbal reaction • 4-4-4-4 Box Breathing • Retain leverage';

  // -------------------------------------------------------------
  // Box Breathing Drill
  // -------------------------------------------------------------
  String get boxBreathingTitle => isHindi
      ? '4-4-4-4 समगति प्राणायाम'
      : '4-4-4-4 Box Breathing';
  String get boxBreathingSubtitle => isHindi
      ? 'नाड़ी तंत्र को शांत करने हेतु नियंत्रित श्वास'
      : 'Regulate nervous system before responding';
  String get breathInhale => isHindi ? 'श्वास लें (4 से.)' : 'Inhale (4s)';
  String get breathHold => isHindi ? 'कुंभक / रोकें (4 से.)' : 'Hold (4s)';
  String get breathExhale => isHindi ? 'श्वास छोड़ें (4 से.)' : 'Exhale (4s)';
  String get breathRest => isHindi ? 'विराम (4 से.)' : 'Rest (4s)';
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
      ? 'संकोच त्यागें। 3-2-1... आरंभ करें।'
      : 'Break hesitation. 3-2-1... Execute.';
  String get microIgnitionAnchor => isHindi
      ? 'अपूर्ण कर्म भी निष्कर्मता से श्रेष्ठ है।'
      : 'Done is better than perfect.';
  String get microIgnitionPhilosophy => isHindi
      ? 'Done is better than perfect. 3-2-1... Execute.'
      : 'Done is better than perfect. 3-2-1... Execute.';
  String get microIgnitionDesc => isHindi
      ? 'विलंबित कर्मों को बिना संकोच आरंभ करने हेतु 5-मिनट सूक्ष्म-गति उलटी गिनती।'
      : 'Single-tap friction-breaker countdown to initiate delayed tasks without hesitation.';
  String get microIgnitionStart => isHindi ? '5-मिनट आरंभ करें' : 'Start 5-Min Timer';
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
      ? 'क्षमा एवं उच्च दृष्टिकोण'
      : 'Big-Hearted Composure';

  String get virtueGravitas => isHindi ? 'गांभीर्य' : 'Gravitas & Stillness';
  String get virtueGravitasDesc => isHindi
      ? 'अचल गंभीरता व स्थिरता'
      : 'Unshakable Response';

  String get virtueJoy => isHindi ? 'प्रसन्नता' : 'Genuine Joy & Grace';
  String get virtueJoyDesc => isHindi
      ? 'आंतरिक आनंद व सौम्यता'
      : 'Internal Grounding';

  String get virtueRestraint => isHindi ? 'संयम' : 'Tactical Restraint';
  String get virtueRestraintDesc => isHindi
      ? 'रणनीतिक मौन व आत्म-नियंत्रण'
      : 'Strategic Silence';

  String get addTraitEntry => isHindi
      ? 'नया सद्गुण प्रविष्टि जोड़ें'
      : 'Add Trait Entry';
  String get traitObservationNote => isHindi
      ? 'अनुभव एवं आचरण टिप्पणी'
      : 'Observation & Reflection Note';
  String get traitDictatePrompt => isHindi
      ? 'बोलकर लिखें'
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
      ? 'शून्य-विलंब संकल्प'
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
  // Navigation Tabs & 3 Core Universal Pillars
  // -------------------------------------------------------------
  String get navDashboard => isHindi ? 'प्रारंभ' : 'Dashboard';
  String get navVault => isHindi ? 'कोष' : 'Vault';
  String get navCognition => isHindi ? 'संज्ञान' : 'Cognition';
  String get navDebrief => isHindi ? 'संज्ञान' : 'Cognition';
  String get navSos => isHindi ? 'ठहराव' : 'SOS';
  String get navSettings => isHindi ? 'सेटिंग्स' : 'Settings';
  String get navMukti => isHindi ? 'मुक्ति' : 'Mukti';

  // -------------------------------------------------------------
  // Mukti — Psychological Freedom MVP (3 Core Practices)
  // -------------------------------------------------------------

  // Mukti Hub Screen
  String get muktiHubTitle => isHindi ? 'मुक्ति' : 'Mukti';
  String get muktiHubSubtitle => isHindi
      ? 'आंतरिक स्वतंत्रता के तीन अभ्यास'
      : 'Three Practices of Psychological Freedom';
  String get muktiPhilosophyBadge => isHindi ? 'दार्शनिक मुक्ति' : 'PSYCHOLOGICAL FREEDOM';
  String get muktiIntroText => isHindi
      ? 'अधिकांश ऐप "तनाव कम करने" की सतही तकनीकें देते हैं। मुक्ति "मनोवैज्ञानिक विमुक्ति" और आंतरिक स्वतंत्रता पर काम करती है।'
      : 'Most apps offer surface-level stress relief. Mukti works on psychological detachment and genuine inner freedom.';

  // Practice 1 — साक्षी विराम (The Sky & Cloud Pause)
  String get witnessTitle => isHindi ? 'साक्षी विराम' : 'Witness Pause';
  String get witnessSubtitle => isHindi
      ? '90 सेकंड में भावना को देखें — दबाएं नहीं'
      : 'Observe emotion for 90 seconds — don\'t suppress it';
  String get witnessPillarBadge => isHindi ? 'साक्षी भाव' : 'WITNESSING';
  String get witnessTriggerButton => isHindi
      ? 'मुझे अभी रुकना है'
      : 'I Need to Pause Now';
  String get witnessOpeningQuote => isHindi
      ? 'तुम भावना नहीं हो।\nतुम उसे देखने वाले हो।'
      : 'You are not the emotion.\nYou are the one watching it.';
  String get witnessCloudInstruction => isHindi
      ? 'बादल को आते और जाते देखो — बिना रोके, बिना पकड़े।'
      : 'Watch the cloud arrive and pass — without stopping it, without holding on.';
  String get witnessTimerLabel => isHindi ? 'साक्षी समय' : 'WITNESS TIME';
  String get witnessEmotionPrompt => isHindi
      ? 'जो महसूस हुआ, वह एक शब्द में क्या था?'
      : 'In one word — what did you feel?';
  String get witnessEmotionHint => isHindi
      ? 'उदा. क्रोध, बेचैनी, दुख, डर...'
      : 'e.g. anger, restlessness, grief, fear...';
  String get witnessCompletionMessage => isHindi
      ? 'तुमने देखा। दबाया नहीं।\nयही स्वतंत्रता है।'
      : 'You observed. You did not suppress.\nThis is freedom.';
  String get witnessSkip => isHindi ? 'अभी नहीं' : 'Not now';
  String get witnessBegin => isHindi ? 'साक्षी बनें' : 'Become the Witness';
  String get witnessLogSaved => isHindi
      ? 'साक्षी प्रविष्टि सहेजी गई'
      : 'Witness entry saved';

  // Practice 2 — तथता (Reality Alignment)
  String get tathataTitle => isHindi ? 'तथता' : 'Tathatā';
  String get tathataSubtitle => isHindi
      ? 'जो हुआ उसे जैसा है वैसा देखें — 2 मिनट'
      : 'See what happened as it is — 2 minutes';
  String get tathataPillarBadge => isHindi ? 'पूर्ण स्वीकृति' : 'TOTAL ACCEPTANCE';
  String get tathataTriggerButton => isHindi
      ? 'कुछ गलत हुआ'
      : 'Something Went Wrong';
  String get tathataOpeningQuote => isHindi
      ? 'जो हुआ, हुआ।\nशिकायत उसे नहीं बदलती।'
      : 'What happened, happened.\nComplaint does not change it.';
  String get tathataQ1 => isHindi
      ? 'जो हुआ, क्या उसे बदला जा सकता था?'
      : 'Could what happened have been changed?';
  String get tathataQ1Yes => isHindi ? 'हाँ' : 'Yes';
  String get tathataQ1No => isHindi ? 'नहीं' : 'No';
  String get tathataQ1Partial => isHindi ? 'आंशिक रूप से' : 'Partially';
  String get tathataQ2 => isHindi
      ? 'उसमें तुम्हारा नियंत्रण कितने % था?'
      : 'How much % of it was in your control?';
  String get tathataQ2Hint => isHindi ? 'स्लाइडर खींचें' : 'Drag the slider';
  String get tathataQ3 => isHindi
      ? 'अभी इस क्षण में क्या सच है?'
      : 'What is true right now, in this moment?';
  String get tathataQ3Hint => isHindi
      ? 'उदा. मैं सुरक्षित हूँ। यह भी बीत जाएगा...'
      : 'e.g. I am safe. This too shall pass...';
  String tathataLowControlResponse(int pct) => isHindi
      ? 'केवल $pct% तुम्हारे हाथ था। जो तुम्हारे हाथ नहीं, उसे तुम्हारी शांति क्यों चाहिए?'
      : 'Only $pct% was in your hands. Why should your peace pay for what wasn\'t?';
  String tathataHighControlResponse(int pct) => isHindi
      ? '$pct% तुम्हारे नियंत्रण में था। यह सीखने का अवसर है। अगला कदम क्या हो सकता है?'
      : '$pct% was within your control. This is a learning opportunity. What could the next step be?';
  String get tathataSaveButton => isHindi ? 'स्वीकृति दर्ज करें' : 'Record Acceptance';
  String get tathataLogSaved => isHindi
      ? 'तथता प्रविष्टि सहेजी गई'
      : 'Tathatā entry saved';

  // Practice 3 — मौन संग (Sacred Silence Session)
  String get silenceTitle => isHindi ? 'मौन संग' : 'Sacred Silence';
  String get silenceSubtitle => isHindi
      ? 'बिना गाइडेंस के स्वयं के साथ बैठना'
      : 'Sitting with yourself — no guidance, no music';
  String get silencePillarBadge => isHindi ? 'अकेलेपन से मित्रता' : 'ALONENESS';
  String get silenceTriggerButton => isHindi
      ? 'मौन बैठना है'
      : 'I Want Sacred Silence';
  String get silenceOpeningQuote => isHindi
      ? 'जो अपने आप के साथ बैठ सकता है,\nउसे किसी बाहरी शोर की ज़रूरत नहीं।'
      : 'One who can sit with themselves\nneeds no external noise.';
  String get silenceDurationLabel => isHindi ? 'अवधि चुनें' : 'Choose Duration';
  String get silence5min => isHindi ? '5 मिनट' : '5 min';
  String get silence10min => isHindi ? '10 मिनट' : '10 min';
  String get silence15min => isHindi ? '15 मिनट' : '15 min';
  String get silenceBeginButton => isHindi ? 'मौन आरंभ करें' : 'Begin Silence';
  String get silenceInProgress => isHindi ? 'मौन में हो' : 'In Silence';
  String get silenceBreathLabel => isHindi ? 'श्वास के साथ रहो' : 'Stay with the breath';
  String get silenceTimerDoneMessage => isHindi
      ? 'तुमने स्वयं के साथ समय बिताया।'
      : 'You spent time with yourself.';
  String get silenceEndPrompt => isHindi
      ? 'अभी तुम्हारे मन में क्या था?'
      : 'What was present in your mind just now?';
  String get silenceEndOptThoughts => isHindi ? 'विचार' : 'Thoughts';
  String get silenceEndOptPeace => isHindi ? 'शांति' : 'Peace';
  String get silenceEndOptRestless => isHindi ? 'बेचैनी' : 'Restlessness';
  String get silenceStreakLabel => isHindi ? 'मौन धारा' : 'SILENCE STREAK';
  String silenceStreakDays(int days) => isHindi
      ? '$days दिन की मौन धारा'
      : '$days day silence streak';
  String get silenceLogSaved => isHindi
      ? 'मौन सत्र सहेजा गया'
      : 'Silence session saved';

  // -------------------------------------------------------------
  // Somatic SOS Pause & Immediate Neural Brake (Tab 1)
  // -------------------------------------------------------------
  String get somaticPauseHeader => isHindi ? 'सॉमेटिक आपातकालीन ब्रेक' : 'SOMATIC EMERGENCY BRAKE';
  String get somaticPauseTitle => isHindi ? 'ठहराव' : 'Somatic Pause';
  String get somaticPauseSubtitle => isHindi
      ? 'अचानक उकसावे या तनाव के क्षणों में तत्काल विराम। मौन ही शक्ति है।'
      : 'Immediate somatic neural brake for high-pressure moments. Silence is power.';
  String get somaticTriggerButton => isHindi ? '3-सेकंड ठहराव' : 'Pause Now';
  String get somaticTriggerButtonBilingual => isHindi ? '3-सेकंड ठहराव' : 'Pause Now';
  String get somaticInstructionBanner => isHindi
      ? 'जीभ को तालू से सटाएं और जबड़ा ढीला छोड़ें।'
      : 'Press tongue to roof of mouth and relax your jaw.';
  String get somaticInstructionSub => isHindi
      ? 'शारीरिक तनाव मुक्त करें • शून्य मौखिक प्रतिक्रिया'
      : 'Release physical tension • Zero verbal reaction';
  String get somaticCountdownStayStill => isHindi
      ? 'स्थिर रहें • शांत श्वास'
      : 'Stay still • Breathe calmly';
  String get coreArmorRuleHeader => isHindi ? 'मूल सुरक्षा नियम' : 'CORE ARMOR RULE';
  String get coreArmorRuleText => isHindi
      ? 'प्रतिक्रिया देकर अपनी शक्ति मत गंवाओ। मौन ही तुम्हारा नियंत्रण है।'
      : 'Do not surrender your power by reacting. Silence is your control.';
  String get coreArmorRuleSub => isHindi
      ? 'उकसाने वाले को कोई ईंधन न दें। मौन ही आपका संप्रभु कवच है।'
      : 'Give the trigger zero fuel. Absolute silence is your sovereign armor.';
  String get somaticResetButton => isHindi ? 'पुनः ठहराव (रीसेट)' : 'Reset Pause';
  String get somaticAnchoredBadge => isHindi ? 'समत्व सिद्ध' : 'PAUSE ANCHORED';
  String get boxBreathingSectionTitle => isHindi ? '4-4-4-4 श्वास चक्र' : '4-4-4-4 Box Breathing';
  String get boxBreathingSectionSubtitle => isHindi
      ? 'नाड़ी तंत्र को शांत करने हेतु 4-4-4-4 समगति प्राणायाम'
      : '4-4-4-4 somatic box breathing for physical de-escalation';

  // -------------------------------------------------------------
  // Cognition Workspace Reflection Categories (Pillar 3)
  // -------------------------------------------------------------
  String get catDailyReview => isHindi ? 'दैनिक समीक्षा' : 'Daily Review';
  String get catPersonalJournal => isHindi ? 'व्यक्तिगत डायरी' : 'Personal Journal';
  String get catPlanning => isHindi ? 'योजना व रणनीति' : 'Planning';
  String get catSelfTalk => isHindi ? 'आत्म-संवाद' : 'Self-Talk';
  String get catInputOutput1to3 => isHindi ? '1:3 आउटपुट' : '1:3 Output';
  String get catSaveToVault => isHindi ? 'सामग्री संचयन' : 'Save to Vault';
  String get catDailyReviewDesc => isHindi
      ? 'दिन का अंत, समत्व स्कोर व मर्यादा की निष्पक्ष समीक्षा'
      : 'End of day audit, composure score & boundary review';
  String get catPersonalJournalDesc => isHindi
      ? 'मन के अव्यक्त विचार, भावनाएं व मुक्त चिंतन'
      : 'Freeform thoughts, unfiltered feelings & stream of consciousness';
  String get catPlanningDesc => isHindi
      ? 'आगामी कार्य, रणनीतिक प्राथमिकताएं व कार्य योजना'
      : 'Upcoming tasks, high leverage priorities & action plans';
  String get catSelfTalkDesc => isHindi
      ? 'शांतिदायक आंतरिक संवाद, स्थितप्रज्ञ लंगर व संकल्प'
      : 'Calming self-scripts, stoic grounding & composure anchors';
  String get catInputOutput1to3Desc => isHindi
      ? 'किसी भी पुस्तक, वीडियो या शोध से 3 मुख्य निष्कर्ष व उनका व्यावहारिक प्रयोग'
      : '3 key takeaways & practical application after consuming any book or video';
  String get catSaveToVaultDesc => isHindi
      ? 'बाह्य लिंक, यूट्यूब वीडियो, लेख व प्रशिक्षण संदर्भ सीधे कोषों में सहेजें'
      : 'Save external links, videos, articles & training references directly to vaults';

  // 1:3 Input-Output Logger Fields
  String get sourceTitleLabel => isHindi ? 'पुस्तक / वीडियो / स्रोत का शीर्षक' : 'Source / Book / Video Title';
  String get sourceTitleHint => isHindi ? 'उदा. Twelve Angry Men, Meditations, Deep Work...' : 'e.g. Twelve Angry Men, Meditations, Deep Work...';
  String get takeaway1Label => isHindi ? 'निष्कर्ष 1' : 'Takeaway 1';
  String get takeaway1Hint => isHindi ? 'पहला सबसे महत्वपूर्ण सिद्धांत या मॉडल...' : 'Primary insight or core mental model...';
  String get takeaway2Label => isHindi ? 'निष्कर्ष 2' : 'Takeaway 2';
  String get takeaway2Hint => isHindi ? 'दूसरा महत्वपूर्ण सिद्धांत या तर्कदोष बचाव...' : 'Secondary analytical perspective or countermeasure...';
  String get takeaway3Label => isHindi ? 'निष्कर्ष 3' : 'Takeaway 3';
  String get takeaway3Hint => isHindi ? 'तीसरा सिद्धांत या आचरण का नियम...' : 'Tertiary rule of engagement or tactical lesson...';
  String get practicalApplicationLabel => isHindi ? 'व्यावहारिक अनुप्रयोग' : 'Practical Application';
  String get practicalApplicationHint => isHindi ? 'मैं इसे अपने दैनिक कार्य या निर्णयों में कैसे लागू करूंगा...' : 'How will I apply these 3 takeaways into daily execution...';

  // -------------------------------------------------------------
  // Morning Grounding (05:30 - 07:00 AM) & Night Debrief (09:30 - 10:30 PM)
  // -------------------------------------------------------------
  String get morningGroundingBadge => isHindi ? 'प्रातःकालीन लंगर' : 'MORNING GROUNDING';
  String get morningGroundingTime => isHindi ? '05:30 - 07:00 AM' : '05:30 - 07:00 AM';
  String get morningGroundingTitle => isHindi ? 'प्रातः कालीन प्रक्रम (05:30 – 07:00 AM) • ग्राउंडिंग फेज़' : 'Morning Grounding Routine (05:30 – 07:00 AM)';
  String get morningGroundingHeaderTitle => isHindi ? 'प्रातः कालीन प्रक्रम (05:30 – 07:00 AM) • ग्राउंडिंग फेज़' : 'Morning Grounding Routine (05:30 – 07:00 AM)';
  String get morningGroundingDesc => isHindi
      ? 'दिन के आरंभ में मानसिक कवच व दो अटल संकल्पों की पुष्टि।'
      : 'Affirm your two non-negotiable mental rules before beginning the day.';
  String get morningNeuroProtocolBanner => isHindi
      ? 'आज की घटनाओं पर मेरा वश हो न हो, मेरी प्रतिक्रिया पर मेरा शत-प्रतिशत नियंत्रण है।'
      : 'Events may be outside my control, but my reaction is 100% under my command.';
  String get morningStep1Title => isHindi
      ? 'डिजिटल स्क्रीन वर्जित (0–15 मिनट)'
      : 'Zero Digital Screen (0–15 Min)';
  String get morningStep1Desc => isHindi
      ? 'बालकनी/खिड़की से प्रकृति दर्शन व शांत श्वास।'
      : 'Natural sunlight and nature viewing from balcony/window & calm breathing.';
  String get morningStep2Title => isHindi
      ? 'बाह्य भ्रमण व सॉक्रेटिक संवाद (15 मिनट)'
      : 'Brisk Walk & Socratic Dialogue (15 Min)';
  String get morningStep2Desc => isHindi
      ? 'तेज चाल + दिन के संभावित तनावों की पूर्व-कल्पना और मौन रहने का अभ्यास।'
      : 'Brisk walking + premeditation of daily stress triggers & practice of silence.';
  String get morningStep3Title => isHindi
      ? 'द एंकर ऑफ काम (चाय का समय)'
      : 'The Anchor of Calm (Tea Time)';
  String get morningStep3Desc => isHindi
      ? 'पूर्ण उपस्थिति, बिना शिकायत या दफ्तर की चर्चा के शांत संवाद।'
      : 'Absolute presence, peaceful dialogue with zero complaining or office chatter.';
  String get actionAnchorsHeader => isHindi ? 'दैनिक क्रिया लंगर (3 चरण)' : 'Action Anchors (3 Steps)';
  String get expandRoutine => isHindi ? 'चरण देखें' : 'Show Steps';
  String get collapseRoutine => isHindi ? 'संक्षिप्त करें' : 'Hide Steps';
  String get pauseRuleTitle => isHindi ? '3-सेकंड ठहराव नियम' : '3-Second Pause Rule';
  String get pauseRuleDesc => isHindi
      ? 'किसी भी उकसावे पर तुरंत न बोलें। पहले 3 सेकंड का पूर्ण मौन रखें।'
      : 'Never react instantly to provocation. Take a conscious 3-second pause.';
  String get unapologeticNoTitle => isHindi ? 'संकोचहीन "ना"' : 'Unapologetic No';
  String get unapologeticNoDesc => isHindi
      ? 'व्यर्थ मांगों व भटकावों को बिना अपराधबोध या लंबी सफाई के अस्वीकार करें।'
      : 'Decline low-yield demands and distractions without apology or over-explaining.';
  String get committedBadge => isHindi ? 'संकल्प पूर्ण' : 'Committed';
  String get tapToCommitBadge => isHindi ? 'संकल्प लें' : 'Tap to Commit';

  String get dayFocusTimeBadge => isHindi ? '09:30 AM' : '09:30 AM';

  String get nightDebriefBadge => isHindi ? 'रात्रि आत्म-समीक्षा' : 'NIGHT DEBRIEF';
  String get nightDebriefTime => isHindi ? '09:30 - 10:30 PM' : '09:30 - 10:30 PM';
  String get nightDebriefTitle => isHindi ? 'रात्रि आत्म-समीक्षा' : 'Night Debrief & Audit';
  String get nightDebriefDesc => isHindi
      ? 'दिन के अंत में 3 स्टोइक प्रश्नों का त्वरित व निष्पक्ष मूल्यांकन।'
      : 'Rapid audit across the 3 core Stoic questions before sleep.';
  String get stoicQ1Header => isHindi ? '1. उकसावे/प्रलोभन पर प्रतिक्रिया?' : '1. Reaction to Provocation / Temptation?';
  String get stoicQ2Header => isHindi ? '2. व्यर्थ सफाई या शिकायत?' : '2. Useless Excuses or Complaining?';
  String get stoicQ2Maintained => isHindi ? 'कोई शिकायत/सफाई नहीं' : 'No Excuses / Complaints';
  String get stoicQ2Compromised => isHindi ? 'शिकायत या सफाई दी' : 'Complained / Over-explained';
  String get stoicQ3Header => isHindi ? '3. आज का सबसे तार्किक निर्णय / मुख्य कार्य?' : '3. Today\'s Most Rational Decision / Core Output?';
  String get stoicQ3Hint => isHindi
      ? 'आज का मुख्य ठोस परिणाम या विवेकपूर्ण निर्णय...'
      : 'Today\'s key rational decision or core milestone...';

  // Vault Filtering
  String get filterCaseStudies => isHindi ? 'केस स्टडीज' : 'Case Studies';
  String get filterAllFallacies => isHindi ? 'सभी तर्कदोष' : 'All Fallacies';

  // -------------------------------------------------------------
  // Vault & Sub-Tabs (Pillar 2)
  // -------------------------------------------------------------
  String get cognitionVaultTitle => isHindi ? 'कोष' : 'VAULT';
  String get cognitionVaultSubtitle => isHindi
      ? 'ज्ञान, चिंतन मॉडल, तर्क दोष व टूल्स'
      : 'Wisdom cards, mental models, fallacies & HTML tools';
  String get segmentWisdom => isHindi ? 'ज्ञान व श्लोक' : 'WISDOM CARDS';
  String get segmentMentalModels => isHindi ? 'चिंतन मॉडल' : 'MENTAL MODELS';
  String get segmentLogicalFallacies => isHindi ? 'तर्क दोष' : 'LOGICAL FALLACIES';
  String get segmentFallacies => isHindi ? 'तर्क दोष व मॉडल' : 'FALLACIES & MODELS';
  String get segmentResources => isHindi ? 'संदर्भ कोष' : 'RESOURCE HUB';
  String get segmentJoy => isHindi ? 'जॉय बॉक्स' : 'JOY BOX';
  String get segmentHtmlTools => isHindi ? 'टूल्स इंजन' : 'HTML TOOLS';

  // -------------------------------------------------------------
  // Joy Box (Soul Sanctuary)
  // -------------------------------------------------------------
  String get joyReservoirTitle => isHindi ? 'जॉय बॉक्स' : 'Joy Box';
  String get joyReservoirSubtitle => isHindi
      ? 'आत्म-प्रसन्नता व शांति धाम'
      : 'The Things I Love / Soul Sanctuary';
  String get joyReservoirDesc => isHindi
      ? 'व्यक्तिगत प्रसन्नता, मानसिक शांति व आंतरिक शक्ति का सुरक्षित संचय।'
      : 'A dedicated space designed to house personal sources of joy, serenity, and grounding.';
  String get addJoyAnchor => isHindi ? 'जॉय लंगर जोड़ें' : 'Add Joy Anchor';
  String get selectLocalAudio => isHindi ? 'डिवाइस से ऑडियो चुनें' : 'Select Local Audio';
  String get localAudioAnchor => isHindi ? 'ऑफ़लाइन स्थानीय ऑडियो' : 'Offline Local Audio';
  String get localAudioFile => isHindi ? 'स्थानीय ऑडियो फ़ाइल' : 'Local Audio File';
  String get audioFileSelected => isHindi ? 'ऑडियो फ़ाइल चयनित' : 'Audio file selected';
  String get playAudio => isHindi ? 'ऑडियो चलाएं' : 'Play Audio';
  String get pauseAudio => isHindi ? 'रोकें' : 'Pause Audio';
  String get stopAudio => isHindi ? 'बंद करें' : 'Stop Audio';
  String get openInYoutube => isHindi ? 'यूट्यूब में चलाएं' : 'Play in YouTube';
  String get openInYoutubeMusic => isHindi ? 'यूट्यूब म्यूज़िक में खोलें' : 'Open in YouTube Music';
  String get externalPlayer => isHindi ? 'बाहरी ऐप में चलाएं' : 'Open in Native Player';
  String get addMusicPlaylist => isHindi ? 'संगीत / प्लेलिस्ट जोड़ें' : 'Add Music / Playlist';
  String get musicLinkHint => isHindi
      ? 'यूट्यूब म्यूज़िक, यूट्यूब लिंक या स्थानीय ऑडियो फ़ाइल'
      : 'YouTube Music, YouTube link, or local audio file';
  String get audioPickingError => isHindi ? 'ऑडियो फ़ाइल चयन में त्रुटि' : 'Error picking audio file';
  String get noAudioSelected => isHindi ? 'कोई ऑडियो फ़ाइल नहीं चुनी गई' : 'No audio file selected';
  String get removeAnchorTitle => isHindi ? 'लंगर हटाएं?' : 'Remove Anchor?';
  String get removeAnchorConfirm => isHindi
      ? 'क्या आप इस लंगर को जॉय बॉक्स से हटाना चाहते हैं?'
      : 'Remove this anchor from your Joy Box?';
  String get removeButton => isHindi ? 'हटाएं' : 'REMOVE';
  String get cancelButton => isHindi ? 'रद्द करें' : 'CANCEL';
  String get joyAnchorSaved => isHindi
      ? 'आनंद लंगर जॉय बॉक्स में सुरक्षित'
      : 'Joy anchor saved to Joy Box';
  String get allAnchors => isHindi ? 'सभी लंगर' : 'ALL ANCHORS';
  String get musicCategory => isHindi ? 'संगीत व ध्वनि' : 'MUSIC & SOUND';
  String get visualCategory => isHindi ? 'दृश्य लंगर' : 'VISUAL ANCHORS';
  String get quoteCategory => isHindi ? 'शांति वचन' : 'WORDS OF PEACE';
  String get memoryCategory => isHindi ? 'स्मृति लंगर' : 'SOUL MEMORIES';
  String get noAnchorsInCategory => isHindi
      ? 'इस श्रेणी में कोई लंगर नहीं है'
      : 'NO ANCHORS IN THIS CATEGORY';
  String get tapAddPrompt => isHindi
      ? 'शांतिदायक स्मृति, संगीत या विचार सहेजने के लिए \'+ जोड़ें\' दबाएं'
      : 'Tap \'+ ADD\' above to preserve a peaceful memory, sound, or reflection.';
  String get anchorClassification => isHindi ? 'लंगर श्रेणी' : 'ANCHOR CLASSIFICATION';
  String get anchorTitle => isHindi ? 'लंगर शीर्षक' : 'ANCHOR TITLE';
  String get anchorTitleHint => isHindi
      ? 'उदा. प्रातःकालीन राग भैरव या वर्षा ध्वनि'
      : 'e.g., Morning Raga Bhairav or Rain Sounds';
  String get anchorTitleRequired => isHindi ? 'शीर्षक आवश्यक है' : 'Title is required';
  String get anchorMediaOptional => isHindi
      ? 'यूट्यूब या ऑडियो लिंक (वैकल्पिक)'
      : 'YOUTUBE OR AUDIO LINK (OPTIONAL)';
  String get anchorNoteLabel => isHindi
      ? 'यह आपको शांति क्यों देता है (टिप्पणी)'
      : 'WHY THIS BRINGS YOU SERENITY (NOTES)';
  String get anchorNoteHint => isHindi
      ? 'गहरी सांस लें, ठहरें और मानसिक स्थिरता में लौटें...'
      : 'Reminds me to breathe, pause, and step back into quiet composure...';
  String get addToJoyReservoir => isHindi ? 'जॉय बॉक्स में जोड़ें' : 'ADD TO JOY BOX';
  String get openLink => isHindi ? 'लिंक खोलें' : 'OPEN LINK';
  String get viewImage => isHindi ? 'देखें' : 'VIEW';
  String get unableToLoadImage => isHindi ? 'छवि लोड करने में असमर्थ।' : 'Unable to load image anchor.';
  String get fileSizeLabel => isHindi ? 'आकार' : 'Size';
  String get offlineAudioPlaying => isHindi ? 'ऑफ़लाइन ऑडियो बज रहा है' : 'Playing offline audio';
  String get nowPlaying => isHindi ? 'बज रहा है' : 'Now Playing';
  String get pausedStatus => isHindi ? 'ठहरा हुआ' : 'Paused';
  String get stoppedStatus => isHindi ? 'रुका हुआ' : 'Stopped';
  String get quickAddBannerText => isHindi
      ? 'संकट व तनाव के क्षणों में मानसिक संतुलन हेतु अपना पसंदीदा संगीत, शांत दृश्य या प्रेरक विचार सहेजें।'
      : 'Add personal uplifting music, photos of serene moments, or soothing quotes to ground yourself in moments of distress.';
  String get addButton => isHindi ? 'जोड़ें' : 'ADD';
  String get anchorRemovedNotice => isHindi
      ? 'लंगर जॉय बॉक्स से हटा दिया गया।'
      : 'Anchor removed from Joy Box.';

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
  String get importHtmlToolTitle => isHindi
      ? 'HTML टूल आयात व सुरक्षित संचय'
      : 'Import & Embed HTML Tool';
  String get safeOverwriteMode => isHindi
      ? 'सुरक्षित अधिलेखन सक्रिय'
      : 'SAFE OVERWRITE ACTIVE';
  String get safeOverwriteNotice => isHindi
      ? 'इस नाम का टूल पहले से मौजूद है। सामग्री को बिना डुप्लिकेट कार्ड बनाए सुरक्षित रूप से अपडेट किया जाएगा।'
      : 'A tool with this filename already exists. Content will be safely overwritten without duplicate cards.';
  String get newToolImportMode => isHindi
      ? 'नया टूल आंतरिक सैंडबॉक्स में स्थायी रूप से संचित होगा।'
      : 'New tool will be permanently embedded into internal sandbox storage.';
  String get toolTitleLabel => isHindi ? 'टूल शीर्षक' : 'TOOL TITLE';
  String get toolCategoryLabel => isHindi ? 'टूल श्रेणी' : 'TOOL CATEGORY';
  String get toolDescriptionLabel => isHindi
      ? 'विवरण व उपयोगिता (वैकल्पिक)'
      : 'DESCRIPTION & USE CASE (OPTIONAL)';
  String get saveHtmlTool => isHindi
      ? 'सैंडबॉक्स में संचित करें'
      : 'EMBED INTO SANDBOX';
  String get updateHtmlTool => isHindi
      ? 'सुरक्षित अधिलेखन व अपडेट'
      : 'SAFE OVERWRITE & UPDATE';
  String get deleteToolTitle => isHindi ? 'टूल हटाएं?' : 'Delete Tool?';
  String get deleteToolConfirm => isHindi
      ? 'क्या आप इस टूल को स्थायी रूप से हटाना चाहते हैं? यह आंतरिक सैंडबॉक्स डायरेक्टरी (app_html_tools) से मिटा दिया जाएगा।'
      : 'Are you sure you want to delete this tool? The file will be permanently removed from sandbox storage (app_html_tools).';
  String get toolDeletedNotice => isHindi
      ? 'टूल आंतरिक सैंडबॉक्स से हटा दिया गया।'
      : 'Tool permanently removed from sandbox storage.';
  String get toolOverwrittenNotice => isHindi
      ? 'टूल सामग्री सुरक्षित रूप से अधिलेखित व अपडेट की गई।'
      : 'Tool content safely overwritten and updated.';
  String get toolImportedNotice => isHindi
      ? 'HTML टूल आंतरिक सैंडबॉक्स में संचित हुआ।'
      : 'HTML tool permanently embedded into sandbox.';
  String get deleteAction => isHindi ? 'हटाएं' : 'Delete';
  String get launchAction => isHindi ? 'चलाएं' : 'LAUNCH';
  String get reloadTool => isHindi
      ? 'पुनः लोड करें (कैश खाली करें)'
      : 'Reload & Clear Cache';
  String get reimportTool => isHindi
      ? 'नई फ़ाइल से अपडेट करें'
      : 'Update with New File';
  String get noHtmlToolsFound => isHindi
      ? 'इस श्रेणी में कोई HTML टूल नहीं मिला'
      : 'No HTML tools found in this category';
  String get noHtmlToolsPrompt => isHindi
      ? 'ऑफ़लाइन उपयोग हेतु अपने कस्टम HTML डैशबोर्ड या कैलकुलेटर को आयात करें।'
      : 'Import your custom HTML dashboards or calculators for instant offline access.';
  String get selectHtmlFileFirst => isHindi
      ? 'कृपया आयात करने के लिए एक HTML फ़ाइल चुनें।'
      : 'Please select an HTML file to import.';
  String get specifyTitleFirst => isHindi
      ? 'कृपया इस टूल के लिए शीर्षक निर्दिष्ट करें।'
      : 'Please specify a title for this tool.';

  // -------------------------------------------------------------
  // Post-Incident Recovery & Slip-Up Logger
  // -------------------------------------------------------------
  String get slipUpRecoveryButton => isHindi
      ? 'स्खलन दर्ज करें (पुनः संतुलन)'
      : 'Log a Slip-Up & Reset';
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
  String get scriptRemovedNotice => isHindi
      ? 'रक्षात्मक सूत्र हटा दिया गया है।'
      : 'Script removed from Sanctuary.';
  String get logIncidentAction => isHindi ? 'डायरी में दर्ज करें' : 'Log Incident';

  // Composure Counter
  String get composureCounterLabel => isHindi
      ? 'आज का ठहराव दर्ज करें (+1)'
      : 'Log Today\'s Pause (+1)';
  String composureCounterValue(int count) => isHindi
      ? 'आज: $count ठहराव'
      : 'Today: $count pauses';
  String get composureCounterBadge => isHindi
      ? 'ठहराव काउंटर'
      : 'COMPOSURE COUNTER';

  String getDefensiveCategoryName(String category) {
    if (!isHindi) {
      // English display names for universal and specification categories
      switch (category) {
        case 'All':
          return 'All';
        case 'Pinned':
          return 'Pinned';
        case 'Unjust Accusation':
          return 'Unjust Accusation';
        case 'Intimidation':
          return 'Intimidation';
        case 'Impossible Deadlines':
          return 'Impossible Deadlines';
        case 'Interruption':
          return 'Interruption';
        case 'Blame Shifting':
          return 'Blame Shifting';
        case 'Passive Aggression':
          return 'Passive Aggression';
        case 'Scope Creep':
          return 'Scope Creep';
        case 'PublicTransit':
          return 'Transit / Public';
        case 'Provocation':
          return 'Provocation';
        case 'FamilyBoundary':
          return 'Family / Home';
        case 'WorkplaceComposure':
          return 'Workplace';
        case 'Gaslighting':
          return 'Gaslighting';
        case 'SelfMastery':
          return 'Self-Mastery';
        case 'Rules of Engagement':
          return 'Tactical Rules';
        case 'Custom':
          return 'Custom';
        default:
          return category;
      }
    }
    switch (category) {
      case 'All':
        return 'सभी';
      case 'Pinned':
        return 'पिन किए गए';
      case 'Unjust Accusation':
        return 'झूठा आरोप';
      case 'Intimidation':
        return 'धौंस / दबदबा';
      case 'Impossible Deadlines':
        return 'असंभव डेडलाइन';
      case 'Interruption':
        return 'हस्तक्षेप / टोकना';
      case 'PublicTransit':
        return 'सड़क व सार्वजनिक स्थल';
      case 'Provocation':
        return 'उकसावा व तंज';
      case 'FamilyBoundary':
        return 'पारिवारिक सीमा';
      case 'WorkplaceComposure':
        return 'कार्यस्थल शांति';
      case 'Gaslighting':
        return 'गैसलाइटिंग';
      case 'Blame Shifting':
        return 'दोषारोपण';
      case 'Passive Aggression':
        return 'अप्रत्यक्ष आक्रामकता';
      case 'Scope Creep':
        return 'कार्यक्षेत्र विस्तार';
      case 'SelfMastery':
        return 'आत्म-अनुशासन';
      case 'Rules of Engagement':
        return 'कार्य नियम';
      case 'Custom':
        return 'कस्टम';
      default:
        return category;
    }
  }

  String get reviewAndDrills => isHindi
      ? 'आत्म-समीक्षा व अभ्यास'
      : 'REVIEW & DRILLS';
  String get emergencyPerspectiveTab => isHindi
      ? 'आपातकालीन दृष्टिकोण (60 से.)'
      : 'EMERGENCY PERSPECTIVE (60s)';
  String get emergencyPerspectiveBadge => isHindi
      ? '60-सेकंड आपातकालीन दृष्टिकोण'
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
      ? 'बॉक्स ब्रीदिंग (2 मिनट)'
      : 'BOX BREATHING (2M)';
  String get twoMinuteBoxBreathing => isHindi
      ? '2-मिनट बॉक्स ब्रीदिंग अभ्यास'
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
  String get thirtySecondReview => isHindi
      ? '1. 30-सेकंड आत्म-समीक्षा'
      : '1. 30-SECOND EQUANIMITY REVIEW';
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
      ? '60-सेकंड संध्या आत्म-निरीक्षण'
      : '60s Evening Audit';
  String get saveDebriefButton => isHindi
      ? 'समीक्षा सुरक्षित करें'
      : 'Save Daily Debrief';
  String get debriefLoggedScore => isHindi
      ? 'दर्ज समत्व'
      : 'Logged Score';
  String get eveningLogBadge => isHindi
      ? '60-सेकंड संध्या समीक्षा'
      : '60-SECOND EVENING LOG';
  String get dailyClosureTitle => isHindi
      ? 'दैनिक हिसाब'
      : 'Daily Closure (Evening Audit)';
  String get debriefLockedBadge => isHindi
      ? 'हिसाब बंद (पूर्ण)'
      : 'LOCKED (DEBRIEF COMPLETED)';
  String get debriefPendingBadge => isHindi
      ? 'लंबित'
      : 'PENDING';
  String get dailyClosureDesc => isHindi
      ? '60 सेकंड में मानसिक शटडाउन। उकसावे पर चित्त की स्थिरता, मर्यादा की जाँच और आज का ठोस आउटपुट दर्ज करें।'
      : '60-second mental shutdown. Record reaction composure under provocation, boundary integrity, and core solid output.';
  String get tab3IndexDebrief => isHindi
      ? '3-सूत्री समीक्षा'
      : '3-INDEX DEBRIEF';
  String get tabMediaVault => isHindi
      ? 'मीडिया कोष'
      : 'MEDIA VAULT';

  // Index 01: Reaction Score
  String get index01Badge => isHindi ? 'सूचकांक 01' : 'INDEX 01';
  String get index01Title => isHindi ? 'प्रतिक्रिया समत्व' : 'REACTION SCORE';
  String get index01Question => isHindi
      ? 'आज उकसावे पर चित्त कितना स्थिर रहा?'
      : 'How composed was your mind under provocation today?';
  String reactionScoreLabel(int score) {
    if (isHindi) {
      switch (score) {
        case 1:
          return '1: नियंत्रण खोया (भड़का)';
        case 2:
          return '2: तनाव में बोला (उद्विग्न)';
        case 3:
          return '3: तटस्थ व सामान्य';
        case 4:
          return '4: पूर्ण नियंत्रण (स्थिर चित्त)';
        case 5:
          return '5: स्थितप्रज्ञ (अचल समत्व)';
        default:
          return '3: तटस्थ व सामान्य';
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
  String get index02Badge => isHindi ? 'सूचकांक 02' : 'INDEX 02';
  String get index02Title => isHindi ? 'मर्यादा व सीमा रक्षा' : 'BOUNDARY INTEGRITY';
  String get boundaryMaintainedBadge => isHindi ? 'अक्षुण्ण' : 'PRESERVED';
  String get boundaryCompromisedBadge => isHindi ? 'खंडित' : 'COMPROMISED';
  String get index02Question => isHindi
      ? 'क्या आज बिना सफाई दिए \'ना\' कहने की मर्यादा बची रही?'
      : 'Did you preserve dignity by saying \'No\' without over-explaining?';
  String get boundaryYesButton => isHindi
      ? 'हाँ (मर्यादा सुरक्षित)'
      : 'YES (Boundary Preserved)';
  String get boundaryNoButton => isHindi
      ? 'नहीं (समझौता हुआ)'
      : 'NO (Compromised)';
  String get boundaryYesShort => isHindi ? 'हाँ' : 'YES';
  String get boundaryYesSub => isHindi ? 'मर्यादा सुरक्षित' : 'Boundary Preserved';
  String get boundaryNoShort => isHindi ? 'नहीं' : 'NO';
  String get boundaryNoSub => isHindi ? 'समझौता हुआ' : 'Compromised';

  // Main Focus of the Day & Distraction Control
  String get index03Badge => isHindi ? 'मुख्य लक्ष्य' : 'MAIN FOCUS';
  String get index03Title =>
      isHindi ? 'आज का मुख्य लक्ष्य' : 'Main Focus of the Day';
  String get index03Tag =>
      isHindi ? '1 पंक्ति में' : '1-Liner';
  String get index03OutputQuestion => isHindi
      ? 'आज का सबसे ज़रूरी काम जो पूरा करना है:'
      : 'The single most important task to complete today:';
  String get index03OutputHint => isHindi
      ? 'उदा. प्रेजेंटेशन तैयार की, 2 अध्याय पढ़े, मुख्य रिपोर्ट भेजी, 30 मिनट व्यायाम'
      : 'e.g., Finished presentation, studied 2 chapters, submitted report, 30-min workout';
  String get index03ProvocationQuestion => isHindi
      ? 'मन का भटकाव कैसे रोका (वैकल्पिक):'
      : 'How you avoided distraction today (Optional):';
  String get index03ProvocationHint => isHindi
      ? 'उदा. सोशल मीडिया नहीं चलाया, काम के समय फोन दूर रखा, व्यर्थ बहस से बचा'
      : 'e.g., Stayed off social media, kept phone in another room, avoided unnecessary arguments';

  // Media Audit Section
  String get mediaAuditBadge => isHindi ? 'मीडिया समीक्षा' : 'MEDIA AUDIT';
  String get mediaAuditTitle => isHindi ? 'चिंतनशील मीडिया' : 'REFLECTIVE MEDIA';
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
  String get videoDrillTitle => isHindi ? '60-से. मुद्रा समीक्षा' : '60S VIDEO DRILL';
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
      ? 'हिसाब बंद करें'
      : 'Lock Daily Debrief';
  String get updateDayButton => isHindi
      ? 'दैनिक हिसाब अपडेट करें'
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
      ? 'मूल स्वरूप में रीसेट करें (4 मुख्य स्लॉट)'
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
      ? 'आज का दिन'
      : 'MY DAY TODAY';
  String get myDayTodayBilingual => isHindi
      ? 'आज का दिन'
      : 'My Day Today';
  String get editTodayTriggerTooltip => isHindi
      ? 'आज का दिन संपादित करें'
      : 'Edit My Day Today';
  String get editTodayTriggerTitle => isHindi
      ? 'आज का दिन संपादित करें'
      : 'Edit My Day Today';
  String get reminderChimeLabel => isHindi
      ? 'दैनिक स्मरण घंटी'
      : 'Daily Reminder Chime';
  String get reminderChimeSubtitle => isHindi
      ? 'टैप करें: घंटी बजाएं व टेस्ट स्मरण देखें'
      : 'Tap to sound chime & test reminder';
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
        return '4-सेकंड रणनीतिक मौन (विराम)';
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
        return 'बैठक में आक्षेप होने पर बोलने से पहले पूरे 4 सेकंड प्रतीक्षा करें। मौन को उनके भावात्मक वेग को सोखने दें।';
      case 2:
        return 'पहचानें कि इस संकट में आपका वास्तविक दायित्व क्या है और नेतृत्व की घबराहट क्या। केवल अपने कर्म पर ध्यान दें, नाटक की उपेक्षा करें।';
      case 3:
        return 'सपाट एवं शांत स्वर में उत्तर दें। उच्च स्वर घबराहट दर्शाता है; धीर व गंभीर स्वर आत्म-नियंत्रण और प्रभावशीलता प्रकट करता है।';
      case 4:
        return 'दोपहर 1 बजे से पहले 3 अतार्किक मांगों की पूर्व-अपेक्षा रखें। चूंकि आपने उनका पूर्वाभ्यास किया है, वे आपके तंत्रिका-तंत्र को विचलित नहीं करेंगी।';
      case 5:
        return 'स्वयं को स्मरण कराएं: आप एक संप्रभु, कुशल परामर्शदाता हैं, न कि किसी अधिकारी से कृपा या प्रशंसा के आकांक्षी बालक।';
      case 6:
        return 'आलोचनात्मक ईमेल्स को अपनी योग्यता पर आक्रमण न मानें। उन्हें केवल प्रेषक के व्यक्तिगत तनाव और चिंता के डेटा के रूप में पढ़ें।';
      case 7:
        return 'पूछें: "क्या यह छूटी हुई समय-सीमा या विलंबित प्रस्तुति 36 महीनों बाद भी मायने रखेगी?" यदि नहीं, तो इसे 36 सेकंड का उद्वेग भी न दें।';
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
  String get microIgnitionRule => isHindi ? 'सूक्ष्म गति • 5-मिनट नियम' : 'Micro-Ignition • 5-Min Rule';
  String get microIgnitionQuestion => isHindi
      ? 'आप अभी किस कार्य का आरंभ कर रहे हैं?'
      : 'What task are you executing right now?';
  String get microIgnitionDescription => isHindi
      ? 'मात्र 5 मिनट का संकल्प। परिणाम की चिंता त्यागें।\nगति आरंभ होते ही मानसिक प्रतिरोध समाप्त हो जाता है।'
      : 'Commit to just 5 minutes without hesitation. Done is better than perfect.\nMomentum breaks all resistance.';

  // Pulse & Box Breathing
  String get breathInhaleVisual => isHindi ? 'श्वास लें (4 से.)' : 'INHALE (4s)';
  String get breathHoldVisual => isHindi ? 'कुंभक / रोकें (4 से.)' : 'HOLD & DETACH (4s)';
  String get breathExhaleVisual => isHindi ? 'श्वास छोड़ें (4 से.)' : 'EXHALE CORTISOL (4s)';
  String get boxBreathInhaleVisual => isHindi ? 'श्वास लें (4 से.)' : 'INHALE (4s)';
  String get boxBreathHoldFullVisual => isHindi ? 'कुंभक / रोकें (4 से.)' : 'HOLD FULL (4s)';
  String get boxBreathExhaleVisual => isHindi ? 'श्वास छोड़ें (4 से.)' : 'EXHALE (4s)';
  String get boxBreathHoldEmptyVisual => isHindi ? 'शांत शून्यता (4 से.)' : 'HOLD EMPTY (4s)';
  String get breathNavelExpand => isHindi
      ? 'नाभि नीचे • फेफड़ों का विस्तार'
      : 'Diaphragmatic expansion • Lower belly';
  String get breathSteadfastObserver => isHindi
      ? 'अचल साक्षी भाव बनाए रखें'
      : 'Maintain steadfast detached observer';
  String get breathReleaseCortisol => isHindi
      ? 'तनाव विसर्जन • कंधों को शिथिल करें'
      : 'Release cortisol • Drop shoulder tension';
  String get breathRestInStillness => isHindi
      ? 'शांत शून्यता • जीभ तालू से सटाएं'
      : 'Rest in stillness • Tongue on roof of mouth';
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
      ? 'उदाहरण: "इस काम में कोई दम नहीं है"'
      : 'e.g. "Your approach makes no sense"';
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
      ? 'कृपया आज का सबसे ज़रूरी काम दर्ज करें।'
      : 'Please enter the single most important task for today.';
  String debriefSavedConfirmation(int score) => isHindi
      ? 'आज का हिसाब पूरा हुआ। तनाव यहीं विसर्जित है। (समत्व: $score%)'
      : 'Daily audit locked. Stress released at the threshold. (Equanimity: $score%)';
  String get oralAudioNote => isHindi ? 'मौखिक हिसाब' : 'Audio Reflection Note';
  String get physicalComposureDrill => isHindi ? 'आंगिक स्थिरता' : 'Physical Composure Video Drill';
  String get yesLabel => isHindi ? 'हाँ' : 'YES';
  String get noLabel => isHindi ? 'नहीं' : 'NO';
  String get tacticalInsightLabel => isHindi ? 'रणनीतिक सीख' : 'Tactical Insight';
  String get updateAction => isHindi ? 'बदलें' : 'UPDATE';
  String get recordAction => isHindi ? 'रिकॉर्ड' : 'RECORD';
  String get retakeAction => isHindi ? 'पुनः लें' : 'RETAKE';
  String get reviewAction => isHindi ? 'समीक्षा' : 'REVIEW';
  String get videoDrillStartRecord => isHindi ? 'रिकॉर्ड शुरू करें' : 'Start Recording';
  String get videoDrillStartRecordSub => isHindi ? '60 सेकंड आंगिक स्थिरता' : '60s Composure Review';
  String get videoDrillStopRecord => isHindi ? 'रिकॉर्ड रोकें' : 'Stop Recording';
  String get videoDrillSaveRecord => isHindi ? 'वीडियो सहेजें' : 'Save Video';
  String get videoDrillRetake => isHindi ? 'पुनः रिकॉर्ड करें' : 'Re-take';
  String get videoDrillSuccessNotice => isHindi
      ? '✓ वीडियो रिकॉर्डिंग संपन्न • सहेजने के लिए "वीडियो सहेजें" दबाएं।'
      : '✓ Composure drill recorded. Tap "Save Video" to attach.';
  String get videoDrillHoldFrameHint => isHindi
      ? 'जीभ तालू से सटाएं • जबड़ा ढीला छोड़ें • सीधी नजर'
      : 'Tongue on roof of mouth • Relax jaw • Direct eye contact';

  // Badges & Toolbars
  String get yourSourcesTitle =>
      isHindi ? 'आपके स्रोत' : 'Your Sources';
  String get systemShareSheetBadge =>
      isHindi ? 'सिस्टम शेयर शीट (रिसीव इंटेंट)' : 'SYSTEM SHARE SHEET (RECEIVE INTENT)';
  String get systemShareSheetDescription => isHindi
      ? 'स्थितप्रज्ञ आपके सिस्टम शेयर मेनू में सीधे दिखाई देता है। आप लिंक, लेख या शांत संगीत साझा कर सकते हैं।'
      : 'Sthitaprajna appears directly in your system Share menu. You can share links, classical articles, or calming music and save them with personal trigger notes.';
  String get testShareInterceptorButton =>
      isHindi ? 'शेयर इंटरसेप्टर का परीक्षण करें' : 'TEST SHARE INTERCEPTOR MODAL';
  String get systemShareInterceptor => isHindi
      ? 'शेयर इंटरसेप्टर • सहेजें'
      : 'SYSTEM SHARE INTERCEPTOR • SAVE';
  String get offlineLocalTools => isHindi
      ? 'ऑफ़लाइन वास्तुकला • स्थानीय उपकरण'
      : 'OFFLINE ARCHITECTURE • LOCAL TOOLS';
  String get soulSanctuaryBadge => isHindi
      ? 'शांति धाम • जॉय बॉक्स'
      : 'SOUL SANCTUARY • JOY BOX';
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
      ? 'आज के 4 डेटासेट स्लॉट में बदलें'
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
          return 'निर्णय लेने, कार्यनीति व स्पष्ट चिंतन हेतु शास्त्रीय मानसिक मॉडल व नियम।';
        case 2:
          return 'तार्किक दोषों, संज्ञानात्मक भटकाव एवं संशय का विश्लेषण व समाधान।';
        case 3:
          return 'व्यक्तिगत स्वतंत्र HTML डैशबोर्ड, निर्णय कैलकुलेटर एवं स्थानीय जावास्क्रिप्ट संचालित उपकरण।';
        case 4:
          return 'आनंद कोष • व्यक्तिगत संगीत, स्थानीय ऑडियो एंकर, शांत करने वाले दृश्य व सुखद स्मृतियां।';
        case 5:
          return 'सार्वजनिक साहित्य, ऑडियो/वीडियो विश्लेषण एवं आपके व्यक्तिगत Google Drive व Keep नोट्स।';
        default:
          return 'ज्ञान, चिंतन मॉडल, तर्क दोष व उपकरणों का संप्रभु कोष।';
      }
    }
    switch (segment) {
      case 0:
        return 'Classic Sthitaprajna shlokas, Western Stoicism, and Behavioral Psychology for unflinching poise.';
      case 1:
        return 'Timeless mental models, first principles, and systems thinking for high-leverage decisions.';
      case 2:
        return 'Dissect logical fallacies, cognitive biases, and rhetorical tricks for crystalline clarity.';
      case 3:
        return 'Personal standalone HTML dashboards, decision calculators, and interactive tools rendered locally.';
      case 4:
        return 'Soul Sanctuary • Personal music, offline audio anchors, visual memories, and comforting quotes.';
      case 5:
        return 'Curated public-domain literature, audio/video breakdowns, and your personal Google Drive & Keep notes.';
      default:
        return 'Sovereign vault of timeless wisdom, mental models, fallacies, and sandbox tools.';
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
  String get executionChimeHeader => isHindi ? 'कार्य ट्रिगर' : 'Execution Chime';
  String get fiveMinKickstart => isHindi ? '5-मिनट शुरुआत' : '5-Min Kickstart';
  String get fiveMinTimerSubtitle => isHindi ? '5 मिनट का टाइमर' : '5-Min Start';
  String get dailyFocusBlocks => isHindi ? 'दैनिक कार्य ब्लॉक' : 'Daily Focus Blocks';
  String get addTimeBlock => isHindi ? '+ नया ब्लॉक जोड़ें' : '+ Add Time Block';
  String get editTimeBlock => isHindi ? 'ब्लॉक संपादित करें' : 'Edit Time Block';
  String get deleteTimeBlock => isHindi ? 'ब्लॉक हटाएं' : 'Delete Time Block';
  String get blockTitleLabel => isHindi ? 'ब्लॉक शीर्षक' : 'Block Title';
  String get blockTitleHint => isHindi ? 'उदा. गहन कार्य, व्यायाम, स्वाध्याय' : 'e.g., Deep Work, Exercise, Reading';
  String get scheduledTimeLabel => isHindi ? 'निर्धारित समय' : 'Scheduled Time';
  String get pickTime => isHindi ? 'समय चुनें' : 'Pick Time';
  String get noDailyBlocks => isHindi ? 'अभी कोई दैनिक ब्लॉक नहीं जुड़ा है' : 'No focus blocks scheduled yet';
  String get noDailyBlocksSub => isHindi ? 'नया ब्लॉक जोड़ने के लिए "+ नया ब्लॉक जोड़ें" दबाएं।' : 'Tap "+ Add Time Block" above to set your schedule.';
  String get deleteBlockConfirm => isHindi ? 'क्या आप इस ब्लॉक को हटाना चाहते हैं?' : 'Remove this focus block?';
  String get chimeTriggeredNotice => isHindi ? '108Hz गोंग ध्वनि सक्रिय' : '108Hz chime active';
  String get microIgnitionCardTitle => isHindi ? '5-मिनट सूक्ष्म गति टाइमर' : '5-Minute Micro-Ignition Timer';
  String get microIgnitionCardDesc => isHindi
      ? 'टालमटोल मात्र आरंभ बिंदु पर मानसिक प्रतिरोध है। एक टैप से 5 मिनट का काउंटडाउन शुरू करें।'
      : 'Procrastination is merely cognitive friction at the start threshold. Single-tap to begin a discrete 5-minute countdown and dissolve resistance immediately.';
  String get launchMicroIgnitionAction => isHindi
      ? '5-मिनट सूक्ष्म गति अभी आरंभ करें'
      : 'LAUNCH 5-MIN MICRO-IGNITION NOW';

  // -------------------------------------------------------------
  // Settings Screen & Checkpoint Customization
  // -------------------------------------------------------------
  String get globalNotificationShieldTitle => isHindi
      ? 'वैश्विक अधिसूचना कवच'
      : 'Global Notification Shield';
  String get globalNotificationShieldSubActive => isHindi
      ? 'निर्धारित दिनों में स्थानीय अलार्म सक्रिय हैं'
      : 'Local scheduled alarms active across configured days';
  String get globalNotificationShieldSubMuted => isHindi
      ? 'सभी रिमाइंडर मूक (शांत) हैं'
      : 'All reminders silenced';
  String get deleteCheckpointTitle => isHindi
      ? 'चेकपॉइंट हटाएं?'
      : 'Delete Checkpoint?';
  String deleteCheckpointConfirm(String slotName) => isHindi
      ? 'क्या आप वास्तव में "$slotName" को हटाना चाहते हैं? इसके निर्धारित रिमाइंडर रद्द कर दिए जाएंगे।'
      : 'Are you sure you want to remove "$slotName"? Its scheduled notifications will be cancelled.';
  String get resetFactoryBlueprintTitle => isHindi
      ? 'फैक्टरी ब्लूप्रिंट पर रीसेट करें?'
      : 'Reset to Factory Blueprint?';
  String get resetFactoryBlueprintContent => isHindi
      ? 'यह डेटासेट से 4 डिफ़ॉल्ट चेकपॉइंट्स (05:45 AM प्रातः संबल, 09:00 AM कार्य प्रवेश कवच, 02:00 PM मध्याह्न समीक्षा, और 09:30 PM रात्रि समापन) को पुनर्स्थापित करेगा।'
      : 'This will restore the 4 default checkpoints (05:45 AM Morning Grounding, 09:00 AM Work Entry Shield, 02:00 PM Mid-Day Audit, and 09:30 PM Night Closure) from the dataset.';
  String get factoryScheduleRestoredNotice => isHindi
      ? 'फैक्टरी अधिसूचना कार्यक्रम पुनर्स्थापित कर दिया गया।'
      : 'Factory notification schedule restored.';
  String get addCustomCheckpointTooltip => isHindi
      ? 'अनुकूलित चेकपॉइंट जोड़ें'
      : 'Add Custom Checkpoint';
  String get noReminderSlotsTitle => isHindi
      ? 'कोई रिमाइंडर स्लॉट निर्धारित नहीं है'
      : 'No Reminder Slots Configured';
  String get noReminderSlotsSub => isHindi
      ? 'नया चेकपॉइंट जोड़ें या नीचे "फैक्टरी ब्लूप्रिंट पर रीसेट करें" दबाएं।'
      : 'Add a custom checkpoint or tap "Reset to Factory Blueprint" below.';
  String get offlineZeroTelemetryBadge => isHindi
      ? '100% ऑफ़लाइन • शून्य टेलीमेट्री'
      : '100% OFFLINE • ZERO TELEMETRY';
  String get offlineZeroTelemetryDesc => isHindi
      ? 'सभी रिमाइंडर डिवाइस हार्डवेयर अलार्म में सुरक्षित रहते हैं। शून्य क्लाउड निर्भरता।'
      : 'All reminder schedules reside in the device hardware alarm manager. Zero cloud pings.';
  String get executiveShieldNotificationsActivated => isHindi
      ? 'कवच अधिसूचनाएं सक्रिय कर दी गईं।'
      : 'Executive Shield Notifications activated.';
  String get allBackgroundNotificationsPaused => isHindi
      ? 'सभी पृष्ठभूमि अधिसूचनाएं रोक दी गईं।'
      : 'All background notifications paused.';
  String dispatchedTestPush(String name, String time) => isHindi
      ? '"$name" ($time) के लिए टेस्ट रिमाइंडर भेजा गया'
      : 'Dispatched test push for "$name" ($time)';
  String get allMutedMasterOff => isHindi
      ? 'सभी मूक (मास्टर स्विच बंद)'
      : 'ALL MUTED (MASTER OFF)';
  String activeSlotsCount(int active, int total) => isHindi
      ? '$total में से $active सक्रिय'
      : '$active OF $total ACTIVE';
  String get sendTestNotificationTooltip => isHindi
      ? 'अभी टेस्ट रिमाइंडर भेजें'
      : 'Send Test Notification Now';
  String get editCheckpointTooltip => isHindi
      ? 'चेकपॉइंट संपादित करें'
      : 'Edit Checkpoint';
  String get deleteCheckpointTooltip => isHindi
      ? 'चेकपॉइंट हटाएं'
      : 'Delete Checkpoint';
  String get resetScheduleAction => isHindi
      ? 'शेड्यूल रीसेट करें'
      : 'RESET SCHEDULE';

  // Slot Edit Modal
  String get checkpointSavedSuccess => isHindi
      ? 'चेकपॉइंट सफलतापूर्वक सुरक्षित किया गया!'
      : 'Checkpoint saved successfully!';
  String get checkpointRemovedNotice => isHindi
      ? 'चेकपॉइंट हटा दिया गया'
      : 'Checkpoint removed';
  String get editCheckpointHeader => isHindi
      ? 'चेकपॉइंट संपादित करें'
      : 'EDIT CHECKPOINT';
  String get newCheckpointHeader => isHindi
      ? 'नया चेकपॉइंट'
      : 'NEW CHECKPOINT';
  String get customizeReminderSlotTitle => isHindi
      ? 'रिमाइंडर स्लॉट अनुकूलित करें'
      : 'Customize Reminder Slot';
  String get addStrategicReminderTitle => isHindi
      ? 'रणनीतिक रिमाइंडर जोड़ें'
      : 'Add Strategic Reminder';
  String get checkpointNameLabel => isHindi
      ? 'चेकपॉइंट का नाम'
      : 'CHECKPOINT NAME';
  String get checkpointNameHint => isHindi
      ? 'उदा. कार्य प्रवेश कवच, गहन कार्य संबल'
      : 'e.g. Work Entry Shield, Deep Work Anchor';
  String get dispatchTimeLabel => isHindi
      ? 'प्रेषण समय'
      : 'DISPATCH TIME';
  String get activeStatusLabel => isHindi
      ? 'सक्रिय स्थिति'
      : 'ACTIVE STATUS';
  String get activeBadge => isHindi ? 'सक्रिय' : 'ACTIVE';
  String get mutedBadge => isHindi ? 'मौन' : 'MUTED';

  // -------------------------------------------------------------
  // SOS / Somatic Brake Screen
  // -------------------------------------------------------------
  String get somaticScreenTitle => isHindi ? 'ठहराव' : 'Pause / SOS';
  String get slipUpResetBadge => isHindi ? 'स्लिप-अप' : 'Slip-Up Reset';
  String get somaticIdleGuidance => isHindi
      ? 'अचानक उकसावे या तनाव पर तुरंत दबाएं • 3 सेकंड का मौन साधें'
      : 'Tap immediately when triggered • Observe 3-second absolute silence';
  String get threeSecondPause => isHindi ? '3-सेकंड ठहराव' : 'Pause Now';
  String get pauseNowAction => isHindi ? 'ठहराव' : 'PAUSE NOW';
  String get secondsRemaining => isHindi ? 'सेकंड शेष' : 'SECONDS';
  String get defensiveScriptsSectionTitle => isHindi
      ? 'सामरिक रक्षा लिपियां'
      : 'TACTICAL DEFENSIVE SCRIPTS';
  String get calmResponseProtocols => isHindi
      ? 'प्रति-रणनीति व शांत उत्तर'
      : 'Calm Response Protocols';
  String get addCustomScriptTooltip => isHindi
      ? 'नई रक्षा लिपि जोड़ें'
      : 'Add Custom Script';
  String get searchDefensiveScriptsHint => isHindi
      ? 'उकसावे, शब्द या श्रेणी खोजें...'
      : 'Search trigger, response script, or intent...';
  String get noScriptsFound => isHindi
      ? 'कोई रक्षा लिपि नहीं मिली'
      : 'No defensive scripts found';
  String get copyTextAction => isHindi ? 'टेक्स्ट कॉपी करें' : 'COPY TEXT';
  String get handledNeutralAction => isHindi ? 'संभाला (तटस्थ)' : 'HANDLED (NEUTRAL)';
  String get coreArmorRuleSubText => isHindi
      ? 'केवल अपने ठहराव और स्वर पर अधिकार रखें। शेष सब बाहरी जगत का है।'
      : 'Own only your pause and tone. The rest belongs to the world.';

  // -------------------------------------------------------------
  // Dashboard & Kickstart Timer & Joy Box
  // -------------------------------------------------------------
  String get kickstartTimerBadge => isHindi
      ? '5-मिनट किकस्टार्ट'
      : '5-MIN KICKSTART TIMER';
  String get kickstartFrictionBreaker => isHindi
      ? '• प्रतिरोध निवारण'
      : '• Friction Breaker';
  String get kickstartDescription => isHindi
      ? 'आरंभिक मानसिक प्रतिरोध को 5 मिनट की त्वरित गति से दूर करें।'
      : 'Dissolve starting resistance with a zero-friction 5-minute timer.';
  String get kickstartStart => isHindi ? 'आरंभ' : 'START';
  String stepsCompletedFraction(int completed, int total) => isHindi
      ? '$completed/$total पूर्ण'
      : '$completed/$total DONE';
  String get coreNeuroProtocolBadge => isHindi
      ? 'मूल तंत्रिका-प्रोटोकॉल'
      : 'CORE NEURO-PROTOCOL';
  String get distractionAvoidedLabel => isHindi
      ? 'मन का भटकाव नियंत्रण:'
      : 'Distraction avoided:';
  String get enterFocusTargetPrompt => isHindi
      ? 'कृपया आज का मुख्य लक्ष्य दर्ज करें।'
      : 'Please enter today\'s main focus target.';
  String get focusTargetSavedNotice => isHindi
      ? 'मुख्य लक्ष्य सफलतापूर्वक सुरक्षित किया गया!'
      : 'Primary focus target saved successfully!';
  String get sosEmergencyBadge => isHindi
      ? 'आपातकालीन स्थिरता'
      : 'SOS EMERGENCY';
  String get boxBreathingDrillCardTitle => isHindi
      ? '4-4-4-4 श्वास व स्थिरता ड्रिल'
      : '4-4-4-4 Box Breathing Drill';
  String get boxBreathingDrillCardSub => isHindi
      ? 'तनाव या आवेग के क्षणों में तुरंत मन को शांत करें।'
      : 'Rapidly restore nervous system equilibrium in high-stress moments.';
  String get calmButtonLabel => isHindi ? 'शांत हों' : 'Calm';
  String get manageActionLabel => isHindi ? 'प्रबंधन / सूची →' : 'Manage →';
  String get joyBoxTitle => isHindi ? 'जॉय बॉक्स' : 'JOY BOX';
  String get joyBoxSubtitle => isHindi
      ? 'आनंद कोष • संगीत, शांत ऑडियो व प्रिय स्मृतियां'
      : 'Soul Sanctuary • Music, serene audio & grounding anchors';
  String joyAnchorsCount(int count) => isHindi
      ? '$count एंकर'
      : '$count ANCHORS';
  String get addAudioFileTooltip => isHindi
      ? 'ऑडियो फ़ाइल जोड़ें'
      : 'Add Audio File';
  String get addJoyAnchorTooltip => isHindi
      ? 'नया एंकर जोड़ें'
      : 'Add Joy Anchor';
  String get openFullSanctuaryTooltip => isHindi
      ? 'पूरा कोष खोलें'
      : 'Open Full Sanctuary';
  String get emptyJoyReservoirDesc => isHindi
      ? 'तनाव निवारण हेतु अपना प्रिय संगीत, ध्यान राग या स्थानीय ऑडियो फ़ाइल (.mp3, .m4a) जोड़ें।'
      : 'Add your serene anchors, grounding music, or local audio files (.mp3, .m4a) for emotional sovereignty.';
  String get selectLocalAudioButton => isHindi
      ? 'लोकल ऑडियो चुनें'
      : 'SELECT AUDIO';
  String get addMusicLinkButton => isHindi
      ? 'यूट्यूब या संगीत लिंक'
      : 'ADD MUSIC LINK';
  String get addTextButton => isHindi ? '+ जोड़ें' : '+ Add';
  String get playingStatus => isHindi ? 'चल रहा है...' : 'Playing...';
  String get localAudioStatus => isHindi ? 'लोकल ऑडियो' : 'Local Audio';
  String get myDayTodayEditTitle => isHindi
      ? 'आज का दिन • संपादन'
      : 'MY DAY TODAY • EDIT';
  String get editTodaysFocusAndTrigger => isHindi
      ? 'दैनिक सूत्र व विचार संपादित करें'
      : 'Edit Today\'s Focus & Trigger';
  String get titleCoreThemeLabel => isHindi
      ? 'शीर्षक व मुख्य भाव'
      : 'TITLE & CORE THEME';
  String get titleCoreThemeHint => isHindi
      ? 'उदा. सप्ताहांत स्थिरता'
      : 'e.g. Weekend Equanimity';
  String get dailyThoughtMaximLabel => isHindi
      ? 'दैनिक विचार व उद्धरण'
      : 'DAILY THOUGHT & MAXIM QUOTE';
  String get dailyThoughtMaximHint => isHindi
      ? 'उदा. प्रकृति के साथ समय, पूर्ण उपस्थिति...'
      : 'e.g. Time in nature, pure presence...';
  String get resetDefaultButton => isHindi ? 'रीसेट' : 'Reset Default';
  String get todaysTriggerUpdatedNotice => isHindi
      ? 'आज का दिन अपडेट हो गया'
      : 'Today\'s trigger updated';
  String get saveChangesButton => isHindi ? 'परिवर्तन सहेजें' : 'Save Changes';
  String get soundChimeTooltip => isHindi ? 'घंटी बजाएं' : 'Sound chime';
  String chimeSoundedAlert(String time) => isHindi
      ? 'घंटी बजी! $time पर दैनिक स्मरण सक्रिय है।'
      : 'Chime sounded! Daily reminder active at $time.';
  String dailyReminderTimeLabel(String time) => isHindi
      ? 'दैनिक स्मरण ($time)'
      : 'Daily Reminder ($time)';

  // -------------------------------------------------------------
  // Cognition Vault & HTML Tool Viewer
  // -------------------------------------------------------------
  String get addModelAction => isHindi ? 'मॉडल जोड़ें' : 'ADD MODEL';
  String get addFallacyAction => isHindi ? 'भ्रांति जोड़ें' : 'ADD FALLACY';
  String get importHtmlAction => isHindi ? 'HTML आयात करें' : 'IMPORT HTML';
  String get addAnchorAction => isHindi ? 'एंकर जोड़ें' : 'ADD ANCHOR';
  String get addResourceAction => isHindi ? 'सामग्री जोड़ें' : 'ADD RESOURCE';
  String get joyBoxSegmentTitle => isHindi ? 'जॉय बॉक्स' : 'Joy Box';
  String get soulSanctuaryHeader => isHindi ? 'आत्म संबल कोष' : 'Soul Sanctuary';
  String socialMediaCategory(int count) => isHindi
      ? 'सोशल मीडिया ($count)'
      : 'SOCIAL MEDIA ($count)';
  String webArchiveCategory(int count) => isHindi
      ? 'वेब अभिलेखागार ($count)'
      : 'WEB ARCHIVE ($count)';
  String get noResourcesInCluster => isHindi
      ? 'इस क्लस्टर में कोई सामग्री नहीं है'
      : 'NO RESOURCES IN THIS CLUSTER';
  String get noMentalModelsFound => isHindi
      ? 'कोई मानसिक मॉडल नहीं मिला'
      : 'NO MENTAL MODELS FOUND';
  String get tryAdjustingSearch => isHindi
      ? 'कृपया खोज शब्द बदलकर पुनः प्रयास करें।'
      : 'Try adjusting your search terms.';
  String get noLogicalFallaciesFound => isHindi
      ? 'कोई तार्किक भ्रांति नहीं मिली'
      : 'NO LOGICAL FALLACIES FOUND';
  String toolsCountBadge(int count) => isHindi
      ? '$count टूल्स'
      : '$count TOOLS';
  String get resourceRemovedFromSanctuary => isHindi
      ? 'सामग्री कोष से हटा दी गई।'
      : 'Resource removed from Sanctuary.';
  String get unableToRenderOfflineTool => isHindi
      ? 'ऑफलाइन टूल प्रस्तुत करने में असमर्थ'
      : 'Unable to render offline tool';
  String get externalBrowserAction => isHindi ? 'बाहरी ब्राउज़र' : 'EXTERNAL BROWSER';
  String get openInBrowserAction => isHindi ? 'ब्राउज़र में खोलें' : 'Open in Browser';
  String get renameToolAction => isHindi ? 'टूल का नाम बदलें' : 'Rename Tool';
  String get saveAction => isHindi ? 'सहेजें' : 'SAVE';
  String get retryAction => isHindi ? 'पुनः प्रयास' : 'RETRY';

  // -------------------------------------------------------------
  // Journal Screen, 1:3 Output & Media Vault
  // -------------------------------------------------------------
  String get composeSegment => isHindi ? 'लेखन' : 'COMPOSE';
  String get timelineSegment => isHindi ? 'समयरेखा' : 'TIMELINE';
  String get mediaVaultSegment => isHindi ? 'मीडिया कोष' : 'MEDIA VAULT';
  String get editingReflectionBadge => isHindi ? 'चिंतन संपादन' : 'Editing Reflection';
  String get cancelEditAction => isHindi ? 'संपादन रद्द करें' : 'Cancel Edit';
  String get reflectionSavedSuccess => isHindi
      ? 'चिंतन सफलतापूर्वक सहेजा गया।'
      : 'Reflection saved successfully.';
  String get pillar3CognitionHeader => isHindi
      ? 'स्तंभ 03 • संज्ञान व आत्म-चिंतन'
      : 'PILLAR 03 • COGNITION & REFLECTION';
  String get cognitionWorkspaceTitle => isHindi
      ? 'संज्ञान कार्यक्षेत्र'
      : 'Cognition Workspace';
  String get threeMandatoryTakeaways => isHindi
      ? '3 अनिवार्य निष्कर्ष'
      : '3 MANDATORY TAKEAWAYS';
  String get saveOneThreeOutput => isHindi ? '1:3 निष्कर्ष सहेजें' : 'SAVE 1:3 OUTPUT';
  String get oneThreeOutputTakeaways => isHindi ? '1:3 आउटपुट निष्कर्ष' : '1:3 Output Takeaways';
  String get oneThreeOutputSavedSuccess => isHindi
      ? '1:3 आउटपुट सफलतापूर्वक दर्ज किया गया।'
      : '1:3 Output logged successfully.';
  String get oneThreeEngineHeader => isHindi
      ? '1:3 इनपुट-आउटपुट इंजन'
      : '1:3 Input-Output Engine';
  String get journalTitleOptional => isHindi
      ? 'डायरी शीर्षक (वैकल्पिक)'
      : 'Journal Title (Optional)';
  String get planningObjectiveOptional => isHindi
      ? 'योजना उद्देश्य (वैकल्पिक)'
      : 'Planning Objective (Optional)';
  String get selfTalkThemeOptional => isHindi
      ? 'आत्म-संवाद विषय (वैकल्पिक)'
      : 'Self-Talk Theme (Optional)';
  String get tagsInputHint => isHindi
      ? 'टैग जोड़ें (अल्पविराम से अलग, उदा. #एकाग्रता, #शांति)'
      : 'Tags (comma separated, e.g. #focus, #calm)';
  String get saveReflectionButton => isHindi ? 'चिंतन सुरक्षित करें' : 'SAVE REFLECTION';
  String get multimodalAttachmentsOptional => isHindi
      ? 'मल्टीमॉडल संलग्नक (वैकल्पिक)'
      : 'MULTIMODAL ATTACHMENTS (OPTIONAL)';
  String get pauseAudioAction => isHindi ? 'ऑडियो रोकें' : 'Pause Audio';
  String get playAudioAction => isHindi ? 'ऑडियो सुनें' : 'Play Audio';
  String get playingAudioMemo => isHindi ? 'ऑडियो मेमो चल रहा है...' : 'Playing Audio Memo...';
  String get audioMemoAttached => isHindi ? 'ऑडियो मेमो संलग्न है' : 'Audio Memo Attached';
  String get recordVoiceMemoPrompt => isHindi
      ? 'वॉइस मेमो रिकॉर्ड करें (.m4a)'
      : 'Record Audio Voice Memo (.m4a)';
  String get tapToPausePrompt => isHindi ? 'रोकने के लिए टैप करें' : 'Tap to pause';
  String get tapToListenPrompt => isHindi ? 'सुनने के लिए टैप करें' : 'Tap to listen';
  String get sixtySecVideoAttached => isHindi
      ? '60-सेकंड वीडियो संलग्न'
      : '60s Video Drill Attached';
  String get sixtySecVideoPrompt => isHindi
      ? '60-सेकंड वीडियो ड्रिल (.mp4)'
      : '60-Second Video Drill (.mp4)';
  String get drillAction => isHindi ? 'अभ्यास' : 'DRILL';
  String get executionAndCharacterLedgerHeader => isHindi
      ? 'कार्य-अनुशासन व चरित्र बही'
      : 'EXECUTION & CHARACTER LEDGER';
  String get actionTriggersAndVirtueSub => isHindi
      ? 'कार्य-संकल्प व सद्गुण डायरी'
      : 'Action-Triggers & Virtue Journal';
  String get executionChimeButton => isHindi ? 'कार्य-घंटी' : 'EXECUTION CHIME';
  String get characterLedgerButton => isHindi ? 'चरित्र बही' : 'CHARACTER LEDGER';
  String get videoFileNotFound => isHindi
      ? 'डिवाइस पर वीडियो फ़ाइल नहीं मिली'
      : 'Video file not found on device';
  String get reflectionCopiedNotice => isHindi
      ? 'चिंतन क्लिपबोर्ड पर कॉपी हो गया'
      : 'Reflection copied to clipboard';
  String get deleteRecordingTitle => isHindi
      ? 'रिकॉर्डिंग हटाएं?'
      : 'DELETE RECORDING?';
  String get storagePathLabel => isHindi ? 'संग्रहण पथ:' : 'Storage Path:';
  String get stopRecordingAction => isHindi ? 'रिकॉर्डिंग रोकें' : 'STOP RECORDING';
  String get discardAction => isHindi ? 'हटाएं' : 'DISCARD';
  String get attachAction => isHindi ? 'संलग्न करें' : 'ATTACH';
  String get startAudioMemoAction => isHindi ? 'ऑडियो मेमो शुरू करें' : 'START AUDIO MEMO';

  // -------------------------------------------------------------
  // Character Ledger & Virtue Tracking
  // -------------------------------------------------------------
  String get deleteTraitTitle => isHindi ? 'सद्गुण रिकॉर्ड हटाएं?' : 'Delete Trait Record?';
  String get recordFirstTrait => isHindi ? 'पहला सद्गुण दर्ज करें' : 'RECORD FIRST TRAIT';
  String get describeTraitPrompt => isHindi
      ? 'कृपया सद्गुण अवलोकन या संयम का विवरण दें।'
      : 'Please describe the trait observation or restraint.';
  String get recordCharacterTraitTitle => isHindi
      ? 'चरित्र सद्गुण दर्ज करें'
      : 'Record Character Trait';

  // -------------------------------------------------------------
  // Incoming Sharing Intent & Recovery
  // -------------------------------------------------------------
  String get selectDestinationBadge => isHindi ? 'गंतव्य चुनें' : 'SELECT DESTINATION';
  String get sharedContentUrlBadge => isHindi ? 'साझा सामग्री / लिंक' : 'SHARED CONTENT / URL';
  String get resourceAnchorTitleBadge => isHindi ? 'सामग्री / एंकर शीर्षक' : 'RESOURCE / ANCHOR TITLE';
  String get cognitionClusterBadge => isHindi ? 'संज्ञान श्रेणी क्लस्टर' : 'COGNITION CATEGORY CLUSTER';
  String get joyAnchorTypeBadge => isHindi ? 'जॉय एंकर प्रकार' : 'JOY RESERVOIR ANCHOR TYPE';
  String saveToDestinationButton(String dest) => isHindi
      ? '$dest में सहेजें'
      : 'SAVE TO $dest';
  String get saveAndReclaimComposureAction => isHindi
      ? 'सहेजें व संतुलन पुनः प्राप्त करें'
      : 'SAVE & RECLAIM COMPOSURE';

  // Web & Media Launchers
  String get launchWebResource => isHindi ? 'वेब संसाधन खोलें' : 'LAUNCH WEB RESOURCE';
  String get openInChromeAction => isHindi ? 'क्रोम में खोलें' : 'OPEN IN CHROME';
  String get openInWebViewAction => isHindi ? 'वेबव्यू में खोलें' : 'OPEN IN WEBVIEW';
  // Response Script Card
  String get hostileTriggerBadge => isHindi ? 'उकसावा' : 'HOSTILE TRIGGER';
  String get verbatimScriptBadge => isHindi ? 'सटीक उत्तर' : 'VERBATIM SCRIPT';
  String get copiedToClipboardBadge => isHindi ? 'क्लिपबोर्ड पर कॉपी किया गया' : 'COPIED TO CLIPBOARD';
  String get whyItWorksLabel => isHindi ? 'रणनीतिक प्रभाव: ' : 'WHY IT WORKS: ';
  String get deliveryLabel => isHindi ? 'स्वर निर्देश: ' : 'DELIVERY: ';
  String scriptCopiedNotice(String category) => isHindi
      ? 'स्क्रिप्ट क्लिपबोर्ड पर कॉपी की गई: "$category"'
      : 'Script copied to clipboard: "$category"';
  String get listenDeflectionTooltip => isHindi ? 'रक्षा लिपि सुनें' : 'Listen to deflection script';
  String get bookmarkScriptTooltip => isHindi ? 'लिपि बुकमार्क करें' : 'Bookmark Script';
  String get editScriptTooltip => isHindi ? 'लिपि संपादित करें' : 'Edit Script';
  String get deleteScriptTooltip => isHindi ? 'लिपि हटाएं' : 'Delete Script';
  String get copyScriptTooltip => isHindi ? 'लिपि कॉपी करें' : 'Copy Script';
  String get parasympatheticPacerBadge => isHindi ? 'परानुकंपी गति' : 'PARASYMPATHETIC PACER';
  String secondsGroundedLabel(int s) => isHindi ? '$s से. स्थिर' : '${s}s GROUNDED';
  String get composureScoreLabel => isHindi ? 'उकसावे पर प्रतिक्रिया:' : 'Composure score:';
  String get boundaryLabel => isHindi ? 'सीमा व अनुशासन:' : 'Boundary:';
  String get rationalDecisionCoreOutputLabel => isHindi
      ? 'तार्किक निर्णय व मुख्य कार्य:'
      : 'Rational decision & core output:';
  String get editDebriefButton => isHindi ? 'संपादित करें' : 'Edit Debrief';
  String get cognitionTimelineAction => isHindi ? 'संज्ञान इतिहास →' : 'Cognition Timeline →';
  String renamedToolNotice(String title) => isHindi
      ? 'नाम बदलकर "$title" किया गया।'
      : 'Renamed to "$title".';

  // Common Dialog & Button Labels
  String get cancelAction => isHindi ? 'रद्द करें' : 'Cancel';
  String get deleteButton => isHindi ? 'हटाएं' : 'DELETE';
  String get editAction => isHindi ? 'संपादित करें' : 'Edit';
  String get copyAction => isHindi ? 'कॉपी करें' : 'Copy';
  String get openInYouTubeAction => isHindi ? 'यूट्यूब में खोलें' : 'OPEN IN YOUTUBE';
  String get youtubeAppAction => isHindi ? 'यूट्यूब ऐप' : 'YOUTUBE APP';
  String get saveNameButton => isHindi ? 'नाम सहेजें' : 'SAVE NAME';

  // Character Ledger Additions
  String deleteTraitRecordConfirm(String title) => isHindi
      ? 'क्या आप "$title" को अपनी चरित्र बही से हटाना चाहते हैं?'
      : 'Are you sure you want to remove "$title" from your Character Ledger?';
  String get allClearFilter => isHindi ? 'सभी देखें ✕' : 'ALL ✕';
  String get searchCharacterLedgerHint => isHindi
      ? 'परिस्थितियां, टैग (#मौन), या चिंतन खोजें...'
      : 'Search situations, tags (#Silence), or reflections...';
  String get noCharacterRecordsFound => isHindi
      ? 'कोई चरित्र रिकॉर्ड नहीं मिला'
      : 'No Character Records Found';
  String get recordEverydayArenasSub => isHindi
      ? 'दैनिक परिस्थितियों को दर्ज करें जहाँ आपने समत्व, रणनीतिक मौन या उदारता का पालन किया।'
      : 'Record everyday arenas where you embodied composure, strategic silence, or big-hearted magnanimity.';
  String get deleteEntryTooltip => isHindi ? 'प्रविष्टि हटाएं' : 'Delete Entry';
  String get arenaLabel => isHindi ? 'परिस्थिति: ' : 'ARENA: ';
  String traitRecordedNotice(String title, String category) => isHindi
      ? 'चरित्र बही में दर्ज किया गया: "$title" [$category]'
      : 'Recorded to Character Ledger: "$title" [$category]';
  String get selectVirtueCategoryBadge => isHindi
      ? 'सद्गुण संवर्ग चुनें'
      : 'SELECT VIRTUE CATEGORY';
  String get headlineTraitSummaryLabel => isHindi
      ? 'शीर्षक व सद्गुण सारांश'
      : 'Headline & Trait Summary';
  String get headlineTraitSummaryHint => isHindi
      ? 'उदा. टकराव के दौरान शांत और स्थिर स्वर बनाए रखा'
      : 'e.g., Maintained low monotone voice during confrontation';
  String get arenaTriggerContextLabel => isHindi
      ? 'परिस्थिति व ट्रिगर संदर्भ (वैकल्पिक)'
      : 'Arena & Trigger Context (Optional)';
  String get arenaTriggerContextHint => isHindi
      ? 'उदा. प्रबंधन या बैठक में अप्रत्याशित टकराव'
      : 'e.g., Q3 Executive Standup with VP of Engineering';
  String get observationEmbodiedActionBadge => isHindi
      ? 'अवलोकन व व्यावहारिक आचरण'
      : 'OBSERVATION & EMBODIED ACTION';
  String get voiceDictateLabel => isHindi ? 'वाणी श्रुतलेख' : 'Voice Dictate';
  String get behaviorObservationHint => isHindi
      ? 'आपने अपने भीतर क्या देखा? आपने कैसे प्रतिक्रिया दी या रुकना चुना? बोलें या टाइप करें...'
      : 'What did you observe in yourself? How did you respond or refrain from reacting? Speak or type...';
  String get keyRealizationAnchorLabel => isHindi
      ? 'मुख्य बोध व एंकर (वैकल्पिक)'
      : 'Key Realization & Anchor (Optional)';
  String get keyRealizationAnchorHint => isHindi
      ? 'उदा. मौन ने मुझे तुरंत बढ़त दी। सभा मेरे नियंत्रण में आ गई।'
      : 'e.g., Silence gave me instant leverage. The room followed my pacing.';
  String get customTagsLabel => isHindi
      ? 'कस्टम टैग (अल्पविराम से अलग)'
      : 'Custom Tags (Comma-separated)';
  String get gravitasRatingBadge => isHindi
      ? 'गांभीर्य व संतुलन रेटिंग'
      : 'GRAVITAS & COMPOSURE RATING';
  String get saveToCharacterLedgerButton => isHindi
      ? 'चरित्र बही में सहेजें'
      : 'SAVE TO CHARACTER LEDGER';

  // Sharing & Universal Interceptor Additions
  String get systemShareInterceptorBadge => isHindi
      ? 'सिस्टम संचयन इंटरसेप्टर • सेव'
      : 'SYSTEM SHARE INTERCEPTOR • SAVE';
  String get saveToSthitaprajna => isHindi
      ? 'स्थितप्रज्ञ में सहेजें'
      : 'SAVE TO STHITAPRAJNA';
  String get resetFormTooltip => isHindi ? 'फ़ॉर्म रीसेट करें' : 'Reset Form';
  String get pasteAction => isHindi ? 'पेस्ट करें' : 'PASTE';
  String get contentOrLinkRequired => isHindi
      ? 'सामग्री या लिंक आवश्यक है'
      : 'Shared content is required';
  String get enterDescriptiveTitleHint => isHindi
      ? 'वर्णनात्मक शीर्षक दर्ज करें...'
      : 'Enter a descriptive title...';
  String get titleRequired => isHindi ? 'शीर्षक आवश्यक है' : 'Title is required';
  String get recoverySituationalTagBadge => isHindi
      ? 'अभ्यास व रिकवरी स्थिति टैग'
      : 'RECOVERY SITUATIONAL TAG';
  String get whySavingCommentBadge => isHindi
      ? 'सहेजने का कारण व व्यक्तिगत संदर्भ (टिप्पणी)'
      : 'WHY I AM SAVING THIS & PERSONAL CONTEXT (COMMENT FIELD)';
  String savedToDestinationNotice(String dest) => isHindi
      ? '$dest और चिंतन इतिहास में सहेजा गया।'
      : 'Saved to $dest & Reflection Timeline.';

  // Reflection Timeline Additions
  String get searchReflectionsHint => isHindi
      ? 'चिंतन, विचार, कार्य या टैग खोजें...'
      : 'Search reflections, insights, tasks, or tags...';
  String reflectionEntriesCount(int count) => isHindi
      ? '$count चिंतन प्रविष्टियां'
      : '$count REFLECTION ENTRIES';
  String get offlineHiveBadge => isHindi
      ? '100% ऑफ़लाइन सुरक्षित'
      : '100% OFFLINE HIVE';
  String get noReflectionsFound => isHindi
      ? 'कोई प्रविष्टि नहीं मिली'
      : 'NO REFLECTIONS FOUND';
  String get noReflectionsSub => isHindi
      ? 'ऊपर लेखन टैब में जाकर अपनी पहली चिंतन या दैनिकी प्रविष्टि दर्ज करें।'
      : 'Switch to the Compose tab above to record your first reflection.';
  String get deleteReflectionTitle => isHindi
      ? 'प्रविष्टि हटाएं?'
      : 'Delete Reflection?';
  String get deleteReflectionConfirm => isHindi
      ? 'क्या आप इस प्रविष्टि को स्थायी रूप से हटाना चाहते हैं?'
      : 'Permanently remove this reflection from storage?';
  String sourceLabel(String source) => isHindi
      ? 'स्रोत: $source'
      : 'Source: $source';
  String composureScoreBadge(int score) => isHindi
      ? '$score/5 समत्व'
      : '$score/5 Composure';
  String get boundaryHeld => isHindi ? 'मर्यादा अक्षुण्ण' : 'Boundary Held';
  String get boundaryCompromised => isHindi ? 'सीमा विचलित' : 'Boundary Compromised';
  String get distractionControlLabel => isHindi
      ? 'भटकाव नियंत्रण'
      : 'Distraction Control';
  String get audioMemoLabel => isHindi ? 'ऑडियो मेमो' : 'Voice Memo';
  String get audioPlayingLabel => isHindi ? 'बज रहा है...' : 'Playing...';
  String get videoDrillLabel => isHindi ? 'वीडियो समीक्षा' : 'Video Drill';
  String get allTimeLabel => isHindi ? 'सभी तिथियां' : 'All Time';
  String get todayLabel => isHindi ? 'आज' : 'Today';
  String get thisWeekLabel => isHindi ? 'इस सप्ताह' : 'This Week';
  String get thisMonthLabel => isHindi ? 'इस माह' : 'This Month';

  // Wisdom & Sanctuary Resource Modal
  String get mediaClassificationBadge => isHindi
      ? 'मीडिया वर्गीकरण'
      : 'MEDIA CLASSIFICATION';
  String get resourceTitleBadge => isHindi
      ? 'संसाधन शीर्षक'
      : 'RESOURCE TITLE';
  String get resourceUrlBadge => isHindi
      ? 'संसाधन URL व लिंक'
      : 'RESOURCE URL & LINK';
  String get categoryClusterBadge => isHindi
      ? 'श्रेणी संवर्ग'
      : 'CATEGORY CLUSTER';
  String get keyTakeawaysOptionalBadge => isHindi
      ? 'मुख्य बोध व नोट्स (वैकल्पिक)'
      : 'KEY TAKEAWAYS & NOTES (OPTIONAL)';
  String get saveToPersonalSanctuaryButton => isHindi
      ? 'व्यक्तिगत आश्रय में सहेजें'
      : 'SAVE TO PERSONAL SANCTUARY';
  String get resourceLinkSavedNotice => isHindi
      ? 'संसाधन लिंक ऑफ़लाइन आश्रय में सहेजा गया'
      : 'Resource link saved to offline Sanctuary';
  String get invalidResourceUrl => isHindi
      ? 'अमान्य संसाधन URL।'
      : 'Invalid resource URL.';

  // Filter chips in timeline
  String categoryFilterAll(int count) => isHindi ? 'सभी ($count)' : 'ALL ($count)';
  String categoryFilterVault(int count) => isHindi ? 'संचयन ($count)' : 'SAVED ($count)';
  String categoryFilter1to3(int count) => isHindi ? '1:3 आउटपुट ($count)' : '1:3 OUTPUT ($count)';
  String categoryFilterDaily(int count) => isHindi ? 'दैनिक समीक्षा ($count)' : 'DAILY REVIEW ($count)';
  String categoryFilterJournal(int count) => isHindi ? 'डायरी ($count)' : 'JOURNAL ($count)';
  String categoryFilterPlanning(int count) => isHindi ? 'योजना ($count)' : 'PLANNING ($count)';
  String categoryFilterSelfTalk(int count) => isHindi ? 'आत्म-संवाद ($count)' : 'SELF-TALK ($count)';

  // Slot Edit Modal Sheet
  String get slotNameRequiredNotice => isHindi
      ? 'कृपया चेकपॉइंट का नाम दर्ज करें (उदा. "कार्य प्रवेश कवच")'
      : 'Please enter a slot name (e.g. "Work Entry Shield")';
  String get checkpointSavedNotice => isHindi
      ? 'चेकपॉइंट सफलतापूर्वक सुरक्षित किया गया!'
      : 'Checkpoint saved successfully!';
  String getSlotCategoryName(String cat) {
    if (!isHindi) return cat;
    switch (cat) {
      case 'Morning Grounding':
        return 'प्रातः संबल';
      case 'Work Entry Shield':
        return 'कार्य प्रवेश कवच';
      case 'Mid-Day Audit':
        return 'मध्याह्न समीक्षा';
      case 'Night Closure':
        return 'रात्रि समापन';
      case 'Tactical Reset':
        return 'रणनीतिक रीसेट';
      case 'Deep Work':
        return 'गहन कार्य';
      case 'Custom Focus':
        return 'अनुकूलित लक्ष्य';
      default:
        return cat;
    }
  }
  List<String> get dayAbbrList => isHindi
      ? const ['सो', 'मं', 'बु', 'गु', 'शु', 'श', 'र']
      : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  String get editCheckpointBadge => isHindi ? 'चेकपॉइंट संपादित करें' : 'EDIT CHECKPOINT';
  String get newCheckpointBadge => isHindi ? 'नया चेकपॉइंट' : 'NEW CHECKPOINT';
  String get checkpointNameBadge => isHindi ? 'चेकपॉइंट का नाम' : 'CHECKPOINT NAME';
  String get dispatchTimeBadge => isHindi ? 'प्रेषण समय' : 'DISPATCH TIME';
  String get activeStatusBadge => isHindi ? 'सक्रिय स्थिति' : 'ACTIVE STATUS';
  String get statusActiveBadge => isHindi ? 'सक्रिय' : 'ACTIVE';
  String get statusMutedBadge => isHindi ? 'मौन' : 'MUTED';
  String get categoryThemeBadge => isHindi ? 'श्रेणी / विषय' : 'CATEGORY / THEME';
  String get activeDaysScheduleBadge => isHindi
      ? 'सक्रिय दिन (अनुसूची)'
      : 'ACTIVE DAYS (SCHEDULE)';
  String activeDaysFraction(int count) => isHindi
      ? '$count / 7 दिन'
      : '$count / 7 DAYS';
  String get presetEveryDay => isHindi ? 'प्रतिदिन' : 'EVERY DAY';
  String get presetWeekdays => isHindi ? 'कार्यदिवस (सोम-शुक्र)' : 'WEEKDAYS (M–F)';
  String get presetWeekends => isHindi ? 'सप्ताहांत (शनि-रवि)' : 'WEEKENDS (S–S)';
  String get customNotificationTitleBadge => isHindi
      ? 'अनुकूलित सूचना शीर्षक (वैकल्पिक)'
      : 'CUSTOM NOTIFICATION TITLE (OPTIONAL)';
  String get customNotificationTitleHint => isHindi
      ? 'स्लॉट नाम या दैनिक नियम स्वतः लागू होगा'
      : 'Defaults to slot name or daily Hindi rule';
  String get customNotificationMessageBadge => isHindi
      ? 'अनुकूलित सूचना संदेश (वैकल्पिक)'
      : 'CUSTOM NOTIFICATION MESSAGE (OPTIONAL)';
  String get customNotificationMessageHint => isHindi
      ? 'दैनिक प्रेरणा या अनुकूलित संदेश'
      : 'Defaults to day-wise Stoic prompt or custom mantra';
  String get createCheckpointButton => isHindi ? 'चेकपॉइंट बनाएं' : 'CREATE CHECKPOINT';

  // Expandable Micro Card
  String get deleteFrameworkCardTitle => isHindi ? 'कार्ड हटाएं' : 'Delete Framework Card';
  String removeVaultItemConfirm(String title) => isHindi
      ? 'क्या आप "$title" को कोष से हटाना चाहते हैं?'
      : 'Remove "$title" from your Vault?';
  String get logicalFallacyBadge => isHindi ? 'तर्क दोष' : 'LOGICAL FALLACY';
  String get rulesOfEngagementBadge => isHindi ? 'व्यवहार नियम' : 'RULES OF ENGAGEMENT';
  String get mentalModelBadge => isHindi ? 'चिंतन मॉडल' : 'MENTAL MODEL';
  String get corePrincipleBadge => isHindi ? 'मूल सिद्धांत' : 'CORE PRINCIPLE';
  String get realLifeScenarioBadge => isHindi ? 'दैनिक जीवन में उदाहरण' : 'REAL LIFE SCENARIO';
  String get practicalApplicationBadge => isHindi ? 'व्यावहारिक प्रभाव' : 'PRACTICAL APPLICATION';
  String get counterStrategyBadge => isHindi ? 'बचाव व समाधान' : 'COUNTER-STRATEGY';
  String get actionProtocolBadge => isHindi ? 'क्रियान्वयन विधि' : 'ACTION PROTOCOL';
  String get audioNoteLabel => isHindi ? 'ऑडियो नोट' : 'Audio Note';
  String get addVoiceNoteAction => isHindi ? '+ ऑडियो जोड़ें' : '+ Voice Note';
  String get videoAttachedLabel => isHindi ? 'वीडियो ड्रिल संलग्न' : 'Video Attached';
  String get addVideoDrillAction => isHindi ? '+ वीडियो ड्रिल' : '+ Video Drill';

  // Add Cognition Item Modal Sheet
  String get titleRequiredError => isHindi ? 'शीर्षक दर्ज करना अनिवार्य है' : 'Title is required';
  String get savedToVaultSuccess => isHindi ? 'कोष में सफलतापूर्वक सुरक्षित किया गया!' : 'Saved to Vault successfully!';
  String get editFrameworkCard => isHindi ? 'संपादित करें' : 'Edit Framework';
  String get addToVaultCard => isHindi ? 'नया कार्ड जोड़ें' : 'Add to Vault';
  String get typeChoiceMentalModel => isHindi ? 'चिंतन मॉडल' : 'Mental Model';
  String get typeChoiceFallacy => isHindi ? 'तर्क दोष' : 'Logical Fallacy';
  String get frameworkTitleLabel => isHindi ? 'शीर्षक *' : 'Title *';
  String get frameworkTitleHint => isHindi
      ? 'उदा. प्रथम सिद्धांत, स्ट्रॉमैन, व्युत्क्रमण'
      : 'e.g., First Principles, Inversion, Sunk Cost';
  String get frameworkSubtitleLabel => isHindi ? 'उपशीर्षक व सार' : 'Subtitle & Essence';
  String get frameworkSubtitleHint => isHindi
      ? 'उदा. जटिल समस्याओं को मूल तत्वों में तोड़ना'
      : 'e.g., Breaking problems down to fundamental truths';
  String get frameworkMechanismLabel => isHindi ? 'मूल सिद्धांत व तंत्र' : 'Core Principle & Mechanism';
  String get frameworkMechanismHint => isHindi
      ? 'यह मॉडल या तर्क दोष कैसे काम करता है?'
      : 'How does this framework or cognitive bias operate?';
  String get frameworkScenarioLabel => isHindi ? 'व्यावहारिक उदाहरण' : 'Real Life Scenario';
  String get frameworkScenarioHint => isHindi
      ? 'दैनिक जीवन या कार्यस्थल पर इसका वास्तविक उदाहरण'
      : 'Practical real-life or workplace manifestation';
  String get frameworkAntidoteLabel => isHindi ? 'बचाव व समाधान (प्रति-रणनीति)' : 'Counter-Strategy & Action Protocol';
  String get frameworkAntidoteHint => isHindi
      ? 'इसके समाधान या उपयोग की चरणबद्ध विधि'
      : 'Practical steps to counter or apply this model';
  String get frameworkMaximLabel => isHindi ? 'एक-पंक्ति सूत्र' : '1-Liner Maxim';
  String get frameworkMaximHint => isHindi
      ? 'उदा. अनुमानों पर नहीं, तथ्यों पर विश्वास करें।'
      : 'e.g., Audit assumptions; trust verified reality.';
  String get frameworkTagsLabel => isHindi ? 'टैग्स (अल्पविराम से अलग)' : 'Tags (comma separated)';
  String get frameworkTagsHint => isHindi ? 'निर्णय, तर्क, समत्व' : 'Decisions, Logic, Poise';
  String get saveToVaultButton => isHindi ? 'कोष में सुरक्षित करें' : 'Save to Vault';

  // Cognition Vault Screen
  String joyItemsSummary(int total, int music, int visual, int other) => isHindi
      ? 'कुल $total व्यक्तिगत एंकर ($music संगीत, $visual दृश्य, $other उद्धरण व स्मृति)'
      : '$total personal serenity anchors ($music music, $visual visual, $other quotes & memories)';
  String allResourcesCategory(int count) => isHindi ? 'सभी स्रोत ($count)' : 'ALL RESOURCES ($count)';
  String get sanctuaryResourceTapBanner => isHindi
      ? 'किसी भी स्रोत पर टैप करें - ग्रंथ, ड्राइव पीडीएफ या यूट्यूब वीडियो सीधे ऐप के भीतर खुलेंगे।'
      : 'Tap any resource to open classical texts, Drive PDFs, or YouTube videos seamlessly inside the app.';
  String get searchMentalModelsHint => isHindi
      ? 'मानसिक मॉडल, प्रथम सिद्धांत, सिस्टम्स खोजें...'
      : 'Search mental models, first principles, systems...';
  String allModelsCategory(int count) => isHindi ? 'सभी मॉडल ($count)' : 'ALL MODELS ($count)';
  String stoicModelsCategory(int count) => isHindi ? 'स्टोइक मॉडल ($count)' : 'STOIC MODELS ($count)';
  String rulesOfEngagementCategory(int count) => isHindi ? 'आचरण के नियम ($count)' : 'RULES OF ENGAGEMENT ($count)';
  String caseStudiesCategory(int count) => isHindi ? 'केस स्टडीज ($count)' : 'CASE STUDIES ($count)';
  String get searchFallaciesHint => isHindi ? 'तर्कदोष, भ्रांतियां, पूर्वाग्रह खोजें...' : 'Search ad hominem, strawman, false dilemma...';
  String get appealToEmotionTag => isHindi ? 'भावनात्मक अपील' : 'Appeal to Emotion';
  String get offlineSovereignSandboxBadge => isHindi ? 'ऑफ़लाइन संप्रभु सैंडबॉक्स' : 'OFFLINE SOVEREIGN SANDBOX';
  String get offlineToolsDescription => isHindi
      ? 'अपने निजी उपकरण, कैलकुलेटर और इंटरैक्टिव निर्णय मैट्रिक्स आयात करें। बिना किसी बाहरी निर्भरता के 100% ऑफ़लाइन।'
      : 'Import your private single-page tools, calculators, and interactive decision matrices. Stored 100% offline with zero cloud telemetry and full JavaScript execution.';

  // Execution Trigger Screen
  String get changeTimeButton => isHindi ? 'बदलें' : 'Change';
  String get dailyBlockSubtitle => isHindi ? 'दैनिक ब्लॉक' : 'Daily Block';
  String removeTimeBlockConfirm(String title) => isHindi
      ? 'क्या आप "$title" को दैनिक सूची से हटाना चाहते हैं?'
      : 'Remove "$title" from your daily blocks schedule?';
  String get testChimeTooltip => isHindi ? 'नाद परीक्षण' : 'Test Chime';

  // Video Reflection Drill Modal
  String get sixtySecComposureBadge => isHindi ? '60-सेकंड आंगिक समीक्षा' : '60-SECOND COMPOSURE REVIEW';
  String get closeTooltip => isHindi ? 'बंद करें' : 'Close';
  String get initializingLens => isHindi ? 'लेंस सक्रिय हो रहा है...' : 'Initializing camera lens for composure review...';
  String get recordingActiveHoldFrame => isHindi ? 'रिकॉर्डिंग चालू है • शांत रहें' : 'RECORDING ACTIVE • HOLD FRAME';
  String secondsRemainingBadge(String time) => isHindi ? '$time शेष' : '$time remaining';

  // Core Rule Card
  String chimeSoundedNotice(String time) => isHindi
      ? 'घंटी बजी! $time पर दैनिक स्मरण सक्रिय है।'
      : 'Chime sounded! Active daily reminder set for $time.';
  String dailyReminderTimeBadge(String time) => isHindi
      ? 'दैनिक स्मरण ($time)'
      : 'Daily Reminder ($time)';

  // Dashboard Screen
  String viewAllAnchorsAction(int count) => isHindi
      ? 'सभी $count एंकर देखें व प्रबंधित करें'
      : 'View & manage all $count anchors';
  String get composureScoreScaleSub => isHindi
      ? '1 = पूर्ण नियंत्रण खोया (आवेग), 5 = पूर्णतः शांत व निष्पक्ष रहा'
      : '1 = Lost control, 5 = Absolute composure & calm';
  String dailyReviewDateTitle(String date) => isHindi
      ? 'दैनिक व्यवहार समीक्षा • $date'
      : 'Daily Review • $date';

  // Journal Screen
  String get enterReflectionPrompt => isHindi ? 'कृपया अपने विचार या चिंतन लिखें।' : 'Please enter your reflection or thoughts.';
  String get enterSourceOrTakeawayPrompt => isHindi
      ? 'कृपया स्रोत का नाम अथवा कम से कम एक निष्कर्ष दर्ज करें।'
      : 'Please enter a source title or at least one takeaway.';
  String get cognitionWorkspaceSubtitle => isHindi
      ? 'दैनिक व्यवहार समीक्षा, 1:3 आउटपुट, व्यक्तिगत डायरी व स्थितप्रज्ञ संचयन का संप्रभु केंद्र।'
      : 'Sovereign workspace for daily reviews, 1:3 takeaways, personal journal notes, and saving resources to vaults.';
  String get journalFreeformHint => isHindi
      ? 'मन के अव्यक्त विचार, भावनाएं व मुक्त चिंतन बिना किसी संकोच के लिखें...'
      : 'Write your thoughts freely, unfiltered feelings, observations, or reflections...';
  String get planningObjectiveHint => isHindi
      ? 'आगामी कार्य, रणनीतिक प्राथमिकताएं व कार्य योजना बिंदुवार लिखें...'
      : 'Outline upcoming tasks, milestones, high leverage actions, or strategic plans...';
  String get selfTalkScriptHint => isHindi
      ? 'कठिन परिस्थितियों हेतु शांतिदायक आंतरिक संवाद, स्थितप्रज्ञ लंगर व संकल्प लिखें...'
      : 'Write calming scripts, stoic self-talk, reassuring perspectives, or personal mantras...';
  String get executionLedgerDescription => isHindi
      ? 'साधारण अलार्म के स्थान पर शांत कर्म-घोष, 5-मिनट प्रज्वलन व सद्गुण आचरण प्रविष्टियां (उदारता, गांभीर्य, प्रसन्नता, संयम)।'
      : 'Customizable execution chimes, 5-minute micro-ignitions, and sovereign trait logs (Magnanimity, Gravitas, Joy, Restraint).';

  // Audio Memo Recorder
  String get audioPlayingStatus => isHindi ? 'बज रहा है...' : 'Playing...';
  String get audioRecordingReady => isHindi ? 'ऑडियो रिकॉर्डिंग तैयार' : 'Audio recording ready';
  String get audioRecordingActivePrompt => isHindi ? 'मौखिक समीक्षा रिकॉर्ड हो रही है...' : 'Recording verbal audit...';
  String get tapRecordToCapturePrompt => isHindi ? 'रिकॉर्ड करने के लिए टैप करें' : 'Tap record to capture verbal thoughts';

  // Wisdom Card
  String get wisdomCopiedNotice => isHindi ? 'प्रज्ञा क्लिपबोर्ड पर कॉपी की गई' : 'Copied wisdom to clipboard';

  // Dashboard Additional
  String get enterFocusPrompt => isHindi ? 'कृपया आज का मुख्य लक्ष्य दर्ज करें।' : 'Please enter today\'s main focus.';
  String get focusSavedNotice => isHindi ? 'मुख्य लक्ष्य सफलतापूर्वक सुरक्षित किया गया!' : 'Main focus saved successfully!';
  String get enterRationalDecisionPrompt => isHindi
      ? 'कृपया आज का सबसे तार्किक निर्णय या मुख्य कार्य दर्ज करें।'
      : 'Please state today\'s most rational decision or core milestone.';
  String get nightDebriefSavedNotice => isHindi ? 'रात्रि समीक्षा सफलतापूर्वक संजोई गई!' : 'Night debrief recorded successfully!';
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
