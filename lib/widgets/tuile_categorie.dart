import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../core/app_theme.dart';
import '../core/emojis.dart';
import '../data/categories.dart';
import 'ui.dart';

/// Tuile de catégorie, identique dans Paramètres, Catégories et dans
/// Nouvelle opération : icône, nom, nombre d'opérations et mention
/// « Par défaut » ou « Personnalisée ». Quand elle est [selectionnee], elle
/// prend un contour brun et une coche.
class TuileCategorie extends StatelessWidget {
  const TuileCategorie({
    super.key,
    required this.info,
    required this.largeur,
    required this.onTap,
    this.selectionnee = false,
  });

  final CategoryInfo info;
  final double largeur;
  final VoidCallback onTap;
  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const duree = Duration(milliseconds: 220);
    final operations = info.usage > 1
        ? '${info.usage} opérations'
        : '${info.usage} opération';

    return SizedBox(
      width: largeur,
      child: AnimatedContainer(
        duration: duree,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selectionnee
              ? Color.alphaBlend(p.principal.withValues(alpha: 0.10), p.surface)
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      PastilleEmoji(emojiCategorie(info.name), taille: 44),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: duree,
                        child: selectionnee
                            ? Icon(
                                Icons.check_circle_rounded,
                                key: const ValueKey<String>('choisie'),
                                size: 22,
                                color: p.principal,
                              )
                            : Icon(
                                info.isDefault
                                    ? Icons.lock_outline_rounded
                                    : Icons.edit_outlined,
                                key: const ValueKey<String>('etat'),
                                size: 18,
                                color: p.texteDoux,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: p.texte,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    operations,
                    style: TextStyle(fontSize: 12, color: p.texteDoux),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.isDefault ? 'Par défaut' : 'Personnalisée',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.accent,
                    ),
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