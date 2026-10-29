import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'ui.dart';

/// En-tête commun aux écrans principaux : un titre avec son emoji et,
/// pour certains écrans, une grande carte de total en dégradé brun-doré.
class EnteteEcran extends StatelessWidget {
  const EnteteEcran({
    super.key,
    required this.emoji,
    required this.titre,
    this.etiquette,
    this.montant,
    this.sousTitre,
    this.action,
    this.badge,
  });

  final String emoji;
  final String titre;

  /// Texte au-dessus du montant de la carte de total.
  final String? etiquette;

  /// Montant de la carte de total (s'affiche avec [etiquette]).
  final int? montant;

  final String? sousTitre;
  final Widget? action;

  /// Petite pastille en haut à droite de la carte de total.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final haut = MediaQuery.paddingOf(context).top;
    final etiquetteHero = etiquette;
    final montantHero = montant;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, haut + 12, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pastille(emoji: emoji),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: TextStyle(
                        fontFamily: AppTheme.fontTitre,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: p.texte,
                      ),
                    ),
                    if (sousTitre != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          sousTitre!,
                          style: TextStyle(fontSize: 13, color: p.texteDoux),
                        ),
                      ),
                  ],
                ),
              ),
              ?action,
            ],
          ),
          if (etiquetteHero != null && montantHero != null) ...[
            const SizedBox(height: 18),
            _CarteHero(
              etiquette: etiquetteHero,
              montant: montantHero,
              badge: badge,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, echelle, child) =>
          Transform.scale(scale: echelle, child: child),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.surface,
          border: Border.all(color: p.bordure),
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _CarteHero extends StatelessWidget {
  const _CarteHero({
    required this.etiquette,
    required this.montant,
    this.badge,
  });

  final String etiquette;
  final int montant;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final rayon = BorderRadius.circular(28);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: rayon,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroDebut, p.heroFin],
        ),
        boxShadow: [
          BoxShadow(
            color: p.heroDebut.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: rayon,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MotifPainter(p.surHero)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          etiquette,
                          style: TextStyle(
                            fontSize: 11.5,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: p.surHero.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: p.surHero.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: p.surHero,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MontantAnime(
                      montant: montant,
                      style: TextStyle(
                        fontFamily: AppTheme.fontTitre,
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        color: p.surHero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Motif de la carte : pièces concentriques.
class _MotifPainter extends CustomPainter {
  const _MotifPainter(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.9, size.height * 0.2);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        centre,
        32.0 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = couleur.withValues(alpha: 0.22 - i * 0.04),
      );
    }
    canvas.drawCircle(
      centre,
      10,
      Paint()..color = couleur.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _MotifPainter old) => old.couleur != couleur;
}