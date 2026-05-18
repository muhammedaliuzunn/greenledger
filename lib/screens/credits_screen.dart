import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';

String _t(String lang, String tr, String en) => lang == 'EN' ? en : tr;

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  List<CreditApplication> _apps = [];
  bool _loading = true;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final apps = await DataService.getCreditApplications();
    if (mounted) {
      setState(() {
        _apps = apps;
        _loading = false;
      });
    }
  }

  List<CreditApplication> get _filtered {
    final tab = _tabCtrl.index;
    if (tab == 1) return _apps.where((a) => a.type == 'credit').toList();
    if (tab == 2) return _apps.where((a) => a.type == 'factoring').toList();
    return _apps;
  }

  double get _totalAmount =>
      _apps.fold(0, (s, a) => s + a.amount);
  double get _disbursed => _apps
      .where((a) => a.status == 'disbursed')
      .fold(0.0, (s, a) => s + a.amount);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    if (_loading) return LoadingWidget(message: _t(lang, 'Başvurular yükleniyor...', 'Loading applications...'));

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t(lang, 'Kredi & Faktoring', 'Credit & Factoring'),
                        style: Theme.of(context).textTheme.displayMedium),
                    Text(
                      '${_t(lang, 'Toplam', 'Total')}: ₺${(_totalAmount / 1000000).toStringAsFixed(1)}M · ${_t(lang, 'Kullandırılan', 'Disbursed')}: ₺${(_disbursed / 1000000).toStringAsFixed(1)}M',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: AppTheme.muted,
                      indicatorColor: AppTheme.primary,
                      onTap: (_) => setState(() {}),
                      tabs: [
                        Tab(text: '${_t(lang, 'Tümü', 'All')} (${_apps.length})'),
                        Tab(text: _t(lang, 'Kredi', 'Credit')),
                        Tab(text: _t(lang, 'Faktoring', 'Factoring')),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CreditCard(app: _filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final CreditApplication app;

  const _CreditCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                app.type == 'factoring'
                    ? Icons.description_outlined
                    : Icons.credit_card_outlined,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.sellerName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Builder(builder: (ctx) {
                    final l = ctx.watch<LanguageProvider>().lang;
                    return Text(
                      '${app.type == 'factoring' ? _t(l, 'Smart Faktoring', 'Smart Factoring') : _t(l, 'Yeşil Kredi', 'Green Credit')} · ${app.termDays}${_t(l, 'g', 'd')} · GS:${app.greenScoreAtTime.toInt()}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                    );
                  }),
                  if (app.createdDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM yyyy').format(app.createdDate!),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.muted),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${(app.amount / 1000).toStringAsFixed(0)}K',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Builder(builder: (ctx) {
                  final l = ctx.watch<LanguageProvider>().lang;
                  return Text('%${app.interestRate} ${_t(l, 'faiz', 'interest')}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.muted));
                }),
                const SizedBox(height: 4),
                StatusBadge(status: app.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}