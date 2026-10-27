import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formats.dart';

/// Fait apparaître un élément en fondu, avec un léger glissement vers
/// le haut. Plus [index] est grand, plus l'apparition est retardée.
class Apparition extends StatelessWidget {
  const Apparition({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final rang = index > 10 ? 10 : index;
    final delaiMs = 70 * rang;
    final dureeMs = 450 + delaiMs;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: dureeMs),
      curve: Interval(delaiMs / dureeMs, 1.0, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

/// Affiche un montant en Ariary qui « défile » jusqu'à sa valeur.
class MontantAnime extends StatelessWidget {
  const MontantAnime({super.key, required this.montant, this.style});

  final int montant;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: montant.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, valeur, _) =>
          Text(formatAr(valeur.round()), style: style),
    );
  }
}

/// Emoji dans une pastille ronde.
class PastilleEmoji extends StatelessWidget {
  const PastilleEmoji(this.emoji, {super.key, this.taille = 42});

  final String emoji;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.creme,
        border: Border.all(color: AppColors.sable),
      ),
      child: Text(emoji, style: TextStyle(fontSize: taille * 0.48)),
    );
  }
}

/// Titre de section : petit trait caramel et texte en capitales.
class TitreSection extends StatelessWidget {
  const TitreSection(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.caramel,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texte.toUpperCase(),
            style: const TextStyle(
              fontSize: 12.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.noyer,
            ),
          ),
        ],
      ),
    );
  }
}