import 'models/fallacy_and_model.dart';

/// CognitionDataSource provides an exhaustive, curated library of
/// corporate manipulation fallacies and stoic executive mental models.
class CognitionDataSource {
  CognitionDataSource._();

  static const List<CognitionItem> items = [
    // ------------------------------------------------------------------
    // SECTION 1: LOGICAL FALLACIES IN CORPORATE WARFARE
    // ------------------------------------------------------------------
    CognitionItem(
      id: 'fal_01',
      type: CognitionType.fallacy,
      title: 'Ad Hominem (Personal Attack)',
      subtitle: 'Attacking the person instead of the argument',
      latinName: 'Argumentum Ad Hominem',
      definition: 'Subverting an executive argument or data point by impugning the motives, personality, or tenure of the speaker.',
      corporateManifestation: '"You\'ve only been at this company for six months, so you don\'t understand how complex our culture is."',
      antidoteProtocol: 'Separate the person from the data: "My tenure doesn\'t alter the telemetry on latency. Let\'s evaluate the benchmark numbers directly."',
      quickMaxim: 'Disregard the speaker\'s identity; audit the arithmetic.',
      tags: ['Defense', 'Boardroom', 'Tenure', 'Meetings'],
    ),
    CognitionItem(
      id: 'fal_02',
      type: CognitionType.fallacy,
      title: 'Strawman Distortion',
      subtitle: 'Refuting an exaggerated, ridiculous caricature',
      latinName: 'Ignoratio Elenchi',
      definition: 'Mischaracterizing your measured proposal into an extreme, reckless absurdity, then attacking that absurdity.',
      corporateManifestation: '"So what you\'re saying is you want us to halt all shipping and let our competitors destroy our market share?"',
      antidoteProtocol: 'Name the delta: "No. I proposed a 48-hour soak test for security patches, not halting shipping. Let\'s address the soak test parameters."',
      quickMaxim:
          'Re-anchor on your exact words; refuse the cartoon caricature.',
      tags: ['Manipulation', 'Debate', 'Scope'],
    ),
    CognitionItem(
      id: 'fal_03',
      type: CognitionType.fallacy,
      title: 'False Dilemma / Hobson\'s Trap',
      subtitle: 'Forcing an artificial binary choice',
      latinName: 'Bifurcatio Falsa',
      definition: 'Framing a complex operational problem as an either-or scenario to eliminate nuanced objections or push risky shortcuts.',
      corporateManifestation: '"Either we work this entire weekend and cut the compliance checks, or the launch is cancelled."',
      antidoteProtocol: 'Introduce the third option: "Those aren\'t the only two paths. We can release the core module on schedule and stage the secondary feature next sprint."',
      quickMaxim: 'Refuse false binaries; create Option C.',
      tags: ['Negotiation', 'Deadlines', 'Pressure'],
    ),
    CognitionItem(
      id: 'fal_04',
      type: CognitionType.fallacy,
      title: 'Moving Goalposts',
      subtitle: 'Shifting the criteria after fulfillment',
      latinName: 'Special Pleading',
      definition: 'Demanding further proof or additional concessions immediately after you fulfill previously agreed requirements.',
      corporateManifestation: '"Yes, you reduced the defect rate to 2%, but you didn\'t rewrite the documentation pipeline."',
      antidoteProtocol: 'Document the baseline: "Our agreed SLA was 2% defect rate. Let\'s mark that deliverable closed before scoping the documentation rewrite for Q2."',
      quickMaxim: 'Lock the sprint definition; refuse retroactive expansion.',
      tags: ['Reviews', 'SLA', 'Scope Creep'],
    ),
    CognitionItem(
      id: 'fal_05',
      type: CognitionType.fallacy,
      title: 'Kafka-Trapping',
      subtitle: 'Treating denial of guilt as proof of guilt',
      latinName: 'Contraria Assertio',
      definition: 'A psychological trap where your calm denial of an accusation is cited as conclusive evidence that the accusation is true.',
      corporateManifestation: '"Your defensive reaction proves that you feel guilty about the client churn."',
      antidoteProtocol: 'Refuse emotional engagement: "I am providing documented churn telemetry, not emotional defensiveness. Let us look at the analytics."',
      quickMaxim: 'Never defend against accusations of emotion; present immutable logs.',
      tags: ['Gaslighting', 'Psychological', '1-on-1s'],
    ),
    CognitionItem(
      id: 'fal_06',
      type: CognitionType.fallacy,
      title: 'Sunk Cost Guilt-Trip',
      subtitle: 'Throwing good energy after bad to preserve ego',
      latinName: 'Concordia Fallacia',
      definition: 'Justifying further expenditure of engineering time or weekend labor because "we\'ve already put so much into it."',
      corporateManifestation: '"We\'ve already invested 8 months into this vendor solution, we can\'t pull out now just because it failed the audit."',
      antidoteProtocol: 'Audit the forward delta: "Past hours are unrecoverable. Every hour going forward is new capital. Is this the highest yield use of next week?"',
      quickMaxim: 'Past time is spent; judge solely on forward ROI.',
      tags: ['Budget', 'Strategy', 'Projects'],
    ),
    CognitionItem(
      id: 'fal_07',
      type: CognitionType.fallacy,
      title: 'Motte-and-Bailey Maneuver',
      subtitle: 'Conflating a radical demand with common sense',
      latinName: 'Castellum et Vallum',
      definition: 'Advancing an overreaching demand (the bailey), but retreating to an unassailable modest claim (the motte) when challenged.',
      corporateManifestation: '"I just want the team to care about quality!" (after demanding unpaid 80-hour workweeks).',
      antidoteProtocol: 'Pin down the exact policy: "We all agree on quality. We are discussing the specific mechanism: 80-hour weeks vs sustainable automated testing."',
      quickMaxim: 'Agree with the obvious virtue; isolate the abusive policy.',
      tags: ['Manipulation', 'Leadership', 'Overwork'],
    ),

    // ------------------------------------------------------------------
    // SECTION 2: STOIC MENTAL MODELS FOR EXECUTIVE EQUANIMITY
    // ------------------------------------------------------------------
    CognitionItem(
      id: 'stoic_01',
      type: CognitionType.mentalModel,
      title: 'Dichotomy of Control',
      subtitle: 'The supreme foundation of mental peace',
      latinName: 'Epictetus • Enchiridion',
      definition: 'Dividing reality into two strict buckets: what is within your voluntary control (opinions, intentions, actions) and what is not (other people\'s moods, decisions, promotions).',
      corporateManifestation: 'A toxic CEO sends a late-night furious Slack. The CEO\'s volatility is entirely in their bucket. Your response tempo and composure are in yours.',
      antidoteProtocol: 'Audit every crisis: "Is this factor within my sovereign control?" If no, mark it as external weather and refuse to bleed for it.',
      quickMaxim:
          'Do not invest emotional capital in other people\'s nervous systems.',
      tags: ['Foundation', 'Control', 'Equanimity'],
    ),
    CognitionItem(
      id: 'stoic_02',
      type: CognitionType.mentalModel,
      title: 'Premeditatio Malorum',
      subtitle: 'Negative visualization & crisis inoculation',
      latinName: 'Seneca • Letters 24',
      definition: 'Pre-imagining potential workplace catastrophes, layoffs, sabotage, and difficult personalities before they happen so you are psychologically inoculated.',
      corporateManifestation: 'Before walking into a contentious QBR, visualize the VP interrupting you, cutting budget, and demanding impossible deadlines.',
      antidoteProtocol: 'Because you ran the simulation in advance, the actual hostility causes zero surprise, zero adrenaline spike, and zero panic.',
      quickMaxim: 'Surprise is the father of panic; premeditation is the father of poise.',
      tags: ['Preparation', 'Meetings', 'Resilience'],
    ),
    CognitionItem(
      id: 'stoic_03',
      type: CognitionType.mentalModel,
      title: 'The View from Above',
      subtitle: 'Orbital detachment & cognitive scaling',
      latinName: 'Marcus Aurelius • Meditations IX',
      definition: 'Zooming out your mental camera to orbital altitude—viewing the office building, the city, the continent, and geologic time.',
      corporateManifestation: 'When a colleague leaves a passive-aggressive comment on your pull request and your heart rate accelerates.',
      antidoteProtocol: 'Observe the microscopic insignificance of a pull request comment against the cosmic timeline. Laugh softly at the illusion of gravity.',
      quickMaxim: 'Expand the aperture; dissolve the drama.',
      tags: ['Perspective', 'Detachment', 'Stress'],
    ),
    CognitionItem(
      id: 'stoic_04',
      type: CognitionType.mentalModel,
      title: 'Amor Fati (Loving the Obstacle)',
      subtitle: 'Transmuting toxicity into training',
      latinName: 'Nietzsche / Marcus Aurelius',
      definition: 'Not merely tolerating difficult leaders or broken systems, but actively embracing them as weight plates in your executive gym.',
      corporateManifestation: 'Assigned to clean up an intractable legacy mess under a dysfunctional micromanager.',
      antidoteProtocol: 'Reframe: "This is a masterclass in written boundary enforcement and contractual self-protection. I will leave this stronger than any easy project could make me."',
      quickMaxim: 'The fire feeds on what is thrown upon it.',
      tags: ['Growth', 'Mindset', 'Hardship'],
    ),
    CognitionItem(
      id: 'stoic_05',
      type: CognitionType.mentalModel,
      title: 'Cognitive Distancing / Solomon\'s Paradox',
      subtitle: 'Advising yourself as a third-party consultant',
      latinName: 'Alter Ego Separation',
      definition: 'Humans make terrible, reactive decisions for themselves because of cortisol, but give brilliant, composed advice to others.',
      corporateManifestation: 'Feeling paralyzed after being humiliated in a team-wide email thread.',
      antidoteProtocol: 'Ask: "If a tier-one executive consultant were hired to handle this scenario on my behalf, what precise email would they draft right now?"',
      quickMaxim: 'Step outside the ego; advise the operator.',
      tags: ['Objectivity', 'Strategy', 'Crisis'],
    ),
    CognitionItem(
      id: 'stoic_06',
      type: CognitionType.mentalModel,
      title: 'The Inner Citadel (Apatheia)',
      subtitle: 'The inviolable sanctuary of the rational mind',
      latinName: 'Arx Mentis',
      definition: 'Recognizing that no manager or hostile coworker can penetrate your internal mind without your explicit assent.',
      corporateManifestation: 'A toxic executive attempts to intimidate you through shouting or physical posturing in a private room.',
      antidoteProtocol: 'Observe them like an actor performing on a stage. Their yelling is merely sound waves vibrating air. Your citadel remains impregnable.',
      quickMaxim: 'They can touch the project; they cannot touch the mind.',
      tags: ['Invulnerability', 'Poise', 'High Tension'],
    ),

    // ------------------------------------------------------------------
    // SECTION 3: EXECUTIVE RULES OF ENGAGEMENT
    // ------------------------------------------------------------------
    CognitionItem(
      id: 'roe_cog_01',
      type: CognitionType.rulesOfEngagement,
      title: 'Offer Choices to Expose Intent',
      subtitle: 'To reveal true intent, offer choices—preferences expose character.',
      latinName: 'Optio Probat Hominem',
      definition: 'When adversaries disguise their true agenda behind vague or contradictory demands, present binary professional choices with clear trade-offs. Their selection forces their actual motives into daylight.',
      corporateManifestation: 'A manager gives confusing directives, refusing to commit to scope while hinting at dissatisfaction.',
      antidoteProtocol: 'Present Option A (Velocity focus) vs Option B (Robustness focus) in writing. Ask: "Which priority guides our milestone?"',
      quickMaxim: 'Preferences expose character; force binary commitments in writing.',
      tags: ['Rules of Engagement', 'Manipulation', 'Intent', 'Options'],
    ),
    CognitionItem(
      id: 'roe_cog_02',
      type: CognitionType.rulesOfEngagement,
      title: 'Victim Card Disengagement',
      subtitle: 'Never argue with someone playing the victim card—stick strictly to facts and formal closure.',
      latinName: 'Facies Non Lacrimae',
      definition: 'Emotional manipulation where an underperforming or passive-aggressive peer weaponizes perceived persecution or martyrdom to derail objective scrutiny.',
      corporateManifestation: '"Why are you always picking on my deliverables? Everyone knows you favor the frontend team!"',
      antidoteProtocol: 'Refuse all emotional debate. Reiterate factual deliverables and documented SLA without apology: "We are reviewing Jira item 402 against the acceptance criteria. Here is the delta."',
      quickMaxim: 'Drama demands an audience; facts terminate the theater.',
      tags: ['Rules of Engagement', 'Victimhood', 'Emotional Shield', 'Boundaries'],
    ),
    CognitionItem(
      id: 'roe_cog_03',
      type: CognitionType.rulesOfEngagement,
      title: 'Strategic Silence on Abstract Criticism',
      subtitle: 'Demand objective specifics on abstract criticism, then embrace strategic silence.',
      latinName: 'Silentium Strategicum',
      definition: 'When met with unsubstantiated, vague disapproval designed to induce self-doubt, require concrete metrics and maintain complete silence while they struggle to substantiate it.',
      corporateManifestation: '"I\'m just not feeling that your team is aligned with our executive ethos."',
      antidoteProtocol: 'Ask: "What specific objective criteria or data points are you measuring that alignment against?" Then stay completely silent. Do not nod, do not fidget, do not speak.',
      quickMaxim: 'The first person to speak after a calibrated question loses frame.',
      tags: ['Rules of Engagement', 'Silence', 'Executive Frame', 'Critique'],
    ),
  ];

  static List<CognitionItem> getFallacies() {
    return items.where((i) => i.type == CognitionType.fallacy).toList();
  }

  static List<CognitionItem> getMentalModels() {
    return items.where((i) => i.type == CognitionType.mentalModel).toList();
  }

  static List<CognitionItem> getRulesOfEngagement() {
    return items.where((i) => i.type == CognitionType.rulesOfEngagement).toList();
  }

  static List<CognitionItem> search(String query, [CognitionType? filterType]) {
    return items.where((i) {
      if (filterType != null && i.type != filterType) return false;
      return i.matchesQuery(query);
    }).toList();
  }
}
