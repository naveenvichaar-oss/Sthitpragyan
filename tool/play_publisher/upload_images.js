const { google } = require('googleapis');
const path = require('path');
const fs = require('fs');

async function uploadImages() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';
  const language = 'en-US';

  const iconPath = 'C:\\Users\\NAVEEN\\Downloads\\app_icon_512.png';
  const featureGraphicPath = 'C:\\Users\\NAVEEN\\Downloads\\feature_graphic_1024x500.png';
  const screenshot1Path = 'C:\\Users\\NAVEEN\\Downloads\\screenshot_1.png';
  const screenshot2Path = 'C:\\Users\\NAVEEN\\Downloads\\screenshot_2.png';
  const screenshot3Path = 'C:\\Users\\NAVEEN\\Downloads\\screenshot_3.png';

  console.log('Connecting to Google Play API to upload store visual assets...');

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

  // 1. App Icon
  if (fs.existsSync(iconPath)) {
    console.log(`Uploading App Icon (512x512)...`);
    await play.edits.images.upload({
      editId,
      packageName,
      imageType: 'icon',
      language,
      media: {
        mimeType: 'image/png',
        body: fs.createReadStream(iconPath),
      },
    });
    console.log(`  -> Icon uploaded!`);
  }

  // 2. Feature Graphic
  if (fs.existsSync(featureGraphicPath)) {
    console.log(`Uploading Feature Graphic (1024x500)...`);
    await play.edits.images.upload({
      editId,
      packageName,
      imageType: 'featureGraphic',
      language,
      media: {
        mimeType: 'image/png',
        body: fs.createReadStream(featureGraphicPath),
      },
    });
    console.log(`  -> Feature Graphic uploaded!`);
  }

  // 3. Phone Screenshots
  const screenshots = [screenshot1Path, screenshot2Path, screenshot3Path];
  for (let i = 0; i < screenshots.length; i++) {
    const sPath = screenshots[i];
    if (fs.existsSync(sPath)) {
      console.log(`Uploading Phone Screenshot ${i + 1}...`);
      await play.edits.images.upload({
        editId,
        packageName,
        imageType: 'phoneScreenshots',
        language,
        media: {
          mimeType: 'image/png',
          body: fs.createReadStream(sPath),
        },
      });
      console.log(`  -> Screenshot ${i + 1} uploaded!`);
    }
  }

  console.log(`Committing image edits to Google Play...`);
  await play.edits.commit({ editId, packageName });
  console.log(`🎉 SUCCESS! All images (Icon, Feature Graphic, Screenshots) uploaded via API!`);
}

uploadImages().catch((err) => {
  console.error(`❌ Upload failed:`, err.message);
  if (err.response && err.response.data) {
    console.error(JSON.stringify(err.response.data, null, 2));
  }
});

