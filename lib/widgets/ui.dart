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
    final p = context.pal;
    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surfaceDouce,
        border: Border.all(color: p.bordure),
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
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texte.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
              color: p.texteDoux,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton rond placé dans l'en-tête d'un écran (paramètres, ajout...).
class BoutonHeader extends StatelessWidget {
  const BoutonHeader({
    super.key,
    required this.icone,
    required this.infobulle,
    required this.onTap,
  });

  final IconData icone;
  final String infobulle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tooltip(
      message: infobulle,
      child: Material(
        color: p.surface,
        shape: CircleBorder(side: BorderSide(color: p.bordure)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icone, color: p.principal, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Carte à bordure en pointillés pour ajouter un élément à une liste
/// (« Ajouter un compte », « Nouveau budget »...).
class CarteAjout extends StatelessWidget {
  const CarteAjout({super.key, required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return CustomPaint(
      foregroundPainter: _BordureTiretee(
        couleur: p.accent.withValues(alpha: 0.75),
        rayon: 20,
      ),
      child: Material(
        color: p.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.principal,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: p.surPrincipal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  libelle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: p.principal,
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

class _BordureTiretee extends CustomPainter {
  const _BordureTiretee({required this.couleur, required this.rayon});

  final Color couleur;
  final double rayon;

  @override
  void paint(Canvas canvas, Size size) {
    final chemin = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(rayon)),
      );
    final pinceau = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final mesure in chemin.computeMetrics()) {
      var distance = 0.0;
      while (distance < mesure.length) {
        canvas.drawPath(mesure.extractPath(distance, distance + 7), pinceau);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BordureTiretee old) =>
      old.couleur != couleur || old.rayon != rayon;
}