const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const distDir = path.join(rootDir, 'dist');
const androidMainDir = path.join(rootDir, 'android', 'app', 'src', 'main');
const androidAssetsDir = path.join(androidMainDir, 'assets');
const androidPublicDir = path.join(androidAssetsDir, 'public');

function copyDirRecursive(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

console.log('[Build] Preparing bundles for Web and Android...');

// 1. Prepare dist
if (fs.existsSync(distDir)) {
  fs.rmSync(distDir, { recursive: true, force: true });
}
fs.mkdirSync(distDir, { recursive: true });

fs.copyFileSync(path.join(rootDir, 'index.html'), path.join(distDir, 'index.html'));
if (fs.existsSync(path.join(rootDir, 'vendor'))) {
  copyDirRecursive(path.join(rootDir, 'vendor'), path.join(distDir, 'vendor'));
}
if (fs.existsSync(path.join(rootDir, 'assets'))) {
  copyDirRecursive(path.join(rootDir, 'assets'), path.join(distDir, 'assets'));
}
console.log('  -> dist/ bundle ready.');

// 2. Prepare android/app/src/main/assets/public directly
if (fs.existsSync(androidMainDir)) {
  if (!fs.existsSync(androidAssetsDir)) {
    fs.mkdirSync(androidAssetsDir, { recursive: true });
  }
  if (fs.existsSync(androidPublicDir)) {
    fs.rmSync(androidPublicDir, { recursive: true, force: true });
  }
  fs.mkdirSync(androidPublicDir, { recursive: true });

  fs.copyFileSync(path.join(rootDir, 'index.html'), path.join(androidPublicDir, 'index.html'));
  if (fs.existsSync(path.join(rootDir, 'vendor'))) {
    copyDirRecursive(path.join(rootDir, 'vendor'), path.join(androidPublicDir, 'vendor'));
  }
  if (fs.existsSync(path.join(rootDir, 'assets'))) {
    copyDirRecursive(path.join(rootDir, 'assets'), path.join(androidPublicDir, 'assets'));
  }
  
  // Also copy capacitor.config.json into android assets
  const capConfigSrc = path.join(rootDir, 'capacitor.config.json');
  const capConfigDest = path.join(androidAssetsDir, 'capacitor.config.json');
  if (fs.existsSync(capConfigSrc)) {
    fs.copyFileSync(capConfigSrc, capConfigDest);
  }
  console.log('  -> android/app/src/main/assets/public bundle ready.');
}

console.log('[Build] All bundles prepared successfully!');
