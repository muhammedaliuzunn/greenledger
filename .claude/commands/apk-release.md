---
name: apk-release
description: GreenLedger APK release checklist — build, optimize, and verify before sharing
---

# /apk-release — APK Yayın Kontrol Listesi

GreenLedger APK'sını yayına hazırlamak için adım adım kontrol et.

## 1. Kod Kontrol
- [ ] Tüm `print()` ve debug log'ları kaldırıldı
- [ ] `flutter analyze` sıfır hata/uyarı
- [ ] Tüm TODO'lar gözden geçirildi
- [ ] API anahtarları hardcode değil (environment variable)

## 2. Versiyon Güncelle
`pubspec.yaml` dosyasında:
```yaml
version: X.Y.Z+BUILD_NUMBER
# Örn: 1.2.0+5
```

## 3. Build
```bash
# Küçük APK (ABI başına ayrı)
flutter build apk --split-per-abi --release

# Tek APK (evrensel)
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/`

## 4. Test
- [ ] Release APK gerçek cihazda çalıştırıldı
- [ ] Ana akışlar test edildi (login, veri görüntüleme, grafik)
- [ ] Yavaş cihazda performans kabul edilebilir

## 5. Boyut Kontrolü
```bash
flutter build apk --analyze-size --release
```
Hedef: <30MB (split-per-abi ile)

## 6. Yayın
- Direkt paylaşım: `app-arm64-v8a-release.apk` dosyasını ilet
- Play Store: `flutter build appbundle --release` → `.aab` dosyası

Şimdi hangi adımda yardım lazım?
