import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _isRegister = false;

  // Demo kullanıcılar
  static const Map<String, String> _demoUsers = {
    'admin@greenledger.com': '123456',
    'demo@greenledger.com': 'demo123',
  };

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() { _error = 'Email ve şifre boş olamaz!'; _loading = false; });
      return;
    }

    if (_isRegister) {
      // Kayıt ol - basit validasyon
      if (pass.length < 6) {
        setState(() { _error = 'Şifre en az 6 karakter olmalı!'; _loading = false; });
        return;
      }
      // Kayıt başarılı
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);
      _goToMain();
    } else {
      // Giriş yap
      if (_demoUsers.containsKey(email) && _demoUsers[email] == pass) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setBool('is_logged_in', true);
        _goToMain();
      } else {
        setState(() {
          _error = 'Email veya şifre hatalı!\nDemo: admin@greenledger.com / 123456';
          _loading = false;
        });
      }
    }
  }

  void _goToMain() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Logo & Başlık
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.eco, color: Colors.white, size: 44),
                    )
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 16),

                    Text(
                      'GreenLedger',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 4),

                    Text(
                      _isRegister ? 'Hesap Oluştur' : 'Hoş Geldiniz',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.muted,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Form Kartı
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRegister ? 'Kayıt Ol' : 'Giriş Yap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppTheme.muted, size: 20),
                        hintText: 'ornek@email.com',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Şifre
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outlined,
                            color: AppTheme.muted, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.muted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Hata mesajı
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.destructive.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.destructive.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.destructive, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.destructive)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Giriş Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isRegister ? 'Hesap Oluştur' : 'Giriş Yap',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Kayıt ol / Giriş yap geçiş
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() {
                          _isRegister = !_isRegister;
                          _error = null;
                        }),
                        child: Text(
                          _isRegister
                              ? 'Zaten hesabın var mı? Giriş Yap'
                              : 'Hesabın yok mu? Kayıt Ol',
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Demo Bilgi Kartı
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text('Demo Hesaplar',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary)),
                    ]),
                    const SizedBox(height: 8),
                    _DemoTile(
                      email: 'admin@greenledger.com',
                      pass: '123456',
                      label: 'Admin',
                      onTap: () {
                        _emailCtrl.text = 'admin@greenledger.com';
                        _passCtrl.text = '123456';
                      },
                    ),
                    const SizedBox(height: 4),
                    _DemoTile(
                      email: 'demo@greenledger.com',
                      pass: 'demo123',
                      label: 'Demo',
                      onTap: () {
                        _emailCtrl.text = 'demo@greenledger.com';
                        _passCtrl.text = 'demo123';
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final String email;
  final String pass;
  final String label;
  final VoidCallback onTap;

  const _DemoTile({
    required this.email,
    required this.pass,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$email / $pass',
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}