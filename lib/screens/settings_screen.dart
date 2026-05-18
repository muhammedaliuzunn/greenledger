import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/help_sheet.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Çıkış Yap',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Çıkış Yap',
                  style: TextStyle(color: AppTheme.destructive))),
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

  String get _roleLabel => _role == 'seller' ? 'Satıcı' : 'Alıcı Platform';
  IconData get _roleIcon =>
      _role == 'seller' ? Icons.store_outlined : Icons.account_balance_outlined;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hesabım',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(email: _email, role: _roleLabel, roleIcon: _roleIcon),

            const SizedBox(height: 24),

            _SectionLabel(title: 'TERCİHLER'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    title: isDark ? 'Aydınlık Mod' : 'Koyu Mod',
                    subtitle: isDark
                        ? 'Açık temaya geçmek için tıklayın'
                        : 'Koyu temaya geçmek için tıklayın',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggle(),
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Kredi ve GreenScore uyarıları',
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

            _SectionLabel(title: 'HESAP'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: _roleIcon,
                    title: 'Rolüm',
                    subtitle: _roleLabel,
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
                          child: Text(_roleLabel,
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
                    title: 'E-posta',
                    subtitle: _email,
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.lock_outlined,
                    title: 'Şifre',
                    subtitle: 'Şifrenizi güncelleyin',
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Şifre Güncelle'),
                        content: const Text(
                            'Şifre güncelleme özelliği yakında aktif olacak.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tamam'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SectionLabel(title: 'UYGULAMA'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Nasıl Kullanılır',
                    subtitle: 'Ekran bazlı rehber',
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.muted),
                    onTap: () => showHelpSheet(context),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'GreenLedger Hakkında',
                    subtitle: 'v1.0.0 · Sürdürülebilir Finans Platformu',
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
                      children: const [
                        Text(
                            'Sürdürülebilir Finans Platformu\nGemini AI ile güçlendirilmiş yeşil finansman çözümleri.'),
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
                label: const Text('Çıkış Yap',
                    style: TextStyle(
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
