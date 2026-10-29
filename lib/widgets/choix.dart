import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Petite pastille de choix (période, compte, catégorie, filtre...).
class ChipChoix extends StatelessWidget {
  const ChipChoix({
    super.key,
    required this.libelle,
    required this.actif,
    required this.onTap,
    this.emoji,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: actif ? p.principal : p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: actif ? p.principal : p.bordure),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              libelle,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: actif ? p.surPrincipal : p.texte,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grande carte de choix avec un emoji (type d'opération, type de compte).
/// Se place dans un Expanded, à l'intérieur d'un Row.
class CarteChoix extends StatelessWidget {
  const CarteChoix({
    super.key,
    required this.emoji,
    required this.libelle,
    required this.actif,
    required this.onTap,
    this.couleur,
  });

  final String emoji;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = couleur ?? p.principal;
    const duree = Duration(milliseconds: 250);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: duree,
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: actif ? c.withValues(alpha: 0.14) : p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: actif ? c : p.bordure,
            width: actif ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: actif ? 1.15 : 1.0,
              duration: duree,
              curve: Curves.easeOutBack,
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 6),
            Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: actif ? c : p.texteDoux,
              ),
            ),
          ],
        ),
      ),
    );
  }
}