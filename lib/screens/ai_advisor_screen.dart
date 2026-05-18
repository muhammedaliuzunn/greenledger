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

class AIAdvisorScreen extends StatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen>
    with SingleTickerProviderStateMixin {
  List<Seller> _sellers = [];
  Seller? _selectedSeller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSellers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSellers() async {
    final sellers = await DataService.getSellers();
    if (mounted) setState(() => _sellers = sellers);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_t(lang, 'AI Danışman', 'AI Advisor'),
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
                      const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 12),
                      const SizedBox(width: 4),
                      Text('Gemini',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Seller>(
                value: _selectedSeller,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _t(lang, 'Satıcı seçin', 'Select seller'),
                  prefixIcon: const Icon(Icons.store_outlined, color: AppTheme.muted, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _sellers.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('${s.name} (GS: ${s.greenScore.toInt()})',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _selectedSeller = v),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.muted,
                indicatorColor: AppTheme.primary,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(icon: Icon(Icons.eco, size: 16), text: 'GreenScore'),
                  const Tab(icon: Icon(Icons.credit_card, size: 16), text: 'Risk'),
                  Tab(icon: const Icon(Icons.trending_up, size: 16), text: _t(lang, 'Koç', 'Coach')),
                  Tab(icon: const Icon(Icons.description, size: 16), text: _t(lang, 'Rapor', 'Report')),
                  Tab(icon: const Icon(Icons.map_outlined, size: 16), text: _t(lang, 'Harita', 'Roadmap')),
                ],
              ),
            ],
          ),
        ),

        // Tab içeriği
        Expanded(
          child: _selectedSeller == null
              ? _EmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _GreenScoreTab(seller: _selectedSeller!),
                    _CreditRiskTab(seller: _selectedSeller!),
                    _CoachTab(seller: _selectedSeller!),
                    _ReportTab(seller: _selectedSeller!),
                    _RoadmapTab(seller: _selectedSeller!),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_outlined, size: 56, color: AppTheme.border),
            const SizedBox(height: 12),
            Text(_t(lang, 'AI Danışmanınız Hazır', 'Your AI Advisor is Ready'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(_t(lang, 'Yukarıdan satıcı seçin', 'Select a seller above'),
                style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Map<String, dynamic>>[
                {'icon': Icons.eco, 'label': 'GreenScore'},
                {'icon': Icons.shield_outlined, 'label': 'Risk'},
                {'icon': Icons.trending_up, 'label': 'Koç'},
                {'icon': Icons.description_outlined, 'label': 'Rapor'},
                {'icon': Icons.map_outlined, 'label': 'Harita'},
              ].map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f['icon'] as IconData, size: 12, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(f['label'] as String, style: const TextStyle(fontSize: 11)),
                ]),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// GreenScore Tab
class _GreenScoreTab extends StatefulWidget {
  final Seller seller;
  const _GreenScoreTab({required this.seller});

  @override
  State<_GreenScoreTab> createState() => _GreenScoreTabState();
}

class _GreenScoreTabState extends State<_GreenScoreTab> {
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  Future<void> _analyze() async {
    final lang = context.read<LanguageProvider>().lang;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await GeminiService.analyzeGreenScore(widget.seller.toJson(), lang: lang);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_result == null && !_loading)
            _AnalyzeButton(label: _t(lang, 'Sürdürülebilirlik Analizi Yap', 'Run Sustainability Analysis'), icon: Icons.eco, onTap: _analyze),
          if (_loading) Padding(
            padding: const EdgeInsets.all(32),
            child: LoadingWidget(message: _t(lang, 'Gemini analiz yapıyor...', 'Gemini is analyzing...')),
          ),
          if (_error != null) _ErrorWidget(message: _error!),
          if (_result != null) ...[
            Card(
              color: AppTheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Text(_result!['genel_degerlendirme'] ?? '',
                      style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ScoreBox(label: 'Mevcut', value: '${widget.seller.greenScore.toInt()}'),
                    const Icon(Icons.arrow_forward, color: AppTheme.muted, size: 20),
                    _ScoreBox(label: 'Tahmini', value: '${_result!['tahmini_yeni_skor']}', isGreen: true),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            _ListCard(title: 'Güçlü Yönler',
                items: List<String>.from(_result!['guclu_yonler'] ?? []), color: AppTheme.primary),
            const SizedBox(height: 10),
            _ListCard(title: 'Zayıf Yönler',
                items: List<String>.from(_result!['zayif_yonler'] ?? []), color: AppTheme.destructive),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Öncelikli Adımlar', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...List<Map>.from(_result!['oncelikli_adimlar'] ?? []).map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.background,
                          borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(a['adim'] ?? '',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(a['etki'] ?? '',
                                style: const TextStyle(fontSize: 10, color: AppTheme.primary)),
                          ),
                        ]),
                        const SizedBox(height: 3),
                        Text(a['aciklama'] ?? '',
                            style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                      ]),
                    ),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _analyze,
                icon: const Icon(Icons.refresh, size: 14), label: const Text('Yeniden Analiz Et')),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Credit Risk Tab
