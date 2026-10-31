const { google } = require('googleapis');
const path = require('path');
const fs = require('fs');

async function uploadHindiScreenshots() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';

  const screenshots = [
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_1.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_2.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_3.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_4.png',
  ];

  console.log('Uploading 4 high-res Hindi screenshots via Google Play API...');

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
  console.log(`Edit ID: ${editId}`);

  // Delete prior phoneScreenshots in hi-IN and upload all 4
  try {
    await play.edits.images.deleteall({ editId, packageName, language: 'hi-IN', imageType: 'phoneScreenshots' });
  } catch (e) {}

  for (let i = 0; i < screenshots.length; i++) {
    console.log(`Uploading Hindi screenshot ${i + 1} to hi-IN...`);
    await play.edits.images.upload({
      editId,
      packageName,
      imageType: 'phoneScreenshots',
      language: 'hi-IN',
      media: {
        mimeType: 'image/png',
        body: fs.createReadStream(screenshots[i]),
      },
    });
  }

  // Also upload Hindi icon and feature graphic for hi-IN
  const iconPath = 'C:\\Users\\NAVEEN\\Downloads\\app_icon_512.png';
  const featureGraphicPath = 'C:\\Users\\NAVEEN\\Downloads\\feature_graphic_1024x500.png';

  console.log('Uploading Icon & Feature graphic for hi-IN...');
  await play.edits.images.upload({
    editId,
    packageName,
    imageType: 'icon',
    language: 'hi-IN',
    media: { mimeType: 'image/png', body: fs.createReadStream(iconPath) },
  });

  await play.edits.images.upload({
    editId,
    packageName,
    imageType: 'featureGraphic',
    language: 'hi-IN',
    media: { mimeType: 'image/png', body: fs.createReadStream(featureGraphicPath) },
  });

  // Also add 4th screenshot to en-US so it has 4 screenshots
  console.log('Uploading 4th screenshot to en-US...');
  await play.edits.images.upload({
    editId,
    packageName,
    imageType: 'phoneScreenshots',
    language: 'en-US',
    media: {
      mimeType: 'image/png',
      body: fs.createReadStream(screenshots[0]),
    },
  });

  await play.edits.commit({ editId, packageName });
  console.log('🎉 SUCCESS! 4 Hindi Screenshots uploaded & committed to Google Play!');
}

uploadHindiScreenshots().catch((err) => {
  console.error('❌ Error:', err.message);
  if (err.response && err.response.data) {
    console.error(JSON.stringify(err.response.data, null, 2));
  }
});

