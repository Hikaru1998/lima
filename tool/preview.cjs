// Local-only static preview of `flutter build web` output.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../build/web');
const types = {'.html':'text/html', '.js':'application/javascript', '.json':'application/json', '.wasm':'application/wasm', '.png':'image/png', '.svg':'image/svg+xml', '.css':'text/css'};
http.createServer((req, res) => {
  let file;
  try { file = path.resolve(root, '.' + decodeURIComponent(new URL(req.url, 'http://localhost').pathname)); } catch { res.writeHead(400).end(); return; }
  if (file !== root && !file.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
  if (file === root || file.endsWith(path.sep)) file = path.join(file, 'index.html');
  fs.readFile(file, (err, body) => {
    if (err) { res.writeHead(404).end('Not found'); return; }
    res.writeHead(200, {'Content-Type': types[path.extname(file)] || 'application/octet-stream', 'Cache-Control':'no-store'});
    res.end(body);
  });
}).listen(8087, '127.0.0.1', () => console.log('Luma preview: http://127.0.0.1:8087'));
