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
    DefensiveScript(
      id: 'pas_02',
      category: 'Passive Aggression',
      scenario: 'Snide remarks during a review meeting.',
      hostileTrigger:
          '"Well, if you really think that\'s the best you can do..."',
      executiveScript: 'I evaluate proposals against empirical metrics. What specific change in the output metric do you recommend?',
      tacticalRationale: 'Converts subjective disdain into actionable quantitative critique, which passive aggressors cannot support.',
      toneGuidance: 'Direct, open, unhurried.',
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
    DefensiveScript(
      id: 'urg_02',
      category: 'Scope Creep',
      scenario: 'Manager adds a major project without adjusting bandwidth.',
      hostileTrigger: '"Can you just squeeze this in on top of your existing deliverables?"',
      executiveScript: 'My capacity is currently committed to Project Alpha. If this new initiative takes precedence, which milestone in Alpha should we pause?',
      tacticalRationale: 'Reminds leadership that time is zero-sum without saying a defiant "no".',
      toneGuidance: 'Calmly operational.',
    ),

    // -------------------------------------------------------------
    // Category 6: Emotional Baiting & Derailment
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'bat_01',
      category: 'Emotional Baiting',
      scenario:
          'Personalized attack on competence or status in front of peers.',
      hostileTrigger: '"Are you even qualified to make this call?"',
      executiveScript: 'My responsibility here is to evaluate the technical risk according to company standards. Let\'s keep the discussion focused on the architectural impact.',
      tacticalRationale: 'Ignores the bait completely. Does not defend self-worth; protects scope authority.',
      toneGuidance: 'Unflinching eye contact, lower chest resonance, unsmiling stillness.',
    ),
  ];

  static List<String> get categories {
    return [
      'All',
      'Interruption',
      'Gaslighting',
      'Blame Shifting',
      'Passive Aggression',
      'Scope Creep',
      'Emotional Baiting',
    ];
  }

  static List<DefensiveScript> getByCategory(String category) {
    if (category == 'All') return scripts;
    return scripts.where((s) => s.category == category).toList();
  }
}
