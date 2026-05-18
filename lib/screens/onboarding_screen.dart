import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      icon: Icons.eco,
      title: 'GreenLedger\'a Hoş Geldiniz',
      subtitle: 'Sürdürülebilir Finans Platformu',
      description:
          'E-ticaret satıcılarınızın çevresel performansını takip edin ve yeşil finansman avantajlarından yararlanın.',
    ),
    _PageData(
      icon: Icons.analytics_outlined,
      title: 'GreenScore ile Takip',
      subtitle: 'Akıllı Sürdürülebilirlik Skoru',
      description:
          'Her satıcı için otomatik hesaplanan GreenScore; eko paketleme, yeşil lojistik ve müşteri memnuniyetini değerlendirir. Yüksek skor = düşük faiz.',
    ),
    _PageData(
      icon: Icons.credit_card_outlined,
      title: 'Yeşil Kredi Avantajı',
      subtitle: 'Sürdürülebilirlik Ödüllendirilir',
      description:
          'GreenScore arttıkça kredi faiz oranları düşer. Standart kredi, faktoring ve yeşil finansman ürünlerine tek platformdan erişin.',
    ),
    _PageData(
      icon: Icons.psychology_outlined,
      title: 'AI Danışmanınız',
      subtitle: 'Gemini ile Güçlendirilmiş',
      description:
          'Kişisel sürdürülebilirlik analizi, kredi risk raporu ve 30-60-90 günlük büyüme yol haritanızı yapay zeka ile oluşturun.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_shown', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 18),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Atla',
                        style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageView(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primary
                              : AppTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut),
                      child: Text(
                        isLast ? 'Başlayalım' : 'İleri',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class _PageView extends StatelessWidget {
  final _PageData page;
  const _PageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(page.icon, size: 60, color: AppTheme.primary),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOut)
              .fadeIn(),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D2617),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            page.subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.muted,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
