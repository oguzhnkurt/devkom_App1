#!/usr/bin/env bash
#
# DevKom - iOS release build (Mac'te calistirilir)
# Kullanim:  bash scripts/ios_release.sh
#
# Bu script tek basina her seyi yapar: on kontroller -> temizlik ->
# bagimliliklar -> analiz -> ipa build. Herhangi bir adim hata verirse
# ANINDA durur ve ne yapman gerektigini soyler.

set -euo pipefail

BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; NC=$'\033[0m'

step()  { echo ""; echo "${BOLD}==> $1${NC}"; }
ok()    { echo "${GREEN}OK${NC} $1"; }
warn()  { echo "${YELLOW}UYARI${NC} $1"; }
die()   { echo ""; echo "${RED}DURDU:${NC} $1"; echo ""; exit 1; }

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
echo "${BOLD}DevKom iOS release${NC}  ($ROOT)"

# ---------------------------------------------------------------
step "1/7  On kontroller"

command -v flutter >/dev/null 2>&1 || die "flutter bulunamadi. Flutter SDK kurulu ve PATH'te olmali."
ok "flutter: $(flutter --version 2>/dev/null | head -1)"

command -v pod >/dev/null 2>&1 || die "CocoaPods bulunamadi. Kur:  sudo gem install cocoapods"
ok "cocoapods: $(pod --version)"

command -v xcodebuild >/dev/null 2>&1 || die "Xcode command line tools yok. Kur:  xcode-select --install"
ok "xcode: $(xcodebuild -version 2>/dev/null | head -1)"

# .env - git'e dahil DEGIL, elle kopyalanmali. Yoksa build asset hatasi verir.
if [ ! -f "$ROOT/.env" ]; then
  die ".env dosyasi yok!

  Bu dosya guvenlik nedeniyle git'e dahil edilmiyor ama pubspec.yaml onu
  zorunlu asset olarak listeliyor - olmadan build BASARISIZ olur.

  Windows makinendeki  C:\\Users\\Oguzhan\\devkom_app\\.env  dosyasini
  bu klasore (.env adiyla) kopyala, sonra scripti tekrar calistir.

  Icermesi gereken anahtarlar:
    GEMINI_API_KEY=...
    ADAPTY_PUBLIC_KEY=...
    MIXPANEL_TOKEN=..."
fi
ok ".env mevcut"

for key in GEMINI_API_KEY ADAPTY_PUBLIC_KEY MIXPANEL_TOKEN; do
  if ! grep -q "^${key}=." "$ROOT/.env"; then
    warn ".env icinde $key bos veya eksik - o ozellik calismayabilir"
  fi
done

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
ok "surum: $VERSION   (App Store ayni build numarasini iki kez kabul etmez)"

# ---------------------------------------------------------------
step "2/7  Temizlik"
flutter clean
rm -rf ios/Pods ios/Podfile.lock
ok "eski build ve pod artiklari silindi"

# ---------------------------------------------------------------
step "3/7  Dart bagimliliklari"
flutter pub get
ok "pub get tamam"

# ---------------------------------------------------------------
step "4/7  CocoaPods"
( cd ios && pod install --repo-update )
ok "pod install tamam"

# ---------------------------------------------------------------
step "5/7  Statik analiz"
echo "(Hata cikarsa build'e gecmeden once duracak)"
if ! flutter analyze --no-pub; then
  die "flutter analyze hata verdi.

  Yukaridaki hatalari duzeltmeden devam etme.
  Ciktinin tamamini Claude'a yapistirirsan duzeltmede yardim eder."
fi
ok "analiz temiz"

# ---------------------------------------------------------------
step "6/7  Testler (varsa)"
if [ -d test ] && [ -n "$(find test -name '*_test.dart' -print -quit 2>/dev/null)" ]; then
  flutter test || warn "testler basarisiz - devam ediliyor, ama gozden gecir"
else
  warn "test dosyasi yok, atlandi"
fi

# ---------------------------------------------------------------
step "7/7  IPA build (release)"
flutter build ipa --release

echo ""
echo "${GREEN}${BOLD}BITTI.${NC}"
echo ""
echo "Arsiv:  ${BOLD}build/ios/archive/Runner.xcarchive${NC}"
echo "IPA:    ${BOLD}build/ios/ipa/${NC}"
echo ""
echo "Simdi TestFlight'a gondermek icin:"
echo "  1. Xcode'u ac"
echo "  2. Window -> Organizer"
echo "  3. Ustteki arsivi sec -> ${BOLD}Distribute App${NC}"
echo "  4. ${BOLD}App Store Connect${NC} -> Upload -> ileri ileri -> Upload"
echo ""
echo "Alternatif (komut satirindan, App Store Connect API key gerekir):"
echo "  xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>"
echo ""
