import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'models.dart';

class AppBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool earned;

  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
  });
}

class BadgeService {
  static String getTitle(Seller seller) {
    if (seller.greenScore >= 90) return 'Çevre Şampiyonu';
    if (seller.greenScore >= 80) return 'Yeşil Lider';
    if (seller.greenScore >= 70) return 'Eko Satıcı';
    if (seller.greenScore >= 60) return 'Sürdürülebilir';
    if (seller.greenScore >= 40) return 'Gelişmekte';
    return 'Başlangıç';
  }

  static Color getTitleColor(double greenScore) {
    if (greenScore >= 80) return AppTheme.primary;
    if (greenScore >= 60) return AppTheme.accent;
    return AppTheme.destructive;
  }

  static List<AppBadge> getBadges(Seller seller) {
    return [
      AppBadge(
        id: 'eco_pioneer',
        title: 'Yeşil Öncü',
        description: 'Eko paket ve yeşil kargo kullanıyor',
        icon: Icons.eco,
        color: AppTheme.primary,
        earned: seller.ecoPackaging && seller.ecoLogistics,
      ),
      AppBadge(
        id: 'green_master',
        title: 'GreenScore Ustası',
        description: 'GreenScore 80 üzerinde',
        icon: Icons.military_tech,
        color: const Color(0xFF16A34A),
        earned: seller.greenScore >= 80,
      ),
      AppBadge(
        id: 'carbon_warrior',
        title: 'Karbon Savaşçısı',
        description: 'Aylık CO₂ 200kg altında',
        icon: Icons.cloud_outlined,
        color: const Color(0xFF0EA5E9),
        earned: seller.carbonEmission < 200,
      ),
      AppBadge(
        id: 'customer_champion',
        title: 'Müşteri Dostu',
        description: 'Müşteri memnuniyeti 4.5 üzeri',
        icon: Icons.favorite,
        color: const Color(0xFFEC4899),
        earned: seller.customerSatisfaction >= 4.5,
      ),
      AppBadge(
        id: 'return_hero',
        title: 'İade Şampiyonu',
        description: 'İade oranı %3 altında',
        icon: Icons.verified,
        color: AppTheme.accent,
        earned: seller.returnRate < 3,
      ),
      AppBadge(
        id: 'eco_packaging',
        title: 'Eko Paket',
        description: 'Çevreci ambalaj kullanıyor',
        icon: Icons.recycling,
        color: const Color(0xFF0D9488),
        earned: seller.ecoPackaging,
      ),
      AppBadge(
        id: 'green_logistics',
        title: 'Yeşil Kargo',
        description: 'Düşük karbonlu lojistik',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF7C3AED),
        earned: seller.ecoLogistics,
      ),
      AppBadge(
        id: 'stock_speed',
        title: 'Hız Ustası',
        description: 'Stok devir hızı 10 günün altında',
        icon: Icons.flash_on,
        color: const Color(0xFFCA8A04),
        earned: seller.stockVelocity < 10,
      ),
    ];
  }

  static int earnedCount(Seller seller) =>
      getBadges(seller).where((b) => b.earned).length;
}
