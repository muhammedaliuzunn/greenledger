import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../models/badge_model.dart';
import '../services/data_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<Seller> _sellers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sellers = await DataService.getSellers();
    if (mounted) setState(() { _sellers = sellers; _loading = false; });
  }

  List<Seller> get _low  => _sellers.where((s) => s.greenScore >= 70).toList()
    ..sort((a, b) => b.greenScore.compareTo(a.greenScore));
  List<Seller> get _mid  => _sellers.where((s) => s.greenScore >= 50 && s.greenScore < 70).toList()
    ..sort((a, b) => b.greenScore.compareTo(a.greenScore));
  List<Seller> get _high => _sellers.where((s) => s.greenScore < 50).toList()
    ..sort((a, b) => b.greenScore.compareTo(a.greenScore));

  double get _totalExposure => _sellers.fold(0.0, (s, sel) => s + sel.creditLimit);
  double get _avgScore     => _sellers.isEmpty ? 0
      : _sellers.fold(0.0, (s, sel) => s + sel.greenScore) / _sellers.length;
  int    get _activeCount  => _sellers.where((s) => s.status == 'active').length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget(message: 'Portfolio yükleniyor...');

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Portfolio', style: Theme.of(context).textTheme.displayMedium),
                      Text('Satıcı risk & kredi görünümü',
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
                  child: Row(children: [
                    const Icon(Icons.account_balance, size: 13, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text('Alıcı Platform',
                        style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Özet Kartlar
            Row(
              children: [
                Expanded(child: _SummaryCard(
                  label: 'Toplam Exposure',
                  value: '₺${(_totalExposure / 1000000).toStringAsFixed(1)}M',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppTheme.primary,
                )),
                const SizedBox(width: 10),
                Expanded(child: _SummaryCard(
                  label: 'Ort. GreenScore',
                  value: _avgScore.toInt().toString(),
                  icon: Icons.eco_outlined,
                  color: _avgScore >= 70 ? AppTheme.primary : AppTheme.accent,
                )),
                const SizedBox(width: 10),
                Expanded(child: _SummaryCard(
                  label: 'Aktif Satıcı',
                  value: '$_activeCount',
                  icon: Icons.store_outlined,
                  color: AppTheme.chart3,
                )),
              ],
            ),

            const SizedBox(height: 20),

            // Risk Dağılımı
            Text('Risk Dağılımı', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Satıcıların GreenScore\'a göre risk segmentasyonu',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            _RiskDistributionBar(
              low: _low.length,
              mid: _mid.length,
              high: _high.length,
              total: _sellers.length,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _RiskLegend(color: const Color(0xFF16A34A), label: 'Düşük Risk', count: _low.length),
                _RiskLegend(color: AppTheme.accent, label: 'Orta Risk', count: _mid.length),
                _RiskLegend(color: AppTheme.destructive, label: 'Yüksek Risk', count: _high.length),
              ],
            ),

            const SizedBox(height: 24),

            // Exposure Breakdown
            _ExposureBreakdown(low: _low, mid: _mid, high: _high, total: _totalExposure),

            const SizedBox(height: 24),

            // Düşük Risk
            if (_low.isNotEmpty) ...[
              _RiskGroupHeader(
                label: 'Düşük Risk',
                count: _low.length,
                color: const Color(0xFF16A34A),
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 8),
              ..._low.map((s) => _PortfolioSellerCard(seller: s, riskLevel: 'low')),
              const SizedBox(height: 16),
            ],

            // Orta Risk
            if (_mid.isNotEmpty) ...[
              _RiskGroupHeader(
                label: 'Orta Risk',
                count: _mid.length,
                color: AppTheme.accent,
                icon: Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 8),
              ..._mid.map((s) => _PortfolioSellerCard(seller: s, riskLevel: 'mid')),
              const SizedBox(height: 16),
            ],

            // Yüksek Risk
            if (_high.isNotEmpty) ...[
              _RiskGroupHeader(
                label: 'Yüksek Risk',
                count: _high.length,
                color: AppTheme.destructive,
                icon: Icons.error_outline,
              ),
              const SizedBox(height: 8),
              ..._high.map((s) => _PortfolioSellerCard(seller: s, riskLevel: 'high')),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Risk Distribution Bar ─────────────────────────────────────────────────────

class _RiskDistributionBar extends StatelessWidget {
  final int low, mid, high, total;

  const _RiskDistributionBar({
    required this.low, required this.mid,
    required this.high, required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final lowPct  = low  / total;
    final midPct  = mid  / total;
    final highPct = high / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            if (lowPct > 0) Expanded(
              flex: (lowPct * 100).round(),
              child: Container(color: const Color(0xFF16A34A)),
            ),
            if (midPct > 0) Expanded(
              flex: (midPct * 100).round(),
              child: Container(color: AppTheme.accent),
            ),
            if (highPct > 0) Expanded(
              flex: (highPct * 100).round(),
              child: Container(color: AppTheme.destructive),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _RiskLegend({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$label ($count)',
          style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
    ]);
  }
}

// ── Exposure Breakdown ────────────────────────────────────────────────────────

class _ExposureBreakdown extends StatelessWidget {
  final List<Seller> low, mid, high;
  final double total;

  const _ExposureBreakdown({
    required this.low, required this.mid,
    required this.high, required this.total,
  });

  double _sum(List<Seller> list) => list.fold(0.0, (s, sel) => s + sel.creditLimit);

  @override
  Widget build(BuildContext context) {
    final lowAmt  = _sum(low);
    final midAmt  = _sum(mid);
    final highAmt = _sum(high);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kredi Exposure Dağılımı',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            _ExposureRow(
              label: 'Düşük Risk',
              amount: lowAmt,
              total: total,
              color: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 10),
            _ExposureRow(
              label: 'Orta Risk',
              amount: midAmt,
              total: total,
              color: AppTheme.accent,
            ),
            const SizedBox(height: 10),
            _ExposureRow(
              label: 'Yüksek Risk',
              amount: highAmt,
              total: total,
              color: AppTheme.destructive,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExposureRow extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  final Color color;

  const _ExposureRow({
    required this.label, required this.amount,
    required this.total, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? amount / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
            Text(
              '₺${(amount / 1000).toStringAsFixed(0)}K  (${(pct * 100).toInt()}%)',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Risk Group Header ─────────────────────────────────────────────────────────

class _RiskGroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _RiskGroupHeader({
    required this.label, required this.count,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text('$label · $count satıcı',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ]);
  }
}

// ── Portfolio Seller Card ─────────────────────────────────────────────────────

class _PortfolioSellerCard extends StatelessWidget {
  final Seller seller;
  final String riskLevel;

  const _PortfolioSellerCard({required this.seller, required this.riskLevel});

  Color get _riskColor {
    if (riskLevel == 'low')  return const Color(0xFF16A34A);
    if (riskLevel == 'mid')  return AppTheme.accent;
    return AppTheme.destructive;
  }

  @override
  Widget build(BuildContext context) {
    final badges = BadgeService.getBadges(seller);
    final earnedBadges = badges.where((b) => b.earned).take(3).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Risk indicator
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _riskColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seller.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(children: [
                        PlatformBadge(platform: seller.platform),
                        const SizedBox(width: 6),
                        Text(BadgeService.getTitle(seller),
                            style: TextStyle(
                                fontSize: 10,
                                color: BadgeService.getTitleColor(seller.greenScore),
                                fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.eco, color: AppTheme.primary, size: 13),
                      const SizedBox(width: 3),
                      Text('${seller.greenScore.toInt()}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    Text('%${seller.interestRate.toStringAsFixed(2)} faiz',
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.muted)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Limit',
                    value: '₺${(seller.creditLimit / 1000).toStringAsFixed(0)}K',
                  ),
                ),
                Expanded(
                  child: _MetricChip(
                    icon: Icons.trending_up,
                    label: 'Ciro',
                    value: '₺${(seller.monthlyRevenue / 1000).toStringAsFixed(0)}K',
                  ),
                ),
                Expanded(
                  child: _MetricChip(
                    icon: Icons.undo,
                    label: 'İade',
                    value: '%${seller.returnRate}',
                  ),
                ),
              ],
            ),

            if (earnedBadges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: earnedBadges.map((b) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: b.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(b.icon, size: 10, color: b.color),
                    const SizedBox(width: 3),
                    Text(b.title, style: TextStyle(fontSize: 10, color: b.color, fontWeight: FontWeight.w500)),
                  ]),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: AppTheme.muted),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
      ],
    );
  }
}
