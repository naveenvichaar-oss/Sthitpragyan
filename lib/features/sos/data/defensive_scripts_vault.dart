/// DefensiveScript provides an exact verbal formulation for hostile workplace situations.
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
      category: map['category'] as String? ?? 'Unjust Accusation',
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
/// tested for high-stakes corporate conversations, meetings, and emails.
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
    // Category 1: Interruption & Over-talking
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'int_01',
      category: 'Interruption',
      scenario: 'A colleague or manager cuts you off mid-presentation.',
      hostileTrigger:
          '"Hold on, let me jump in because you\'re missing the point..."',
      executiveScript: 'Allow me to finish this point to complete the data picture, and then I\'ll immediately open the floor for your feedback.',
      tacticalRationale: 'Asserts procedural dominance without attacking their character. Keeps meeting momentum in your court.',
      toneGuidance:
          'Calm, steady volume, no pitch spike, index finger slightly raised.',
    ),
    DefensiveScript(
      id: 'int_02',
      category: 'Interruption',
      scenario: 'Persistent aggressive talker repeatedly overrides the room.',
      hostileTrigger: 'Continuous overriding chatter whenever you speak.',
      executiveScript: 'I\'ve listened to your perspectives for the last ten minutes. I will now share the technical assessment without interruptions.',
      tacticalRationale: 'Highlights the asymmetry of their conduct while establishing a firm procedural boundary.',
      toneGuidance:
          'Slow tempo, authoritative eye contact, direct neutral gaze.',
    ),

    // -------------------------------------------------------------
    // Category 2: Gaslighting & Reality Inversion
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'gas_01',
      category: 'Gaslighting',
      scenario: 'Stakeholder claims an agreed decision or deliverable was never discussed.',
      hostileTrigger:
          '"I never approved this scope. You misunderstood the objective."',
      executiveScript: 'I am referencing the sign-off notes from our October 4th sync, section 3.2. Let\'s pull that document up right now so we\'re anchored on verified facts.',
      tacticalRationale: 'Deflects emotional doubt by grounding the room in immutable written records.',
      toneGuidance:
          'Matter-of-fact, collaborative curiosity, zero defensiveness.',
    ),
    DefensiveScript(
      id: 'gas_02',
      category: 'Gaslighting',
      scenario: 'Boss claims you are being "too emotional" or "defensive" when stating facts.',
      hostileTrigger: '"Why are you taking this so personally? You\'re being overly emotional."',
      executiveScript: 'My tone is neutral; my focus is purely on project risk and contract parameters. Let\'s return to slide 4 and resolve the bottleneck.',
      tacticalRationale: 'Rejects the psychoanalysis label in one sentence and redirects attention back to technical deliverables.',
      toneGuidance: 'Completely flat cadence. Zero inflection.',
    ),

    // -------------------------------------------------------------
    // Category 3: Blame Shifting & Scapegoating
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
      scenario:
          'Executive demands an instant confession of fault in public chat.',
      hostileTrigger:
          '"Why was this pushed if it wasn\'t ready? Whose fault is this?"',
      executiveScript: 'We are conducting a root cause post-mortem right now. I will publish the factual incident report with remediations by 4 PM rather than speculate.',
      tacticalRationale: 'Puts a stop to public kangaroo courts and buys time for verified facts.',
      toneGuidance: 'Sober, responsible, forward-looking.',
    ),

    // -------------------------------------------------------------
    // Category 4: Passive Aggression & Sarcasm
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'pas_01',
      category: 'Passive Aggression',
      scenario:
          'Colleague makes a sarcastic jab about your hours or boundaries.',
      hostileTrigger: '"Must be nice to clock out right at 5 while the rest of us work hard."',
      executiveScript: 'My working agreements and milestones are calibrated with leadership. If there\'s an unassigned deliverable you need help prioritizing, let\'s document it.',
      tacticalRationale: 'Exposes covert guilt-tripping by demanding professional specificity.',
      toneGuidance: 'Polite, unruffled, professional.',
    ),

    // -------------------------------------------------------------
    // Category 5: Scope Creep & Manufactured Urgency
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
    // Category 6: Executive Rules of Engagement (Tactical Doctrines)
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'roe_script_01',
      category: 'Rules of Engagement',
      scenario: 'To reveal true intent, offer choices—preferences expose character.',
      hostileTrigger: 'Hidden agendas, ambiguous corporate demands, or manipulative politicking.',
      executiveScript: 'I see two distinct ways to move this forward: Option A focuses on velocity, while Option B protects reliability. Which of these two aligns with your core priority?',
      tacticalRationale: 'To reveal true intent, offer choices—preferences expose character. Never guess what they want; let their selection commit their motives in writing.',
      toneGuidance: 'Calm, measured, consultative, zero defensive justification.',
    ),
    DefensiveScript(
      id: 'roe_script_02',
      category: 'Rules of Engagement',
      scenario: 'Never argue with someone playing the victim card—stick strictly to facts and formal closure.',
      hostileTrigger: '"You are always targeting me / No one supports my department / This is so unfair!"',
      executiveScript: 'Let\'s focus strictly on the agreed milestones and documented criteria. The current delta is X; here is the factual remediation path. Let\'s record this and proceed.',
      tacticalRationale: 'Never argue with someone playing the victim card—stick strictly to facts and formal closure. Emotional validation fuels the drama cycle; factual clarity terminates it.',
      toneGuidance: 'Neutral, flat, firm tone; do not match emotional hysterics.',
    ),
    DefensiveScript(
      id: 'roe_script_03',
      category: 'Rules of Engagement',
      scenario: 'Demand objective specifics on abstract criticism, then embrace strategic silence.',
      hostileTrigger: '"This report doesn\'t feel right / Your team isn\'t showing executive presence."',
      executiveScript: 'What specific objective metrics or factual criteria are you measuring that against? [Strategic silence: Maintain direct eye contact, do not fill the silence].',
      tacticalRationale: 'Demand objective specifics on abstract criticism, then embrace strategic silence. Forces the critic to either substantiate or withdraw their bluster.',
      toneGuidance: 'Slow, steady cadence, direct eye contact; zero rush to fill the silence.',
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
