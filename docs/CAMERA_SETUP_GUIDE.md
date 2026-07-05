# Kamera Sistemi Kurulum Rehberi

## 📹 Genel Bakış

Bu dokümantasyon, Devkom App için IP kamera entegrasyonunu ve RTSP'den WebRTC'ye dönüşüm sürecini detaylı olarak açıklar.

---

## 🎯 İki Alternatif Implementasyon

### **Seçenek 1: VLC/RTSP (Düşük Maliyet) ✅ HAZIR**

**Avantajlar:**
- ✅ Minimum altyapı maliyeti
- ✅ Mevcut IP kameraları direkt kullanabilir
- ✅ Kurulum basit
- ✅ Şu an çalışır durumda

**Dezavantajlar:**
- ⚠️ Web desteği sınırlı (VLC plugin gerekir)
- ⚠️ Gecikme biraz daha yüksek (1-3 saniye)
- ⚠️ Mobil platformlarda daha fazla kaynak tüketir

**Kullanım Senaryosu:**
- Sadece mobil (Android/iOS) kullanıcılar
- Düşük maliyetli çözüm gerekiyor
- Az sayıda eşzamanlı izleyici

---

### **Seçenek 2: WebRTC (Modern Çözüm) 🚀 KURULUM GEREKİYOR**

**Avantajlar:**
- ✅ Çok düşük gecikme (<500ms)
- ✅ Web desteği mükemmel
- ✅ Yüksek kalite
- ✅ Ölçeklenebilir

**Dezavantajlar:**
- ⚠️ Altyapı maliyeti (Media Server)
- ⚠️ Kurulum karmaşık
- ⚠️ STUN/TURN sunucuları gerekir

**Kullanım Senaryosu:**
- Web uygulaması gerekli
- Gerçek zamanlı iletişim önemli
- Çok sayıda eşzamanlı izleyici

---

## 🔧 Seçenek 1: VLC/RTSP Kurulumu (MEVCUT)

### 1. IP Kamera Ayarları

Kameranızın RTSP stream'ini etkinleştirin:

```
RTSP URL Formatı:
rtsp://<KULLANICI>:<ŞİFRE>@<KAMERA_IP>:<PORT>/<STREAM_YOLU>

Örnekler:
- rtsp://admin:12345@192.168.1.100:554/stream1
- rtsp://admin:password@192.168.1.101:554/h264/ch1/main/av_stream
- rtsp://user:pass@camera.local:8554/live
```

### 2. Kamera Bilgilerini Güncelle

`lib/services/camera_service.dart` dosyasında `getDemoCameras()` metodunu güncelleyin:

```dart
List<CameraModel> getDemoCameras() {
  return [
    CameraModel(
      id: 'cam1',
      name: 'Sınıf Kamerası',
      rtspUrl: 'rtsp://admin:password@192.168.1.100:554/stream1',
      location: 'Yazılım Sınıfı',
      quality: CameraQuality.high,
    ),
    // Diğer kameralar...
  ];
}
```

### 3. Test Edin

```bash
# Mobil cihazda test
flutter run -d <device-id>

# VLC ile test (masaüstünde)
vlc rtsp://admin:password@192.168.1.100:554/stream1
```

### 4. Network Güvenliği

**Önemli:** Kameralar aynı ağda olmalı veya VPN kullanılmalı.

```
Seçenek A: Yerel Ağ
- Uygulama ve kameralar aynı WiFi'de
- Port yönlendirme gerekmez
- En güvenli seçenek

Seçenek B: VPN (Tailscale/ZeroTier)
- Uzaktan erişim için
- Ücretsiz planlar mevcut
- Güvenli tünel

Seçenek C: Port Forwarding (ÖNERİLMEZ)
- Güvenlik riski
- Sadece gerekirse kullanın
- Mutlaka güçlü şifre
```

---

## 🚀 Seçenek 2: WebRTC Kurulumu

### Gerekli Bileşenler

1. **Signaling Server** - İstemciler arası bağlantı kurulumu
2. **Media Server** - RTSP'den WebRTC'ye dönüşüm
3. **STUN/TURN Servers** - NAT traversal
4. **HTTPS/WSS** - Güvenli bağlantı

---

### Adım 1: Media Server Seçimi

#### **A) Mediasoup (Önerilen) 🌟**

