import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final bool isChanging;
  const RoleSelectionScreen({super.key, this.isChanging = false});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  Future<void> _confirm() async {
    if (_selectedRole == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole!);
    if (!mounted) return;

    if (widget.isChanging) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 40),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        widget.isChanging ? 'Rolünüzü Değiştirin' : 'Rolünüzü Seçin',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Size özel içerik sunabilmemiz için\nkullanım amacınızı belirtin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.muted,
                          height: 1.5,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 40),

                    _RoleCard(
                      icon: Icons.store_outlined,
                      title: 'Satıcı',
                      subtitle: 'E-ticaret mağazam var',
                      description:
                          'Mağazanızın GreenScore\'unu takip edin, yeşil finansman avantajlarından yararlanın ve AI koçunuzla büyüyün.',
                      bulletPoints: const [
                        'Mağaza çevre skoru takibi',
                        'Düşük faizli yeşil kredi',
                        'Kişisel AI yol haritası',
                      ],
                      selected: _selectedRole == 'seller',
                      onTap: () => setState(() => _selectedRole = 'seller'),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.08, end: 0),

                    const SizedBox(height: 16),

                    _RoleCard(
                      icon: Icons.account_balance_outlined,
                      title: 'Alıcı Platform',
                      subtitle: 'Finansman ve satıcı yönetimi',
                      description:
                          'Satıcı portföyünüzü yönetin, kredi başvurularını takip edin ve sürdürülebilir finansman sağlayın.',
                      bulletPoints: const [
                        'Tüm satıcı portföyü görünümü',
                        'Kredi & faktoring yönetimi',
                        'Platform geneli GreenScore analizi',
                      ],
                      selected: _selectedRole == 'buyer',
                      onTap: () => setState(() => _selectedRole = 'buyer'),
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.08, end: 0),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _confirm : null,
                  child: Text(
                    widget.isChanging ? 'Rolü Güncelle' : 'Devam Et',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> bulletPoints;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bulletPoints,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.06)
              : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppTheme.primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.muted, height: 1.4),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: bulletPoints
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 11, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(p,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
