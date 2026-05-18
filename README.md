# GreenLedger — Sürdürülebilir Finans Platformu

> **Hackathon projesi** · Flutter · Gemini AI · Android

GreenLedger, e-ticaret satıcılarının sürdürülebilirlik performansını ölçen, yapay zeka destekli kredi ve finansman kararları sunan bir fintech platformudur. Yeşil iş yapış biçimlerini teşvik ederek çevresel etkiyi azaltmayı ve finansal erişimi artırmayı hedefler.

---

## Temel Özellikler

### GreenScore Sistemi
Satıcıların çevresel performansını 0–100 arası puanlayan dinamik skor:
- Eko ambalaj (+15 puan)
- Yeşil lojistik (+20 puan)
- İade oranı (−1.5× oran)
- Müşteri memnuniyeti & mağaza puanı
- Stok devir hızı

GreenScore doğrudan **faiz oranını** (%0.8–%2.4) ve **kredi limitini** belirler.

### AI Danışman (Gemini 2.5 Flash)
Satıcı bazlı 5 farklı AI analizi:

| Sekme | İçerik |
|-------|--------|
| GreenScore | Güçlü/zayıf yönler, tahmini skor artışı |
| Kredi Riski | Risk skoru, kredi kararı, 6 aylık tahmin |
| AI Koç | Gerçek zamanlı sohbet, pratik tavsiyeler |
| Aylık Rapor | Performans özeti ve öneriler |
| 90 Günlük Harita | Adım adım sürdürülebilirlik yol haritası |

### Rozet Sistemi
8 farklı başarı rozeti:

| Rozet | Koşul |
|-------|-------|
| Yeşil Öncü | Eko paket + yeşil kargo |
| GreenScore Ustası | Skor ≥ 80 |
| Karbon Savaşçısı | CO₂ < 200 kg/ay |
| Müşteri Dostu | Memnuniyet ≥ 4.5 |
| İade Şampiyonu | İade oranı < %3 |
| Eko Paket | Çevreci ambalaj |
| Yeşil Kargo | Düşük karbonlu lojistik |
| Hız Ustası | Stok devir < 10 gün |

### Diğer Özellikler
- **Dashboard** — Toplam ciro, ortalama GreenScore, karbon ayak izi, kullandırılan kredi tutarı
- **Satıcı Yönetimi** — Platform filtresi (Trendyol, Amazon, Hepsiburada, N11, Etsy), arama, sıralama
- **Sıralama Tablosu** — GreenScore / Ciro / Müşteri Memnuniyeti / İade bazlı rekabet
- **Kredi & Faktoring** — Başvuru takibi, tür ve durum filtreleri
- **PDF Rapor** — Satıcı bazlı rapor çıktısı
- **Bildirimler** — Kredi hazır ve GreenScore milestone uyarıları
- **Hamburger Menü** — Hızlı filtreler (min GreenScore, Eco-only), dil seçimi (TR/EN), yardım
- **Karanlık / Aydınlık Mod**
- **Satıcı / Alıcı Rolü** — Rol bazlı farklı arayüz

---

## Teknik Mimari

```
lib/
├── main.dart              # Uygulama girişi, navigasyon, hamburger menü
├── models/
│   ├── models.dart        # Seller, CreditApplication veri modelleri
│   └── badge_model.dart   # Rozet sistemi
├── screens/
│   ├── dashboard_screen.dart
│   ├── sellers_screen.dart
│   ├── leaderboard_screen.dart
│   ├── credits_screen.dart
│   ├── ai_advisor_screen.dart
│   ├── portfolio_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── gemini_service.dart    # Gemini 2.5 Flash entegrasyonu
│   ├── data_service.dart      # Yerel veri yönetimi
│   ├── notification_service.dart
│   └── pdf_service.dart
├── theme/
│   └── app_theme.dart         # Material 3, dark/light tema
└── widgets/
    ├── common_widgets.dart
    └── help_sheet.dart
```

### Kullanılan Teknolojiler

| Kategori | Paket |
|----------|-------|
| State Management | `provider` |
| AI | `http` → Google Gemini 2.5 Flash API |
| Grafikler | `fl_chart` |
| Fontlar | `google_fonts` (Space Grotesk) |
| Animasyon | `flutter_animate`, `shimmer` |
| Depolama | `shared_preferences` |
| PDF | `pdf`, `printing` |
| Bildirimler | `flutter_local_notifications` |
| Tarih/ID | `intl`, `uuid` |

---

## Kurulum

### Gereksinimler
- Flutter SDK ≥ 3.0.0
- Android SDK (min API 21 / Android 5.0)
- Google Gemini API anahtarı

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/<kullanici>/greenledger.git
cd greenledger

# 2. Bağımlılıkları yükle
flutter pub get

# 3. API anahtarını ayarla
# lib/services/gemini_service.dart dosyasında:
# static const String _apiKey = 'SENIN_API_KEY';

# 4. Debug APK çalıştır
flutter run

# 5. Release APK oluştur
flutter build apk --split-per-abi --release
```

### APK İndir

| Mimari | Dosya | Hedef |
|--------|-------|-------|
| arm64-v8a | `app-arm64-v8a-release.apk` | Modern Android (önerilir) |
| armeabi-v7a | `app-armeabi-v7a-release.apk` | Eski cihazlar |
| x86_64 | `app-x86_64-release.apk` | Emülatör |

---

## GreenScore → Faiz Oranı Tablosu

| GreenScore | Faiz Oranı | Kredi Çarpanı |
|:----------:|:----------:|:-------------:|
| 90–100 | %0.8 | 0.66× aylık ciro |
| 70–89 | %1.2 | 0.58× aylık ciro |
| 50–69 | %1.8 | 0.50× aylık ciro |
| 0–49 | %2.4 | 0.30× aylık ciro |

---

## Neden GreenLedger?

E-ticaret sektöründe sürdürülebilirlik genellikle **maliyet kalemi** olarak görülür. GreenLedger bunu **finansal avantaja** dönüştürür: çevreci davranan satıcı daha düşük faizle kredi alır. Bu yaklaşım hem çevresel etkiyi azaltır hem de satıcıların finansal kararlarını yeşil kriterlere göre şekillendirmesini teşvik eder.

---

## Takım — DATALIM

| İsim | Rol |
|------|-----|
| Muhammed Ali Uzun | Geliştirici |
| Bahar Direk | Geliştirici |
| Abdullah Alagöz | Geliştirici |

---

## Lisans

MIT © 2025 DATALIM