**Neden Mediasoup?**
- ✅ Açık kaynak ve ücretsiz
- ✅ Çok yüksek performans
- ✅ SFU (Selective Forwarding Unit) desteği
- ✅ Aktif geliştirici topluluğu

**Kurulum:**

```bash
# Node.js kurulumu (v16+)
sudo apt update
sudo apt install nodejs npm

# Mediasoup projesi oluştur
mkdir mediasoup-server
cd mediasoup-server
npm init -y
npm install mediasoup socket.io express

# RTSP to WebRTC gateway ekle
npm install ffmpeg-static node-rtsp-stream
```

**Örnek Server Kodu:**

```javascript
// server.js
const express = require('express');
const https = require('https');
const socketIO = require('socket.io');
const mediasoup = require('mediasoup');
const fs = require('fs');

const app = express();
const httpsServer = https.createServer({
  key: fs.readFileSync('server-key.pem'),
  cert: fs.readFileSync('server-cert.pem')
}, app);

const io = socketIO(httpsServer, {
  cors: { origin: '*' }
});

let worker, router;

async function startMediasoup() {
  worker = await mediasoup.createWorker({
    logLevel: 'warn',
    rtcMinPort: 10000,
    rtcMaxPort: 10100,
  });

  router = await worker.createRouter({
    mediaCodecs: [
      {
        kind: 'video',
        mimeType: 'video/H264',
        clockRate: 90000,
      }
    ]
  });
}

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('getRtpCapabilities', (callback) => {
    callback(router.rtpCapabilities);
  });

  // RTSP stream'i WebRTC'ye dönüştür
  socket.on('startStream', async (rtspUrl, callback) => {
    // FFmpeg ile RTSP'yi RTP'ye dönüştür
    // Mediasoup ile WebRTC'ye ilet
    // callback ile stream bilgisini gönder
  });
});

startMediasoup().then(() => {
  httpsServer.listen(3000, () => {
    console.log('Mediasoup server running on https://localhost:3000');
  });
});
```

**Maliyetler:**
- Server: $5-20/ay (DigitalOcean/Hetzner)
- Domain: $10/yıl (optional)
- **TOPLAM: ~$10/ay**

---

#### **B) Janus Gateway (Alternatif)**

**Neden Janus?**
- ✅ C dilinde yazılmış (çok hızlı)
- ✅ RTSP plugin'i mevcut
- ✅ Dokümantasyon zengin

**Kurulum:**

```bash
# Ubuntu/Debian
sudo apt install libmicrohttpd-dev libjansson-dev \
  libssl-dev libsrtp2-dev libsofia-sip-ua-dev \
  libglib2.0-dev libopus-dev libogg-dev \
  libcurl4-openssl-dev liblua5.3-dev \
  libconfig-dev pkg-config gengetopt \
  libtool automake

git clone https://github.com/meetecho/janus-gateway.git
cd janus-gateway
sh autogen.sh
./configure --prefix=/opt/janus
make
sudo make install
```

**Janus Streaming Plugin ile RTSP:**

```bash
# /opt/janus/etc/janus/janus.plugin.streaming.jcfg

rtsp-test: {
  type = "rtsp"
  id = 1
  description = "Classroom Camera"
  url = "rtsp://192.168.1.100:554/stream1"
  rtsp_user = "admin"
  rtsp_pwd = "password"
}
```

---

#### **C) GStreamer (DIY Çözüm)**

**En Düşük Maliyetli** ama teknik bilgi gerektirir.

```bash
# GStreamer kurulumu
sudo apt install gstreamer1.0-tools gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly gstreamer1.0-libav

# RTSP'den WebRTC'ye pipeline
gst-launch-1.0 rtspsrc location=rtsp://192.168.1.100:554/stream1 \
  ! rtph264depay ! h264parse ! avdec_h264 \
  ! videoconvert ! vp8enc ! webrtcbin
```

---

### Adım 2: Signaling Server

**Socket.io ile Basit Signaling Server:**

