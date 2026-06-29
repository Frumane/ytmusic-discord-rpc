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

  // "11:42 / 12:49" gibi metni saniyeye çevir
  function parseTimeInfo() {
    const el = document.querySelector('.time-info');
    if (!el) return null;
    const m = el.textContent
      .trim()
      .match(/(\d+):(\d+)(?::(\d+))?\s*\/\s*(\d+):(\d+)(?::(\d+))?/);
    if (!m) return null;
    const cur = m[3] ? +m[1] * 3600 + +m[2] * 60 + +m[3] : +m[1] * 60 + +m[2];
    const tot = m[6] ? +m[4] * 3600 + +m[5] * 60 + +m[6] : +m[4] * 60 + +m[5];
    return { position: cur, duration: tot };
  }

  // Konum/süreyi önce player çubuğundan oku (ekranda görünenle birebir aynı).
  // Ham <video> öğesi yanlış olabiliyor (reklam/önizleme), o yüzden son çare.
  function readProgress() {
    const slider =
      document.querySelector('#progress-bar') ||
      document.querySelector('tp-yt-paper-slider#progress-bar');
    if (slider) {
      const pos = Number(slider.getAttribute('aria-valuenow'));
      const dur = Number(slider.getAttribute('aria-valuemax'));
      if (dur > 0) return { position: pos || 0, duration: dur };
    }
    const t = parseTimeInfo();
    if (t && t.duration > 0) return t;

    const v = document.querySelector('video');
    if (v && isFinite(v.duration) && v.duration > 0) {
      return { position: Math.floor(v.currentTime || 0), duration: Math.floor(v.duration) };
    }
    return { position: 0, duration: 0 };
  }

  function isPlaying() {
    const ps = navigator.mediaSession && navigator.mediaSession.playbackState;
    if (ps === 'playing') return true;
    if (ps === 'paused') return false;
    const v = document.querySelector('video');
    return v ? !v.paused && !v.ended : false;
  }

  function readTrack() {
    const meta = navigator.mediaSession && navigator.mediaSession.metadata;
    if (!meta || !meta.title) return null;

    const prog = readProgress();
    const title = meta.title;
    const artist = meta.artist || '';
    const album = meta.album || '';
    const cover = bestArtwork(meta.artwork);
    const playing = isPlaying();

    const url =
      findWatchUrl() ||
      'https://music.youtube.com/search?q=' +
        encodeURIComponent(title + ' ' + artist);

    return {
      title,
      artist,
      album,
      cover,
      playing,
      position: prog.position,
      duration: prog.duration,
      url,
    };
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
