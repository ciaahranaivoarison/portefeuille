import 'package:flutter/material.dart' hide Text;

import '../../core/app_theme.dart';
import '../../core/reglages.dart';
import '../../widgets/texte.dart';
import '../../widgets/ui.dart';

/// Choix de la langue : français, anglais ou malgache.
class LanguePage extends StatelessWidget {
  const LanguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Reglages.instance,
      builder: (context, _) {
        final actuelle = Reglages.instance.langue;
        final p = context.pal;

        return Scaffold(
          appBar: AppBar(title: const Text('Langue')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Center(child: PastilleEmoji(':globe:', taille: 74)),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  "Choisissez la langue de l'application",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.texte,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              for (var i = 0; i < Reglages.langues.length; i++)
                Apparition(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CarteLangue(
                      drapeau: Reglages.langues[i].$2,
                      nom: Reglages.langues[i].$3,
                      actif: actuelle == Reglages.langues[i].$1,
                      onTap: () =>
                          Reglages.instance.definirLangue(Reglages.langues[i].$1),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MEmoji(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Le changement s'applique tout de suite à tous les écrans.",
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

/// Petite ampoule d'information.
class MEmoji extends StatelessWidget {
  const MEmoji({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(':lightbulb:', style: TextStyle(fontSize: 18));
  }
}

class _CarteLangue extends StatelessWidget {
  const _CarteLangue({
    required this.drapeau,
    required this.nom,
    required this.actif,
    required this.onTap,
  });

  final String drapeau;
  final String nom;
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Text(drapeau, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
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