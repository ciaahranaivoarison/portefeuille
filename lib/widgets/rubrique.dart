import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../core/app_theme.dart';
import 'ui.dart';

/// Ligne de paramètre : emoji, titre, sous-titre et flèche.
class Rubrique extends StatelessWidget {
  const Rubrique({
    super.key,
    required this.emoji,
    required this.titre,
    required this.onTap,
    this.sousTitre,
    this.etiquette,
  });

  final String emoji;
  final String titre;
  final String? sousTitre;

  /// Petite pastille verte à droite (ex. : « Activée »).
  final String? etiquette;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            PastilleEmoji(emoji, taille: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  if (sousTitre != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        sousTitre!,
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ),
                ],
              ),
            ),
            if (etiquette != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.revenu.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  etiquette!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: p.revenu,
                  ),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: p.texteDoux),
          ],
        ),
      ),
    );
  }
}

/// Carte qui regroupe plusieurs lignes séparées par un filet.
class CarteRubriques extends StatelessWidget {
  const CarteRubriques({super.key, required this.enfants});

  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < enfants.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 74),
            enfants[i],
          ],
        ],
      ),
    );
  }
}