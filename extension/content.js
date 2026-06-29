// music.youtube.com sayfasında çalışır.
// Çalan şarkı bilgisini okuyup her saniye background service worker'a yollar.
(function () {
  'use strict';

  // En büyük kapak görselini seç ve çözünürlüğü yükselt
  function bestArtwork(artwork) {
    if (!artwork || !artwork.length) return '';
    const sorted = artwork.slice().sort((a, b) => area(b) - area(a));
    let src = sorted[0].src || '';
    // YT Music kapakları "...=w60-h60-l90-rj" gibi gelir; daha büyük iste
    src = src.replace(/=w\d+-h\d+/, '=w544-h544');
    return src;
  }

  function area(img) {
    const m = /(\d+)x(\d+)/.exec(img.sizes || '');
    return m ? Number(m[1]) * Number(m[2]) : 0;
  }

  function findWatchUrl() {
    const a = document.querySelector(
      'ytmusic-player-bar a.yt-simple-endpoint[href*="watch"]'
    );
    if (a) {
      try {
        return new URL(a.getAttribute('href'), location.origin).href;
      } catch (_) {}
    }
    return null;
  }

  function readTrack() {
    const video = document.querySelector('video');
    const meta = navigator.mediaSession && navigator.mediaSession.metadata;
    if (!video || !meta || !meta.title) return null;

    const title = meta.title;
    const artist = meta.artist || '';
    const album = meta.album || '';
    const cover = bestArtwork(meta.artwork);
    const playing = !video.paused && !video.ended;
    const position = Math.floor(video.currentTime || 0);
    const duration =
      isFinite(video.duration) && video.duration > 0
        ? Math.floor(video.duration)
        : 0;

    const url =
      findWatchUrl() ||
      'https://music.youtube.com/search?q=' +
        encodeURIComponent(title + ' ' + artist);

    return { title, artist, album, cover, playing, position, duration, url };
  }

  // Her saniye gönder; tekrar/akış süzgeci yerel uygulamada yapılır.
  setInterval(function () {
    const track = readTrack();
    if (!track) return;
    try {
      chrome.runtime.sendMessage({ type: 'track', track: track });
    } catch (_) {
      // service worker uyumuş olabilir; sonraki tik tekrar dener
    }
  }, 1000);
})();