```javascript
// signaling-server.js
const express = require('express');
const https = require('https');
const socketIO = require('socket.io');
const fs = require('fs');

const app = express();
const httpsServer = https.createServer({
  key: fs.readFileSync('server-key.pem'),
  cert: fs.readFileSync('server-cert.pem')
}, app);

const io = socketIO(httpsServer, {
  cors: { origin: '*' }
});

const rooms = new Map();

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join-room', (roomId, userId) => {
    socket.join(roomId);

    if (!rooms.has(roomId)) {
      rooms.set(roomId, new Set());
    }
    rooms.get(roomId).add(userId);

    // Notify others in room
    socket.to(roomId).emit('user-connected', userId);
  });

  socket.on('offer', (offer, roomId) => {
    socket.to(roomId).emit('offer', offer);
  });

  socket.on('answer', (answer, roomId) => {
    socket.to(roomId).emit('answer', answer);
  });

  socket.on('ice-candidate', (candidate, roomId) => {
    socket.to(roomId).emit('ice-candidate', candidate);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

httpsServer.listen(4000, () => {
  console.log('Signaling server on https://localhost:4000');
});
```

---

### Adım 3: STUN/TURN Servers

#### **Ücretsiz STUN Servers:**

```dart
final iceServers = [
  {'urls': 'stun:stun.l.google.com:19302'},
  {'urls': 'stun:stun1.l.google.com:19302'},
  {'urls': 'stun:stun2.l.google.com:19302'},
];
```

#### **TURN Server (Gerekirse):**

**Ücretsiz Seçenek: Metered.ca**
- 50GB/ay ücretsiz
- Kayıt: https://www.metered.ca

**Kendi TURN Sunucunuz:**

```bash
# Coturn kurulumu
sudo apt install coturn

# /etc/turnserver.conf
listening-port=3478
fingerprint
lt-cred-mech
user=username:password
realm=yourdomain.com
```

**Maliyetler:**
- Ücretsiz STUN: $0
- Metered.ca (50GB): $0
- Kendi TURN server: $5/ay

---

### Adım 4: Flutter WebRTC Entegrasyonu

#### **Paket Kurulumu:**

```bash
flutter pub add flutter_webrtc socket_io_client
```

#### **Kullanım (webrtc_camera_player.dart dosyasında örnek kod mevcut):**

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// RTCVideoRenderer ile video gösterimi
final _localRenderer = RTCVideoRenderer();
await _localRenderer.initialize();

// Socket.io bağlantısı
final socket = IO.io('https://your-signaling-server.com');

// Peer connection
final configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
  ]
};
final pc = await createPeerConnection(configuration);

// Render video
RTCVideoView(_localRenderer);
```

---

## 💰 Maliyet Karşılaştırması

### Minimum Maliyet Senaryosu

| Bileşen | VLC/RTSP | WebRTC |
|---------|----------|--------|
| Media Server | $0 | $5-10/ay |
| Signaling Server | $0 | $0 (aynı sunucu) |
| STUN/TURN | $0 | $0 (ücretsiz) |
| Domain | $0 | $10/yıl |
| **TOPLAM** | **$0/ay** | **~$10/ay** |

### Önerilen Ücretsiz/Düşük Maliyetli Stack

**En Ekonomik WebRTC Çözümü:**

```
1. Oracle Cloud (Always Free Tier)
   - 1 VM (1GB RAM) - ÜCRETSIZ
   - 10TB trafik/ay - ÜCRETSIZ

2. Mediasoup + Signaling Server
   - Aynı VM'de çalışır - ÜCRETSIZ

3. Google STUN
   - stun.l.google.com - ÜCRETSIZ

4. Metered.ca TURN
   - 50GB/ay - ÜCRETSIZ

5. Let's Encrypt SSL
   - HTTPS sertifikası - ÜCRETSIZ

TOPLAM MALIYET: $0/ay 🎉
```

---

## 🔒 Güvenlik En İyi Uygulamaları

### 1. **Token Authentication**

```dart
// Flutter tarafı
final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

// Kamera bağlantısında token gönder
socket.emit('authenticate', {
  'token': userToken,
  'cameraId': camera.id,
});

// Server tarafı (Node.js)
socket.on('authenticate', async (data) => {
  const verified = await admin.auth().verifyIdToken(data.token);
  if (verified.uid) {
    // Check user role
    const userDoc = await firestore.collection('users').doc(verified.uid).get();
    if (userDoc.data().role === 'parent') {
      // Allow access
      socket.emit('authenticated', true);
    }
  }
});
```

### 2. **Rate Limiting**

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // 100 requests per window
});

app.use('/api/', limiter);
```

### 3. **HTTPS/WSS Only**

```dart
// Sadece güvenli bağlantılara izin ver
final socket = IO.io(
  'https://your-server.com', // HTTP değil!
  IO.OptionBuilder()
    .setTransports(['websocket'])
    .disableAutoConnect()
    .build()
);
```

