import type { GoldieConfig } from "goldie";

/**
 * DevEducation — App Store gorselleri (goldie).
 *
 * goldie MAC'te calisir: iOS simulator, argent ve Release build gerekiyor.
 * Bulut ortamindan calistirilamaz.
 *
 *   1) Simulator build:
 *        flutter build ios --simulator
 *      Cikti: build/ios/iphonesimulator/Runner.app
 *
 *      SIMULATORDE RELEASE YOK. Flutter simulator icin AOT derlemiyor;
 *      hem `--release` hem `--profile` "not supported for simulators"
 *      diyip cikiyor. Simulatorde tek secenek debug build.
 *
 *      Bu bir sorun DEGIL: debug banner'i endiselenecek sey olurdu,
 *      ama iki MaterialApp da debugShowCheckedModeBanner: false
 *      veriyor (main.dart:114 ve main.dart:157), yani ekranda banner
 *      yok. `goldie doctor` bu build'i "release build" diye
 *      etiketliyor; etiket yaniltici, cikti temiz.
 *
 *   2) Her komut config yolunu ortam degiskeninden okuyor:
 *        export GOLDIE_CONFIG=$PWD/goldie/goldie.config.ts
 *        npx -y goldie@0 doctor
 *        npx -y goldie@0 capture && npx -y goldie@0 frame
 *        npx -y goldie@0 studio            # http://localhost:4321
 *
 * AKISLAR: .argent/flows/store-*.yaml — 2026-09-09'da iPhone 17 Pro Max
 * simulatorunde gezilerek yazildi ve oynatildi.
 *
 * Akislarda METIN SECICI YOK, koordinat var. Sebep: ayni akis dort
 * yerel icin ayri ayri oynatiliyor ve cihaz dili bos kurulumda
 * uygulamaya geciyor (settings_provider.dart:92). "Hesabım" secicisi
 * tr kosusunda bulunur, en/de/es kosusunda bulunmaz. Arayuz duzeni
 * dort dilde ayni oldugu icin koordinat calisiyor; her koordinatin
 * ustunde neyi hedefledigini soyleyen bir echo var.
 */
const APP_ROOT = "/Users/fatihozcan/devkom_build";

