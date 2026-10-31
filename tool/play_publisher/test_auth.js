const { google } = require('googleapis');
const path = require('path');

async function testAuth() {
  const keyFilePath = path.resolve(__dirname, '../../android/play-publisher-key.json');
  const packageName = 'com.sthitaprajna.app';

  console.log('Testing authentication with Google Play API...');
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

    console.log(`Checking app listing for '${packageName}'...`);
    const edit = await play.edits.insert({ packageName });
    console.log(`✅ Authentication SUCCESSFUL! Edit ID created: ${edit.data.id}`);

    // Clean up edit so it doesn't linger
    await play.edits.delete({ editId: edit.data.id, packageName });
    console.log(`✅ Google Play Developer API is 100% configured, authorized and working!`);
  } catch (err) {
    console.error('❌ Test failed:', err.message);
    if (err.response && err.response.data) {
      console.error(JSON.stringify(err.response.data, null, 2));
    }
  }
}

testAuth();

