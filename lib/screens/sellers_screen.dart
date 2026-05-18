import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';
import 'seller_detail_screen.dart';

class SellersScreen extends StatefulWidget {
  final double quickMinScore;
  final bool quickEcoOnly;

  const SellersScreen({
    super.key,
    this.quickMinScore = 0,
    this.quickEcoOnly = false,
  });

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  List<Seller> _sellers = [];
  List<Seller> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _platformFilter = 'Tümü';
  String _sortBy = 'green_score';

  final List<String> _platforms = [
    'Tümü', 'trendyol', 'amazon', 'hepsiburada', 'n11', 'etsy'
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'key': 'green_score', 'label': 'GreenScore'},
    {'key': 'monthly_revenue', 'label': 'Ciro'},
    {'key': 'interest_rate', 'label': 'Faiz'},
    {'key': 'name', 'label': 'İsim'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilters);
  }

  @override
  void didUpdateWidget(SellersScreen old) {
    super.didUpdateWidget(old);
    if (old.quickMinScore != widget.quickMinScore ||
        old.quickEcoOnly != widget.quickEcoOnly) {
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sellers = await DataService.getSellers();
    if (mounted) {
      setState(() {
        _sellers = sellers;
        _loading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase();
    var list = [..._sellers];

    // Platform filtresi
    if (_platformFilter != 'Tümü') {
      list = list.where((s) => s.platform == _platformFilter).toList();
    }

    // Hızlı filtreler
    if (widget.quickMinScore > 0) {
      list = list.where((s) => s.greenScore >= widget.quickMinScore).toList();
    }
    if (widget.quickEcoOnly) {
      list = list.where((s) => s.ecoPackaging && s.ecoLogistics).toList();
    }

    // Arama
    if (q.isNotEmpty) {
      list = list.where((s) => s.name.toLowerCase().contains(q)).toList();
    }

    // Sıralama
    switch (_sortBy) {
      case 'monthly_revenue':
        list.sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));
        break;
      case 'interest_rate':
        list.sort((a, b) => a.interestRate.compareTo(b.interestRate));
        break;
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        list.sort((a, b) => b.greenScore.compareTo(a.greenScore));
    }

    setState(() => _filtered = list);
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSellerSheet(onAdded: () {
        _load();
        Navigator.pop(context);
      }),
    );
  }

  Future<void> _deleteSeller(Seller seller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Satıcıyı Sil'),
        content: Text('${seller.name} silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.destructive),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DataService.deleteSeller(seller.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${seller.name} silindi'),
            backgroundColor: AppTheme.destructive,
          ),
        );
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtrele & Sırala',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Platform', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _platforms.map((p) => GestureDetector(
                onTap: () {
                  setState(() => _platformFilter = p);
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _platformFilter == p
                        ? AppTheme.primary
                        : AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _platformFilter == p
                          ? AppTheme.primary
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(p,
                      style: TextStyle(
                          fontSize: 12,
                          color: _platformFilter == p
                              ? Colors.white
                              : AppTheme.primary,
                          fontWeight: FontWeight.w500)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Sırala', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _sortOptions.map((o) => GestureDetector(
                onTap: () {
                  setState(() => _sortBy = o['key']);
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _sortBy == o['key']
                        ? AppTheme.accent
                        : AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _sortBy == o['key']
                          ? AppTheme.accent
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(o['label'],
                      style: TextStyle(
                          fontSize: 12,
                          color: _sortBy == o['key']
                              ? Colors.white
                              : AppTheme.accent,
                          fontWeight: FontWeight.w500)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingWidget(message: 'Satıcılar yükleniyor...');

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Satıcılar',
                                style: Theme.of(context).textTheme.displayMedium),
                            Text('${_filtered.length}/${_sellers.length} satıcı',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Row(
                          children: [
                            // Filtre butonu
                            IconButton(
                              onPressed: _showFilterSheet,
                              icon: Stack(
                                children: [
                                  const Icon(Icons.tune_outlined,
                                      color: AppTheme.primary),
                                  if (_platformFilter != 'Tümü')
                                    Positioned(
                                      right: 0, top: 0,
                                      child: Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.destructive,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Ekle'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Satıcı ara...',
                        prefixIcon: Icon(Icons.search, color: AppTheme.muted),
                      ),
                    ),
                    // Aktif filtreler
                    if (_platformFilter != 'Tümü') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_platformFilter,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppTheme.primary)),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _platformFilter = 'Tümü');
                                    _applyFilters();
                                  },
                                  child: const Icon(Icons.close,
                                      size: 12, color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.store_outlined,
                                size: 48, color: AppTheme.border),
                            const SizedBox(height: 12),
                            const Text('Satıcı bulunamadı',
                                style: TextStyle(color: AppTheme.muted)),
                            if (_platformFilter != 'Tümü') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() => _platformFilter = 'Tümü');
                                  _applyFilters();
                                },
                                child: const Text('Filtreyi Temizle'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _SellerCard(
                          seller: _filtered[i],
                          index: i,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SellerDetailScreen(
                                    seller: _filtered[i]),
                              ),
                            );
                            _load();
                          },
                          onDelete: () => _deleteSeller(_filtered[i]),
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

class _SellerCard extends StatelessWidget {
  final Seller seller;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SellerCard({
    required this.seller,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(seller.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppTheme.destructive),
                  title: const Text('Satıcıyı Sil',
                      style: TextStyle(color: AppTheme.destructive)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: AppTheme.muted),
                  title: const Text('İptal'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.store_outlined,
                        color: AppTheme.primary, size: 18),
                  ),
                  if (seller.ecoPackaging)
                    const Icon(Icons.eco, color: AppTheme.primary, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                seller.name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              PlatformBadge(platform: seller.platform),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('GreenScore',
                          style: TextStyle(
                              fontSize: 9, color: AppTheme.muted)),
                      Row(children: [
                        const Icon(Icons.eco,
                            color: AppTheme.primary, size: 12),
                        const SizedBox(width: 2),
                        Text(seller.greenScore.toInt().toString(),
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary)),
                      ]),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Faiz',
                          style: TextStyle(
                              fontSize: 9, color: AppTheme.muted)),
                      Text('%${seller.interestRate}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: seller.greenScore / 100,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    seller.greenScore >= 80
                        ? AppTheme.primary
                        : seller.greenScore >= 60
                            ? AppTheme.accent
                            : AppTheme.destructive.withOpacity(0.7),
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSellerSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddSellerSheet({required this.onAdded});

  @override
  State<_AddSellerSheet> createState() => _AddSellerSheetState();
}

class _AddSellerSheetState extends State<_AddSellerSheet> {
  final _nameCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  final _ordersCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _satisfactionCtrl = TextEditingController();
  String _platform = 'trendyol';
  bool _ecoPackaging = false;
  bool _ecoLogistics = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _revenueCtrl.dispose();
    _ordersCtrl.dispose();
    _returnCtrl.dispose();
    _satisfactionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yeni Satıcı Ekle',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Mağaza Adı *')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: ['trendyol', 'amazon', 'hepsiburada', 'n11', 'etsy']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v!),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _revenueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Aylık Ciro (₺)'),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(
                controller: _ordersCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sipariş Sayısı'),
              )),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: _returnCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'İade Oranı (%)'),
              )),
            ]),
            const SizedBox(height: 10),
            TextField(
              controller: _satisfactionCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Müşteri Memnuniyeti (1-5)'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _ecoPackaging,
              onChanged: (v) => setState(() => _ecoPackaging = v),
              title: const Text('Çevreci Paketleme',
                  style: TextStyle(fontSize: 14)),
              activeColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _ecoLogistics,
              onChanged: (v) => setState(() => _ecoLogistics = v),
              title: const Text('Yeşil Lojistik',
                  style: TextStyle(fontSize: 14)),
              activeColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Kaydediliyor...' : 'Satıcı Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    final seller = Seller(
      id: DataService.newId(),
      name: _nameCtrl.text,
      platform: _platform,
      monthlyRevenue: double.tryParse(_revenueCtrl.text) ?? 0,
      totalOrders: int.tryParse(_ordersCtrl.text) ?? 0,
      returnRate: double.tryParse(_returnCtrl.text) ?? 5,
      customerSatisfaction: double.tryParse(_satisfactionCtrl.text) ?? 4,
      ecoPackaging: _ecoPackaging,
      ecoLogistics: _ecoLogistics,
    );
    await DataService.addSeller(seller);
    widget.onAdded();
  }
}