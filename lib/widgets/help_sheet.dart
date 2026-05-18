import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

void showHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const HelpSheet(),
  );
}

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  static const _items = [
    _HelpItem(
      icon: Icons.dashboard_outlined,
      title: 'Ana Sayfa',
      description:
          'Mağazanızın GreenScore\'unu ve eko performansını takip edin. Satıcı rolünde kendi mağazanızı, alıcı rolünde tüm platform özetini görün.',
    ),
    _HelpItem(
      icon: Icons.store_outlined,
      title: 'Satıcılar',
      description:
          'Tüm satıcılarınızı görüntüleyin, arama yapın, platforma ve skora göre filtreleyin. "Ekle" butonuyla yeni satıcı ekleyin; karta uzun basınca silme seçeneği çıkar.',
    ),
    _HelpItem(
      icon: Icons.leaderboard_outlined,
      title: 'Sıralama',
      description:
          'GreenScore, ciro, müşteri memnuniyeti ve iade oranına göre satıcıları karşılaştırın. "AI Tavsiye" butonuna basarak o satıcıya özel öneri alın.',
    ),
    _HelpItem(
      icon: Icons.credit_card_outlined,
      title: 'Kredi & Faktoring',
      description:
          'Tüm kredi ve faktoring başvurularını listeleyin. Başvuruları türe göre (Kredi / Faktoring) sekmeleriyle filtreleyin.',
    ),
    _HelpItem(
      icon: Icons.psychology_outlined,
      title: 'AI Danışman',
      description:
          'Üstten bir satıcı seçin, ardından sekmelerden analiz türünü belirleyin: GreenScore analizi, kredi riski, AI koç sohbeti, aylık rapor veya 90 günlük yol haritası.',
    ),
    _HelpItem(
      icon: Icons.account_circle_outlined,
      title: 'Hesabım',
      description:
          'Rolünüzü değiştirin, koyu/aydınlık mod arasında geçiş yapın, bildirim tercihlerinizi yönetin ve hesap ayarlarınıza ulaşın.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.help_outline, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('Nasıl Kullanılır',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          Text('Her ekranın kısa açıklaması',
              style: TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 16),
          ..._items.map((item) => _HelpTile(item: item)),
        ],
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _HelpTile extends StatelessWidget {
  final _HelpItem item;
  const _HelpTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
