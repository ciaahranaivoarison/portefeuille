import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';

/// Structure principale : le contenu et la barre de navigation du bas.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _index == 0 ? const HomePage() : const HistoryPage(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.blanc,
        indicatorColor: AppColors.sable,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}