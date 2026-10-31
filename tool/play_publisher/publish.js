const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

async function main() {
  const args = process.argv.slice(2);
  const aabPath = args[0] || path.resolve(__dirname, '../../release_builds/Sthitaprajna-v1.0.1-signed.aab');
  const packageName = args[1] || 'com.sthitaprajna.app';
  const track = args[2] || 'internal';
  const keyFilePath = args[3] || path.resolve(__dirname, '../../android/play-publisher-key.json');

  if (!fs.existsSync(keyFilePath)) {
    console.error(`❌ Key file not found at: ${keyFilePath}`);
    process.exit(1);
  }

  if (!fs.existsSync(aabPath)) {
    console.error(`❌ AAB file not found at: ${aabPath}`);
    process.exit(1);
  }

  console.log(`===============================================`);
  console.log(`🚀 Automated Google Play Publisher`);
  console.log(`📦 Package: ${packageName}`);
  console.log(`🎯 Track:   ${track}`);
  console.log(`📁 AAB:     ${aabPath}`);
  console.log(`🔑 Key:     ${keyFilePath}`);
  console.log(`===============================================`);

  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: keyFilePath,
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });

    const client = await auth.getClient();
    const play = google.androidpublisher({
      version: 'v3',
      auth: client,
    });

    console.log(`[1/4] Starting new release edit...`);
    const edit = await play.edits.insert({
      packageName,
    });
    const editId = edit.data.id;
    console.log(`  -> Edit created with ID: ${editId}`);

    console.log(`[2/4] Uploading App Bundle (${(fs.statSync(aabPath).size / (1024 * 1024)).toFixed(2)} MB)...`);
    const bundleStream = fs.createReadStream(aabPath);
    const uploadRes = await play.edits.bundles.upload({
      editId,
      packageName,
      media: {
        mimeType: 'application/octet-stream',
        body: bundleStream,
      },
    });

    const versionCode = uploadRes.data.versionCode;
    console.log(`  -> AAB uploaded successfully! Version Code: ${versionCode}`);

    console.log(`[3/4] Assigning bundle to '${track}' track...`);
    await play.edits.tracks.update({
      editId,
      packageName,
      track,
      requestBody: {
        track,
        releases: [
          {
            name: `${versionCode}`,
            versionCodes: [versionCode.toString()],
            status: 'completed',
          },
        ],
      },
    });
    console.log(`  -> Track updated!`);

    console.log(`[4/4] Committing release to Google Play...`);
    await play.edits.commit({
      editId,
      packageName,
    });

    console.log(`===============================================`);
    console.log(`🎉 SUCCESS! App successfully published to Google Play (${track})!`);
    console.log(`===============================================`);
  } catch (err) {
    console.error(`\n❌ Publishing failed:`, err.message);
    if (err.response && err.response.data) {
      console.error(JSON.stringify(err.response.data, null, 2));
    }
    process.exit(1);
  }
}

main();

