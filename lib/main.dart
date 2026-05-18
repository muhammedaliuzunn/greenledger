import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/notification_service.dart';
import 'services/data_service.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sellers_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/ai_advisor_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/help_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const GreenLedgerApp(),
    ),
  );
}

class GreenLedgerApp extends StatelessWidget {
  const GreenLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) => MaterialApp(
        title: 'GreenLedger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        scrollBehavior: const _NoGlowScrollBehavior(),
        home: const SplashScreen(),
      ),
    );
  }
}

// ── Bildirimler Alt Paneli ────────────────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sellers = await DataService.getSellers();
    final notifs = <Map<String, dynamic>>[];
    for (final s in sellers) {
      if (s.greenScore >= 70 && s.creditLimit > 0) {
        notifs.add({
          'message': '${s.name}: ₺${(s.creditLimit / 1000).toStringAsFixed(0)}K kredi hazır! Faiz: %${s.interestRate}',
          'color': AppTheme.primary,
          'icon': Icons.credit_card,
        });
      }
      if (s.greenScore >= 80) {
        notifs.add({
          'message': '${s.name} Mükemmel GreenScore\'a ulaştı: ${s.greenScore.toInt()}!',
          'color': AppTheme.accent,
          'icon': Icons.eco,
        });
      }
    }
    if (mounted) setState(() { _notifications = notifs.take(10).toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Bildirimler',
                    style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat', style: TextStyle(color: AppTheme.muted)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            )
          else if (_notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.notifications_none, size: 48, color: AppTheme.border),
                  SizedBox(height: 8),
                  Text('Henüz bildirim yok', style: TextStyle(color: AppTheme.muted)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (n['color'] as Color).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (n['color'] as Color).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(n['icon'] as IconData, color: n['color'] as Color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(n['message'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                color: n['color'] as Color,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class _AppDrawer extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onLangChanged;
  final bool isDark;
  final double quickMinScore;
  final bool quickEcoOnly;
  final void Function(double minScore, bool ecoOnly) onQuickFilter;

  const _AppDrawer({
    required this.lang,
    required this.onLangChanged,
    required this.isDark,
    required this.quickMinScore,
    required this.quickEcoOnly,
    required this.onQuickFilter,
  });

  String _t(String tr, String en) => lang == 'EN' ? en : tr;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final activeFilters = quickMinScore > 0 || quickEcoOnly;

    return Drawer(
      width: 300,
      backgroundColor: bg,
      child: Column(
        children: [
          // ── Gradient Header ──────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, Color(0xFF1A5C38)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GreenLedger',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                            const Text('v1.0.0 · DATALIM',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white60)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.eco,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          _t('Sürdürülebilir Finans',
                              'Sustainable Finance'),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── İçerik ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Dil Seçimi ───────────────────────────
                  _SectionLabel(_t('DİL', 'LANGUAGE')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    child: Row(
                      children: [
                        _LangButton(
                          flag: '🇹🇷',
                          label: 'Türkçe',
                          selected: lang == 'TR',
                          onTap: () => onLangChanged('TR'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _LangButton(
                          flag: '🇬🇧',
                          label: 'English',
                          selected: lang == 'EN',
                          onTap: () => onLangChanged('EN'),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  _DrawerDivider(),

                  // ── Hızlı Filtreler ──────────────────────
                  _SectionLabel(_t('HIZLI FİLTRELER', 'QUICK FILTERS')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('Min GreenScore', 'Min GreenScore'),
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [0, 50, 70, 90].map((score) {
                            final selected =
                                quickMinScore == score.toDouble();
                            return GestureDetector(
                              onTap: () => onQuickFilter(
                                  score.toDouble(), quickEcoOnly),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.primary
                                      : isDark
                                          ? Colors.white10
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  score == 0
                                      ? _t('Tümü', 'All')
                                      : '$score+',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: quickEcoOnly
                                ? AppTheme.primary.withOpacity(0.08)
                                : isDark
                                    ? Colors.white10
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: quickEcoOnly
                                  ? AppTheme.primary.withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.eco,
                                  size: 18,
                                  color: quickEcoOnly
                                      ? AppTheme.primary
                                      : AppTheme.muted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _t('Sadece Eco', 'Eco Only'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: quickEcoOnly
                                        ? AppTheme.primary
                                        : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                              Switch(
                                value: quickEcoOnly,
                                activeColor: AppTheme.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (v) =>
                                    onQuickFilter(quickMinScore, v),
                              ),
                            ],
                          ),
                        ),
                        if (activeFilters) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => onQuickFilter(0, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.destructive.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppTheme.destructive
                                        .withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.close,
                                      size: 13,
                                      color: AppTheme.destructive),
                                  const SizedBox(width: 6),
                                  Text(
                                    _t('Filtreleri Temizle',
                                        'Clear Filters'),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.destructive,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  _DrawerDivider(),

                  // ── Yardım ───────────────────────────────
                  _SectionLabel(_t('DESTEK', 'SUPPORT')),
                  _DrawerTile(
                    icon: Icons.help_outline_rounded,
                    title: _t('Yardım & SSS', 'Help & FAQ'),
                    subtitle:
                        _t('Nasıl kullanılır?', 'How to use?'),
                    onTap: () {
                      Navigator.pop(context);
                      showHelpSheet(context);
                    },
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: AppTheme.border.withOpacity(0.5));
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        title: Text(title,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 12, color: AppTheme.muted),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _LangButton({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary
                : isDark
                    ? Colors.white10
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};
  String _role = 'seller';
  String _lang = 'TR';
  double _quickMinScore = 0;
  bool _quickEcoOnly = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _loadLang();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _role = prefs.getString('user_role') ?? 'seller');
  }

  Future<void> _loadLang() async {
    final lang = context.read<LanguageProvider>().lang;
    if (mounted) setState(() => _lang = lang);
  }

  Future<void> _setLang(String lang) async {
    if (mounted) {
      setState(() => _lang = lang);
      context.read<LanguageProvider>().setLang(lang);
    }
  }

  List<Widget> get _screens => [
    const DashboardScreen(),
    _role == 'buyer'
        ? const PortfolioScreen()
        : SellersScreen(quickMinScore: _quickMinScore, quickEcoOnly: _quickEcoOnly),
    const LeaderboardScreen(),
    const CreditsScreen(),
    const AIAdvisorScreen(),
  ];

  String _t(String tr, String en) => _lang == 'EN' ? en : tr;

  List<NavigationDestination> get _destinations => [
    NavigationDestination(
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard),
      label: _t('Ana Sayfa', 'Home'),
    ),
    if (_role == 'buyer')
      NavigationDestination(
        icon: const Icon(Icons.pie_chart_outline),
        selectedIcon: const Icon(Icons.pie_chart),
        label: _t('Portfolio', 'Portfolio'),
      )
    else
      NavigationDestination(
        icon: const Icon(Icons.store_outlined),
        selectedIcon: const Icon(Icons.store),
        label: _t('Satıcılar', 'Sellers'),
      ),
    NavigationDestination(
      icon: const Icon(Icons.leaderboard_outlined),
      selectedIcon: const Icon(Icons.leaderboard),
      label: _t('Sıralama', 'Rankings'),
    ),
    NavigationDestination(
      icon: const Icon(Icons.credit_card_outlined),
      selectedIcon: const Icon(Icons.credit_card),
      label: _t('Kredi', 'Credit'),
    ),
    NavigationDestination(
      icon: const Icon(Icons.psychology_outlined),
      selectedIcon: const Icon(Icons.psychology),
      label: _t('AI Koç', 'AI Coach'),
    ),
  ];

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = _screens;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _AppDrawer(
        lang: _lang,
        onLangChanged: _setLang,
        isDark: isDark,
        quickMinScore: _quickMinScore,
        quickEcoOnly: _quickEcoOnly,
        onQuickFilter: (minScore, ecoOnly) {
          setState(() {
            _quickMinScore = minScore;
            _quickEcoOnly = ecoOnly;
          });
          if (_currentIndex != 1) setState(() => _currentIndex = 1);
        },
      ),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          'GreenLedger',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: isDark ? AppTheme.darkMuted : AppTheme.muted),
            onPressed: () => _showNotifications(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadRole()),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primary.withOpacity(0.2)
                      : const Color(0xFFE8F5EE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'GL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu,
                color: isDark ? AppTheme.darkMuted : AppTheme.muted),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: Stack(
        children: List.generate(screens.length, (i) {
          if (!_visitedTabs.contains(i)) return const SizedBox.shrink();
          return Offstage(
            offstage: i != _currentIndex,
            child: TickerMode(
              enabled: i == _currentIndex,
              child: screens[i],
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          border: Border(
              top: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() {
            _currentIndex = i;
            _visitedTabs.add(i);
          }),
          destinations: _destinations,
        ),
      ),
    );
  }
}
