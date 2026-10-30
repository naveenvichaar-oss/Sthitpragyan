import 'models/daily_rule.dart';

/// DailyRulesVault provides curated Stoic executive rules.
/// Each rule bridges classical philosophical equanimity with tactical corporate behavior.
class DailyRulesVault {
  DailyRulesVault._();

  static const List<DailyRule> rules = [
    DailyRule(
      id: 1,
      title: 'THE 4-SECOND TACTICAL PAUSE',
      aphorism: 'Remember that foul words or blows are not in themselves an insult. What is insulting is your opinion of them.',
      source: 'Epictetus • Enchiridion 20',
      tacticalAction: 'When attacked or ambushed in a meeting, wait 4 full seconds before opening your mouth. Let silence absorb their emotional velocity.',
      corporateContext:
          'Hostile Q&A, sudden budget attacks, accusatory Slacks.',
    ),
    DailyRule(
      id: 2,
      title: 'DICHOTOMY OF LOCUS',
      aphorism: 'Some things are in our control and others not. Things in our control are opinion, pursuit, desire, aversion, and, in a word, whatever are our own actions.',
      source: 'Epictetus • Discourses I',
      tacticalAction: 'Identify what part of this fire drill is your actual deliverable vs leadership panic. Execute only the former; disregard the drama.',
      corporateContext:
          'Quarter-end re-orgs, executive panic, shifted targets.',
    ),
    DailyRule(
      id: 3,
      title: 'THE IMPASSIVE ROCK',
      aphorism: 'Be like the promontory against which the waves continually break, but it stands firm and tames the fury of the water around it.',
      source: 'Marcus Aurelius • Meditations 4.49',
      tacticalAction: 'Maintain a flat, low-pitch vocal register. High pitch communicates distress; low monotone communicates supreme composure and leverage.',
      corporateContext: 'Confrontational 1-on-1s, aggressive negotiation.',
    ),
    DailyRule(
      id: 4,
      title: 'PREMEDITATION OF HOSTILITY',
      aphorism: 'When you wake up in the morning, tell yourself: The people I deal with today will be meddling, ungrateful, arrogant, dishonest, jealous, and surly.',
      source: 'Marcus Aurelius • Meditations 2.1',
      tacticalAction: 'Expect three illogical demands before 1 PM. Because you foresaw them, they will not rupture your nervous system.',
      corporateContext:
          'Cross-functional alignment meetings, client emergencies.',
    ),
    DailyRule(
      id: 5,
      title: 'UNCOUPLING IDENTITY FROM CORP',
      aphorism: 'He who clings to corporate laurels suffers a double death when they wither. Your soul is not leased to an employer.',
      source: 'Seneca • Letters to Lucilius 71',
      tacticalAction: 'Remind yourself: You are a sovereign operator providing skilled advisory, not a child seeking parental approval from an executive.',
      corporateContext:
          'Performance reviews, delayed promotions, political snubbing.',
    ),
    DailyRule(
      id: 6,
      title: 'THE REFUSAL TO BE INJURED',
      aphorism: 'Choose not to be harmed—and you won\'t feel harmed. Don\'t feel harmed—and you haven\'t been.',
      source: 'Marcus Aurelius • Meditations 4.7',
      tacticalAction: 'Do not interpret critical emails as attacks on your competence. Read them purely as data on the sender\'s anxiety level.',
      corporateContext: 'Passive-aggressive emails, public CC storms.',
    ),
    DailyRule(
      id: 7,
      title: 'THE VIEW FROM ORBIT',
      aphorism: 'Think of the whole universe of matter and how tiny your share of it; of the whole extent of time and how brief your allotted span.',
      source: 'Marcus Aurelius • Meditations 5.24',
      tacticalAction: 'Ask: "Will this missed milestone or delayed slide deck matter in 36 months?" If not, do not give it 36 seconds of adrenaline.',
      corporateContext: 'Urgent sprint fires, delayed product launches.',
    ),
    DailyRule(
      id: 8,
      title: 'STHITAPRAJNA (THE STEADY INTELLECT)',
      aphorism: 'One whose mind is untroubled by sorrow, who has no longing for pleasure, and is free from passion, fear, and anger—such a sage is called of steady intellect.',
      source: 'Bhagavad Gita • 2.56',
      tacticalAction: 'When praised, do not swell; when scapegoated, do not shrink. Ground your reality in the empirical log of your code and contracts.',
      corporateContext: 'Social pressure, public praise or blame games.',
    ),
    DailyRule(
      id: 9,
      title: 'RADICAL BOUNDARY HYGIENE',
      aphorism: 'No person has the power to have everything they want, but it is in their power not to want what they haven\'t got, and cheerfully put to good use what they have.',
      source: 'Seneca • Moral Essays',
      tacticalAction: 'Close your communication channels at your contractual cutoff. An unanswered ping does not kill anyone; chronic availability kills your poise.',
      corporateContext: 'Late evening Slack messages, weekend urgent requests.',
    ),
    DailyRule(
      id: 10,
      title: 'TRANSMUTING OBSTACLES',
      aphorism: 'The impediment to action advances action. What stands in the way becomes the way.',
      source: 'Marcus Aurelius • Meditations 5.20',
      tacticalAction: 'Treat a toxic manager not as a roadblock, but as a sparring partner strengthening your boundary-setting and legal documentation muscles.',
      corporateContext: 'Micromanagement, shifting requirements.',
    ),
    DailyRule(
      id: 11,
      title: 'OFFER CHOICES TO EXPOSE CHARACTER',
      aphorism: 'To reveal true intent, offer choices—preferences expose character.',
      source: 'Executive Rule of Engagement 1',
      tacticalAction: 'When met with ambiguous intent or manipulative hints, give binary operational options with explicit trade-offs. Their choice commits their real motive in writing.',
      corporateContext: 'Unclear executive mandates, scope games, political maneuvering.',
    ),
    DailyRule(
      id: 12,
      title: 'THE VICTIM CARD SHIELD',
      aphorism: 'Never argue with someone playing the victim card—stick strictly to facts and formal closure.',
      source: 'Executive Rule of Engagement 2',
      tacticalAction: 'Refuse to enter emotional theater or offer apologetic reassurance. State documented deliverables, timeline delta, and close the discussion factually.',
      corporateContext: 'Martyrdom tactics, guilt-tripping peers, accusatory escalations.',
    ),
    DailyRule(
      id: 13,
      title: 'STRATEGIC SILENCE ON ABSTRACT CRITIQUE',
      aphorism: 'Demand objective specifics on abstract criticism, then embrace strategic silence.',
      source: 'Executive Rule of Engagement 3',
      tacticalAction: 'Ask: "What objective metrics or criteria are you measuring that against?" Then maintain unbroken eye contact in complete silence. Let them struggle to substantiate the bluster.',
      corporateContext: 'Subjective reviews, vague disapproval, posturing superiors.',
    ),
  ];

  /// Returns today's designated rule based on day-of-year index
  static DailyRule getTodayRule([int? customIndex]) {
    if (customIndex != null && customIndex >= 0 && customIndex < rules.length) {
      return rules[customIndex];
    }
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return rules[dayOfYear % rules.length];
  }

  /// Cycles to the next rule for on-demand reflection
  static DailyRule getNextRule(int currentIndex) {
    return rules[(currentIndex + 1) % rules.length];
  }
}
