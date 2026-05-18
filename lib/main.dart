import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
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
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Menü',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const Divider(),
            // Dil Seçimi
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Dil / Language',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _LangChip(
                    label: 'TR',
                    selected: lang == 'TR',
                    onTap: () => onLangChanged('TR'),
                  ),
                  const SizedBox(width: 8),
                  _LangChip(
                    label: 'EN',
                    selected: lang == 'EN',
                    onTap: () => onLangChanged('EN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Hızlı Filtreler
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Hızlı Filtreler',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min GreenScore',
                      style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [0, 50, 70, 90].map((score) {
                      final selected = quickMinScore == score.toDouble();
                      return GestureDetector(
                        onTap: () => onQuickFilter(score.toDouble(), quickEcoOnly),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? AppTheme.primary : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            score == 0 ? 'Tümü' : '$score+',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selected ? Colors.white : AppTheme.muted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sadece Eco',
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                      Switch(
                        value: quickEcoOnly,
                        activeColor: AppTheme.primary,
                        onChanged: (v) => onQuickFilter(quickMinScore, v),
                      ),
                    ],
                  ),
                  if (quickMinScore > 0 || quickEcoOnly)
                    TextButton(
                      onPressed: () => onQuickFilter(0, false),
                      child: const Text('Filtreleri Temizle',
                          style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const Divider(),
            // Yardım & SSS
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppTheme.primary),
              title: Text(
                'Yardım & SSS',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Nasıl kullanılır?',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              onTap: () {
                Navigator.pop(context);
                showHelpSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppTheme.muted,
            fontSize: 14,
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
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _lang = prefs.getString('app_lang') ?? 'TR');
  }

  Future<void> _setLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', lang);
    if (mounted) setState(() => _lang = lang);
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

  List<NavigationDestination> get _destinations => [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Ana Sayfa',
    ),
    if (_role == 'buyer')
      const NavigationDestination(
        icon: Icon(Icons.pie_chart_outline),
        selectedIcon: Icon(Icons.pie_chart),
        label: 'Portfolio',
      )
    else
      const NavigationDestination(
        icon: Icon(Icons.store_outlined),
        selectedIcon: Icon(Icons.store),
        label: 'Satıcılar',
      ),
    const NavigationDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard),
      label: 'Sıralama',
    ),
    const NavigationDestination(
      icon: Icon(Icons.credit_card_outlined),
      selectedIcon: Icon(Icons.credit_card),
      label: 'Kredi',
    ),
    const NavigationDestination(
      icon: Icon(Icons.psychology_outlined),
      selectedIcon: Icon(Icons.psychology),
      label: 'AI Koç',
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
