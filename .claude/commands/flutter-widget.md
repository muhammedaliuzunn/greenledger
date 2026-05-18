---
name: flutter-widget
description: Create a new Flutter widget following GreenLedger conventions — stateless, stateful, or provider-connected
---

# /flutter-widget — Widget Oluştur

GreenLedger kodlama standartlarına uygun widget oluştur.

## Kullanım
```
/flutter-widget [widget adı] [tip: stateless|stateful|provider]
```

## Örnekler
- `/flutter-widget TransactionCard stateless`
- `/flutter-widget BalanceChart provider`
- `/flutter-widget AddExpenseForm stateful`

## Oluşturulacak widget şu kurallara uyar:
1. `const` constructor (stateless ise)
2. `lib/widgets/` klasörüne kaydet, dosya adı `snake_case_widget.dart`
3. Provider bağlantısı için `context.watch<>()` / `context.read<>()` doğru kullanımı
4. Dispose edilmesi gereken controller'lar için `dispose()` override
5. Yükleme durumu için `shimmer` paketi hazır
6. Animasyon için `flutter_animate` kullan
7. `Semantics` label ikonlu butonlara ekle (erişilebilirlik)

## Widget oluştururken şunu söyle:
"Widget ne işe yarıyor ve hangi veriyi gösteriyor?"
