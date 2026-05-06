import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'alerts/alerts_screen.dart';
import 'ai/ai_chat_screen.dart';
import 'infrastructure/infrastructure_screen.dart';
import 'logs/logs_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  final screens = const [
    DashboardScreen(),
    AlertsScreen(),
    AIChatScreen(),
    InfrastructureScreen(),
    LogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: screens[currentIndex],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D1424).withValues(alpha: 0.9)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x20000000),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(0,
                        Icons.dashboard_rounded, 'Home',
                        isDark),
                    _navItem(1,
                        Icons.notifications_rounded,
                        'Alerts', isDark),
                    _navItem(2,
                        Icons.smart_toy_rounded, 'AI',
                        isDark),
                    _navItem(3,
                        Icons.storage_rounded, 'Servers',
                        isDark),
                    _navItem(4,
                        Icons.list_alt_rounded, 'Logs',
                        isDark),
                    // Theme toggle
                    _themeToggle(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon,
      String label, bool isDark) {
    bool isActive = currentIndex == index;
    Color inactiveColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF7C3AED)
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    isActive ? Colors.white : inactiveColor,
                size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : inactiveColor,
                  fontSize: 9,
                  fontWeight: isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  Widget _themeToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        themeNotifier.value =
            isDark ? ThemeMode.light : ThemeMode.dark;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: isDark
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              isDark ? 'Light' : 'Dark',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF64748B),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}