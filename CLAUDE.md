# GreenLedger App — Claude Rehberi

## Proje Hakkında
**GreenLedger** — Sürdürülebilir Finans Platformu  
Flutter ile geliştirilmiş, APK hedefli Android uygulaması.

## Tech Stack
- **Framework:** Flutter (Dart, SDK >=3.0.0)
- **State Management:** Provider
- **Grafikler:** fl_chart
- **Fontlar:** Google Fonts
- **Animasyonlar:** flutter_animate, shimmer
- **Depolama:** shared_preferences
- **HTTP:** http paketi
- **ID:** uuid, intl

## Klasör Yapısı
```
lib/
├── main.dart          # Uygulama giriş noktası
├── models/            # Veri modelleri
├── screens/           # Ekranlar (UI)
├── services/          # API ve iş mantığı
├── theme/             # Renkler, fontlar, temalar
└── widgets/           # Yeniden kullanılabilir bileşenler
```

## Kod Standartları
- Widget'ları küçük ve tek sorumluluklu tut
- Provider ile state yönet, widget içinde iş mantığı yazma
- const constructor kullan her yerde mümkünse
- Ekran isimlerini `_screen.dart`, widget'ları `_widget.dart` ile bitir
- Model dosyaları `fromJson` / `toJson` içermeli

## Flutter Best Practices
- `setState` yerine Provider kullan (services/models değiştiğinde)
- `BuildContext` async gap'ten sonra kullanma (mounted kontrolü)
- `ListView.builder` kullan, `ListView` içinde `Column` değil
- Animasyonlarda `flutter_animate` paketin mevcut, kullan
- Yükleme durumlarında `shimmer` paketi kullan

## APK Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split ABI (daha küçük dosya boyutu)
flutter build apk --split-per-abi --release
```

---

# Aktif Skill'ler

## 1. Flutter Code Review
Kod incelerken şunlara odaklan:
- Widget rebuild performansı (const, keys)
- Provider misuse (context.watch vs context.read)
- Memory leak riski (controller dispose)
- Null safety uyumu
- Platform spesifik davranışlar (Android APK)

## 2. ASO (App Store Optimization) — Google Play
GreenLedger'ı Play Store'a çıkarırken:

**Başlık formülü:** `[Marka] - [Ana Keyword] [İkincil Keyword]`  
- Karakter limiti: 50 (Google Play)
- Öneri: "GreenLedger - Sürdürülebilir Finans Takip"

**Kısa Açıklama** (80 karakter):
- Ana faydayı öne çıkar, eylem fiili kullan
- Öneri: "Harcamalarını takip et, sürdürülebilir finansal alışkanlıklar kazan."

**Tam Açıklama Yapısı:**
1. Hook (kullanıcı sorununu yakala)
2. Özellikler (madde madde)
3. Sosyal kanıt
4. CTA

**Screenshot İpuçları:**
- İlk screenshot'ta değer önerisini göster (UI değil)
- Her screenshot'ta başlık + kısa açıklama
- Yeşil/sürdürülebilirlik teması tutarlı olsun

## 3. Material Design 3 (Android HIG)
Flutter APK için Android tasarım rehberi:

**Renk Sistemi:**
- `ColorScheme.fromSeed()` kullan — Material 3 dinamik renk
- Surface, primary, secondary semantic renkleri kullan
- Sabit hex kodlardan kaçın (tema desteği için)

**Typography:**
- `TextTheme` kullan, serbest `TextStyle` yazma
- Google Fonts entegrasyonu mevcut — tutarlı kullan

**Bileşen Öncelikleri:**
- `NavigationBar` → Alt navigasyon (Material 3)
- `Card` → Elevated veya Filled variant
- `FilledButton`, `OutlinedButton`, `TextButton`
- Minimum tap target: 48x48dp (Android standartı)

**Erişilebilirlik:**
- `Semantics` widget'ı ikonlu butonlara ekle
- `Tooltip` her icon button'da olsun
- Kontrast oranı min 4.5:1

## 4. Performance Checklist (APK için)
- `flutter build apk --split-per-abi` — ABI başına ayrı APK (boyutu %60 küçültür)
- `const` widget'lar = sıfır rebuild maliyeti
- `RepaintBoundary` — karmaşık animasyonları izole et
- `ListView.builder` — büyük listeler için lazy loading
- Görsel assets: WebP formatı, boyutlandırılmış (@1x, @2x, @3x)
- ProGuard/R8 aktif (release build'de varsayılan)
