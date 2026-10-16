# SOS Screen: UI State-Flow & Logic Architecture

## 1. Overview
SOS स्क्रीन का प्राथमिक उद्देश्य किसी भी हाई-स्ट्रेस या टॉक्सिक उकसावे के क्षण में यूजर को तात्कालिक 'न्यूरो-ग्राउंडिंग' (Neuro-grounding) देना और बिना सोचे सही प्रतिक्रिया चुनने में मदद करना है। इसका लोड टाइम 50ms से कम होना चाहिए।

---

## 2. Finite State Machine (FSM) Workflow

```
[IDLE / HOME]
      |
      | (Tap Floating "SOS Shield" Button)
      v
[STATE 1: TACTILE GROUNDING] (Duration: 0.0s - 0.5s)
      | - Trigger Haptic Feedback (Heavy Impact: 150ms)
      | - Fullscreen Dimming Overlay (#090D16, 95% Opacity)
      | - Body Anchor Banner: "Tongue to roof of mouth | Feet on ground"
      v
[STATE 2: THE 3-SECOND MANDATORY LOCK] (Duration: 0.5s - 3.5s)
      | - Circular Expanding/Contracting Pulse Animation (Breathe in/out)
      | - Display: "Do not speak. Observing..."
      | - Countdown Timer: 3... 2... 1...
      | - All exit and interaction gestures are disabled during these 3 seconds.
      v
[STATE 3: DEFENSIVE SCRIPTS ACTIVE] (Duration: Indefinite)
      | - Subtle Haptic (Success / Double Click)
      | - Display Primary Response Cards (Swipeable Carousel)
      | - Quick Copy / Read Aloud Mode
      | - Exit Button (X) and "Incident Handled" Action
      v
[STATE 4: EXIT / LOG INCIDENT]
      | - Optional 1-tap quick log: "Logged to evening review"
      v
[RETURN TO HOME]
```

---

## 3. Detailed State Specifications

### State 1: Immediate Grounding (`STATE_GROUNDING`)
* **Trigger:** Floating SOS Action Button on Home Screen.
* **UI Behavior:**
  * Background transitions to pitch black/deep slate `#090D16`.
  * Top bar shows a high-contrast amber indicator: `● DEFENSIVE LOCK ENGAGED`.
  * Big bold typography in center:
    > **"दाँत ढीले रखें। जीभ तालू से सटाएं। पैर जमीन पर।"**
* **System Actions:**
  * Invoke `HapticFeedback.heavyImpact()`.
  * Silence non-critical background audio if running.

### State 2: Forced 3-Second Pause (`STATE_COUNTDOWN`)
* **Logic:** जब एड्रेनालिन बढ़ता है, इंसान तुरंत बोल पड़ता है। यह स्क्रीन यूजर को 3 सेकंड तक बोलने या कुछ भी दबाने से रोकती है।
* **UI Elements:**
  * Minimalist circular SVG progress indicator running from $0^{\circ}$ to $360^{\circ}$ over 3000ms.
  * Central large timer: `3` $\rightarrow$ `2` $\rightarrow$ `1`.
  * Micro-text below circle: *"सामने वाले की टोन और आंखों का विचलन केवल देखें।"*
* **Constraints:** Back gesture / Dismiss gesture `PopScope(canPop: false)` enabled.

### State 3: Shield Script Selector (`STATE_CAROUSEL`)
* **Logic:** 3 सेकंड पूरे होते ही कार्ड्स लोड होते हैं। यूजर 3 मुख्य श्रेणियों में से स्वाइप कर सकता है:
  1. **Category A: Unjust Accusation / Vague Editorial Critique**
     * *Script:* `"भाषा या एंगल में क्या विशिष्ट फैक्चुअल बदलाव चाहिए? कृपया बिंदु स्पष्ट करें।"`
     * *Subtext:* कभी सफाई न दें। गेंद उनके पाले में डालें।
  2. **Category B: Intimidation / Micro-Dominance**
     * *Script:* `"नोट कर लिया है। इसे रिव्यू करके अपडेट करता हूँ।"`
     * *Subtext:* सपाट टोन, शून्य मुस्कान, 3 सेकंड आई-कांटेक्ट।
  3. **Category C: Impossible Deadlines / Exploitative Allocation**
     * *Script:* `"प्राथमिकता तय कर दीजिए। मौजूदा 2 मुख्य टास्क में से किसे होल्ड पर डालना है?"`
     * *Subtext:* काम से मना नहीं किया, तार्किक सीमा खींच दी।

* **Action Buttons per Card:**
  * `[Copy Text]` $\rightarrow$ क्लिपबोर्ड में कॉपी करें (यदि स्लैक/व्हाट्सएप पर जवाब देना हो)।
  * `[Handled (Neutral)]` $\rightarrow$ स्क्रीन बंद करें और टाइमस्टैम्प सेव करें।
