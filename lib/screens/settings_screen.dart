import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/help_sheet.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

String _t(String lang, String tr, String en) => lang == 'EN' ? en : tr;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _email = '';
  String _role = 'seller';
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _email = prefs.getString('user_email') ?? 'kullanici@greenledger.com';
      _role = prefs.getString('user_role') ?? 'seller';
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _logout() async {
    final lang = context.read<LanguageProvider>().lang;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t(lang, 'Çıkış Yap', 'Sign Out'),
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: Text(_t(lang, 'Hesabınızdan çıkmak istediğinize emin misiniz?', 'Are you sure you want to sign out?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t(lang, 'İptal', 'Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_t(lang, 'Çıkış Yap', 'Sign Out'),
                  style: const TextStyle(color: AppTheme.destructive))),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _changeRole() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(isChanging: true)),
    );
    _load();
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notifications = value);
  }

  String _roleLabel(String lang) => _role == 'seller' ? _t(lang, 'Satıcı', 'Seller') : _t(lang, 'Alıcı Platform', 'Buyer Platform');
  IconData get _roleIcon =>
      _role == 'seller' ? Icons.store_outlined : Icons.account_balance_outlined;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final lang = context.watch<LanguageProvider>().lang;
    final roleLabel = _roleLabel(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(lang, 'Hesabım', 'My Account'),
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(email: _email, role: roleLabel, roleIcon: _roleIcon),

            const SizedBox(height: 24),

            _SectionLabel(title: _t(lang, 'TERCİHLER', 'PREFERENCES')),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    title: isDark ? _t(lang, 'Aydınlık Mod', 'Light Mode') : _t(lang, 'Koyu Mod', 'Dark Mode'),
                    subtitle: isDark
                        ? _t(lang, 'Açık temaya geçmek için tıklayın', 'Tap to switch to light theme')
                        : _t(lang, 'Koyu temaya geçmek için tıklayın', 'Tap to switch to dark theme'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggle(),
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: _t(lang, 'Bildirimler', 'Notifications'),
                    subtitle: _t(lang, 'Kredi ve GreenScore uyarıları', 'Credit and GreenScore alerts'),
                    trailing: Switch(
                      value: _notifications,
                      onChanged: _toggleNotifications,
                      activeColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SectionLabel(title: _t(lang, 'HESAP', 'ACCOUNT')),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: _roleIcon,
                    title: _t(lang, 'Rolüm', 'My Role'),
                    subtitle: roleLabel,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(roleLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppTheme.muted),
                      ],
                    ),
                    onTap: _changeRole,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: _t(lang, 'E-posta', 'Email'),
                    subtitle: _email,
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.lock_outlined,
                    title: _t(lang, 'Şifre', 'Password'),
                    subtitle: _t(lang, 'Şifrenizi güncelleyin', 'Update your password'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(_t(lang, 'Şifre Güncelle', 'Update Password')),
                        content: Text(_t(lang,
                            'Şifre güncelleme özelliği yakında aktif olacak.',
                            'Password update feature coming soon.')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(_t(lang, 'Tamam', 'OK')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SectionLabel(title: _t(lang, 'UYGULAMA', 'APP')),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: _t(lang, 'Nasıl Kullanılır', 'How to Use'),
                    subtitle: _t(lang, 'Ekran bazlı rehber', 'Screen-based guide'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                    onTap: () => showHelpSheet(context),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: _t(lang, 'GreenLedger Hakkında', 'About GreenLedger'),
                    subtitle: _t(lang, 'v1.0.0 · Sürdürülebilir Finans Platformu', 'v1.0.0 · Sustainable Finance Platform'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'GreenLedger',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.eco, color: Colors.white, size: 28),
                      ),
                      children: [
                        Text(_t(lang,
                            'Sürdürülebilir Finans Platformu\nGemini AI ile güçlendirilmiş yeşil finansman çözümleri.',
                            'Sustainable Finance Platform\nGreen financing solutions powered by Gemini AI.')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18,
                    color: AppTheme.destructive),
                label: Text(_t(lang, 'Çıkış Yap', 'Sign Out'),
                    style: const TextStyle(
                        color: AppTheme.destructive,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppTheme.destructive.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String email;
  final String role;
  final IconData roleIcon;

  const _ProfileCard(
      {required this.email, required this.role, required this.roleIcon});

  @override
  Widget build(BuildContext context) {
    final initials = email.isNotEmpty
        ? email.split('@').first.substring(0, 1).toUpperCase()
        : 'G';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF1A5C38)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.muted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
      trailing: trailing,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
