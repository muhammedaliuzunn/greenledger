import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';

class SellerDetailScreen extends StatefulWidget {
  final Seller seller;
  const SellerDetailScreen({super.key, required this.seller});

  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  late Seller _seller;
  bool _calculating = false;
  bool _applying = false;
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _seller = widget.seller;
  }

  Future<void> _calculateScore() async {
    setState(() => _calculating = true);
    try {
      final result = await GeminiService.analyzeGreenScore(_seller.toJson());
      final updated = _seller.copyWith(
        greenScore: (result['tahmini_yeni_skor'] as num).toDouble(),
        interestRate: _seller.calculateInterestRate(),
        creditLimit: _seller.calculateCreditLimit(),
      );
      await DataService.updateSeller(updated);
      setState(() => _seller = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GreenScore güncellendi: ${updated.greenScore.toInt()}'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: AppTheme.destructive),
        );
      }
    } finally {
      setState(() => _calculating = false);
    }
  }

  Future<void> _applyCredit() async {
    setState(() => _applying = true);
    try {
      final app = CreditApplication(
        id: DataService.newId(),
        sellerId: _seller.id,
        sellerName: _seller.name,
        amount: _seller.creditLimit,
        interestRate: _seller.interestRate,
        greenScoreAtTime: _seller.greenScore,
        createdDate: DateTime.now(),
      );
      await DataService.addCreditApplication(app);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Kredi başvurusu oluşturuldu! ₺${(_seller.creditLimit / 1000).toStringAsFixed(0)}K'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } finally {
      setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_seller.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: PlatformBadge(platform: _seller.platform),
          ),
          IconButton(
            tooltip: 'PDF Rapor Al',
            icon: _generatingPdf
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primary),
            onPressed: _generatingPdf
                ? null
                : () async {
                    setState(() => _generatingPdf = true);
                    try {
                      await PdfService.generatePlatformReport(
                        sellers: [_seller],
                        credits: [],
                      );
                    } finally {
                      if (mounted) setState(() => _generatingPdf = false);
                    }
                  },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('GreenScore',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    GreenScoreGauge(score: _seller.greenScore, size: 140),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_seller.ecoPackaging)
                          _EcoBadge(label: '♻️ Eko Paket'),
                        if (_seller.ecoPackaging && _seller.ecoLogistics)
                          const SizedBox(width: 8),
                        if (_seller.ecoLogistics)
                          _EcoBadge(label: '🚚 Yeşil Lojistik'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculating ? null : _calculateScore,
                        icon: _calculating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.bolt, size: 18),
                        label: Text(_calculating
                            ? 'Gemini analiz yapıyor...'
                            : 'AI ile Skoru Hesapla'),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _InfoTile(label: 'Aylık Ciro', value: '₺${(_seller.monthlyRevenue / 1000).toStringAsFixed(0)}K', icon: Icons.store_outlined),
                _InfoTile(label: 'Kredi Limiti', value: '₺${(_seller.creditLimit / 1000).toStringAsFixed(0)}K', icon: Icons.credit_card_outlined),
                _InfoTile(label: 'Faiz Oranı', value: '%${_seller.interestRate}', icon: Icons.trending_down),
                _InfoTile(label: 'Karbon CO₂', value: '${_seller.carbonEmission.toInt()} kg', icon: Icons.eco_outlined),
                _InfoTile(label: 'Müşteri Mem.', value: '${_seller.customerSatisfaction}/5', icon: Icons.star_outlined),
                _InfoTile(label: 'İade Oranı', value: '%${_seller.returnRate}', icon: Icons.replay_outlined),
                _InfoTile(label: 'Stok Hızı', value: '${_seller.stockVelocity.toInt()} gün', icon: Icons.inventory_2_outlined),
                _InfoTile(label: 'Sipariş', value: '${_seller.totalOrders}', icon: Icons.local_shipping_outlined),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            if (_seller.greenScore > 0)
              Card(
                color: AppTheme.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.credit_card,
                                color: AppTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Kredi Teklifi Hazır!',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GreenScore\'unuz sayesinde faiz oranınız %${_seller.interestRate} olarak belirlenmiştir.',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${_seller.creditLimit.toStringAsFixed(0)}',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary),
                      ),
                      const Text('limit hazır',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.muted)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _applying ? null : _applyCredit,
                          icon: const Icon(Icons.bolt, size: 18),
                          label: Text(_applying
                              ? 'Başvuruluyor...'
                              : 'Tek Tıkla Kredi Çek'),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.muted)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _EcoBadge extends StatelessWidget {
  final String label;
  const _EcoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500)),
    );
  }
}