class _CreditRiskTab extends StatefulWidget {
  final Seller seller;
  const _CreditRiskTab({required this.seller});

  @override
  State<_CreditRiskTab> createState() => _CreditRiskTabState();
}

class _CreditRiskTabState extends State<_CreditRiskTab> {
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  Future<void> _analyze() async {
    final lang = context.read<LanguageProvider>().lang;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await GeminiService.analyzeCreditRisk(widget.seller.toJson(), lang: lang);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    Color riskColor = AppTheme.primary;
    if (_result != null) {
      if (_result!['risk_seviyesi'] == 'orta') riskColor = AppTheme.accent;
      if (_result!['risk_seviyesi'] == 'yuksek') riskColor = AppTheme.destructive;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_result == null && !_loading)
            _AnalyzeButton(label: _t(lang, 'Kredi Risk Raporu Oluştur', 'Generate Credit Risk Report'), icon: Icons.shield_outlined, onTap: _analyze),
          if (_loading) Padding(
            padding: const EdgeInsets.all(32),
            child: LoadingWidget(message: _t(lang, 'Kredi riski hesaplanıyor...', 'Calculating credit risk...')),
          ),
          if (_error != null) _ErrorWidget(message: _error!),
          if (_result != null) ...[
            Card(
              color: riskColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: riskColor.withOpacity(0.3))),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Row(children: [
                    Icon(Icons.shield, color: riskColor, size: 32),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${(_result!['risk_seviyesi'] ?? '').toString().toUpperCase()} RİSK',
                          style: TextStyle(fontWeight: FontWeight.bold, color: riskColor, fontSize: 15)),
                      Text(_result!['karar_gerekce'] ?? '',
                          style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ])),
                  ]),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _ScoreBox(label: 'Risk Skoru', value: '${_result!['risk_skoru']}'),
                    _ScoreBox(label: 'Önerilen Limit',
                        value: '₺${((_result!['onerilen_limit'] as num) / 1000).toStringAsFixed(0)}K',
                        isGreen: true),
                    _ScoreBox(label: 'Faiz', value: '%${_result!['onerilen_faiz']}'),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Risk Faktörleri', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...List<Map>.from(_result!['risk_faktorleri'] ?? []).map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(f['durum'] == 'pozitif' ? Icons.arrow_upward : Icons.arrow_downward,
                          color: f['durum'] == 'pozitif' ? AppTheme.primary : AppTheme.destructive, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text(f['faktor'] ?? '', style: const TextStyle(fontSize: 12))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(6)),
                        child: Text(f['agirlik'] ?? '', style: const TextStyle(fontSize: 9)),
                      ),
                    ]),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('6 Aylık Tahmin', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_result!['6_ay_tahmin'] ?? '',
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _analyze,
                icon: const Icon(Icons.refresh, size: 14), label: const Text('Yeniden Analiz Et')),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Coach Tab
