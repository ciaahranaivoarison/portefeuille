import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../core/app_theme.dart';
import '../data/categories.dart';
import 'pastille_categorie.dart';

/// Tuile de catégorie : icône colorée, nom, nombre d'opérations, barre de
/// part d'utilisation (facultative) et mention « Par défaut » ou
/// « Personnalisée ».
class TuileCategorie extends StatelessWidget {
  const TuileCategorie({
    super.key,
    required this.info,
    required this.largeur,
    required this.onTap,
    this.selectionnee = false,
    this.part,
  });

  final CategoryInfo info;
  final double largeur;
  final VoidCallback onTap;
  final bool selectionnee;

  /// Part d'utilisation entre 0 et 1 pour la barre fine ; null = pas de barre.
  final double? part;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final teinte = teinteCategorie(context, info.name);
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
              ? Color.alphaBlend(teinte.withValues(alpha: 0.08), p.surface)
              : p.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selectionnee ? p.principal : p.bordure,
            width: selectionnee ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: teinte.withValues(alpha: 0.13),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Positioned(
                    right: -28,
                    top: -28,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: teinte.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            PastilleCategorie(info.name, taille: 50),
                            const Spacer(),
                            AnimatedSwitcher(
                              duration: duree,
                              child: selectionnee
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      key: const ValueKey<String>('choisie'),
                                      size: 24,
                                      color: p.principal,
                                    )
                                  : Container(
                                      key: const ValueKey<String>('etat'),
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: p.surfaceDouce,
                                      ),
                                      child: Icon(
                                        info.isDefault
                                            ? Icons.lock_outline_rounded
                                            : Icons.edit_outlined,
                                        size: 15,
                                        color: p.texteDoux,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          info.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            height: 1.15,
                            color: p.texte,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 14,
                              color: p.texteDoux,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                operations,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: p.texteDoux,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (part != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 5,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Container(color: p.surfaceDouce),
                                  FractionallySizedBox(
                                    widthFactor: part!.clamp(0.0, 1.0),
                                    child: Container(color: teinte),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            info.isDefault ? 'Par défaut' : 'Personnalisée',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.accent,
                            ),
                          ),
                        ),
                      ],
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