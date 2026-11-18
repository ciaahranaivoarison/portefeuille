import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/reglages.dart';
import '../../widgets/ui.dart';

/// Choix du mode d'apparence : clair, sombre ou automatique.
class ApparencePage extends StatelessWidget {
  const ApparencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Reglages.instance,
      builder: (context, _) {
        final mode = Reglages.instance.mode;
        final p = context.pal;

        return Scaffold(
          appBar: AppBar(title: const Text('Apparence')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Center(child: PastilleEmoji(':palette:', taille: 74)),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Choisissez votre ambiance',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.texte,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Apparition(
                index: 0,
                child: _CarteMode(
                  emoji: ':sun:',
                  titre: 'Mode clair',
                  description: 'Fond crème, pour la journée',
                  apercu: const _Apercu(Palette.clair),
                  actif: mode == ThemeMode.light,
                  onTap: () => Reglages.instance.definirMode(ThemeMode.light),
                ),
              ),
              const SizedBox(height: 12),
              Apparition(
                index: 1,
                child: _CarteMode(
                  emoji: ':moon:',
                  titre: 'Mode sombre',
                  description: 'Bruns chocolat, reposant le soir',
                  apercu: const _Apercu(Palette.sombre),
                  actif: mode == ThemeMode.dark,
                  onTap: () => Reglages.instance.definirMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(height: 12),
              Apparition(
                index: 2,
                child: _CarteMode(
                  emoji: ':smartphone:',
                  titre: 'Automatique',
                  description: 'Suit le réglage de votre téléphone',
                  apercu: const _ApercuMoitie(),
                  actif: mode == ThemeMode.system,
                  onTap: () => Reglages.instance.definirMode(ThemeMode.system),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(':lightbulb:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Votre choix s'applique à tous les écrans et reste "
                        'mémorisé quand vous fermez l\'application.',
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarteMode extends StatelessWidget {
  const _CarteMode({
    required this.emoji,
    required this.titre,
    required this.description,
    required this.apercu,
    required this.actif,
    required this.onTap,
  });

  final String emoji;
  final String titre;
  final String description;
  final Widget apercu;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: actif ? p.principal : p.bordure,
          width: actif ? 2 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                apercu,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$emoji  $titre',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: actif
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey<bool>(true),
                          color: p.principal,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey<bool>(false),
                          color: p.bordure,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Miniature d'un écran dans une palette donnée.
class _Apercu extends StatelessWidget {
  const _Apercu(this.p);

  final Palette p;

  Widget _ligne() {
    return Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: p.texteDoux.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: p.fond,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.bordure),
      ),
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [p.heroDebut, p.heroFin]),
            ),
          ),
          const SizedBox(height: 7),
          _ligne(),
          const SizedBox(height: 5),
          _ligne(),
          const SizedBox(height: 5),
          _ligne(),
        ],
      ),
    );
  }
}

/// Miniature coupée en deux : moitié claire, moitié sombre.
class _ApercuMoitie extends StatelessWidget {
  const _ApercuMoitie();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 0.5,
            child: const _Apercu(Palette.clair),
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: 0.5,
            child: const _Apercu(Palette.sombre),
          ),
        ),
      ],
    );
  }
}