import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import 'ui.dart';

/// En-tête commun aux écrans principaux : dégradé marron, emoji, titre,
/// et éventuellement un montant animé.
class EnteteEcran extends StatelessWidget {
  const EnteteEcran({
    super.key,
    required this.emoji,
    required this.titre,
    this.etiquette,
    this.montant,
    this.sousTitre,
    this.action,
  });

  final String emoji;
  final String titre;
  final String? etiquette;
  final int? montant;
  final String? sousTitre;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    const rayon = BorderRadius.vertical(bottom: Radius.circular(30));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: rayon,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.noyer, AppColors.cacao],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x333B2418),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: rayon,
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _MotifPainter()),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.4, end: 1),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.elasticOut,
                            builder: (context, echelle, child) =>
                                Transform.scale(scale: echelle, child: child),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.creme.withValues(alpha: 0.16),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              titre,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontTitre,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.creme,
                              ),
                            ),
                          ),
                          ?action,
                          //if (action != null) action!,
                        ],
                      ),
                      if (etiquette != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          etiquette!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sable,
                          ),
                        ),
                      ],
                      if (montant != null) ...[
                        const SizedBox(height: 4),
                        MontantAnime(
                          montant: montant!,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: AppColors.creme,
                          ),
                        ),
                      ],
                      if (sousTitre != null) ...[
                        SizedBox(height: etiquette != null ? 6 : 12),
                        Text(
                          sousTitre!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.sable,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Motif du bandeau : lignes de carnet et pièces concentriques.
class _MotifPainter extends CustomPainter {
  const _MotifPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ligne = Paint()
      ..color = AppColors.creme.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var y = 26.0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ligne);
    }

    final centre = Offset(size.width * 0.88, size.height * 0.28);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        centre,
        28.0 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.caramel.withValues(alpha: 0.55 - i * 0.1),
      );
    }
    canvas.drawCircle(
      centre,
      9,
      Paint()..color = AppColors.caramel.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}