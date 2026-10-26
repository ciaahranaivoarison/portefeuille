import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Bandeau brun décoré d'un motif (pièces et lignes de carnet).
/// Le paramètre [asset] n'est plus utilisé : il est conservé pour ne pas
/// avoir à modifier les écrans qui appellent ce bandeau.
class BanniereImage extends StatelessWidget {
  const BanniereImage({
    super.key,
    this.asset,
    required this.child,
    this.hauteur = 190,
  });

  final String? asset;
  final Widget child;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: hauteur,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.noyer, AppColors.cacao],
                ),
              ),
            ),
            const CustomPaint(painter: _MotifPainter()),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  const _MotifPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Lignes de carnet
    final ligne = Paint()
      ..color = AppColors.creme.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var y = 24.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ligne);
    }

    // Pièces : cercles concentriques en haut à droite
    final centre = Offset(size.width * 0.86, size.height * 0.30);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        centre,
        26.0 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.caramel.withValues(alpha: 0.55 - i * 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}