class _CoachTab extends StatefulWidget {
  final Seller seller;
  const _CoachTab({required this.seller});

  @override
  State<_CoachTab> createState() => _CoachTabState();
}

class _CoachTabState extends State<_CoachTab> {
  final List<Map<String, String>> _messages = [];
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = false;

  final List<String> _quickQuestions = [
    'İade oranımı nasıl düşürürüm?',
    'GreenScore\'umu nasıl artırırım?',
    'Faiz oranımı düşürmek için ne yapmalıyım?',
    'Rakiplerime karşı öne çıkmak için?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'text': 'Merhaba! ${widget.seller.name} için buradayım. Ne sormak istersiniz?',
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _scroll();
    try {
      final lang = context.read<LanguageProvider>().lang;
      final response = await GeminiService.chatWithCoach(text, widget.seller.toJson(), lang: lang);
      setState(() => _messages.add({'role': 'assistant', 'text': response}));
    } catch (e) {
      setState(() => _messages.add({
        'role': 'assistant',
        'text': e.toString().replaceAll('Exception: ', '')
      }));
    } finally {
      setState(() => _loading = false);
      _scroll();
    }
  }

  void _scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            children: [
              ..._messages.map((m) => _ChatBubble(role: m['role']!, text: m['text']!)),
              if (_loading)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(width: 40, child: LinearProgressIndicator(color: AppTheme.primary)),
                  ),
                ),
              if (_messages.length <= 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _quickQuestions.map((q) => GestureDetector(
                      onTap: () => _send(q),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                        ),
                        child: Text(q, style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
                      ),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
              color: Colors.white, border: Border(top: BorderSide(color: AppTheme.border))),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: _send,
                  decoration: const InputDecoration(
                      hintText: 'Sorunuzu yazın...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44, height: 44,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _send(_ctrl.text),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const CircleBorder()),
                  child: const Icon(Icons.send, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String role;
  final String text;
  const _ChatBubble({required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(radius: 14, backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: const Icon(Icons.psychology, color: AppTheme.primary, size: 14)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 3),
                  bottomRight: Radius.circular(isUser ? 3 : 14),
                ),
                border: isUser ? null : Border.all(color: AppTheme.border),
              ),
              child: Text(text, style: TextStyle(fontSize: 13,
                  color: isUser ? Colors.white : const Color(0xFF0D2617), height: 1.4)),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 6),
            CircleAvatar(radius: 14, backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppTheme.primary, size: 14)),
          ],
        ],
      ),
    );
  }
}

