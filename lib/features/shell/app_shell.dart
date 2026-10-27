import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../accounts/accounts_page.dart';
import '../budgets/budgets_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../stats/stats_page.dart';

/// Structure principale : le contenu et le menu du bas.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _entrees = <(String, String)>[
    ('💰', 'Accueil'),
    ('💳', 'Comptes'),
    ('🧾', 'Historique'),
    ('🎯', 'Budgets'),
    ('📊', 'Stats'),
  ];

  Widget _page(int i) => switch (i) {
        0 => const HomePage(),
        1 => const AccountsPage(),
        2 => const HistoryPage(),
        3 => const BudgetsPage(),
        _ => const StatsPage(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: _page(_index),
        ),
      ),
      bottomNavigationBar: _BarreMenu(
        index: _index,
        entrees: _entrees,
        onTap: (i) {
          if (i != _index) setState(() => _index = i);
        },
      ),
    );
  }
}

/// Menu flottant : l'onglet actif devient un bouton marron avec son nom.
class _BarreMenu extends StatelessWidget {
  const _BarreMenu({
    required this.index,
    required this.entrees,
    required this.onTap,
  });

  final int index;
  final List<(String, String)> entrees;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.sable),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E3B2418),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < entrees.length; i++)
                _Entree(
                  emoji: entrees[i].$1,
                  libelle: entrees[i].$2,
                  actif: i == index,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Entree extends StatelessWidget {
  const _Entree({
    required this.emoji,
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String emoji;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: actif ? 12 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: actif ? AppColors.noyer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: actif ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: actif
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        libelle,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          color: AppColors.creme,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}