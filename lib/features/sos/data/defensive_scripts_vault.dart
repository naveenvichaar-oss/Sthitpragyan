/// DefensiveScript provides an exact verbal formulation for hostile or difficult
/// life situations — commute, family, public spaces, or workplace.
class DefensiveScript {
  final String id;
  final String category;
  final String scenario;
  final String hostileTrigger;
  final String executiveScript;
  final String tacticalRationale;
  final String toneGuidance;
  final bool isCustom;

  const DefensiveScript({
    required this.id,
    required this.category,
    required this.scenario,
    required this.hostileTrigger,
    required this.executiveScript,
    required this.tacticalRationale,
    required this.toneGuidance,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'scenario': scenario,
    'hostileTrigger': hostileTrigger,
    'executiveScript': executiveScript,
    'tacticalRationale': tacticalRationale,
    'toneGuidance': toneGuidance,
    'isCustom': isCustom,
  };

  factory DefensiveScript.fromMap(Map<String, dynamic> map) {
    return DefensiveScript(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? 'Provocation',
      scenario: map['scenario'] as String? ?? '',
      hostileTrigger: map['hostileTrigger'] as String? ?? '',
      executiveScript: map['executiveScript'] as String? ?? '',
      tacticalRationale: map['tacticalRationale'] as String? ?? '',
      toneGuidance: map['toneGuidance'] as String? ?? '',
      isCustom: map['isCustom'] == true,
    );
  }

  DefensiveScript copyWith({
    String? id,
    String? category,
    String? scenario,
    String? hostileTrigger,
    String? executiveScript,
    String? tacticalRationale,
    String? toneGuidance,
    bool? isCustom,
  }) {
    return DefensiveScript(
      id: id ?? this.id,
      category: category ?? this.category,
      scenario: scenario ?? this.scenario,
      hostileTrigger: hostileTrigger ?? this.hostileTrigger,
      executiveScript: executiveScript ?? this.executiveScript,
      tacticalRationale: tacticalRationale ?? this.tacticalRationale,
      toneGuidance: toneGuidance ?? this.toneGuidance,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// DefensiveScriptsVault contains high-leverage, non-reactive scripts
/// for universal human situations — commute, family, public, workplace, or self-mastery.
class DefensiveScriptsVault {
  DefensiveScriptsVault._();

  static const List<DefensiveScript> scripts = [
    // -------------------------------------------------------------
    // Core Category A: Unjust Accusation / Vague Critique
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'spec_cat_a',
      category: 'Unjust Accusation',
      scenario: 'अमूर्त आरोप, अस्पष्ट आलोचना या गलत दोषारोपण।',
      hostileTrigger: 'इस काम में कोई दम नहीं है / एंगल ठीक नहीं लगा / "Your approach makes no sense"',
      executiveScript: 'भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए? कृपया बिंदु स्पष्ट करें।',
      tacticalRationale: 'कभी सफाई न दें। गेंद उनके पाले में डालें।',
      toneGuidance: 'तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।',
    ),

    // -------------------------------------------------------------
    // Core Category B: Intimidation / Micro-Dominance
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'spec_cat_b',
      category: 'Intimidation',
      scenario: 'आवाज ऊंची करना, धौंस जमाना या माइक्रो-डोमिनेंस दिखाना।',
      hostileTrigger: 'तुम्हें समझ नहीं आ रहा मैं क्या कह रहा हूँ / "You need to fix your attitude"',
      executiveScript: 'नोट कर लिया है। इसे रिव्यू करके अपडेट करता हूँ।',
      tacticalRationale: 'सपाट टोन, शून्य मुस्कान, 3 सेकंड आई-कांटेक्ट।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
    ),

    // -------------------------------------------------------------
    // Core Category C: Impossible Deadlines / Exploitative Allocation
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'spec_cat_c',
      category: 'Impossible Deadlines',
      scenario: 'असंभव डेडलाइन या अचानक नया काम थोपना।',
      hostileTrigger:
          'यह काम आज रात तक ही चाहिए / "I need this done right now regardless"',
      executiveScript: 'प्राथमिकता तय कर दीजिए। मौजूदा 2 मुख्य टास्क में से किसे होल्ड पर डालना है?',
      tacticalRationale: 'काम से मना नहीं किया, तार्किक सीमा खींच दी।',
      toneGuidance: 'पेशेवर, तार्किक, स्पष्ट सीमा रेखा।',
    ),

    // -------------------------------------------------------------
    // Category: Interruption & Over-talking
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'int_01',
      category: 'Interruption',
      scenario: 'Aggressive stakeholder talks over your presentation or explanation.',
      hostileTrigger: '"Hold on, let me stop you right there—you clearly haven\'t thought about..."',
      executiveScript: 'Allow me 60 seconds to finish the quantitative data point, and then we will open the floor directly for your counter-proposals.',
      tacticalRationale: 'Maintains conversational authority without matching vocal aggression. Establishes a concrete time boundary.',
      toneGuidance: 'Measured, unhurried, lower vocal register.',
    ),

    // -------------------------------------------------------------
    // Category: Blame Shifting & Scapegoating
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'blm_01',
      category: 'Blame Shifting',
      scenario: 'Cross-functional partner tries to pin a delayed project on your team.',
      hostileTrigger: '"The entire rollout is stuck because your team didn\'t move fast enough."',
      executiveScript: 'Let\'s separate system dependencies from execution. The dependency on your API specs was logged 18 days ago. Let\'s review the timeline audit together.',
      tacticalRationale: 'Separates emotion from sequence. Introduces chronological evidence that eliminates subjective blame.',
      toneGuidance: 'Objective, analytical, as if dissecting a machine part.',
    ),
    DefensiveScript(
      id: 'blm_02',
      category: 'Blame Shifting',
      scenario: 'Executive demands an instant confession of fault in public chat.',
      hostileTrigger: '"Why was this pushed if it wasn\'t ready? Whose fault is this?"',
      executiveScript: 'We are conducting a root cause post-mortem right now. I will publish the factual incident report with remediations by 4 PM rather than speculate.',
      tacticalRationale: 'Puts a stop to public kangaroo courts and buys time for verified facts.',
      toneGuidance: 'Sober, responsible, forward-looking.',
    ),

