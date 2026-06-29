// Yerel Node uygulamasına (http://127.0.0.1:PORT) şarkı bilgisini iletir.
// WebSocket yerine HTTP kullanılır: Firefox/Floorp HTTPS-Only modu ws:// adresini
// wss://'e yükseltip bağlantıyı kırar; loopback HTTP yükseltilmediği için sorunsuz çalışır.
const PORT = 7700; // app/config.json içindeki "port" ile aynı olmalı
const ENDPOINT = 'http://127.0.0.1:' + PORT + '/';

chrome.runtime.onMessage.addListener(function (msg) {
  if (!msg || msg.type !== 'track') return;
  fetch(ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(msg.track),
  }).catch(function () {
    // Uygulama kapalı olabilir; bir sonraki saniye tekrar denenir
  });
});
