const http = require('http');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const server = http.createServer((req, res) => {
  let filePath = path.join(root, req.url === '/' ? 'index.html' : req.url.replace(/^\//, ''));
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    res.writeHead(200);
    res.end(fs.readFileSync(filePath));
  } else {
    res.writeHead(404);
    res.end('Not found: ' + req.url);
  }
});

server.listen(8099, async () => {
  console.log('Test offline server listening on http://localhost:8099');
  const indexHtml = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
  
  const urls = [];
  const scriptRegex = /<script\s+src=["']([^"']+)["']/g;
  let m;
  while ((m = scriptRegex.exec(indexHtml)) !== null) urls.push(m[1]);
  const texRegex = /assets\/textures\/[a-zA-Z0-9_\-\.]+\.(?:jpg|png)/g;
  while ((m = texRegex.exec(indexHtml)) !== null) urls.push(m[0]);
  
  const uniqueUrls = [...new Set(urls)];
  console.log(`Checking ${uniqueUrls.length} internal asset requests:\n`);
  let allOk = true;
  for (const u of uniqueUrls) {
    try {
      const res = await fetch('http://localhost:8099/' + u);
      if (res.status === 200) {
        console.log(`  [OK 200] ${u} (${res.headers.get('content-length') || fs.statSync(path.join(root, u)).size} bytes)`);
      } else {
        console.error(`  [FAIL ${res.status}] ${u}`);
        allOk = false;
      }
    } catch (e) {
      console.error(`  [ERR] ${u}: ${e.message}`);
      allOk = false;
    }
  }
  server.close(() => {
    console.log(`\nServer stopped. All assets verified: ${allOk}`);
    process.exit(allOk ? 0 : 1);
  });
});
