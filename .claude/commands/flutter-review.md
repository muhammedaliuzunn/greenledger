---
name: flutter-review
description: Flutter-specific code review for GreenLedger — performance, state management, Android compatibility
---

# /flutter-review — Flutter Kod İncelemesi

Belirtilen dosya veya klasörü Flutter + Android APK perspektifiyle incele.

## Kullanım
```
/flutter-review [dosya yolu veya klasör]
/flutter-review lib/screens/home_screen.dart
/flutter-review lib/widgets/
```

## İnceleme Kriterleri

### Performans
- Gereksiz rebuild var mı? (`const` eksikliği)
- `ListView` içinde `Column` ile sonsuz liste var mı?
- Büyük listeler `ListView.builder` kullanıyor mu?
- `RepaintBoundary` gereken animasyonlar izole mi?

### State Management (Provider)
- `context.watch` yerine `context.read` yanlış yerde kullanılıyor mu?
- Widget içinde iş mantığı var mı? (service'e taşınmalı)
- `ChangeNotifier` gereksiz `notifyListeners()` çağırıyor mu?

### Memory & Lifecycle
- `TextEditingController`, `AnimationController`, `ScrollController` dispose ediliyor mu?
- `async` işlemlerde `mounted` kontrolü var mı?
- Stream subscription iptal ediliyor mu?

### Android / APK Uyumu
- Platform spesifik kod (`dart:io`) doğru `Platform.isAndroid` koruması altında mı?
- İzinler `AndroidManifest.xml`'de tanımlı mı?
- Minimum SDK uyumlu API kullanılıyor mu?

### Material Design 3
- Sabit renkler yerine `Theme.of(context).colorScheme` kullanılıyor mu?
- Butonlar Material 3 bileşenleri mi? (FilledButton, OutlinedButton)
- Tap target 48dp minimum mi?

## Çıktı Formatı
Her sorun için: **Ne** | **Neden önemli** | **Nasıl düzeltilir** + kod örneği
