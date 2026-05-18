import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/badge_model.dart';
import '../services/data_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Seller> _sellers = [];
  List<CreditApplication> _credits = [];
  bool _loading = true;
  List<Map<String, dynamic>> _notifications = [];
  String _role = 'seller';

  double _totalRevenue = 0;
  double _avgGreenScore = 0;
  double _totalCarbon = 0;
  int _activeSellers = 0;
  double _disbursedAmount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sellers = await DataService.getSellers();
    final credits = await DataService.getCreditApplications();
    if (mounted) {
      setState(() {
        _role = prefs.getString('user_role') ?? 'seller';
        _sellers = sellers;
        _credits = credits;
        _loading = false;
        _notifications = _buildNotifications(sellers);
        _totalRevenue = sellers.fold(0, (s, sel) => s + sel.monthlyRevenue);
        _avgGreenScore = sellers.isEmpty ? 0 : sellers.fold(0.0, (s, sel) => s + sel.greenScore) / sellers.length;
        _totalCarbon = sellers.fold(0.0, (s, sel) => s + sel.carbonEmission);
        _activeSellers = sellers.where((s) => s.status == 'active').length;
        _disbursedAmount = credits.where((c) => c.status == 'disbursed').fold(0.0, (s, c) => s + c.amount);
      });
      _checkAndNotify(sellers, credits);
    }
  }

  Future<void> _checkAndNotify(List<Seller> sellers, List<CreditApplication> credits) async {
    for (final s in sellers) {
      if (s.greenScore >= 80) {
        await NotificationService.showGreenScoreAlert(s.name, s.greenScore.toInt());
        break;
      }
    }
    for (final c in credits) {
      if (c.status == 'disbursed') {
        await NotificationService.showCreditDisbursed(c.sellerName, c.amount);
        break;
      }
    }
  }

  List<Map<String, dynamic>> _buildNotifications(List<Seller> sellers) {
    final List<Map<String, dynamic>> notifs = [];
    for (final s in sellers) {
      if (s.greenScore >= 70 && s.creditLimit > 0) {
        notifs.add({
          'type': 'credit',
          'message': '${s.name}: ₺${(s.creditLimit / 1000).toStringAsFixed(0)}K kredi hazır! Faiz: %${s.interestRate}',
          'color': AppTheme.primary,
          'icon': Icons.credit_card,
        });
      }
      if (s.greenScore >= 80) {
        notifs.add({
          'type': 'green',
          'message': '${s.name} Mükemmel GreenScore\'a ulaştı: ${s.greenScore.toInt()}!',
          'color': AppTheme.accent,
          'icon': Icons.eco,
        });
      }
    }
    return notifs.take(3).toList();
  }

  Seller? get _myStore =>
      _sellers.isNotEmpty ? _sellers.first : null;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget(message: 'Veriler yükleniyor...');

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_role == 'seller') ...[
              _SellerWelcomeBanner(store: _myStore),
              const SizedBox(height: 20),
              if (_myStore != null) ...[
                _MyStoreBanner(store: _myStore!),
                const SizedBox(height: 12),
                _BadgesSection(store: _myStore!),
                const SizedBox(height: 20),
              ],
            ] else ...[
              _BuyerWelcomeBanner(),
              const SizedBox(height: 20),
            ],

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Karbon Takip
            SectionHeader(
                title: 'Karbon Takip',
                subtitle: 'Türkiye e-ticaret karbon izi'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CarbonMetric(
                            label: 'Toplam CO₂',
                            value: '${(_totalCarbon / 1000).toStringAsFixed(1)}t',
                            icon: Icons.cloud_outlined),
                        _CarbonMetric(
                            label: 'Eko Paket',
                            value: '${_sellers.where((s) => s.ecoPackaging).length}/${_sellers.length}',
                            icon: Icons.recycling),
                        _CarbonMetric(
                            label: 'Yeşil Kargo',
                            value: '${_sellers.where((s) => s.ecoLogistics).length}/${_sellers.length}',
                            icon: Icons.local_shipping_outlined),
                        _CarbonMetric(
                            label: 'Ağaç',
                            value: '${(_totalCarbon / 21).toInt()}',
                            icon: Icons.park),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      child: SizedBox(
                        height: 100,
                        child: BarChart(
                          BarChartData(
                            barGroups: _sellers
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) => BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: e.value.carbonEmission / 100,
                                          color: e.value.ecoPackaging && e.value.ecoLogistics
                                              ? AppTheme.primary
                                              : AppTheme.destructive.withOpacity(0.7),
                                          width: 16,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    ))
                                .toList(),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final idx = v.toInt();
                                    if (idx < _sellers.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _sellers[idx].name.split(' ')[0],
                                          style: const TextStyle(
                                              fontSize: 8, color: AppTheme.muted),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(color: AppTheme.primary, label: 'Eko Satıcı'),
                        const SizedBox(width: 16),
                        _LegendDot(
                            color: AppTheme.destructive.withOpacity(0.7),
                            label: 'Standart'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ciro Trendi
            SectionHeader(
                title: 'Ciro & Karbon Trendi', subtitle: 'Son 6 ay'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  child: SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppTheme.border, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              const months = [
                                'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz'
                              ];
                              if (value.toInt() < months.length) {
                                return Text(months[value.toInt()],
                                    style: const TextStyle(
                                        fontSize: 9, color: AppTheme.muted));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2.4), FlSpot(1, 2.8),
                            FlSpot(2, 3.2), FlSpot(3, 3.6),
                            FlSpot(4, 4.1), FlSpot(5, 3.9),
                          ],
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primary.withOpacity(0.1)),
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 1.2), FlSpot(1, 1.1),
                            FlSpot(2, 0.98), FlSpot(3, 0.87),
                            FlSpot(4, 0.75), FlSpot(5, 0.68),
                          ],
                          isCurved: true,
                          color: AppTheme.accent,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.accent.withOpacity(0.1)),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SectionHeader(
                title: 'En Yeşil Satıcılar',
                subtitle: 'GreenScore sıralaması'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: (_sellers.toList()
                      ..sort((a, b) => b.greenScore.compareTo(a.greenScore)))
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => _TopSellerTile(rank: e.key + 1, seller: e.value))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            SectionHeader(
                title: 'Son Başvurular',
                subtitle: 'Kredi ve faktoring'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: _credits
                    .take(5)
                    .map((app) => _CreditTile(app: app))
                    .toList(),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_role == 'seller' && _myStore != null) {
      final store = _myStore!;
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StatCard(
              title: 'Aylık Ciro',
              value: '₺${(store.monthlyRevenue / 1000).toStringAsFixed(0)}K',
              subtitle: '${store.totalOrders} sipariş',
              icon: Icons.trending_up,
              trend: '%12.5',
              trendUp: true),
          StatCard(
              title: 'GreenScore',
              value: store.greenScore.toInt().toString(),
              subtitle: 'Eko performans',
              icon: Icons.eco_outlined,
              trend: '%4.1',
              trendUp: true),
          StatCard(
              title: 'Kredi Limiti',
              value: '₺${(store.creditLimit / 1000).toStringAsFixed(0)}K',
              subtitle: '%${store.interestRate} faiz',
              icon: Icons.credit_card_outlined,
              trend: '',
              trendUp: true),
          StatCard(
              title: 'Karbon İzi',
              value: '${(store.carbonEmission / 1000).toStringAsFixed(1)}t',
              subtitle: 'Aylık CO₂',
              icon: Icons.co2_outlined,
              trend: '%8.3',
              trendUp: false),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
            title: 'Toplam Ciro',
            value: '₺${(_totalRevenue / 1000000).toStringAsFixed(1)}M',
            subtitle: '$_activeSellers aktif satıcı',
            icon: Icons.store_outlined,
            trend: '%12.5',
            trendUp: true),
        StatCard(
            title: 'Kullandırılan',
            value: '₺${(_disbursedAmount / 1000000).toStringAsFixed(1)}M',
            subtitle: '${_credits.length} başvuru',
            icon: Icons.credit_card_outlined,
            trend: '%8.2',
            trendUp: true),
        StatCard(
            title: 'Ort. GreenScore',
            value: _avgGreenScore.toInt().toString(),
            subtitle: 'Platform ortalaması',
            icon: Icons.eco_outlined,
            trend: '%4.1',
            trendUp: true),
        StatCard(
            title: 'Karbon Salınımı',
            value: '${(_totalCarbon / 1000).toStringAsFixed(1)}t',
            subtitle: 'Aylık toplam',
            icon: Icons.co2_outlined,
            trend: '%18.3',
            trendUp: false),
      ],
    );
  }
}

