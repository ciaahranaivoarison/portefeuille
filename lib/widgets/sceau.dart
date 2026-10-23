import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Sceau de l'application : un cachet brun marqué « Ar ».
class Sceau extends StatelessWidget {
  const Sceau({super.key, this.taille = 84});

  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.sable,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.noyer,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.caramel, width: 1.5),
          ),
          child: Text(
            'Ar',
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: taille * 0.34,
              fontWeight: FontWeight.w600,
              color: AppColors.creme,
            ),
          ),
        ),
      ),
    );
  }
}