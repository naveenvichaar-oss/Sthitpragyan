const { google } = require('googleapis');
const path = require('path');
const fs = require('fs');

async function uploadTabletAssets() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';
  const languages = ['en-US', 'hi-IN'];

  const screenshots = [
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_1.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_2.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_3.png',
    'C:\\Users\\NAVEEN\\Downloads\\hindi_screenshot_4.png',
  ];

  console.log('Connecting to Google Play API to upload Tablet assets (7-inch & 10-inch)...');

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

  for (const lang of languages) {
    console.log(`Uploading for language: ${lang}`);
    for (const imageType of ['sevenInchScreenshots', 'tenInchScreenshots']) {
      console.log(`  Uploading ${imageType}...`);
      for (let i = 0; i < 2; i++) {
        await play.edits.images.upload({
          editId,
          packageName,
          imageType,
          language: lang,
          media: {
            mimeType: 'image/png',
            body: fs.createReadStream(screenshots[i]),
          },
        });
      }
    }
  }

  console.log('Committing tablet assets to Google Play...');
  await play.edits.commit({ editId, packageName });
  console.log('🎉 SUCCESS! Tablet screenshots successfully uploaded & committed!');
}

uploadTabletAssets().catch((err) => {
  console.error('❌ Tablet upload message:', err.message);
  if (err.response && err.response.data) {
    console.error(JSON.stringify(err.response.data, null, 2));
  }
});

