import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

export 'dashboard_screen.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة المراقبة الرئيسية — HomeScreen (Alias to DashboardScreen)
/// ══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