// Report Tab
class _ReportTab extends StatefulWidget {
  final Seller seller;
  const _ReportTab({required this.seller});

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  String? _report;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    final lang = context.read<LanguageProvider>().lang;
    final isEN = lang == 'EN';
    setState(() { _loading = true; _error = null; });
    try {
      final report = await GeminiService.ask(
        '''${isEN ? 'Monthly sustainability report for' : 'için aylık sürdürülebilirlik raporu:'} ${widget.seller.name}:
${isEN ? 'Platform' : 'Platform'}: ${widget.seller.platform}, ${isEN ? 'Revenue' : 'Ciro'}: ₺${widget.seller.monthlyRevenue}
GreenScore: ${widget.seller.greenScore}/100, ${isEN ? 'Carbon' : 'Karbon'}: ${widget.seller.carbonEmission} kg
${isEN ? 'Return rate' : 'İade'}: %${widget.seller.returnRate}, ${isEN ? 'Eco Packaging' : 'Eko Paket'}: ${widget.seller.ecoPackaging ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}
${isEN ? 'Green Logistics' : 'Yeşil Lojistik'}: ${widget.seller.ecoLogistics ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}

${isEN ? 'Sections: 1.Summary 2.Environmental Performance 3.Carbon 4.Opportunities 5.Financial Impact 6.Roadmap' : 'Bölümler: 1.Özet 2.Çevresel Performans 3.Karbon 4.Fırsatlar 5.Finansal Etki 6.Yol Haritası'}''',
        systemInstruction: isEN
            ? 'Write a short, professional report in English.'
            : 'Kısa ve profesyonel Türkçe rapor yaz.',
      );
      setState(() => _report = report);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_report == null && !_loading && _error == null)
            _AnalyzeButton(label: _t(lang, 'Aylık Rapor Oluştur', 'Generate Monthly Report'), icon: Icons.description_outlined, onTap: _generate),
          if (_loading) Padding(
            padding: const EdgeInsets.all(32),
            child: LoadingWidget(message: _t(lang, 'Rapor hazırlanıyor...', 'Preparing report...')),
          ),
          if (_error != null) _ErrorWidget(message: _error!),
          if (_report != null) ...[
            Card(child: Padding(padding: const EdgeInsets.all(14),
                child: SelectableText(_report!, style: const TextStyle(fontSize: 12, height: 1.6)))),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _generate,
                icon: const Icon(Icons.refresh, size: 14), label: const Text('Yeniden Oluştur')),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Roadmap Tab
class _RoadmapTab extends StatefulWidget {
  final Seller seller;
  const _RoadmapTab({required this.seller});

  @override
  State<_RoadmapTab> createState() => _RoadmapTabState();
}

class _RoadmapTabState extends State<_RoadmapTab> {
  Map<String, dynamic>? _roadmap;
  bool _loading = false;
  String? _error;
  final Set<String> _completed = {};

