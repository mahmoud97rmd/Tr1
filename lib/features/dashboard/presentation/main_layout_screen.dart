import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import 'main_dashboard_screen.dart';
import '../../strategy_config/presentation/configurator_screen.dart';
import '../../radar_positions/presentation/live_radar_screen.dart';
import '../../backtest_studio/presentation/backtest_studio_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MainDashboardScreen(),
    const LiveRadarScreen(),
    const ConfiguratorScreen(),
    const BacktestStudioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      drawer: _buildSideMenu(),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceGlass, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryNeon,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.radar_rounded), label: 'Live Radar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Strategy'),
            BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'Backtest'),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryNeon.withOpacity(0.8), AppColors.backgroundDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.auto_graph_rounded, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text('Gold Scalper v5.2', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                Text('Triple-Engine Algo', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.rocket_launch, 'Quick Actions', () {}),
          _buildDrawerItem(Icons.history, 'Trade History', () {}),
          _buildDrawerItem(Icons.analytics, 'Deep Analytics', () {}),
          _buildDrawerItem(Icons.notifications_active, 'Alerts Setup', () {}),
          const Divider(color: AppColors.surfaceGlass),
          _buildDrawerItem(Icons.security, 'API Keys', () {}),
          _buildDrawerItem(Icons.help_outline, 'Documentation', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.bodyText),
      onTap: onTap,
    );
  }
}
