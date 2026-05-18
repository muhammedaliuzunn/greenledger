import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../services/gemini_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';

String _t(String lang, String tr, String en) => lang == 'EN' ? en : tr;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<Seller> _sellers = [];
  bool _loading = true;
  String _sortBy = 'green_score';
  String? _aiTip;
  bool _loadingTip = false;
  late TabController _tabCtrl;

  List<Map<String, dynamic>> _categories(String lang) => [
    {'key': 'green_score', 'label': 'GreenScore', 'icon': Icons.eco},
    {'key': 'monthly_revenue', 'label': _t(lang, 'Ciro', 'Revenue'), 'icon': Icons.trending_up},
    {'key': 'customer_satisfaction', 'label': _t(lang, 'Memnuniyet', 'Satisfaction'), 'icon': Icons.star},
    {'key': 'return_rate', 'label': _t(lang, 'İade', 'Returns'), 'icon': Icons.replay},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final cats = _categories('TR');
        setState(() => _sortBy = cats[_tabCtrl.index]['key'] as String);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sellers = await DataService.getSellers();
    if (mounted) setState(() { _sellers = sellers; _loading = false; });
  }

  List<Seller> get _sorted {
    final list = [..._sellers];
    if (_sortBy == 'return_rate') {
      list.sort((a, b) => a.returnRate.compareTo(b.returnRate));
    } else if (_sortBy == 'monthly_revenue') {
      list.sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));
    } else if (_sortBy == 'customer_satisfaction') {
      list.sort((a, b) => b.customerSatisfaction.compareTo(a.customerSatisfaction));
    } else {
      list.sort((a, b) => b.greenScore.compareTo(a.greenScore));
    }
    return list;
  }

  String _getValue(Seller s, String lang) {
    switch (_sortBy) {
      case 'monthly_revenue':
        return '₺${(s.monthlyRevenue / 1000).toStringAsFixed(0)}K';
      case 'customer_satisfaction':
        return '${s.customerSatisfaction}/5';
      case 'return_rate':
        return '%${s.returnRate}';
      default:
        return '${s.greenScore.toInt()} ${_t(lang, 'puan', 'pts')}';
    }
  }

  Future<void> _getAITip(Seller seller) async {
    if (_loadingTip) return;
    setState(() { _loadingTip = true; _aiTip = null; });
    try {
      final rank = _sorted.indexOf(seller) + 1;
      final tip = await GeminiService.chatWithCoach(
        '${seller.name} şu an $rank. sırada. Rakiplerini geçmek için en kritik 2 öneriyi ver. Çok kısa.',
        seller.toJson(),
      );
      setState(() => _aiTip = tip);
    } catch (e) {
      setState(() => _aiTip = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loadingTip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    if (_loading) return LoadingWidget(message: _t(lang, 'Sıralama yükleniyor...', 'Loading rankings...'));

    final sorted = _sorted;
    final ecoCount = _sellers.where((s) => s.ecoPackaging && s.ecoLogistics).length;
    final avgScore = _sellers.isEmpty ? 0.0 :
        _sellers.fold(0.0, (s, sel) => s + sel.greenScore) / _sellers.length;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_t(lang, 'Yeşil Rekabet', 'Green Competition'),
                            style: Theme.of(context).textTheme.displayMedium),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6,
                              decoration: const BoxDecoration(
                                  color: AppTheme.primary, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(_t(lang, 'Canlı', 'Live'),
                              style: const TextStyle(fontSize: 11, color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _StatMini(label: _t(lang, 'Toplam', 'Total'), value: '${_sellers.length}')),
                      const SizedBox(width: 8),
                      Expanded(child: _StatMini(label: _t(lang, 'Tam Eko', 'Full Eco'), value: '$ecoCount',
                          color: AppTheme.primary)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatMini(label: _t(lang, 'Ort. Skor', 'Avg Score'),
                          value: avgScore.toInt().toString())),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TabBar(
                    controller: _tabCtrl,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.muted,
                    indicatorColor: AppTheme.primary,
                    labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    tabs: _categories(lang).map((c) => Tab(
                      icon: Icon(c['icon'] as IconData, size: 15),
                      text: c['label'] as String,
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            if (sorted.length >= 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _PodiumCard(
                        seller: sorted[1], rank: 2, value: _getValue(sorted[1], lang))),
                    const SizedBox(width: 8),
                    Expanded(child: Transform.translate(
                      offset: const Offset(0, -12),
                      child: _PodiumCard(seller: sorted[0], rank: 1,
                          value: _getValue(sorted[0], lang), isFirst: true),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _PodiumCard(
                        seller: sorted[2], rank: 3, value: _getValue(sorted[2], lang))),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // AI Tip Banner
            if (_aiTip != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: AppTheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_aiTip!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.primary))),
                        GestureDetector(
                          onTap: () => setState(() => _aiTip = null),
                          child: const Icon(Icons.close, size: 14, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Card(
                child: Column(
                  children: sorted.asMap().entries.map((entry) =>
                    _LeaderRow(
                      rank: entry.key + 1,
                      seller: entry.value,
                      value: _getValue(entry.value, lang),
                      onAITip: () => _getAITip(entry.value),
                      loadingTip: _loadingTip,
                    ),
                  ).toList(),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatMini({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.spaceGrotesk(
              fontSize: 18, fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF0D2617),
            )),
          ],
        ),
      ),
    );
  }
}

Color _rankColor(int rank) {
  if (rank == 1) return const Color(0xFFD4A017);
  if (rank == 2) return const Color(0xFF9E9E9E);
  return const Color(0xFFCD7F32);
}

class _PodiumCard extends StatelessWidget {
  final Seller seller;
  final int rank;
  final String value;
  final bool isFirst;

  const _PodiumCard({
    required this.seller,
    required this.rank,
    required this.value,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(rank);
    return Card(
      color: isFirst ? AppTheme.primary.withOpacity(0.05) : null,
      shape: isFirst
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.primary.withOpacity(0.3), width: 1.5))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFirst)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                    color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                child: Text(context.watch<LanguageProvider>().lang == 'EN' ? 'LEADER' : 'LİDER',
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            Container(
              width: isFirst ? 44 : 36,
              height: isFirst ? 44 : 36,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor.withOpacity(0.5), width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: isFirst ? 18.0 : 14.0,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(seller.name,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            PlatformBadge(platform: seller.platform),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.spaceGrotesk(
              fontSize: isFirst ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: isFirst ? AppTheme.primary : const Color(0xFF0D2617),
            )),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final Seller seller;
  final String value;
  final VoidCallback onAITip;
  final bool loadingTip;

  const _LeaderRow({
    required this.rank,
    required this.seller,
    required this.value,
    required this.onAITip,
    required this.loadingTip,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isTop3 ? AppTheme.primary.withOpacity(0.02) : null,
        border: Border(bottom: BorderSide(color: AppTheme.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32, height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: isTop3
                    ? _rankColor(rank).withOpacity(0.1)
                    : AppTheme.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isTop3 ? _rankColor(rank) : AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  PlatformBadge(platform: seller.platform),
                  if (seller.ecoPackaging && seller.ecoLogistics) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.recycling, size: 9, color: AppTheme.primary),
                        const SizedBox(width: 2),
                        Text(context.watch<LanguageProvider>().lang == 'EN' ? 'Full Eco' : 'Tam Eko',
                            style: const TextStyle(fontSize: 8, color: AppTheme.primary)),
                      ]),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // Value + AI Tip
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: loadingTip ? null : onAITip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    loadingTip
                        ? const SizedBox(width: 9, height: 9,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primary))
                        : const Icon(Icons.auto_awesome, size: 9, color: AppTheme.primary),
                    const SizedBox(width: 3),
                    Text(context.watch<LanguageProvider>().lang == 'EN' ? 'AI Tip' : 'AI Tavsiye',
                        style: const TextStyle(fontSize: 9, color: AppTheme.primary)),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}