---

## 📊 Performans Optimizasyonu

### Bandwidth Tasarrufu

```dart
// Kalite adaptasyonu
CameraQuality selectQuality(double bandwidth) {
  if (bandwidth > 5000) return CameraQuality.high;
  if (bandwidth > 2000) return CameraQuality.medium;
  return CameraQuality.low;
}

// Buffering ayarları
final vlcPlayerController = VlcPlayerController.network(
  camera.rtspUrl,
  hwAcc: HwAcc.full,
  options: VlcPlayerOptions(
    advanced: VlcAdvancedOptions([
      VlcAdvancedOptions.networkCaching(2000), // 2 saniye buffer
      VlcAdvancedOptions.fileCaching(500),
    ]),
  ),
);
```

---

## 🧪 Test Araçları

### RTSP Stream Test

```bash
# FFplay ile test
ffplay -rtsp_transport tcp rtsp://192.168.1.100:554/stream1

# VLC ile test
vlc rtsp://admin:password@192.168.1.100:554/stream1

# cURL ile HTTP test
curl -I http://192.168.1.100:8080/stream
```

### WebRTC Test

```bash
# WebRTC test sayfası
https://test.webrtc.org

# STUN/TURN test
https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/
```

---

## 📱 Platform Specific Notlar

### Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Network security config (HTTP için gerekli) -->
<application
  android:usesCleartextTraffic="true">
```

### iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Canlı kamera izlemek için kamera erişimi gereklidir</string>
<key>NSMicrophoneUsageDescription</key>
<string>Ses dinlemek için mikrofon erişimi gereklidir</string>
```

### Web

```html
<!-- web/index.html -->
<head>
  <meta http-equiv="Content-Security-Policy"
    content="default-src 'self'; media-src *; connect-src *;">
</head>
```

---

## 🆘 Sorun Giderme

### Sık Karşılaşılan Sorunlar

**1. "Connection timeout"**
```
Çözüm:
- Kamera IP adresini kontrol edin
- Port'un açık olduğundan emin olun
- Firewall kurallarını kontrol edin
```

**2. "Authentication failed"**
```
Çözüm:
- Kullanıcı adı/şifre doğru mu?
- RTSP URL formatı doğru mu?
- Kamera RTSP'yi destekliyor mu?
```

**3. "Buffering constantly"**
```
Çözüm:
- Network caching artırın (2000ms+)
- Kaliteyi düşürün
- Bandwidth kontrolü yapın
```

**4. "Black screen"**
```
Çözüm:
- Codec uyumluluğu kontrol edin (H.264 önerilir)
- Hardware acceleration etkin mi?
- Stream URL'i VLC ile test edin
```

---

## 📚 Kaynaklar

### Dokümantasyon
- [Mediasoup](https://mediasoup.org)
- [Janus Gateway](https://janus.conf.meetecho.com)
- [flutter_webrtc](https://github.com/flutter-webrtc/flutter-webrtc)
- [flutter_vlc_player](https://pub.dev/packages/flutter_vlc_player)

### Örnek Projeler
- [Mediasoup Demo](https://github.com/versatica/mediasoup-demo)
- [Flutter WebRTC Examples](https://github.com/flutter-webrtc/flutter-webrtc/tree/master/example)

### Video Tutorials
- [WebRTC Crash Course](https://www.youtube.com/watch?v=FExZvpVvYxA)
- [Mediasoup Tutorial](https://www.youtube.com/watch?v=N-VKL39VFUI)

---

## 🎓 Sonuç ve Öneri

### **Başlangıç İçin: VLC/RTSP** ✅
- Hemen kullanıma hazır
- Sıfır maliyet
- Kolay kurulum
- Mobil odaklı projeler için ideal

### **Gelecek İçin: WebRTC** 🚀
- Profesyonel çözüm
- Web desteği
- Düşük gecikme
- Ölçeklenebilir

### **Önerilen Geçiş Yolu:**
1. **Faz 1**: VLC/RTSP ile başla (MEVCUT)
2. **Faz 2**: Kullanıcı geri bildirimi topla
3. **Faz 3**: Oracle Free Tier'da Mediasoup test et
4. **Faz 4**: WebRTC'ye geçiş yap

---

**Hazırlayan:** Claude Code
**Tarih:** 18 Ekim 2025
**Versiyon:** 1.0
