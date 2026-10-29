import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../accounts/accounts_page.dart';
import '../budgets/budgets_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../stats/stats_page.dart';

/// Structure principale : le contenu et le menu flottant du bas.
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
    final p = context.pal;
    final sombre = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (sombre ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: p.fond,
        systemNavigationBarIconBrightness:
            sombre ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
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
      ),
    );
  }
}

/// Menu flottant : chaque onglet montre son emoji et son nom. L'onglet
/// actif est mis en valeur par une pastille caramel et un petit trait.
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
    final p = context.pal;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: p.bordure),
            boxShadow: [
              BoxShadow(
                color: p.texte.withValues(alpha: 0.12),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < entrees.length; i++)
                Expanded(
                  child: _Entree(
                    emoji: entrees[i].$1,
                    libelle: entrees[i].$2,
                    actif: i == index,
                    onTap: () => onTap(i),
                  ),
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
    final p = context.pal;
    const duree = Duration(milliseconds: 280);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: duree,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: actif ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: actif ? 1.2 : 1.0,
              duration: duree,
              curve: Curves.easeOutBack,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: duree,
              style: TextStyle(
                fontSize: 11,
                fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
                color: actif ? p.principal : p.texteDoux,
              ),
              child: Text(
                libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: duree,
              curve: Curves.easeOutCubic,
              width: actif ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}