// ── Seller Welcome Banner ────────────────────────────────────────────────────

class _SellerWelcomeBanner extends StatelessWidget {
  final Seller? store;
  const _SellerWelcomeBanner({required this.store});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mağazam',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 2),
              Text(
                store != null
                    ? '${store!.name} · ${store!.platform}'
                    : 'Mağaza performansınız',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.store, size: 13, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text('Satıcı',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuyerWelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 2),
              Text('GreenLedger platformu genel bakış',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance, size: 13, color: AppTheme.accent),
              const SizedBox(width: 4),
              Text('Alıcı Platform',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── My Store Banner (Seller role only) ───────────────────────────────────────

class _MyStoreBanner extends StatelessWidget {
  final Seller store;
  const _MyStoreBanner({required this.store});

  String get _scoreLabel {
    if (store.greenScore >= 80) return 'Mükemmel';
    if (store.greenScore >= 60) return 'İyi';
    if (store.greenScore >= 40) return 'Orta';
    return 'Gelişmeli';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            const Color(0xFF1A5C38),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ne Kadar Çevreciyim?',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          store.greenScore.toInt().toString(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '/100',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _scoreLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.military_tech, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            BadgeService.getTitle(store),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                    ]),
                  ],
                ),
              ),
              // Score Gauge
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: store.greenScore / 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                    const Icon(Icons.eco, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: store.greenScore / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // Eco badges + metrics row
          Row(
            children: [
              _EcoBadge(
                icon: Icons.recycling,
                label: 'Eko Paket',
                active: store.ecoPackaging,
              ),
              const SizedBox(width: 8),
              _EcoBadge(
                icon: Icons.local_shipping_outlined,
                label: 'Yeşil Kargo',
                active: store.ecoLogistics,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '%${store.interestRate.toStringAsFixed(1)} faiz',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Kredi faiziniz',
                    style: TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Improvement tip
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTip(),
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTip() {
    if (!store.ecoPackaging && !store.ecoLogistics) {
      return 'Eko paketleme ve yeşil kargo ekleyerek skorunuzu 35 puan artırabilirsiniz.';
    }
    if (!store.ecoPackaging) {
      return 'Eko paketlemeye geçerek GreenScore\'unuzu 15 puan artırın, faizinizi düşürün.';
    }
    if (!store.ecoLogistics) {
      return 'Yeşil kargo ile GreenScore\'unuzu 20 puan artırın ve daha düşük faiz kazanın.';
    }
    if (store.returnRate > 5) {
      return 'İade oranınızı düşürerek GreenScore\'unuzu daha da iyileştirebilirsiniz.';
    }
    return 'Harika! Sürdürülebilirlik liderlerindensiniz. Sıralamayı kontrol edin.';
  }
}

class _EcoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _EcoBadge(
      {required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: active ? Colors.white30 : Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? icon : Icons.close,
              size: 11,
              color: active ? Colors.white : Colors.white38),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badges Section ────────────────────────────────────────────────────────────

class _BadgesSection extends StatefulWidget {
  final Seller store;
  const _BadgesSection({required this.store});

  @override
  State<_BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends State<_BadgesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final badges = BadgeService.getBadges(widget.store);
    final earned = badges.where((b) => b.earned).length;
    final shown = _expanded ? badges : badges.where((b) => b.earned).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppTheme.accent, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Başarılar',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$earned/${badges.length}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'Gizle' : 'Tümünü Gör',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: shown.map((b) => _BadgeChip(badge: b)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final AppBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badge.earned
              ? badge.color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badge.earned
                ? badge.color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            badge.earned ? badge.icon : Icons.lock_outline,
            size: 13,
            color: badge.earned ? badge.color : AppTheme.muted,
          ),
          const SizedBox(width: 5),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badge.earned ? badge.color : AppTheme.muted,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _CarbonMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CarbonMetric(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
      ],
    );
  }
}

class _TopSellerTile extends StatelessWidget {
  final int rank;
  final Seller seller;
  const _TopSellerTile({required this.rank, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: AppTheme.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7)),
            child: Center(
                child: Text('$rank',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                PlatformBadge(platform: seller.platform),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(children: [
                const Icon(Icons.eco, color: AppTheme.primary, size: 12),
                const SizedBox(width: 2),
                Text('${seller.greenScore.toInt()}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              Text('%${seller.interestRate} faiz',
                  style: const TextStyle(
                      fontSize: 9, color: AppTheme.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  final CreditApplication app;
  const _CreditTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: AppTheme.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(
                app.type == 'factoring'
                    ? Icons.description_outlined
                    : Icons.credit_card_outlined,
                color: AppTheme.primary,
                size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.sellerName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                Text(
                    '${app.type == 'factoring' ? 'Faktoring' : 'Kredi'} · ${app.termDays}g',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₺${(app.amount / 1000).toStringAsFixed(0)}K',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              StatusBadge(status: app.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ReportButton({required this.onTap});

  @override
  State<_ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<_ReportButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                widget.onTap();
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(isDark ? 0.3 : 0.08),
              AppTheme.accent.withOpacity(isDark ? 0.2 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PDF Rapor Al',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                  Text('Platform performans raporunu indir veya paylaş',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.primary.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}
