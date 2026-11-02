import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';

/// Points qui se remplissent au fil de la saisie d'un code PIN.
class PointsPin extends StatelessWidget {
  const PointsPin({super.key, required this.longueur, required this.remplis});

  final int longueur;
  final int remplis;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < longueur; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              width: i < remplis ? 20 : 14,
              height: i < remplis ? 20 : 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < remplis ? p.principal : Colors.transparent,
                border: Border.all(
                  color: i < remplis
                      ? p.principal
                      : p.texteDoux.withValues(alpha: 0.6),
                  width: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pavé numérique rond (0 à 9, effacer, et bouton biométrie facultatif).
class PaveNumerique extends StatelessWidget {
  const PaveNumerique({
    super.key,
    required this.onChiffre,
    required this.onEffacer,
    this.onBiometrie,
    this.actif = true,
  });

  final ValueChanged<String> onChiffre;
  final VoidCallback onEffacer;

  /// Si elle est fournie, une touche empreinte apparaît en bas à gauche.
  final VoidCallback? onBiometrie;

  final bool actif;

  static const _taille = 72.0;

  Widget _rond(BuildContext context, Widget contenu, VoidCallback onTap) {
    final p = context.pal;
    return Material(
      color: p.surface,
      shape: CircleBorder(side: BorderSide(color: p.bordure)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: actif
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: SizedBox(
          width: _taille,
          height: _taille,
          child: Center(child: contenu),
        ),
      ),
    );
  }

  Widget _chiffre(BuildContext context, String n) {
    final p = context.pal;
    return _rond(
      context,
      Text(
        n,
        style: TextStyle(
          fontFamily: AppTheme.fontTitre,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: p.texte,
        ),
      ),
      () => onChiffre(n),
    );
  }

  Widget _icone(BuildContext context, IconData icone, VoidCallback onTap) {
    return _rond(context, Icon(icone, color: context.pal.principal), onTap);
  }

  Widget _ligne(List<Widget> touches) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < touches.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            touches[i],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometrie = onBiometrie;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ligne([
          _chiffre(context, '1'),
          _chiffre(context, '2'),
          _chiffre(context, '3'),
        ]),
        _ligne([
          _chiffre(context, '4'),
          _chiffre(context, '5'),
          _chiffre(context, '6'),
        ]),
        _ligne([
          _chiffre(context, '7'),
          _chiffre(context, '8'),
          _chiffre(context, '9'),
        ]),
        _ligne([
          biometrie != null
              ? _icone(context, Icons.fingerprint, biometrie)
              : const SizedBox(width: _taille, height: _taille),
          _chiffre(context, '0'),
          _icone(context, Icons.backspace_outlined, onEffacer),
        ]),
      ],
    );
  }
}