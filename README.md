# YouTube Music → Discord Rich Presence

YouTube Music'te çalan şarkıyı Discord profilinde **detaylı** gösterir:

- 🎵 Şarkı adı + sanatçı
- 🖼️ Albüm/şarkı kapağı (büyük görsel)
- ⏱️ Canlı ilerleme çubuğu (geçen / kalan süre)
- 🔗 "YouTube Music'te Dinle" butonu

![durum örneği](docs/preview.png)

---

## Nasıl çalışır?

```
music.youtube.com  ──(tarayıcı eklentisi)──>  http://127.0.0.1:7700  ──(Node app)──>  Discord (IPC)
```

YouTube Music'in resmi Discord entegrasyonu yok ve tarayıcı eklentileri Discord IPC'ye
doğrudan bağlanamaz. Bu yüzden iki parça var:

1. **`extension/`** — Çalan şarkı bilgisini sayfadan okuyup yerel uygulamaya gönderen tarayıcı eklentisi.
2. **`app/`** — Bilgiyi alıp Discord Rich Presence'a çeviren küçük Node.js uygulaması.

İkisi de **kendi bilgisayarında** çalışır, hiçbir veri dışarı gönderilmez.

---

## Kurulum

### 0. Gereksinimler
- [Node.js](https://nodejs.org) 18+
- Masaüstü **Discord** uygulaması (tarayıcıdaki Discord ile çalışmaz — RPC için masaüstü şart)
- Chrome veya Edge (Firefox için aşağıdaki nota bak)

### 1. Yerel uygulamayı kur
```bash
cd app
npm install
npm start
```
Hepsi bu. Repo, gömülü "YouTube Music" Application ID'si ile **kutudan çıktığı gibi** çalışır
— ekstra hesap/anahtar gerekmez.

> **Application ID gizli bir bilgi değildir**, herkese açık durması güvenlidir. Gizli olan
> client secret / bot token'dır ve Rich Presence onları kullanmaz.

### (İsteğe bağlı) Kendi Discord uygulamanı kullan
Durumda kendi uygulamanın görünmesini istersen:
1. <https://discord.com/developers/applications> → **New Application**
2. İsim: **YouTube Music** (durumda "Listening to YouTube Music" diye görünür)
3. **General Information** → **Application ID**'yi kopyala.
4. Şunlardan birini yap:
   - `app/index.js` içindeki `DEFAULT_CLIENT_ID` değerini bu ID ile değiştir, **veya**
   - `config.example.json`'u `config.json` olarak kopyalayıp `clientId` alanına yapıştır.

```bash
npm start
```
`[WS] 127.0.0.1:7700 dinleniyor` ve birazdan `[RPC] Bağlandı` yazısını görmelisin.

### 2. Tarayıcı eklentisini kur

**Chrome / Edge:**
1. `chrome://extensions`
2. Sağ üstten **Geliştirici modu**'nu aç.
3. **Paketlenmemiş öğe yükle** → bu repodaki `extension/` klasörünü seç.
4. `music.youtube.com`'u aç ve bir şarkı çal.

**Floorp / Firefox / LibreWolf:** Aşağıdaki
[Firefox / Floorp bölümüne](#firefox--floorp--librewolf-kullanıyorsan) bak.

Birkaç saniye içinde Discord profilinde durum görünür. 🎉

---

## Yapılandırma (`app/config.json`)

`config.json` isteğe bağlıdır; sadece varsayılanları ezmek istersen oluştur.

| Alan | Açıklama | Varsayılan |
|------|----------|------------|
| `clientId` | Discord Application ID (boş bırakılırsa gömülü varsayılan kullanılır) | gömülü |
| `port` | Eklentinin bağlandığı yerel HTTP portu | `7700` |
| `activityType` | `listening` ("…dinliyor") veya `playing` ("…oynuyor") | `listening` |
| `showButton` | "YouTube Music'te Dinle" butonu | `true` |
| `pauseClears` | Şarkı durunca durumu temizle (`true`) ya da "Duraklatıldı" göster (`false`) | `false` |

> Portu değiştirirsen `extension/background.js` içindeki `PORT` ve `extension/manifest.json`
> içindeki `host_permissions` portunu (`http://127.0.0.1:7700/*`) da aynı yap.

---

## Firefox / Floorp / LibreWolf kullanıyorsan
Eklenti hem Chrome hem Firefox motorunu destekler (manifest her ikisini de içerir).
Floorp Firefox tabanlı olduğu için aynen çalışır.

### Yöntem A — Geçici yükleme (en kolay, test için)
1. Adres çubuğuna `about:debugging#/runtime/this-firefox` yaz.
2. **Geçici Eklenti Yükle** (Load Temporary Add-on) → `extension/manifest.json` dosyasını seç.
3. `music.youtube.com`'u aç ve şarkı çal.

> ⚠️ Geçici eklenti tarayıcı **her kapanışta silinir**, yeniden yüklemen gerekir.

### Yöntem B — Kalıcı yükleme (Floorp'ta imzasız XPI)
Floorp/LibreWolf gibi ESR tabanlı tarayıcılar imzasız eklentiye izin verebilir:
1. `about:config` → `xpinstall.signatures.required` değerini **false** yap.
2. `extension/` klasörünün içindekileri (manifest.json kökte olacak şekilde) bir **.zip**'e koy,
   uzantısını `.xpi` yap.
3. `about:addons` → dişli ⚙️ → **Dosyadan Eklenti Yükle** → `.xpi`'yi seç.

> Not: Standart Firefox'un **release** sürümü imza zorunluluğunu kaldırmaya izin vermez;
> orada yalnızca Yöntem A çalışır. Floorp'ta Yöntem B genelde çalışır.

## Otomatik başlatma (Windows) — kalıcı ve gizli çalıştır
`app` her oturum açılışında, **pencere açmadan (gizli)** başlasın ve çökerse kendini
yeniden başlatsın istiyorsan, hazır scriptler var. **Yönetici (admin) gerekmez.**

Kurmak için (PowerShell'de):
```powershell
cd app
powershell -ExecutionPolicy Bypass -File install-autostart.ps1
```
Bu script:
- `run-hidden.vbs`'i Windows **Başlangıç** klasörüne kısayol olarak ekler (oturum açılışında çalışır),
- node uygulamasını **gizli** olarak başlatır (konsol penceresi görünmez),
- uygulama çökerse 5 sn içinde **otomatik yeniden başlatır**.

Kalıcı olarak kapatmak / kaldırmak için:
```powershell
powershell -ExecutionPolicy Bypass -File uninstall-autostart.ps1
```

> Yine de **Discord masaüstü** uygulamasının açık olması gerekir; durum ancak Discord
> çalışırken görünür.

### Alternatif: pm2 (çok platformlu)
```bash
npm i -g pm2 pm2-windows-startup
pm2 start index.js --name ytmusic-rpc
pm2 save
pm2-startup install
```

---

## Sorun giderme

| Belirti | Çözüm |
|---------|-------|
| `[RPC] Bağlanılamadı` | Masaüstü Discord açık mı? `clientId` doğru mu? |
| Durum hiç görünmüyor | `app` çalışıyor mu, eklenti yüklü mü? `music.youtube.com` sekmesini yenile. |
| Kapak görünmüyor | Şarkıyı değiştir; bazı içeriklerde kapak URL'i geç yüklenir. |
| Buton görünmüyor | Butonlar **başkalarına** görünür; kendi profilinde görünmeyebilir. |

---

## Lisans
[MIT](LICENSE)
