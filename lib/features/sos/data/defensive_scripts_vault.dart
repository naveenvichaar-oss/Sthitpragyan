/// DefensiveScript provides an exact verbal formulation for hostile workplace situations.
class DefensiveScript {
  final String id;
  final String category;
  final String scenario;
  final String hostileTrigger;
  final String executiveScript;
  final String tacticalRationale;
  final String toneGuidance;

  const DefensiveScript({
    required this.id,
    required this.category,
    required this.scenario,
    required this.hostileTrigger,
    required this.executiveScript,
    required this.tacticalRationale,
    required this.toneGuidance,
  });
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
  ];

  static List<String> get categories {
    return [
      'All',
      'Unjust Accusation',
      'Intimidation',
      'Impossible Deadlines',
      'Interruption',
      'Gaslighting',
      'Blame Shifting',
      'Passive Aggression',
      'Scope Creep',
    ];
  }

  static List<DefensiveScript> getByCategory(String category) {
    if (category == 'All') return scripts;
    return scripts.where((s) => s.category == category).toList();
  }
}
