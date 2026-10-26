import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Écran vide illustré : un carnet de comptes avec une pièce « Ar ».
class EtatVide extends StatelessWidget {
  const EtatVide({super.key, required this.titre, this.message});

  final String titre;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 150,
              height: 130,
              child: CustomPaint(painter: _CarnetPainter()),
            ),
            const SizedBox(height: 16),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.cacao,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.noyer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarnetPainter extends CustomPainter {
  const _CarnetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ombre au sol
    canvas.drawOval(
      Rect.fromLTWH(w * 0.12, h * 0.88, w * 0.76, h * 0.08),
      Paint()..color = AppColors.sable,
    );

    // Couverture du carnet
    final couverture = Rect.fromLTWH(w * 0.18, h * 0.08, w * 0.50, h * 0.80);
    canvas.drawRRect(
      RRect.fromRectAndRadius(couverture, const Radius.circular(6)),
      Paint()..color = AppColors.noyer,
    );

    // Reliure, plus sombre
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.18, h * 0.08, w * 0.07, h * 0.80),
        topLeft: const Radius.circular(6),
        bottomLeft: const Radius.circular(6),
      ),
      Paint()..color = AppColors.cacao,
    );

    // Étiquette crème avec deux traits d'écriture
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.31, h * 0.22, w * 0.30, h * 0.22),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.creme,
    );
    final trait = Paint()
      ..color = AppColors.noyer
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.34, h * 0.29),
      Offset(w * 0.58, h * 0.29),
      trait,
    );
    canvas.drawLine(
      Offset(w * 0.34, h * 0.35),
      Offset(w * 0.52, h * 0.35),
      trait,
    );

    // Élastique caramel
    canvas.drawRect(
      Rect.fromLTWH(w * 0.60, h * 0.08, w * 0.025, h * 0.80),
      Paint()..color = AppColors.caramel,
    );

    // Pièce « Ar »
    final centre = Offset(w * 0.72, h * 0.66);
    final rayon = w * 0.17;
    canvas.drawCircle(centre, rayon, Paint()..color = AppColors.caramel);
    canvas.drawCircle(
      centre,
      rayon * 0.74,
      Paint()
        ..color = AppColors.creme
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    final texte = TextPainter(
      text: TextSpan(
        text: 'Ar',
        style: TextStyle(
          fontFamily: AppTheme.fontTitre,
          fontSize: rayon * 0.9,
          fontWeight: FontWeight.w600,
          color: AppColors.creme,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    texte.paint(canvas, centre - Offset(texte.width / 2, texte.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}