  Future<void> _generate() async {
    final lang = context.read<LanguageProvider>().lang;
    final isEN = lang == 'EN';
    setState(() { _loading = true; _error = null; });
    try {
      final result = await GeminiService.askJSON(
        '''${isEN ? 'Sustainability roadmap for' : 'için sürdürülebilirlik yol haritası:'} ${widget.seller.name}:
GreenScore: ${widget.seller.greenScore}/100
${isEN ? 'Platform' : 'Platform'}: ${widget.seller.platform}
${isEN ? 'Eco Packaging' : 'Eko Paket'}: ${widget.seller.ecoPackaging ? (isEN ? 'Yes' : 'Var') : (isEN ? 'No' : 'Yok')}
${isEN ? 'Green Logistics' : 'Yeşil Lojistik'}: ${widget.seller.ecoLogistics ? (isEN ? 'Yes' : 'Var') : (isEN ? 'No' : 'Yok')}
${isEN ? 'Return rate' : 'İade'}: %${widget.seller.returnRate}

JSON:
{
  "ozet": "string",
  "hedef_skor": number,
  "gun_30": {"baslik": "string", "adimlar": ["string","string","string"], "beklenen_etki": "string"},
  "gun_60": {"baslik": "string", "adimlar": ["string","string","string"], "beklened_etki": "string"},
  "gun_90": {"baslik": "string", "adimlar": ["string","string","string"], "beklened_etki": "string"},
  "rozet": "string"
}''',
        systemInstruction: isEN
            ? 'You are a sustainability coach. Give motivating steps in English.'
            : 'Sürdürülebilirlik koçusun. Türkçe, motive edici adımlar ver.',
      );
      setState(() => _roadmap = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().lang;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_roadmap == null && !_loading && _error == null)
            _AnalyzeButton(label: _t(lang, '30-60-90 Günlük Yol Haritası Oluştur', 'Generate 30-60-90 Day Roadmap'),
                icon: Icons.map_outlined, onTap: _generate),
          if (_loading) Padding(
            padding: const EdgeInsets.all(32),
            child: LoadingWidget(message: _t(lang, 'Yol haritanız hazırlanıyor...', 'Preparing your roadmap...')),
          ),
          if (_error != null) _ErrorWidget(message: _error!),
          if (_roadmap != null) ...[
            Card(
              color: AppTheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Text('Kişisel Yol Haritanız',
                      style: GoogleFonts.spaceGrotesk(fontSize: 15,
                          fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 6),
                  Text(_roadmap!['ozet'] ?? '',
                      style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _ScoreBox(label: 'Mevcut', value: '${widget.seller.greenScore.toInt()}'),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward, color: AppTheme.primary, size: 18)),
                    _ScoreBox(label: 'Hedef', value: '${_roadmap!['hedef_skor']}', isGreen: true),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            _RoadmapPhase(phase: '30 Gün', icon: Icons.spa, data: _roadmap!['gun_30'],
                color: AppTheme.chart3, completed: _completed,
                onToggle: (s) => setState(() => _completed.contains(s) ? _completed.remove(s) : _completed.add(s))),
            const SizedBox(height: 10),
            _RoadmapPhase(phase: '60 Gün', icon: Icons.park, data: _roadmap!['gun_60'],
                color: AppTheme.accent, completed: _completed,
                onToggle: (s) => setState(() => _completed.contains(s) ? _completed.remove(s) : _completed.add(s))),
            const SizedBox(height: 10),
            _RoadmapPhase(phase: '90 Gün', icon: Icons.military_tech, data: _roadmap!['gun_90'],
                color: AppTheme.primary, completed: _completed,
                onToggle: (s) => setState(() => _completed.contains(s) ? _completed.remove(s) : _completed.add(s))),
            const SizedBox(height: 10),
            Card(
              color: AppTheme.accent.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppTheme.accent.withOpacity(0.3))),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech, color: AppTheme.accent, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tamamlayınca Kazanırsın',
                        style: TextStyle(fontSize: 10, color: AppTheme.muted)),
                    Text(_roadmap!['rozet'] ?? '',
                        style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold)),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _generate,
                icon: const Icon(Icons.refresh, size: 14), label: const Text('Yeniden Oluştur')),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _RoadmapPhase extends StatelessWidget {
  final String phase;
  final IconData icon;
  final dynamic data;
  final Color color;
  final Set<String> completed;
  final Function(String) onToggle;

  const _RoadmapPhase({
    required this.phase, required this.icon, required this.data,
    required this.color, required this.completed, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox();
    final steps = List<String>.from(data['adimlar'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(phase, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(data['baslik'] ?? '',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 10),
          ...steps.map((step) => GestureDetector(
            onTap: () => onToggle(step),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: completed.contains(step) ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: completed.contains(step) ? AppTheme.primary : AppTheme.border, width: 1.5),
                  ),
                  child: completed.contains(step)
                      ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(step, style: TextStyle(fontSize: 12,
                    color: completed.contains(step) ? AppTheme.muted : const Color(0xFF0D2617),
                    decoration: completed.contains(step) ? TextDecoration.lineThrough : null))),
              ]),
            ),
          )),
          const Divider(height: 16),
          Row(children: [
            const Icon(Icons.bolt, color: AppTheme.accent, size: 13),
            const SizedBox(width: 4),
            Expanded(child: Text(data['beklenen_etki'] ?? '',
                style: const TextStyle(fontSize: 11, color: AppTheme.muted))),
          ]),
        ]),
      ),
    );
  }
}

// Yardımcı Widgetlar
class _AnalyzeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AnalyzeButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppTheme.primary, size: 44),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.bolt, size: 16),
          label: Text(label, textAlign: TextAlign.center),
        ),
      ]),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.destructive.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.destructive, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: const TextStyle(fontSize: 12, color: AppTheme.destructive))),
      ]),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isGreen;

  const _ScoreBox({required this.label, required this.value, this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold,
          color: isGreen ? AppTheme.primary : const Color(0xFF0D2617))),
    ]);
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _ListCard({required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(
                color == AppTheme.primary ? Icons.check_circle_outline : Icons.highlight_off,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 12))),
            ]),
          )),
        ]),
      ),
    );
  }
}