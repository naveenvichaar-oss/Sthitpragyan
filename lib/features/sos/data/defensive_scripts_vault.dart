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
  final String? hostileTriggerEn;
  final String? executiveScriptEn;
  final String? tacticalRationaleEn;
  final String? toneGuidanceEn;

  const DefensiveScript({
    required this.id,
    required this.category,
    required this.scenario,
    required this.hostileTrigger,
    required this.executiveScript,
    required this.tacticalRationale,
    required this.toneGuidance,
    this.isCustom = false,
    this.hostileTriggerEn,
    this.executiveScriptEn,
    this.tacticalRationaleEn,
    this.toneGuidanceEn,
  });

  String getLocalizedHostileTrigger(bool isHindi) {
    if (!isHindi && hostileTriggerEn != null && hostileTriggerEn!.isNotEmpty) {
      return hostileTriggerEn!;
    }
    return hostileTrigger;
  }

  String getLocalizedExecutiveScript(bool isHindi) {
    if (!isHindi && executiveScriptEn != null && executiveScriptEn!.isNotEmpty) {
      return executiveScriptEn!;
    }
    return executiveScript;
  }

  String getLocalizedTacticalRationale(bool isHindi) {
    if (!isHindi && tacticalRationaleEn != null && tacticalRationaleEn!.isNotEmpty) {
      return tacticalRationaleEn!;
    }
    return tacticalRationale;
  }

  String getLocalizedToneGuidance(bool isHindi) {
    if (!isHindi && toneGuidanceEn != null && toneGuidanceEn!.isNotEmpty) {
      return toneGuidanceEn!;
    }
    return toneGuidance;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'scenario': scenario,
    'hostileTrigger': hostileTrigger,
    'executiveScript': executiveScript,
    'tacticalRationale': tacticalRationale,
    'toneGuidance': toneGuidance,
    'isCustom': isCustom,
    if (hostileTriggerEn != null) 'hostileTriggerEn': hostileTriggerEn,
    if (executiveScriptEn != null) 'executiveScriptEn': executiveScriptEn,
    if (tacticalRationaleEn != null) 'tacticalRationaleEn': tacticalRationaleEn,
    if (toneGuidanceEn != null) 'toneGuidanceEn': toneGuidanceEn,
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
      hostileTriggerEn: map['hostileTriggerEn'] as String?,
      executiveScriptEn: map['executiveScriptEn'] as String?,
      tacticalRationaleEn: map['tacticalRationaleEn'] as String?,
      toneGuidanceEn: map['toneGuidanceEn'] as String?,
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
    String? hostileTriggerEn,
    String? executiveScriptEn,
    String? tacticalRationaleEn,
    String? toneGuidanceEn,
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
      hostileTriggerEn: hostileTriggerEn ?? this.hostileTriggerEn,
      executiveScriptEn: executiveScriptEn ?? this.executiveScriptEn,
      tacticalRationaleEn: tacticalRationaleEn ?? this.tacticalRationaleEn,
      toneGuidanceEn: toneGuidanceEn ?? this.toneGuidanceEn,
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
      hostileTrigger: 'इस काम में कोई दम नहीं है / काम का तरीका ठीक नहीं है / बात समझ नहीं आ रही',
      executiveScript: 'भाषा या प्रस्तुति में क्या विशिष्ट तथ्यात्मक बदलाव चाहिए? कृपया बिंदु स्पष्ट करें।',
      tacticalRationale: 'कभी सफाई न दें। गेंद उनके पाले में डालें।',
      toneGuidance: 'तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।',
      hostileTriggerEn: 'Your approach makes no sense / There is no substance in this work / The angle is off.',
      executiveScriptEn: 'What specific factual modifications do you require in the framing? Please clarify the points.',
      tacticalRationaleEn: 'Never make excuses. Place the burden of proof back on them.',
      toneGuidanceEn: 'Neutral, flat, without agitation or defensive explanations.',
    ),

    // -------------------------------------------------------------
    // Core Category B: Intimidation / Micro-Dominance
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'spec_cat_b',
      category: 'Intimidation',
      scenario: 'आवाज ऊंची करना, धौंस जमाना या माइक्रो-डोमिनेंस दिखाना।',
      hostileTrigger: 'तुम्हें समझ नहीं आ रहा मैं क्या कह रहा हूँ / अपना रवैया सुधारो',
      executiveScript: 'नोट कर लिया है। इसे रिव्यू करके अपडेट करता हूँ।',
      tacticalRationale: 'सपाट टोन, शून्य मुस्कान, 3 सेकंड आई-कांटेक्ट।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
      hostileTriggerEn: 'You don\'t understand what I am saying / "You need to fix your attitude"',
      executiveScriptEn: 'Noted. I will review this and follow up with an update.',
      tacticalRationaleEn: 'Flat tone, zero smile, 3 seconds direct eye contact.',
      toneGuidanceEn: 'Measured cadence, lower vocal register, direct eye contact.',
    ),

    // -------------------------------------------------------------
    // Core Category C: Impossible Deadlines / Exploitative Allocation
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'spec_cat_c',
      category: 'Impossible Deadlines',
      scenario: 'असंभव डेडलाइन या अचानक नया काम थोपना।',
      hostileTrigger: 'यह काम आज रात तक ही चाहिए / चाहे कुछ भी हो, मुझे यह अभी चाहिए',
      executiveScript: 'प्राथमिकता तय कर दीजिए। मौजूदा 2 मुख्य टास्क में से किसे होल्ड पर डालना है?',
      tacticalRationale: 'काम से मना नहीं किया, तार्किक सीमा खींच दी।',
      toneGuidance: 'पेशेवर, तार्किक, स्पष्ट सीमा रेखा।',
      hostileTriggerEn: 'I need this done tonight / "I need this done right now regardless"',
      executiveScriptEn: 'Please help prioritize. Which of our current 2 primary deliverables should be placed on hold?',
      tacticalRationaleEn: 'Do not refuse the work; enforce realistic boundaries and trade-offs.',
      toneGuidanceEn: 'Professional, analytical, clear boundary.',
    ),

    // -------------------------------------------------------------
    // Category: Interruption & Over-talking
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'int_01',
      category: 'Interruption',
      scenario: 'कोई आपको बोलने नहीं दे रहा या बार-बार बीच में टोक रहा है।',
      hostileTrigger: '"रुकिए, मुझे आपको यहीं टोकने दीजिए—आपने शायद इस पर सोचा नहीं है..."',
      executiveScript: 'मुझे डेटा और मुख्य बिंदु पूरा करने के लिए 60 सेकंड दीजिए, उसके बाद हम आपके सुझावों पर चर्चा करेंगे।',
      tacticalRationale: 'बिना आवाज उठाए बातचीत पर अपना अधिकार बनाए रखता है। समय की एक स्पष्ट सीमा तय करता है।',
      toneGuidance: 'मापा हुआ, शांत, गंभीर और धीमा स्वर।',
      hostileTriggerEn: '"Hold on, let me stop you right there—you clearly haven\'t thought about..."',
      executiveScriptEn: 'Allow me 60 seconds to finish the quantitative data point, and then we will open the floor directly for your counter-proposals.',
      tacticalRationaleEn: 'Maintains conversational authority without matching vocal aggression. Establishes a concrete time boundary.',
      toneGuidanceEn: 'Measured, unhurried, lower vocal register.',
    ),

    // -------------------------------------------------------------
    // Category: Blame Shifting & Scapegoating
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'blm_01',
      category: 'Blame Shifting',
      scenario: 'काम में देरी का ठीकरा आपकी टीम पर फोड़ने की कोशिश।',
      hostileTrigger: '"पूरी डिलीवरी अटक गई है क्योंकि आपकी टीम ने समय पर काम नहीं किया।"',
      executiveScript: 'आइए व्यक्तिगत राय के बजाय सिस्टम और समय-सीमा पर बात करें। आपके इनपुट की पेंडेंसी 18 दिन पहले दर्ज की गई थी। आइए रिकॉर्ड्स को साथ मिलकर देख लेते हैं।',
      tacticalRationale: 'भावनाओं को तथ्यों से अलग करता है। समय-वार प्रमाण रखकर झूठे दोषारोपण को तुरंत खत्म करता है।',
      toneGuidance: 'तटस्थ, विश्लेषणात्मक, जैसे किसी मशीन के पुर्जे की जांच कर रहे हों।',
      hostileTriggerEn: '"The entire rollout is stuck because your team didn\'t move fast enough."',
      executiveScriptEn: 'Let\'s separate system dependencies from execution. The dependency on your API specs was logged 18 days ago. Let\'s review the timeline audit together.',
      tacticalRationaleEn: 'Separates emotion from sequence. Introduces chronological evidence that eliminates subjective blame.',
      toneGuidanceEn: 'Objective, analytical, as if dissecting a machine part.',
    ),
    DefensiveScript(
      id: 'blm_02',
      category: 'Blame Shifting',
      scenario: 'पब्लिक ग्रुप या मीटिंग में अचानक गलती कबूलने का दबाव।',
      hostileTrigger: '"यह तैयार नहीं था तो लाइव क्यों किया? किसकी गलती है यह?"',
      executiveScript: 'हम अभी इसकी मूल वजह की जांच कर रहे हैं। बिना तथ्यों के अनुमान लगाने के बजाय मैं शाम 4 बजे तक सुधारात्मक कदमों के साथ पूरी तथ्यात्मक रिपोर्ट साझा करूंगा।',
      tacticalRationale: 'सार्वजनिक तमाशे को रोकता है और सत्यापित तथ्यों के आधार पर बात करने का समय सुरक्षित करता है।',
      toneGuidance: 'गंभीर, जिम्मेदार और समाधान पर केंद्रित।',
      hostileTriggerEn: '"Why was this pushed if it wasn\'t ready? Whose fault is this?"',
      executiveScriptEn: 'We are conducting a root cause post-mortem right now. I will publish the factual incident report with remediations by 4 PM rather than speculate.',
      tacticalRationaleEn: 'Puts a stop to public kangaroo courts and buys time for verified facts.',
      toneGuidanceEn: 'Sober, responsible, forward-looking.',
    ),

    // -------------------------------------------------------------
    // Category: Passive Aggression & Sarcasm
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'pas_01',
      category: 'Passive Aggression',
      scenario: 'काम के घंटों या आपकी सीमाओं पर सहकर्मी का कटाक्ष।',
      hostileTrigger: '"मजे हैं तुम्हारे, ठीक 5 बजे निकल जाते हो, बाकी लोग यहाँ मर रहे हैं।"',
      executiveScript: 'मेरे कार्य-लक्ष्य और समय-सीमा नेतृत्व के साथ स्पष्ट हैं। यदि कोई ऐसा काम है जिसमें प्राथमिकता तय करने में सहायता चाहिए, तो उसे ईमेल पर साझा कर लें।',
      tacticalRationale: 'अपराध-बोध कराने की चाल को पेशेवर स्पष्टता की मांग करके विफल करता है।',
      toneGuidance: 'विनम्र, अविचलित, पूरी तरह पेशेवर।',
      hostileTriggerEn: '"Must be nice to clock out right at 5 while the rest of us work hard."',
      executiveScriptEn: 'My working agreements and milestones are calibrated with leadership. If there\'s an unassigned deliverable you need help prioritizing, let\'s document it.',
      tacticalRationaleEn: 'Exposes covert guilt-tripping by demanding professional specificity.',
      toneGuidanceEn: 'Polite, unruffled, professional.',
    ),

    // -------------------------------------------------------------
    // Category: Scope Creep & Manufactured Urgency
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'urg_01',
      category: 'Scope Creep',
      scenario: 'शाम को या वीकेंड पर अचानक काम थोपना।',
      hostileTrigger: '"यह बहुत अर्जेंट है। मुझे यह पूरा काम कल सुबह तक तैयार चाहिए।"',
      executiveScript: 'इस स्तर के कार्य के लिए कम से कम 6 कार्य-घंटे आवश्यक हैं। हम आज रात तक एक संक्षिप्त रूपरेखा दे सकते हैं, या सोमवार सुबह 10 बजे तक पूरा तैयार दस्तावेज़। आप किस विकल्प को चुनना चाहेंगे?',
      tacticalRationale: 'दो स्पष्ट विकल्प प्रस्तुत करता है और काम की गुणवत्ता के समझौते का दायित्व अनुरोधकर्ता पर डाल देता है।',
      toneGuidance: 'दृढ़, निर्णायक, परामर्शी।',
      hostileTriggerEn: '"This is urgent. I need this whole deck rewritten by tomorrow morning."',
      executiveScriptEn: 'High quality execution on this scope requires 6 business hours. We can deliver a high-level outline tonight, or a fully vetted deck on Monday at 10 AM. Which trade-off do you choose?',
      tacticalRationaleEn: 'Offers two clear alternatives while forcing the requester to own the quality trade-off.',
      toneGuidanceEn: 'Firm, decisive, consultative.',
    ),

    // -------------------------------------------------------------
    // Category: PublicTransit — सड़क व सार्वजनिक स्थल
    // Road rage, bus/metro crowding, uncivil strangers
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'transit_01',
      category: 'PublicTransit',
      scenario: 'सड़क पर अचानक गाली या धमकी — ट्रैफिक, पार्किंग विवाद, या भीड़ में टकराव।',
      hostileTrigger: '"अंधे हो क्या? / गाड़ी चलाना आता है कि नहीं?" / आक्रामक हॉर्न और चीख-पुकार।',
      executiveScript: 'शून्य प्रतिक्रिया। खिड़की बंद। नज़र आगे। आंतरिक वाक्य: "इसका गुस्सा इसकी समस्या है, मेरी नहीं।"',
      tacticalRationale: 'सड़क पर किसी अजनबी से वाद-विवाद में कोई जीत नहीं होती — केवल जोखिम बढ़ता है।',
      toneGuidance: 'शून्य आई-कॉन्टैक्ट, शून्य जवाब, शांत गति बनाए रखें।',
      hostileTriggerEn: '"Are you blind? / Don\'t you know how to drive?" / Aggressive honking and road rage.',
      executiveScriptEn: 'Zero verbal reaction. Roll up window. Look straight ahead. Internal anchor: "Their anger is their affliction, not mine."',
      tacticalRationaleEn: 'Arguing with a stranger on the road yields zero wins — only compounding risk.',
      toneGuidanceEn: 'Zero eye contact, zero verbal response, maintain calm steady motion.',
    ),
    DefensiveScript(
      id: 'transit_02',
      category: 'PublicTransit',
      scenario: 'बस/मेट्रो में अजनबी की असभ्य टिप्पणी या जानबूझकर धक्का।',
      hostileTrigger: '"ज़्यादा जगह ले रहे हो / हट जाओ / बूढ़ों को बैठने दो"',
      executiveScript: 'हल्का सिर हिलाना। बिना बोले एक कदम हटना। "मैं इसके स्तर पर नहीं उतरूंगा।"',
      tacticalRationale: 'भीड़ में तर्क करना हमेशा दर्शकों के सामने आपकी गरिमा घटाता है।',
      toneGuidance: 'तटस्थ, शून्य भाव, सपाट चेहरा।',
      hostileTriggerEn: '"You are taking too much space / Move out of the way / Let elders sit"',
      executiveScriptEn: 'Brief nod. Step aside silently without a word. "I will not sink to this level."',
      tacticalRationaleEn: 'Engaging in crowd disputes always erodes your dignity before onlookers.',
      toneGuidanceEn: 'Neutral, unexpressive, calm posture.',
    ),
    DefensiveScript(
      id: 'transit_03',
      category: 'PublicTransit',
      scenario: 'ऑटो या कैब चालक का मीटर से चलने से मना करना या आक्रामक होकर अनुचित किराया मांगना।',
      hostileTrigger: '"मीटर से नहीं जाएंगे। 500 रुपये लगेंगे, चलना है तो चलो वर्ना उतरो।" / आक्रामक रवैया।',
      executiveScript: 'उचित किराया शांति से एक बार स्पष्ट बोलें। यदि न माने: बिना किसी बहस के चुपचाप उतरें और दूसरा साधन लें। शून्य वाद-विवाद।',
      tacticalRationale: 'आप अपने कदमों के स्वामी हैं। मुड़कर चले जाना और बहस में न उलझना ही आपकी सबसे बड़ी शक्ति है।',
      toneGuidance: 'सपाट, तथ्यात्मक, शून्य भावनात्मक निवेश।',
      hostileTriggerEn: '"No meter. Pay 500 or get out." / Threatening body language.',
      executiveScriptEn: 'State the fair fare once, calmly. If refused: exit silently, book alternative. No argument.',
      tacticalRationaleEn: 'You control your feet. Walk away. The refusal to engage is your power.',
      toneGuidanceEn: 'Flat, factual, zero emotional investment.',
    ),

    // -------------------------------------------------------------
    // Category: Provocation — उकसावा व तंज
    // Deliberate baiting, sarcasm, taunts from any source
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'prov_01',
      category: 'Provocation',
      scenario: 'अमूर्त आरोप, अस्पष्ट आलोचना या गलत दोषारोपण।',
      hostileTrigger: '"इस काम में कोई दम नहीं है / तुमसे तो उम्मीद ही नहीं थी / तुम हमेशा सब बिगाड़ देते हो।"',
      executiveScript: 'क्या विशिष्ट तथ्यात्मक बिंदु में बदलाव चाहिए? कृपया स्पष्ट करें।',
      tacticalRationale: 'कभी सफाई न दें। गेंद उनके पाले में डालें। अस्पष्ट आलोचना को विशिष्ट बनाने से वो बेनकाब होते हैं।',
      toneGuidance: 'तटस्थ, सपाट, बिना किसी घबराहट या सफाई के।',
      hostileTriggerEn: '"There is no substance here / We expected better from you / You always mess things up."',
      executiveScriptEn: 'Which specific factual item requires revision? Please clarify.',
      tacticalRationaleEn: 'Never make excuses. Pass the ball to their court. Forcing specificity disarms vague critics.',
      toneGuidanceEn: 'Neutral, calm, unruffled, zero defensive energy.',
    ),
    DefensiveScript(
      id: 'prov_02',
      category: 'Provocation',
      scenario: 'कोई जानबूझकर सार्वजनिक रूप से नीचा दिखाने की कोशिश कर रहा है।',
      hostileTrigger: '"तुम्हें तो कुछ समझ ही नहीं आता / तुम्हारी समझ में कभी नहीं आएगा।"',
      executiveScript: '"नोट कर लिया है।" — बस। कोई विस्तार नहीं, कोई सफाई नहीं।',
      tacticalRationale: 'संक्षिप्त, सपाट उत्तर उत्तेजक को शक्तिहीन बनाता है। लंबा जवाब = उनकी जीत।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
      hostileTriggerEn: '"You don\'t get it, do you? / You never understand."',
      executiveScriptEn: '"Noted." — That is all. No explanation, no elaboration.',
      tacticalRationaleEn: 'A short, flat acknowledgement starves the provoker. Elaborate replies hand them victory.',
      toneGuidanceEn: 'Slow pace, deep voice, steady direct eye contact.',
    ),
    DefensiveScript(
      id: 'prov_03',
      category: 'Provocation',
      scenario: 'आपको उकसाने के लिए मारा गया अप्रत्यक्ष ताना या व्यंग्य।',
      hostileTrigger: '"अरे वाह! आज तो बड़े आराम की ज़िंदगी लग रही है / आज तो आप दर्शन दे ही दिए।"',
      executiveScript: 'संक्षिप्त, शून्य-भाव पावती: "हम्म।" इसके बाद बिना किसी प्रतिक्रिया के तुरंत अपने मुख्य कार्य पर लौट जाएँ।',
      tacticalRationale: 'व्यंग्य आपकी प्रतिक्रिया से ऊर्जा पाता है। सपाट मौन इसे तुरंत भूखा मारकर शांत कर देता है।',
      toneGuidance: 'शिष्ट, अविचलित, शून्य रक्षात्मकता।',
      hostileTriggerEn: '"Must be nice to have such a relaxed life / Oh wow, you actually showed up today."',
      executiveScriptEn: 'Brief, zero-emotion acknowledgment: "Hmm." Then redirect to the task at hand.',
      tacticalRationaleEn: 'Sarcasm feeds on reaction. A flat response starves it.',
      toneGuidanceEn: 'Polite, unruffled, zero defensive energy.',
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
      hostileTriggerEn: '"You never listen to us! / Children shouldn\'t be like this / Look at all we sacrificed for you!"',
      executiveScriptEn: '"I hear what you are saying. Please give me some time to think." — then exit the room.',
      tacticalRationaleEn: 'Engaging in emotional escalation = defeat. "Time to think" = a firm, peaceful boundary.',
      toneGuidanceEn: 'Respectful yet firm. Keep your vocal pitch low and steady.',
    ),
    DefensiveScript(
      id: 'fam_02',
      category: 'FamilyBoundary',
      scenario: 'बिन माँगी सलाह या जीवनशैली पर टिप्पणी।',
      hostileTrigger: '"शादी कब करोगे? / बच्चे कब? / नौकरी बदलो / ये कपड़े ठीक नहीं हैं"',
      executiveScript: '"शुक्रिया, ध्यान रखूंगा।" — फिर विषय बदलें। कोई बहस नहीं, कोई सफाई नहीं।',
      tacticalRationale: 'सलाह देने वाले को सफाई चाहिए, सहमति नहीं। "ध्यान रखूंगा" बंद कर देता है।',
      toneGuidance: 'सौम्य, हल्की मुस्कान, कोई कड़वाहट नहीं।',
      hostileTriggerEn: '"When will you get married? / When are kids coming? / Change your career / Those clothes aren\'t right."',
      executiveScriptEn: '"Thank you, I will keep that in mind." — then change the topic. No argument, no justification.',
      tacticalRationaleEn: 'Unsolicited advisors crave defensive explanations, not agreement. "I\'ll keep that in mind" closes the loop.',
      toneGuidanceEn: 'Gentle, slight smile, zero bitterness or defensiveness.',
    ),
    DefensiveScript(
      id: 'fam_03',
      category: 'FamilyBoundary',
      scenario: 'जीवनसाथी या परिवार में बहस का अनियंत्रित होना और पुरानी बातों को खींचना।',
      hostileTrigger: 'ऊंची आवाज, पिछली गलतियों का उलाहना, या अंतिम अल्टीमेटम।',
      executiveScript: '"मैं समझ रहा हूँ कि यह विषय महत्वपूर्ण है। जब हम दोनों शांत हों तब इस पर बात करते हैं—हम ठीक 30 मिनट बाद इस चर्चा को आगे बढ़ाएंगे।"',
      tacticalRationale: 'आक्रोश में की गई बातचीत रिश्तों को नष्ट करती है। 30 मिनट का ठहराव तंत्रिका तंत्र को रीसेट होने देता है।',
      toneGuidance: 'स्नेहपूर्ण किंतु दृढ़। सामने वाले की आवाज जितनी ऊंची हो, अपनी आवाज उतनी ही धीमी रखें।',
      hostileTriggerEn: 'Raised voice, bringing up past mistakes, or threatening ultimatums.',
      executiveScriptEn: '"I can see this is important. Let\'s discuss this when we\'re both calmer — I commit to resuming in 30 minutes."',
      tacticalRationaleEn: 'Flooded conversations destroy relationships. A 30-min pause allows the nervous system to reset.',
      toneGuidanceEn: 'Warm but firm. Lower your voice as theirs rises.',
    ),

    // -------------------------------------------------------------
    // Category: WorkplaceComposure — कार्यस्थल शांति
    // Corporate toxicity, boss confrontation, meeting ambushes
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'work_01',
      category: 'WorkplaceComposure',
      scenario: 'आवाज ऊंची करना, धौंस जमाना या माइक्रो-डोमिनेंस दिखाना।',
      hostileTrigger: '"तुम्हें समझ नहीं आ रहा मैं क्या कह रहा हूँ / अपना रवैया ठीक करो!"',
      executiveScript: 'नोट कर लिया है। इसे रिव्यू करके अपडेट करता हूँ।',
      tacticalRationale: 'सपाट टोन, शून्य मुस्कान, 3 सेकंड आई-कांटेक्ट।',
      toneGuidance: 'धीमी गति, गहरी आवाज, आँखों में सीधा संपर्क।',
      hostileTriggerEn: '"You don\'t understand what I am saying / Fix your attitude!"',
      executiveScriptEn: 'Noted. I will review this and follow up with an update.',
      tacticalRationaleEn: 'Flat tone, zero smile, 3 seconds direct eye contact.',
      toneGuidanceEn: 'Slow tempo, low voice, direct eye contact.',
    ),
    DefensiveScript(
      id: 'work_02',
      category: 'WorkplaceComposure',
      scenario: 'असंभव डेडलाइन या अचानक नया काम थोपना।',
      hostileTrigger: '"यह काम आज रात तक ही चाहिए / चाहे कुछ भी हो, मुझे यह अभी चाहिए।"',
      executiveScript: 'प्राथमिकता तय कर दीजिए। मौजूदा 2 मुख्य टास्क में से किसे होल्ड पर डालना है?',
      tacticalRationale: 'काम से मना नहीं किया, तार्किक सीमा खींच दी।',
      toneGuidance: 'पेशेवर, तार्किक, स्पष्ट सीमा रेखा।',
      hostileTriggerEn: '"This needs to be finished tonight / I need this right now regardless."',
      executiveScriptEn: 'Please help prioritize. Which of our current 2 active deliverables should be placed on hold?',
      tacticalRationaleEn: 'Did not refuse the task; asserted professional trade-offs.',
      toneGuidanceEn: 'Professional, analytical, clear boundary.',
    ),
    DefensiveScript(
      id: 'work_03',
      category: 'WorkplaceComposure',
      scenario: 'सहकर्मी या मैनेजर का पहले तय किए गए निर्णय को नकारना।',
      hostileTrigger: '"मैंने कभी इसे मंजूरी नहीं दी। आपने उद्देश्य को गलत समझा है।"',
      executiveScript: 'मैं हमारी 4 तारीख की बैठक के मिनट्स और साइन-ऑफ का संदर्भ दे रहा हूँ। आइए उस दस्तावेज़ को साथ में खोलकर देख लेते हैं।',
      tacticalRationale: 'लिखित साक्ष्य भावनात्मक भ्रम को दूर कर स्थिति को तथ्यों पर स्थिर करता है।',
      toneGuidance: 'तथ्यात्मक, सहयोगात्मक जिज्ञासा, बिना किसी कड़वाहट या बचाव के।',
      hostileTriggerEn: '"I never approved this. You misunderstood the objective."',
      executiveScriptEn: 'I am referencing the sign-off from our October 4th sync, section 3.2. Let\'s pull that document now.',
      tacticalRationaleEn: 'Deflect emotional doubt by grounding in written records.',
      toneGuidanceEn: 'Matter-of-fact, collaborative curiosity, zero defensiveness.',
    ),
    DefensiveScript(
      id: 'work_04',
      category: 'WorkplaceComposure',
      scenario: 'मीटिंग में अपनी नाकामी छुपाने के लिए आपकी टीम पर उंगली उठाना।',
      hostileTrigger: '"प्रोजेक्ट इसलिए रुका हुआ है क्योंकि आपकी टीम तेजी से काम नहीं कर रही।"',
      executiveScript: 'आइए निर्भरता और निष्पादन को अलग करके देखें। आपके इनपुट की आवश्यकता 18 दिन पहले लॉग की गई थी। आइए समय-रेखा की समीक्षा करें।',
      tacticalRationale: 'क्रमबद्ध कालानुक्रमिक प्रमाण प्रस्तुत करता है जो व्यक्तिपरक दोष को समाप्त करता है।',
      toneGuidance: 'वस्तुनिष्ठ, विश्लेषणात्मक, सपाट।',
      hostileTriggerEn: '"The rollout is stuck because your team didn\'t move fast enough."',
      executiveScriptEn: 'Let\'s separate dependencies from execution. The dependency on your API specs was logged 18 days ago. Let\'s review the timeline.',
      tacticalRationaleEn: 'Introduces chronological evidence that eliminates subjective blame.',
      toneGuidanceEn: 'Objective, analytical, as if dissecting a machine part.',
    ),

    // -------------------------------------------------------------
    // Category: Gaslighting — गैसलाइटिंग
    // Denial of reality, emotional label attacks
    // -------------------------------------------------------------
    DefensiveScript(
      id: 'gas_01',
      category: 'Gaslighting',
      scenario: 'कोई कह रहा है कि "तुम ज़रूरत से ज़्यादा सोच रहे हो / बहुत भावुक हो रहे हो।"',
      hostileTrigger: '"तुम बहुत भावुक हो रहे हो / इसे व्यक्तिगत रूप से क्यों ले रहे हो?"',
      executiveScript: 'मेरा स्वर तटस्थ है; मेरा फोकस तथ्यों पर है। चलिए मुद्दे पर लौटते हैं।',
      tacticalRationale: 'लेबलिंग को एक वाक्य में खारिज करें और चर्चा को तकनीकी मुद्दे पर लौटाएं।',
      toneGuidance: 'पूर्णत: सपाट स्वर। शून्य उतार-चढ़ाव।',
      hostileTriggerEn: '"You are too emotional / Why are you taking this so personally?"',
      executiveScriptEn: '"My tone is completely neutral; my focus is on verified facts. Let us return to the agenda."',
      tacticalRationaleEn: 'Dismiss emotional labels in a single sentence and re-anchor the dialogue on objective facts.',
      toneGuidanceEn: 'Completely flat cadence. Zero emotional fluctuation.',
    ),
    DefensiveScript(
      id: 'gas_02',
      category: 'Gaslighting',
      scenario: 'कही हुई बात या समझौते को पूरी तरह नकारना और आपको गलत ठहराना।',
      hostileTrigger: '"ऐसा कभी नहीं हुआ था। तुम मनगढ़ंत बातें बना रहे हो।"',
      executiveScript: 'मेरे पास इसके लिखित रिकॉर्ड्स मौजूद हैं। आइए उन्हें साथ मिलकर देख लेते हैं और पुष्टि कर लेते हैं।',
      tacticalRationale: 'लिखित प्रमाण गैसलाइटिंग का सबसे बड़ा काट है। केवल याददाश्त के सहारे कभी बहस न करें।',
      toneGuidance: 'शांत, तथ्यात्मक, बिना किसी उत्तेजना या आवेश के।',
      hostileTriggerEn: '"That never happened. You\'re making things up."',
      executiveScriptEn: '"I have the records. Let\'s pull them up and verify together."',
      tacticalRationaleEn: 'Written evidence is the antidote to gaslighting. Never argue from memory alone.',
      toneGuidanceEn: 'Calm, factual, zero emotional charge.',
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
      hostileTriggerEn: 'Internal voice: "Just skip today / I\'m too exhausted / I\'ll start fresh tomorrow."',
      executiveScriptEn: 'Just 5 minutes. Begin immediately. Set the timer. Decide only after 5 minutes.',
      tacticalRationaleEn: 'The 5-minute rule shatters initial cognitive resistance. Stopping after starting becomes difficult.',
      toneGuidanceEn: 'Internal — firm, resolute, zero self-pity.',
    ),
    DefensiveScript(
      id: 'self_02',
      category: 'SelfMastery',
      scenario: 'किसी असफलता के बाद मन में चलने वाला नकारात्मक चक्र।',
      hostileTrigger: 'आंतरिक आवाज़: "मुझसे नहीं होगा / मैं हमेशा विफल रहता हूँ / क्या फायदा प्रयास करने का?"',
      executiveScript: '"एक परिणाम पूरे जीवन की दिशा तय नहीं करता। इसमें विशिष्ट और सुधरने योग्य गलती क्या थी? केवल उस एक बिंदु को सुधारो।"',
      tacticalRationale: 'अमूर्त आत्म-संदेह को एक ठोस, कार्यवाई योग्य सुधार में बदलें।',
      toneGuidance: 'आंतरिक — निष्पक्ष, तटस्थ, जैसे कोई कोच खेल की समीक्षा कर रहा हो।',
      hostileTriggerEn: 'Internal voice: "I\'m not good enough / I always fail / What\'s the point?"',
      executiveScriptEn: '"One data point does not define a trend. What is the specific, correctable mistake? Fix that single variable."',
      tacticalRationaleEn: 'Convert abstract self-doubt into a specific, actionable correction.',
      toneGuidanceEn: 'Internal — clinical, detached, like a coach reviewing game tape.',
    ),
    DefensiveScript(
      id: 'self_03',
      category: 'SelfMastery',
      scenario: 'सोशल मीडिया या बाहरी तुलना से आत्म-संदेह।',
      hostileTrigger: '"सबके पास सब है, मेरे पास कुछ नहीं / उनकी ज़िंदगी कितनी अच्छी है"',
      executiveScript: '"तुलना = चोरी। दूसरे का हाइलाइट रील ≠ मेरी असलियत। मेरा मापदंड = कल का मैं।"',
      tacticalRationale: 'तुलना हमेशा अधूरी जानकारी पर होती है। एकमात्र वैध मापदंड = कल का स्वयं।',
      toneGuidance: 'आंतरिक — करुणामय किंतु तार्किक।',
      hostileTriggerEn: '"Everyone has everything, I have nothing / Look how great their lives are."',
      executiveScriptEn: '"Comparison is theft. Another\'s highlight reel is not my reality. My sole benchmark is who I was yesterday."',
      tacticalRationaleEn: 'Social comparison is always founded on partial illusions. The only valid metric is continuous self-evolution.',
      toneGuidanceEn: 'Internal — compassionate yet rigorously rational.',
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
      hostileTriggerEn: 'Hidden agendas, ambiguous demands, or manipulative framing.',
      executiveScriptEn: '"There are two distinct options: Option A optimizes for speed; Option B optimizes for reliability. Which is your priority?"',
      tacticalRationaleEn: 'Forcing a binary trade-off exposes hidden motives. Never guess — let their choice reveal their true intent.',
      toneGuidanceEn: 'Calm, measured, advisory.',
    ),
    DefensiveScript(
      id: 'roe_02',
      category: 'Rules of Engagement',
      scenario: 'रणनीतिक मौन: अस्पष्ट आलोचना पर विशिष्ट तथ्य माँगें, फिर चुप रहें।',
      hostileTrigger: '"यह ठीक नहीं लगा / आपकी टीम में प्रभाव और गंभीरता की कमी है"',
      executiveScript: '"किन विशिष्ट मापदंडों के आधार पर? [मौन — सीधा आई-कॉन्टैक्ट, मौन न तोड़ें]"',
      tacticalRationale: 'विशिष्ट तथ्य माँगकर मौन साधना आलोचक को या तो प्रमाणित करने पर मजबूर करता है या वापस हटने पर।',
      toneGuidance: 'धीमी, स्थिर लय, सीधा आई-कॉन्टैक्ट; मौन भरने की जल्दी शून्य।',
      hostileTriggerEn: '"This didn\'t feel right / Your team lacks executive presence."',
      executiveScriptEn: '"Against which specific measurable criteria? [Strategic silence — hold direct eye contact, do not break the pause]"',
      tacticalRationaleEn: 'Demanding concrete criteria followed by disciplined silence forces the critic to either substantiate or retreat.',
      toneGuidanceEn: 'Slow, unhurried cadence, direct eye contact; zero rush to fill the silence.',
    ),
    DefensiveScript(
      id: 'roe_03',
      category: 'Rules of Engagement',
      scenario: 'भावनाओं का ड्रामा रचकर नियमों से छूट चाहने वाला व्यक्ति।',
      hostileTrigger: '"मुझे कोई सपोर्ट नहीं करता / यह मेरे साथ बहुत अन्याय है! / तुम हमेशा मुझे ही टारगेट करते हो!"',
      executiveScript: '"आइए व्यक्तिगत भावनाओं के बजाय तय मानकों और लिखित लक्ष्यों पर ध्यान केंद्रित करें। सुधार का तथ्यात्मक मार्ग यह है।"',
      tacticalRationale: 'भावनात्मक पुष्टि ड्रामे को हवा देती है; वस्तुनिष्ठ स्पष्टता इसे तुरंत समाप्त कर देती है।',
      toneGuidance: 'तटस्थ, सपाट, अडिग। उनके भावनात्मक उफान से अपने स्वर को न बदलने दें।',
      hostileTriggerEn: '"No one supports me / This is so unfair! / You always target me!"',
      executiveScriptEn: '"Let\'s focus strictly on agreed milestones and documented criteria. Here is the factual remediation path."',
      tacticalRationaleEn: 'Emotional validation fuels drama cycles; factual clarity terminates them.',
      toneGuidanceEn: 'Neutral, flat, firm. Do not match emotional hysterics.',
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
