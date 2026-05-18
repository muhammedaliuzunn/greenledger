import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sellers_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/ai_advisor_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';

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

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};
  String _role = 'seller';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _role = prefs.getString('user_role') ?? 'seller');
  }

  List<Widget> get _screens => [
    const DashboardScreen(),
    _role == 'buyer' ? const PortfolioScreen() : const SellersScreen(),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = _screens;

    return Scaffold(
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
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
