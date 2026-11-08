const fs = require('fs');
const path = require('path');

const ASSETS = [
  { url: 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js', dest: 'vendor/three.min.js' },
  { url: 'https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js', dest: 'vendor/OrbitControls.js' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/sunmap.jpg', dest: 'assets/textures/sunmap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/mercurymap.jpg', dest: 'assets/textures/mercurymap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/mercurybump.jpg', dest: 'assets/textures/mercurybump.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/venusmap.jpg', dest: 'assets/textures/venusmap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@master/examples/textures/planets/earth_atmos_2048.jpg', dest: 'assets/textures/earth_atmos_2048.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@master/examples/textures/planets/earth_clouds_1024.png', dest: 'assets/textures/earth_clouds_1024.png' },
  { url: 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@master/examples/textures/planets/moon_1024.jpg', dest: 'assets/textures/moon_1024.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/moonbump1k.jpg', dest: 'assets/textures/moonbump1k.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/marsmap1k.jpg', dest: 'assets/textures/marsmap1k.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/jupitermap.jpg', dest: 'assets/textures/jupitermap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/saturnmap.jpg', dest: 'assets/textures/saturnmap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/saturnringcolor.jpg', dest: 'assets/textures/saturnringcolor.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/uranusmap.jpg', dest: 'assets/textures/uranusmap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/uranusringcolour.jpg', dest: 'assets/textures/uranusringcolour.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/neptunemap.jpg', dest: 'assets/textures/neptunemap.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/jeromeetienne/threex.planets@master/images/plutomap1k.jpg', dest: 'assets/textures/plutomap1k.jpg' },
  { url: 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@master/examples/textures/roughness_map.jpg', dest: 'assets/textures/roughness_map.jpg' }
];

const baseDir = path.resolve(__dirname, '..');

async function downloadFile(item) {
  const fullPath = path.join(baseDir, item.dest);
  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  console.log(`Downloading ${item.dest}...`);
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      const res = await fetch(item.url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
        }
      });
      if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`);
      const arrayBuffer = await res.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      if (buffer.length === 0) throw new Error('Received 0 bytes');
      fs.writeFileSync(fullPath, buffer);
      console.log(`[OK] ${item.dest} (${(buffer.length / 1024).toFixed(1)} KB)`);
      return;
    } catch (err) {
      console.warn(`[Attempt ${attempt}/3 failed] ${item.dest}: ${err.message}`);
      if (attempt === 3) throw err;
      await new Promise(r => setTimeout(r, 1500));
    }
  }
}

async function main() {
  console.log(`Starting download of ${ASSETS.length} offline assets...`);
  let successCount = 0;
  for (const item of ASSETS) {
    try {
      await downloadFile(item);
      successCount++;
    } catch (err) {
      console.error(`FAILED to download ${item.dest}:`, err);
    }
  }
  console.log(`\nFinished: ${successCount}/${ASSETS.length} files successfully saved.`);
  if (successCount !== ASSETS.length) {
    process.exit(1);
  }
}

main();