    // -------------------------------------------------------------
    // Category: Passive Aggression & Sarcasm
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'pas_01',
      category: 'Passive Aggression',
      scenario: 'Colleague makes a sarcastic jab about your hours or boundaries.',
      hostileTrigger: '"Must be nice to clock out right at 5 while the rest of us work hard."',
      executiveScript: 'My working agreements and milestones are calibrated with leadership. If there\'s an unassigned deliverable you need help prioritizing, let\'s document it.',
      tacticalRationale: 'Exposes covert guilt-tripping by demanding professional specificity.',
      toneGuidance: 'Polite, unruffled, professional.',
    ),

    // -------------------------------------------------------------
    // Category: Scope Creep & Manufactured Urgency
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'urg_01',
      category: 'Scope Creep',
      scenario: 'Emergency dump on Friday evening or late night.',
      hostileTrigger: '"This is urgent. I need this whole deck rewritten by tomorrow morning."',
      executiveScript: 'High quality execution on this scope requires 6 business hours. We can deliver a high-level outline tonight, or a fully vetted deck on Monday at 10 AM. Which trade-off do you choose?',
      tacticalRationale: 'Offers two clear alternatives while forcing the requester to own the quality trade-off.',
      toneGuidance: 'Firm, decisive, consultative.',
    ),

    // -------------------------------------------------------------
    // Category: PublicTransit — सड़क व सार्वजनिक स्थल
    // Road rage, bus/metro crowding, uncivil strangers
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'transit_01',
      category: 'PublicTransit',
      scenario: 'सड़क पर अचानक गाली या धमकी — ट्रैफिक, पार्किंग विवाद, या भीड़ में टकराव।',
      hostileTrigger: '"अंधे हो क्या? / गाड़ी चलाना आता है कि नहीं?" / Aggressive honking and shouting.',
      executiveScript: 'शून्य प्रतिक्रिया। खिड़की बंद। नज़र आगे। आंतरिक वाक्य: "इसका गुस्सा इसकी समस्या है, मेरी नहीं।"',
      tacticalRationale: 'सड़क पर किसी अजनबी से वाद-विवाद में कोई जीत नहीं होती — केवल जोखिम बढ़ता है।',
      toneGuidance: 'शून्य आई-कॉन्टैक्ट, शून्य जवाब, शांत गति बनाए रखें।',
    ),
    DefensiveScript(
      id: 'transit_02',
      category: 'PublicTransit',
      scenario: 'बस/मेट्रो में अजनबी की असभ्य टिप्पणी या जानबूझकर धक्का।',
      hostileTrigger: '"ज़्यादा जगह ले रहे हो / हट जाओ / बूढ़ों को बैठने दो"',
      executiveScript: 'हल्का सिर हिलाना। बिना बोले एक कदम हटना। "मैं इसके स्तर पर नहीं उतरूंगा।"',
      tacticalRationale: 'भीड़ में तर्क करना हमेशा दर्शकों के सामने आपकी गरिमा घटाता है।',
      toneGuidance: 'तटस्थ, शून्य भाव, सपाट चेहरा।',
    ),
    DefensiveScript(
      id: 'transit_03',
      category: 'PublicTransit',
      scenario: 'Auto/cab driver refusing meter or overcharging aggressively.',
      hostileTrigger: '"No meter. Pay 500 or get out." / Threatening body language.',
      executiveScript: 'State the fair fare once, calmly. If refused: exit silently, book alternative. No argument.',
      tacticalRationale: 'You control your feet. Walk away. The refusal to engage is your power.',
      toneGuidance: 'Flat, factual, zero emotional investment.',
    ),

    // -------------------------------------------------------------
    // Category: Provocation — उकसावा व तंज
    // Deliberate baiting, sarcasm, taunts from any source
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'prov_01',
      category: 'Provocation',
      scenario: 'अमूर्त आरोप, अस्पष्ट आलोचना या गलत दोषारोपण।',
      hostileTrigger: '"इस काम में कोई दम नहीं है / तुमसे तो उम्मीद ही नहीं थी / You always mess things up."',
      executiveScript: 'क्या विशिष्ट तथ्यात्मक बिंदु में बदलाव चाहिए? कृपया स्पष्ट करें।',
      tacticalRationale: 'कभी सफाई न दें। गेंद उनके पाले में डालें। अस्पष्ट आलोचना को विशिष्ट बनाने से वो बेनकाब होते हैं।',
      toneGuidance: 'तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।',
    ),
    DefensiveScript(
      id: 'prov_02',
      category: 'Provocation',
      scenario: 'कोई जानबूझकर सार्वजनिक रूप से नीचा दिखाने की कोशिश कर रहा है।',
      hostileTrigger: '"तुम्हें तो समझ ही नहीं आता / You don\'t get it, do you?"',
      executiveScript: '"नोट कर लिया है।" — बस। कोई विस्तार नहीं, कोई सफाई नहीं।',
      tacticalRationale: 'संक्षिप्त, सपाट उत्तर उत्तेजक को शक्तिहीन बनाता है। लंबा जवाब = उनकी जीत।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
    ),
    DefensiveScript(
      id: 'prov_03',
      category: 'Provocation',
      scenario: 'Passive-aggressive sarcasm designed to get a rise out of you.',
      hostileTrigger: '"Must be nice to have such a relaxed life / Oh wow, you actually showed up today."',
      executiveScript: 'Brief, zero-emotion acknowledgment: "Hmm." Then redirect to the task at hand.',
      tacticalRationale: 'Sarcasm feeds on reaction. A flat response starves it.',
      toneGuidance: 'Polite, unruffled, zero defensive energy.',
    ),

    // -------------------------------------------------------------
    // Category: FamilyBoundary — पारिवारिक सीमा
    // In-law pressure, emotional manipulation at home, unsolicited advice
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'fam_01',
      category: 'FamilyBoundary',
      scenario: 'परिवार का सदस्य भावनात्मक दबाव डालकर अपनी बात मनवा रहा है।',
      hostileTrigger: '"तुम तो हमारी सुनते ही नहीं / बच्चे ऐसे नहीं होते / हमने तुम्हारे लिए क्या-क्या किया!"',
      executiveScript: '"मैं आपकी बात सुन रहा हूँ। मुझे सोचने का समय दीजिए।" — फिर कमरे से बाहर निकलें।',
      tacticalRationale: 'भावनात्मक बहस में उतरना = हार। "सोचने का समय" = शांत सीमा रेखा।',
      toneGuidance: 'सम्मानजनक किंतु दृढ़। स्वर ऊंचा न हो।',
    ),
    DefensiveScript(
      id: 'fam_02',
      category: 'FamilyBoundary',
      scenario: 'बिन माँगी सलाह या जीवनशैली पर टिप्पणी।',
      hostileTrigger: '"शादी कब करोगे? / बच्चे कब? / नौकरी बदलो / ये कपड़े ठीक नहीं हैं"',
      executiveScript: '"शुक्रिया, ध्यान रखूंगा।" — फिर विषय बदलें। कोई बहस नहीं, कोई सफाई नहीं।',
      tacticalRationale: 'सलाह देने वाले को सफाई चाहिए, सहमति नहीं। "ध्यान रखूंगा" बंद कर देता है।',
      toneGuidance: 'सौम्य, हल्की मुस्कान, कोई कड़वाहट नहीं।',
    ),
    DefensiveScript(
      id: 'fam_03',
      category: 'FamilyBoundary',
      scenario: 'Spouse/partner escalating argument. Emotional flooding.',
      hostileTrigger: 'Raised voice, bringing up past mistakes, or threatening ultimatums.',
      executiveScript: '"I can see this is important. Let\'s discuss this when we\'re both calmer — I commit to resuming in 30 minutes."',
      tacticalRationale: 'Flooded conversations destroy relationships. A 30-min pause allows the nervous system to reset.',
      toneGuidance: 'Warm but firm. Lower your voice as theirs rises.',
    ),

    // -------------------------------------------------------------
    // Category: WorkplaceComposure — कार्यस्थल शांति
    // Corporate toxicity, boss confrontation, meeting ambushes
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'work_01',
      category: 'WorkplaceComposure',
      scenario: 'आवाज ऊंची करना, धौंस जमाना या माइक्रो-डोमिनेंस दिखाना।',
      hostileTrigger: '"तुम्हें समझ नहीं आ रहा मैं क्या कह रहा हूँ / Fix your attitude!"',
      executiveScript: '"नोट कर लिया है। इसे रिव्यू करके अपडेट करता हूँ।"',
      tacticalRationale: 'सपाट टोन, शून्य मुस्कान, 3 सेकंड आई-कांटेक्ट।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
    ),
    DefensiveScript(
      id: 'work_02',
      category: 'WorkplaceComposure',
      scenario: 'असंभव डेडलाइन या अचानक नया काम थोपना।',
      hostileTrigger: '"यह काम आज रात तक ही चाहिए / I need this done right now regardless."',
      executiveScript: '"प्राथमिकता तय कर दीजिए। मौजूदा 2 मुख्य टास्क में से किसे होल्ड पर डालना है?"',
      tacticalRationale: 'काम से मना नहीं किया, तार्किक सीमा खींच दी।',
      toneGuidance: 'पेशेवर, तार्किक, स्पष्ट सीमा रेखा।',
    ),
    DefensiveScript(
      id: 'work_03',
      category: 'WorkplaceComposure',
      scenario: 'Gaslighting — stakeholder denies agreed decisions.',
      hostileTrigger: '"I never approved this. You misunderstood the objective."',
      executiveScript: '"I am referencing the sign-off from our October 4th sync, section 3.2. Let\'s pull that document now."',
      tacticalRationale: 'Deflect emotional doubt by grounding in written records.',
      toneGuidance: 'Matter-of-fact, collaborative curiosity, zero defensiveness.',
    ),
    DefensiveScript(
      id: 'work_04',
      category: 'WorkplaceComposure',
      scenario: 'Blame-shifting in front of leadership.',
      hostileTrigger: '"The rollout is stuck because your team didn\'t move fast enough."',
      executiveScript: '"Let\'s separate dependencies from execution. The dependency on your API specs was logged 18 days ago. Let\'s review the timeline."',
      tacticalRationale: 'Introduces chronological evidence that eliminates subjective blame.',
      toneGuidance: 'Objective, analytical, as if dissecting a machine part.',
    ),

    // -------------------------------------------------------------
    // Category: Gaslighting — गैसलाइटिंग
    // Denial of reality, emotional label attacks
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'gas_01',
      category: 'Gaslighting',
      scenario: 'कोई कह रहा है कि "तुम ज़रूरत से ज़्यादा सोच रहे हो / You\'re overthinking this."',
      hostileTrigger: '"तुम बहुत emotional हो / Why are you taking this so personally?"',
      executiveScript: '"मेरा स्वर तटस्थ है; मेरा फोकस तथ्यों पर है। चलिए मुद्दे पर लौटते हैं।"',
      tacticalRationale: 'लेबलिंग को एक वाक्य में खारिज करें और चर्चा को तकनीकी मुद्दे पर लौटाएं।',
      toneGuidance: 'पूर्णत: सपाट स्वर। शून्य उतार-चढ़ाव।',
    ),
    DefensiveScript(
      id: 'gas_02',
      category: 'Gaslighting',
      scenario: 'Someone rewrites history — denying what was said or agreed upon.',
      hostileTrigger: '"That never happened. You\'re making things up."',
      executiveScript: '"I have the records. Let\'s pull them up and verify together."',
      tacticalRationale: 'Written evidence is the antidote to gaslighting. Never argue from memory alone.',
      toneGuidance: 'Calm, factual, zero emotional charge.',
    ),

    // -------------------------------------------------------------
    // Category: SelfMastery — आत्म-अनुशासन
    // Internal battles, procrastination, self-doubt, discipline failure
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'self_01',
      category: 'SelfMastery',
      scenario: 'आंतरिक आवाज़ कह रही है "आज छोड़ दो, कल कर लेंगे।"',
      hostileTrigger: 'मन में: "बस आज और / थक गया हूँ / कल से पक्का"',
      executiveScript: 'केवल 5 मिनट। बस शुरू करो। टाइमर लगाओ। 5 मिनट बाद फैसला करना।',
      tacticalRationale: '5-मिनट नियम प्रतिरोध की सबसे बड़ी दीवार तोड़ता है। शुरू करने के बाद रुकना कठिन हो जाता है।',
      toneGuidance: 'आंतरिक — दृढ़, संक्षिप्त, बिना दया के।',
    ),
    DefensiveScript(
      id: 'self_02',
      category: 'SelfMastery',
      scenario: 'Self-doubt spiral after a failure or rejection.',
      hostileTrigger: 'Internal voice: "I\'m not good enough / I always fail / What\'s the point?"',
      executiveScript: '"One data point does not define a trend. What is the specific, correctable mistake? Fix that single variable."',
      tacticalRationale: 'Convert abstract self-doubt into a specific, actionable correction.',
      toneGuidance: 'Internal — clinical, detached, like a coach reviewing game tape.',
    ),
    DefensiveScript(
      id: 'self_03',
      category: 'SelfMastery',
      scenario: 'सोशल मीडिया या बाहरी तुलना से आत्म-संदेह।',
      hostileTrigger: '"सबके पास सब है, मेरे पास कुछ नहीं / उनकी ज़िंदगी कितनी अच्छी है"',
      executiveScript: '"तुलना = चोरी। दूसरे का हाइलाइट रील ≠ मेरी असलियत। मेरा मापदंड = कल का मैं।"',
      tacticalRationale: 'तुलना हमेशा अधूरी जानकारी पर होती है। एकमात्र वैध मापदंड = कल का स्वयं।',
      toneGuidance: 'आंतरिक — करुणामय किंतु तार्किक।',
    ),

    // -------------------------------------------------------------
    // Category: Rules of Engagement — कार्य नियम
    // Strategic doctrines for any confrontation
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'roe_01',
      category: 'Rules of Engagement',
      scenario: 'छिपे इरादों को उजागर करने के लिए विकल्प प्रस्तुत करें।',
      hostileTrigger: 'छिपे इरादे, अस्पष्ट माँग, या जोड़-तोड़।',
      executiveScript: '"दो स्पष्ट विकल्प हैं: A गति पर केंद्रित है, B विश्वसनीयता पर। आपकी प्राथमिकता क्या है?"',
      tacticalRationale: 'विकल्प देने से सामने वाले के इरादे उजागर होते हैं। अनुमान मत लगाओ — उनके चयन को उनके इरादे प्रकट करने दो।',
      toneGuidance: 'शांत, मापा हुआ, परामर्शदात्री।',
    ),
    DefensiveScript(
      id: 'roe_02',
      category: 'Rules of Engagement',
      scenario: 'रणनीतिक मौन: अस्पष्ट आलोचना पर विशिष्ट तथ्य माँगें, फिर चुप रहें।',
      hostileTrigger: '"यह ठीक नहीं लगा / आपकी टीम में executive presence नहीं है"',
      executiveScript: '"किन विशिष्ट मापदंडों के आधार पर? [मौन — सीधा आई-कॉन्टैक्ट, मौन न तोड़ें]"',
      tacticalRationale: 'विशिष्ट तथ्य माँगकर मौन साधना आलोचक को या तो प्रमाणित करने पर मजबूर करता है या वापस हटने पर।',
      toneGuidance: 'धीमी, स्थिर लय, सीधा आई-कॉन्टैक्ट; मौन भरने की जल्दी शून्य।',
    ),
    DefensiveScript(
      id: 'roe_03',
      category: 'Rules of Engagement',
      scenario: 'Victim-card player demanding emotional validation.',
      hostileTrigger: '"No one supports me / This is so unfair! / You always target me!"',
      executiveScript: '"Let\'s focus strictly on agreed milestones and documented criteria. Here is the factual remediation path."',
      tacticalRationale: 'Emotional validation fuels drama cycles; factual clarity terminates them.',
      toneGuidance: 'Neutral, flat, firm. Do not match emotional hysterics.',
    ),
  ];

  static List<String> get categories => getCategories();

  static List<String> getCategories([List<DefensiveScript>? currentScripts]) {
    const canonicalOrder = [
      'All',
      'Rules of Engagement',
      'Unjust Accusation',
      'Intimidation',
      'Impossible Deadlines',
      'Interruption',
      'Gaslighting',
      'Blame Shifting',
      'Passive Aggression',
      'Scope Creep',
      'PublicTransit',
      'Provocation',
      'FamilyBoundary',
      'WorkplaceComposure',
      'SelfMastery',
    ];
    if (currentScripts == null) {
      return List<String>.from(canonicalOrder);
    }
    final set = <String>{};
    for (final cat in canonicalOrder) {
      set.add(cat);
    }
    for (final s in currentScripts) {
      if (s.category.trim().isNotEmpty) {
        set.add(s.category.trim());
      }
    }
    return set.toList();
  }

  static List<DefensiveScript> getByCategory(
    String category, [
    List<DefensiveScript>? currentScripts,
  ]) {
    final list = currentScripts ?? scripts;
    if (category == 'All') return list;
    return list
        .where(
          (s) => s.category.trim().toLowerCase() == category.trim().toLowerCase(),
        )
        .toList();
  }
}
