const { google } = require('googleapis');
const path = require('path');

async function checkAppStatus() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';

  console.log(`Checking status for ${packageName} on Google Play...`);

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

  // 1. Details
  try {
    const details = await play.edits.details.get({ editId, packageName });
    console.log('App Details:', JSON.stringify(details.data, null, 2));
  } catch (e) {
    console.log('Details query:', e.message);
  }

  // 2. Listings
  try {
    const listings = await play.edits.listings.list({ editId, packageName });
    console.log('\nConfigured Store Listings:');
    listings.data.listings.forEach(l => {
      console.log(`  - Language: [${l.language}] Title: "${l.title}"`);
    });
  } catch (e) {
    console.log('Listings query:', e.message);
  }

  // 3. Tracks & Releases
  try {
    const tracks = await play.edits.tracks.list({ editId, packageName });
    console.log('\nReleases on Tracks:');
    tracks.data.tracks.forEach(t => {
      const rels = t.releases ? t.releases.map(r => `v${r.name} (codes: ${r.versionCodes}, status: ${r.status})`).join(', ') : 'None';
      console.log(`  - Track [${t.track}]: ${rels}`);
    });
  } catch (e) {
    console.log('Tracks query:', e.message);
  }

  // 4. Bundles
  try {
    const bundles = await play.edits.bundles.list({ editId, packageName });
    console.log('\nUploaded App Bundles:');
    bundles.data.bundles.forEach(b => {
      console.log(`  - VersionCode: ${b.versionCode}, SHA1: ${b.sha1}`);
    });
  } catch (e) {
    console.log('Bundles query:', e.message);
  }

  // 5. Images on en-US and hi-IN
  for (const lang of ['en-US', 'hi-IN']) {
    console.log(`\nImages for ${lang}:`);
    for (const imgType of ['icon', 'featureGraphic', 'phoneScreenshots', 'sevenInchScreenshots', 'tenInchScreenshots']) {
      try {
        const imgs = await play.edits.images.list({ editId, packageName, language: lang, imageType: imgType });
        console.log(`  - ${imgType}: ${imgs.data.images ? imgs.data.images.length : 0} uploaded`);
      } catch (e) {
        console.log(`  - ${imgType}: 0`);
      }
    }
  }

  await play.edits.delete({ editId, packageName });
}

checkAppStatus().catch(err => {
  console.error('Error:', err.message);
});

