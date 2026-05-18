import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingShown = prefs.getBool('onboarding_shown') ?? false;
    final roleSet = prefs.containsKey('user_role');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    final Widget destination;
    if (!onboardingShown) {
      destination = const OnboardingScreen();
    } else if (!roleSet) {
      destination = const RoleSelectionScreen();
    } else if (isLoggedIn) {
      destination = const MainScreen();
    } else {
      destination = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                color: AppTheme.primary,
                size: 56,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              'GreenLedger',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            Text(
              'Sürdürülebilir Finans Platformu',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

            const SizedBox(height: 48),

            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.7),
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

            const SizedBox(height: 16),

            Text(
              'Yükleniyor...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
