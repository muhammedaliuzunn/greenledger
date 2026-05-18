import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import '../models/badge_model.dart';

class PdfService {
  static final _green = PdfColor.fromHex('#16A34A');
  static final _lightGreen = PdfColor.fromHex('#DCFCE7');
  static final _darkText = PdfColor.fromHex('#0D2617');
  static final _muted = PdfColor.fromHex('#6B7280');
  static final _accent = PdfColor.fromHex('#F59E0B');
  static final _red = PdfColor.fromHex('#EF4444');

  static Future<void> generatePlatformReport({
    required List<Seller> sellers,
    required List<CreditApplication> credits,
  }) async {
    final pdf = pw.Document();
    final date = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final totalRevenue = sellers.fold(0.0, (s, sel) => s + sel.monthlyRevenue);
    final avgScore = sellers.isEmpty
        ? 0.0
        : sellers.fold(0.0, (s, sel) => s + sel.greenScore) / sellers.length;
    final totalCarbon = sellers.fold(0.0, (s, sel) => s + sel.carbonEmission);
    final ecoCount = sellers.where((s) => s.ecoPackaging && s.ecoLogistics).length;
    final disbursed = credits
        .where((c) => c.status == 'disbursed')
        .fold(0.0, (s, c) => s + c.amount);

    final sortedSellers = [...sellers]
      ..sort((a, b) => b.greenScore.compareTo(a.greenScore));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _buildHeader('Platform Performans Raporu', date),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Ozet Metrikler'),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            pw.Expanded(child: _metricCard('Toplam Satici', '${sellers.length}', 'aktif')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Ort. GreenScore', avgScore.toInt().toString(), 'puan')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Toplam Ciro', '${(totalRevenue / 1000000).toStringAsFixed(1)}M TL', 'aylik')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Kullandirilan', '${(disbursed / 1000000).toStringAsFixed(1)}M TL', 'kredi')),
          ]),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Expanded(child: _metricCard('Karbon Izleri', '${(totalCarbon / 1000).toStringAsFixed(1)}t', 'CO2/ay')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Tam Eko', '$ecoCount/${sellers.length}', 'satici')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Agac Karsiligi', '${(totalCarbon / 21).toInt()}', 'agac')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Baskuru', '${credits.length}', 'toplam')),
          ]),
          pw.SizedBox(height: 28),
          _buildSectionTitle('En Yesil Saticilar (Top 10)'),
          pw.SizedBox(height: 12),
          _buildSellerTable(sortedSellers.take(10).toList()),
          pw.SizedBox(height: 28),
          _buildSectionTitle('Kredi Basvurulari'),
          pw.SizedBox(height: 12),
          _buildCreditTable(credits.take(10).toList()),
          pw.SizedBox(height: 28),
          _buildSectionTitle('Eko Performans Dagilimi'),
          pw.SizedBox(height: 12),
          _buildEcoBreakdown(sellers),
          pw.SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'GreenLedger_Platform_Raporu_$date.pdf',
    );
  }

  static Future<void> generateSellerReport(Seller seller) async {
    final pdf = pw.Document();
    final date = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final badges = BadgeService.getBadges(seller);
    final earnedBadges = badges.where((b) => b.earned).toList();
    final title = BadgeService.getTitle(seller);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _buildHeader('Magaza Yesil Performans Raporu', date),
          pw.SizedBox(height: 24),

          // Magaza bilgisi
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _lightGreen,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: _green, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(seller.name,
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _darkText)),
                  pw.SizedBox(height: 4),
                  pw.Text('Platform: ${seller.platform}  |  Lakaplar: $title',
                      style: pw.TextStyle(fontSize: 11, color: _muted)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text(seller.greenScore.toInt().toString(),
                      style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: _green)),
                  pw.Text('GreenScore', style: pw.TextStyle(fontSize: 10, color: _muted)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          _buildSectionTitle('Performans Metrikleri'),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            pw.Expanded(child: _metricCard('Aylik Ciro', '${(seller.monthlyRevenue / 1000).toStringAsFixed(0)}K TL', '')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Siparis Sayisi', '${seller.totalOrders}', 'adet')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Iade Orani', '%${seller.returnRate}', '')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Memnuniyet', '${seller.customerSatisfaction}/5', '')),
          ]),
          pw.SizedBox(height: 16),
          pw.Row(children: [
            pw.Expanded(child: _metricCard('Karbon Izi', '${(seller.carbonEmission / 1000).toStringAsFixed(1)}t', 'CO2/ay')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Kredi Limiti', '${(seller.creditLimit / 1000).toStringAsFixed(0)}K TL', '')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Faiz Orani', '%${seller.interestRate}', '')),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _metricCard('Stok Hizi', '${seller.stockVelocity} gun', '')),
          ]),
          pw.SizedBox(height: 20),

          _buildSectionTitle('Eko Durum'),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            pw.Expanded(child: _ecoStatusCard('Eko Paketleme', seller.ecoPackaging)),
            pw.SizedBox(width: 16),
            pw.Expanded(child: _ecoStatusCard('Yesil Lojistik', seller.ecoLogistics)),
          ]),
          pw.SizedBox(height: 20),

          if (earnedBadges.isNotEmpty) ...[
            _buildSectionTitle('Kazanilan Rozetler (${earnedBadges.length}/${badges.length})'),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: earnedBadges.map((b) => _badgeChip(b.title)).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          _buildSectionTitle('Iyilestirme Onerileri'),
          pw.SizedBox(height: 12),
          _buildImprovementTips(seller),
          pw.SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'GreenLedger_${seller.name.replaceAll(' ', '_')}_$date.pdf',
    );
  }

  // ── Yardimci widget'lar ──────────────────────────────────────────────────────

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _green,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('GreenLedger',
                style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(title,
                style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 12)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text(date, style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Text('Surdurulebilir Finans Platformu',
                style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 9)),
          ]),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _green, width: 2)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold, color: _darkText)),
    );
  }

  static pw.Widget _metricCard(String label, String value, String sub) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _muted)),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _darkText)),
        if (sub.isNotEmpty)
          pw.Text(sub, style: pw.TextStyle(fontSize: 9, color: _muted)),
      ]),
    );
  }

  static pw.Widget _ecoStatusCard(String label, bool active) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: active ? _lightGreen : PdfColor.fromHex('#F9FAFB'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(
          color: active ? _green : PdfColor.fromHex('#E5E7EB'),
        ),
      ),
      child: pw.Row(children: [
        pw.Container(
          width: 16,
          height: 16,
          decoration: pw.BoxDecoration(
            color: active ? _green : _muted,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(active ? 'E' : 'H',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: active ? _green : _muted)),
      ]),
    );
  }

  static pw.Widget _badgeChip(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: _lightGreen,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
        border: pw.Border.all(color: _green),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 10, color: _green, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildSellerTable(List<Seller> sellers) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB'), width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _green),
          children: ['#', 'Satici Adi', 'Platform', 'GreenScore', 'Ciro (TL)', 'Faiz']
              .map((h) => _tableHeader(h))
              .toList(),
        ),
        ...sellers.asMap().entries.map((e) {
          final s = e.value;
          final isEven = e.key % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : PdfColor.fromHex('#F9FAFB'),
            ),
            children: [
              _tableCell('${e.key + 1}', center: true),
              _tableCell(s.name),
              _tableCell(s.platform),
              _tableCell('${s.greenScore.toInt()}',
                  color: s.greenScore >= 80 ? _green : s.greenScore >= 60 ? _accent : _red),
              _tableCell('${(s.monthlyRevenue / 1000).toStringAsFixed(0)}K'),
              _tableCell('%${s.interestRate}'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildCreditTable(List<CreditApplication> credits) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB'), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#0EA5E9')),
          children: ['Satici', 'Tür', 'Tutar (TL)', 'Vade', 'Durum']
              .map((h) => _tableHeader(h))
              .toList(),
        ),
        ...credits.map((c) {
          return pw.TableRow(
            children: [
              _tableCell(c.sellerName),
              _tableCell(c.type == 'factoring' ? 'Faktoring' : 'Kredi'),
              _tableCell('${(c.amount / 1000).toStringAsFixed(0)}K'),
              _tableCell('${c.termDays} gun'),
              _tableCell(_statusLabel(c.status)),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildEcoBreakdown(List<Seller> sellers) {
    final both = sellers.where((s) => s.ecoPackaging && s.ecoLogistics).length;
    final onlyPackaging = sellers.where((s) => s.ecoPackaging && !s.ecoLogistics).length;
    final onlyLogistics = sellers.where((s) => !s.ecoPackaging && s.ecoLogistics).length;
    final none = sellers.where((s) => !s.ecoPackaging && !s.ecoLogistics).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(children: [
        _ecoRow('Tam Eko (paket + kargo)', both, sellers.length, _green),
        pw.SizedBox(height: 8),
        _ecoRow('Sadece Eko Paketleme', onlyPackaging, sellers.length, _accent),
        pw.SizedBox(height: 8),
        _ecoRow('Sadece Yesil Kargo', onlyLogistics, sellers.length, PdfColor.fromHex('#0EA5E9')),
        pw.SizedBox(height: 8),
        _ecoRow('Standart', none, sellers.length, _muted),
      ]),
    );
  }

  static pw.Widget _ecoRow(String label, int count, int total, PdfColor color) {
    final pct = total > 0 ? (count / total * 100).toInt() : 0;
    return pw.Row(children: [
      pw.SizedBox(width: 160,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10, color: _darkText))),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Container(
          height: 12,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F3F4F6'),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.LayoutBuilder(
            builder: (context, constraints) => pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                width: (constraints?.maxWidth ?? 0) * (total > 0 ? count / total : 0),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
              ),
            ),
          ),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Text('$count (%$pct)',
          style: pw.TextStyle(fontSize: 10, color: _muted)),
    ]);
  }

  static pw.Widget _buildImprovementTips(Seller seller) {
    final tips = <String>[];
    if (!seller.ecoPackaging) tips.add('Eko paketlemeye gecin: GreenScore +15 puan, faiz dusurer.');
    if (!seller.ecoLogistics) tips.add('Yesil kargo kullanin: GreenScore +20 puan, karbon izinizi azaltin.');
    if (seller.returnRate > 5) tips.add('Iade oraninizi dusurmeye calisin (hedef: %3 alti).');
    if (seller.customerSatisfaction < 4.5) tips.add('Musteri memnuniyetini artirin (hedef: 4.5 uzeri).');
    if (seller.carbonEmission > 200) tips.add('Karbon emisyonunuzu 200kg altina cekin.');
    if (tips.isEmpty) tips.add('Harika! Surdurulebilirlik liderlerindensiniz. Siralama bilgisinizi paylasin.');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: tips.asMap().entries.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 20, height: 20,
              decoration: pw.BoxDecoration(color: _green, shape: pw.BoxShape.circle),
              child: pw.Center(
                child: pw.Text('${e.key + 1}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Text(e.value,
                  style: pw.TextStyle(fontSize: 11, color: _darkText)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E5E7EB'))),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('GreenLedger - Surdurulebilir Finans Platformu',
              style: pw.TextStyle(fontSize: 9, color: _muted)),
          pw.Text('Bu rapor otomatik olarak olusturulmustur.',
              style: pw.TextStyle(fontSize: 9, color: _muted)),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _tableCell(String text, {bool center = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 10, color: color ?? _darkText),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Beklemede';
      case 'approved': return 'Onaylandi';
      case 'rejected': return 'Reddedildi';
      case 'disbursed': return 'Odendi';
      case 'repaid': return 'Geri Odendi';
      default: return status;
    }
  }
}
