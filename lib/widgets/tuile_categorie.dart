import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../core/app_theme.dart';
import '../core/emojis.dart';
import '../data/categories.dart';
import 'ui.dart';

/// Tuile de catégorie, comme dans Paramètres, Catégories : icône, nom et
/// mention « Par défaut » ou « Personnalisée ». Utilisée pour choisir la
/// catégorie d'une opération (contour brun et coche quand elle est choisie).
class TuileCategorie extends StatelessWidget {
  const TuileCategorie({
    super.key,
    required this.info,
    required this.largeur,
    required this.selectionnee,
    required this.onTap,
  });

  final CategoryInfo info;
  final double largeur;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const duree = Duration(milliseconds: 220);

    return SizedBox(
      width: largeur,
      child: AnimatedContainer(
        duration: duree,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selectionnee
              ? p.principal.withValues(alpha: 0.10)
              : p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectionnee ? p.principal : p.bordure,
            width: selectionnee ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              child: Row(
                children: [
                  PastilleEmoji(emojiCategorie(info.name), taille: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          info.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: p.texte,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info.isDefault ? 'Par défaut' : 'Personnalisée',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: duree,
                    child: selectionnee
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey<bool>(true),
                            color: p.principal,
                            size: 22,
                          )
                        : const SizedBox(key: ValueKey<bool>(false), width: 22),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}