const config: GoldieConfig = {
  appRoot: APP_ROOT,
  appPath: `${APP_ROOT}/build/ios/iphonesimulator/Runner.app`,
  bundleId: "com.devkom.app",

  // Apple 6.9" (1320x2868) zorunlu; digerleri bundan turetiliyor.
  devices: ["iphone-6.9"],

  // Uygulamanin arayuzu dort dilde tam. Ders GOVDE metni Almanca ve
  // Ispanyolca'da henuz yok, Ingilizceye dusuyor — bu yuzden o iki
  // dilin slaytlarinda ders ekrani degil oyun/quiz ekranlari one
  // cikariliyor (bkz. sahne siralamasi).
  locales: ["tr-TR", "en-US", "de-DE", "es-ES"],
  appearance: "light",

  frame: { variant: "17-pro-blue" },

  theme: {
    // Uygulamanin kendi acik temasiyla uyumlu, yumusak mavi-beyaz.
    background:
      "linear-gradient(160deg, #EEF2FF 0%, #F6F9FF 55%, #FFFFFF 100%)",
    headlineColor: "#14213D",
    subheadColor: "#5F7085",
    fontFamily: '"DM Sans", -apple-system, "SF Pro Display", system-ui, sans-serif',
    copyHeightRatio: 0.24,
    deviceWidthRatio: 0.84,
    // Ilk kare panorama, sonra hero/offset/nefes/tilt.
    template: "editorial",
    layout: "classic",
    // ROZET YOK — bilerek. "Editors' Choice" gibi bir rozet bize
    // verilmedi; uydurma rozet App Store Kural 2.3.1'e giriyor.
    // Odul kazanildiginda buraya gercek rozet eklenir.
  },

  store: {
    name: "DevEducation",
    subtitle: {
      "tr-TR": "Çocuklar için kodlama",
      "en-US": "Coding & robotics for kids",
      "de-DE": "Programmieren für Kinder",
      "es-ES": "Programación para niños",
    },
    developer: "DevEducation",
    category: "Education",
    // rating/ratingCount yalnizca studio onizlemesinde gorunuyor,
    // magazaya gitmiyor. Yine de uydurma bir puan yazmiyoruz:
    // uygulama henuz yayinda degil.
    rating: 0,
    ratingCount: "Henüz puan yok",
    ageRating: "4+",
    price: "Free",
    description: {
      "tr-TR":
        "DevEducation renkli bloklarla başlar, çocuğunuz gerçek kod yazarak bitirir. Dokuz kurs, on altı mini oyun ve her sorudan sonra açıklama.",
      "en-US":
        "DevEducation starts with coloured blocks and ends with your child writing real code. Nine courses, sixteen mini games, an explanation after every question.",
      "de-DE":
        "DevEducation beginnt mit bunten Blöcken und endet damit, dass Ihr Kind echten Code schreibt. Neun Kurse, sechzehn Minispiele, nach jeder Frage eine Erklärung.",
      "es-ES":
        "DevEducation empieza con bloques de colores y termina con tu hijo escribiendo código de verdad. Nueve cursos, dieciséis minijuegos y una explicación tras cada pregunta.",
    },
  },

  scenes: [
    {
      kind: "screenshot",
      id: "bloklar",
      flow: "store-01-bloklar",
      headline: {
        "tr-TR": "Bloklarla başlar",
        "en-US": "Starts with blocks",
        "de-DE": "Beginnt mit Blöcken",
        "es-ES": "Empieza con bloques",
      },
      subhead: {
        "tr-TR": "Scratch, mBlock ve gerçek Arduino — 9 kurs, 6–14 yaş",
        "en-US": "Scratch, mBlock and a real Arduino — 9 courses, ages 6–14",
        "de-DE": "Scratch, mBlock und echter Arduino — 9 Kurse, 6–14 Jahre",
        "es-ES": "Scratch, mBlock y Arduino real — 9 cursos, 6–14 años",
      },
    },
    {
      kind: "screenshot",
      id: "ilk-gorev",
      flow: "store-02-ilk-gorev",
      headline: {
        "tr-TR": "İlk görevini ilk dakikada çözer",
        "en-US": "Solves the first task in the first minute",
        "de-DE": "Löst die Aufgabe in der ersten Minute",
        "es-ES": "Su primera tarea, en el primer minuto",
      },
      subhead: {
        "tr-TR": "Anlatı yok — dokun, dene, gör",
        "en-US": "No lecture — tap, try, see what happens",
        "de-DE": "Kein Vortrag — tippen, ausprobieren, sehen",
        "es-ES": "Sin discursos: toca, prueba y mira",
      },
    },
    {
      kind: "screenshot",
      id: "oyun",
      flow: "store-03-oyun",
      headline: {
        "tr-TR": "Oyunla pekiştirir",
        "en-US": "Practises by playing",
        "de-DE": "Übt beim Spielen",
        "es-ES": "Practica jugando",
      },
      subhead: {
        "tr-TR": "16 mini oyun · terimleri eşleştir, komutları sırala",
        "en-US": "16 mini games · match terms, order commands",
        "de-DE": "16 Minispiele · Begriffe zuordnen, Befehle ordnen",
        "es-ES": "16 minijuegos · empareja términos, ordena instrucciones",
      },
    },
    {
      kind: "screenshot",
      id: "quiz",
      flow: "store-04-quiz",
      headline: {
        "tr-TR": "Gerçek kodu okur",
        "en-US": "Reads real code",
        "de-DE": "Liest echten Code",
        "es-ES": "Lee código de verdad",
      },
      // "her sorudan sonra aciklama" IDDIASI KALDIRILDI: quiz'de aciklama
      // kendiliginden cikmiyor, "Ipucu"na basilinca aciliyor
      // (quiz_screen.dart:149) ve sonuc ekraninda yalnizca YANLIS
      // cevaplar aciklaniyor (quiz_screen.dart:986). Puan yuzde olarak
      // hesaplaniyor (quiz_screen.dart:648), yanlistan dusen bir sey yok
      // — o yuzden ikinci yari oldugu gibi kaldi.
      subhead: {
        "tr-TR": "Takılırsan ipucu bir dokunuş uzakta · yanlış cevap puan kaybettirmez",
        "en-US": "A hint is one tap away when stuck · a wrong answer never costs points",
        "de-DE": "Ein Tipp ist einen Fingertipp entfernt · eine falsche Antwort kostet nie Punkte",
        "es-ES": "Una pista a un toque cuando se atasca · fallar nunca resta puntos",
      },
    },
    {
      kind: "screenshot",
      id: "karakter",
      flow: "store-05-karakter",
      headline: {
        "tr-TR": "Öğrendikçe jeton kazanır",
        "en-US": "Earns coins as they learn",
        "de-DE": "Verdient Münzen beim Lernen",
        "es-ES": "Gana monedas mientras aprende",
      },
      subhead: {
        "tr-TR": "Beş karakter · kazanılan onlarca şapka, gözlük, ayakkabı",
        "en-US": "Five characters · dozens of hats, glasses and shoes to earn",
        "de-DE": "Fünf Figuren · Dutzende Hüte, Brillen und Schuhe",
        "es-ES": "Cinco personajes · decenas de gorros, gafas y zapatos",
      },
    },

    {
      kind: "preview",
      id: "preview",
      // Tek bir yolculuk: uygulamayi ac -> sana gore ayarla -> oyunlari
      // gor -> ilk soruyu coz. Quiz segmenti CIKARILDI: quiz'e varmak
      // Etkinlikler > Bilgi yarismasi > Gec > Oyna > iki cevap ediyor,
      // 30 saniyelik videoya sigmiyor. Quiz zaten 4. slaytta duruyor.
      segments: [
        { id: "acilis", flow: "store-preview-01-acilis", holdSeconds: 1 },
        { id: "kurulum", flow: "store-preview-02-kurulum", holdSeconds: 1 },
        { id: "oyun", flow: "store-preview-03-oyun", holdSeconds: 1 },
        { id: "ilk-gorev", flow: "store-preview-04-ilk-gorev", holdSeconds: 2 },
      ],
    },
  ],
};

export default config;
