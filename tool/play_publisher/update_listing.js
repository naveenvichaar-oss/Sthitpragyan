const { google } = require('googleapis');
const path = require('path');
const fs = require('fs');

async function updateStoreListings() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';

  console.log(`===============================================`);
  console.log(`📝 Updating Google Play Store Listings via API`);
  console.log(`📦 Package: ${packageName}`);
  console.log(`===============================================`);

  const auth = new google.auth.GoogleAuth({
    keyFile: keyFilePath,
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });

  const client = await auth.getClient();
  const play = google.androidpublisher({
    version: 'v3',
    auth: client,
  });

  const edit = await play.edits.insert({ packageName });
  const editId = edit.data.id;
  console.log(`Created edit ID: ${editId}`);

  // 1. English (en-US) Listing
  const enListing = {
    language: 'en-US',
    title: 'Sthitaprajna - Mindful Living',
    shortDescription: 'Master equanimity with Bhagavad Gita wisdom, somatic calm & mental models.',
    fullDescription: `Cultivate unwavering equanimity, emotional resilience, and intentional action with Sthitaprajna (स्थितप्रज्ञ) — an offline-first mental fortitude and mindfulness sanctuary rooted in timeless Bhagavad Gita philosophy and modern cognitive science.

Derived from Chapter 2 of the Bhagavad Gita, a "Sthitaprajna" is one whose wisdom is firmly established, unperturbed in adversity and untempted in pleasure. Whether facing workplace stress, hostile communication, emotional turbulence, or decision fatigue, Sthitaprajna gives you actionable tools to pause, reflect, and act with clear discernment.

KEY FEATURES:

🧘 Somatic 3-Second Neural Brake
Interrupt high-stress emotional cascades before reacting. A sensory grounding protocol designed to calm physical tension, relax your jaw, and re-anchor your awareness within 3 seconds.

🛡️ Tactical Defensive Scripts
Overcome high-conflict scenarios, workplace micro-dominance, gaslighting, interruption, and passive aggression. Access verbatim, non-reactive responses that preserve your dignity and establish firm boundaries without emotional expenditure.

📖 Bhagavad Gita Wisdom Vault
Immerse yourself in authentic shlokas from the Gita, rendered with pristine transliteration, contextual executive summaries, and practical applications for modern professional and personal life.

🧠 Mental Models & Fallacy Vault
Sharpen your critical thinking with over 50 cognitive biases, formal fallacies, and decision frameworks. Learn to identify manipulated arguments, ad hominems, and false dilemmas in real time.

📝 Private Offline Journal & Character Ledger
Record daily reflections, track virtues, and document composure drills with complete privacy. Your data never touches any remote server — all reflections, voice memos, and notes remain encrypted strictly on your physical device.

🌿 Box-Breathing & Tathata Awareness
Engage in structured 4-4-4-4 tactical breathing drills and radical acceptance practices to dissolve acute anxiety and reclaim grounded executive presence.

100% PRIVATE & AD-FREE:
• No user login or cloud registration required
• Zero data tracking or analytics
• Completely ad-free and distraction-free

Reclaim your mind. Master your composure. Live with the steady wisdom of a Sthitaprajna.`
  };

  console.log(`[1/2] Updating English (en-US) listing...`);
  await play.edits.listings.update({
    editId,
    packageName,
    language: 'en-US',
    requestBody: {
      title: enListing.title,
      shortDescription: enListing.shortDescription,
      fullDescription: enListing.fullDescription,
    },
  });
  console.log(`  -> English listing updated!`);

  // 2. Hindi (hi-IN) Listing
  const hiListing = {
    language: 'hi-IN',
    title: 'स्थितप्रज्ञ - गीता व आत्मसंयम',
    shortDescription: 'भगवद्गीता के श्लोक, 3-सेकंड ठहराव, कार्य नियम व ऑफ़लाइन आत्म-नियंत्रण टूल।',
    fullDescription: `भगवद्गीता के कालातीत दर्शन और आधुनिक संज्ञानात्मक विज्ञान पर आधारित 'स्थितप्रज्ञ' (Sthitaprajna) एक 100% ऑफ़लाइन मानसिक शांति, आत्म-संयम और भावनात्मक दृढ़ता का ऐप है।

श्रीमद्भगवद्गीता के द्वितीय अध्याय में भगवान श्रीकृष्ण स्थितप्रज्ञ के लक्षण बताते हैं—जो दुखों में विचलित नहीं होता, सुखों की लालसा से मुक्त है, और जिसके भीतर से राग, भय तथा क्रोध समाप्त हो चुके हैं। कठिन परिस्थितियों, तनावपूर्ण कार्यक्षेत्र या व्यक्तिगत उथल-पुथल में यह ऐप आपको शांत, संतुलित और विवेकपूर्ण निर्णय लेने की शक्ति देता है।

मुख्य विशेषताएँ:

🧘 3-सेकंड सोमैटिक ठहराव (Neural Brake)
क्रोध या उत्तेजना की स्थिति में तुरंत प्रतिक्रिया देने से बचें। शारीरिक तनाव को ढीला करने और मन को स्थिर करने के लिए 3 सेकंड का वैज्ञानिक व शांत न्यूरल ब्रेक।

🛡️ कार्य नियम व रणनीतिक उत्तर (Defensive Scripts)
कटु व्यवहार, व्यंग्य, टोकना, गैसलाइटिंग या अनुचित दबाव के समय अपनी गरिमा बनाए रखने के लिए सटीक, तटस्थ और पेशेवर उत्तर। बिना आवेश में आए अपनी सीमा तय करें।

📖 गीता श्लोक व ज्ञान संचय (Wisdom Vault)
भगवद्गीता के व्यावहारिक श्लोक, उनके सरल हिंदी भावार्थ और दैनिक जीवन में उनके सटीक अनुप्रयोग। हर श्लोक को ऑडियो (TTS) के माध्यम से सुनें।

🧠 बौद्धिक मॉडल व भ्रम निवारण (Cognition Vault)
50+ तार्किक विसंगतियों (Fallacies) और मेंटल मॉडल्स का संग्रह। भ्रामक तर्कों, भावनात्मक दबाव और गलत धारणाओं को पहचानना सीखें।

📝 100% निजी ऑफ़लाइन जर्नल व चरित्र लेजर
अपने दैनिक आत्म-चिंतन, संकल्प और सुधार को पूरी तरह सुरक्षित रखें। आपका कोई भी डेटा किसी सर्वर पर नहीं भेजा जाता—सब कुछ आपके फ़ोन में ही सुरक्षित रहता है।

🌿 बॉक्स ब्रीदिंग व तथता (Tathata) ध्यान
4-4-4-4 लयबद्ध प्राणायाम अभ्यास और 'तथता' (यथास्थिति स्वीकार) के माध्यम से तात्कालिक चिंता को शांत करें और आंतरिक स्थिरता प्राप्त करें।

पूर्णतः सुरक्षित व विज्ञापन-मुक्त:
• किसी लॉगिन या ईमेल की आवश्यकता नहीं
• शून्य डेटा ट्रैकिंग
• कोई विज्ञापन नहीं

अपनी चेतना पर नियंत्रण पाएँ और जीवन में एक सच्चे स्थितप्रज्ञ की भाँति अडिग रहें।`
  };

  console.log(`[2/2] Updating Hindi (hi-IN) listing...`);
  try {
    await play.edits.listings.update({
      editId,
      packageName,
      language: 'hi-IN',
      requestBody: {
        title: hiListing.title,
        shortDescription: hiListing.shortDescription,
        fullDescription: hiListing.fullDescription,
      },
    });
    console.log(`  -> Hindi listing updated!`);
  } catch (err) {
    console.log(`  (Note on Hindi listing: ${err.message})`);
  }

  console.log(`Committing edits to Google Play...`);
  await play.edits.commit({ editId, packageName });
  console.log(`🎉 SUCCESS! Google Play Store Listings successfully committed!`);
}

updateStoreListings().catch((err) => {
  console.error(`❌ Error updating listings:`, err.message);
  if (err.response && err.response.data) {
    console.error(JSON.stringify(err.response.data, null, 2));
  }
});

