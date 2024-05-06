const fs = require('fs/promises');
const path = require('path');

async function movePublicToDist() {
  const source = 'public';
  const destination = 'dist';

  try {
    const files = await fs.readdir(source);

    for (const file of files) {
      const sourcePath = path.join(source, file);
      const destPath = path.join(destination, file);
      if (file == 'smartcontract.json') {
        await fs.cp(sourcePath, destPath);
        console.log(`${file} added to ${destination}`);
      }
    }
  } catch (err) {
    console.error(err);
  }
}

movePublicToDist();
