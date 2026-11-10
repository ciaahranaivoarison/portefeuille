import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import 'couleur_securite.dart';

/// Couleurs des points et du pavé : celles de l'écran de verrouillage
/// (blanc sur brun) ou celles du thème de l'application.
class _Teintes {
  const _Teintes({
    required this.chiffre,
    required this.point,
    required this.erreur,
    required this.eclat,
  });

  final Color chiffre;
  final Color point;
  final Color erreur;
  final Color eclat;

  static _Teintes de(BuildContext context, bool surColore) {
    if (surColore) {
      final c = CouleurSecurite.de(context);
      return _Teintes(
        chiffre: c.texte,
        point: c.texte,
        erreur: c.erreur,
        eclat: c.texte,
      );
    }
    final p = context.pal;
    return _Teintes(
      chiffre: p.texte,
      point: p.principal,
      erreur: p.depense,
      eclat: p.principal,
    );
  }
}

/// Points qui se remplissent au fil de la saisie d'un code PIN.
class PointsPin extends StatelessWidget {
  const PointsPin({
    super.key,
    required this.longueur,
    required this.remplis,
    this.erreur = false,
    this.surColore = false,
  });

  final int longueur;
  final int remplis;

  /// Si vrai, tous les points prennent la couleur d'erreur.
  final bool erreur;

  /// Vrai sur l'écran de verrouillage (points blancs sur fond brun).
  final bool surColore;

  @override
  Widget build(BuildContext context) {
    final t = _Teintes.de(context, surColore);
    final couleur = erreur ? t.erreur : t.point;

    return SizedBox(
      height: 34,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < longueur; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: i < remplis ? 22 : 18,
              height: i < remplis ? 22 : 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (i < remplis || erreur)
                    ? couleur
                    : couleur.withValues(alpha: surColore ? 0.35 : 0.22),
                boxShadow: (i < remplis || erreur)
                    ? [
                        BoxShadow(
                          color: couleur.withValues(alpha: 0.2),
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Clavier de chiffres simple : pas de cadres, seulement les chiffres et
/// une touche d'effacement.
class PaveNumerique extends StatelessWidget {
  const PaveNumerique({
    super.key,
    required this.onChiffre,
    required this.onEffacer,
    this.actif = true,
    this.surColore = false,
    this.hauteur = 68,
  });

  final ValueChanged<String> onChiffre;
  final VoidCallback onEffacer;
  final bool actif;

  /// Vrai sur l'écran de verrouillage (chiffres blancs sur fond brun).
  final bool surColore;

  /// Hauteur d'une ligne de touches.
  final double hauteur;

  Widget _cellule(
    BuildContext context, {
    Widget? contenu,
    VoidCallback? onTap,
  }) {
    final t = _Teintes.de(context, surColore);
    return Expanded(
      child: SizedBox(
        height: hauteur,
        child: contenu == null
            ? null
            : InkResponse(
                onTap: actif
                    ? () {
                        HapticFeedback.selectionClick();
                        onTap?.call();
                      }
                    : null,
                radius: 38,
                highlightShape: BoxShape.circle,
                splashColor: t.eclat.withValues(alpha: 0.18),
                highlightColor: t.eclat.withValues(alpha: 0.10),
                child: Center(child: contenu),
              ),
      ),
    );
  }

  Widget _chiffre(BuildContext context, String n) {
    final t = _Teintes.de(context, surColore);
    return _cellule(
      context,
      contenu: Text(
        n,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: t.chiffre,
        ),
      ),
      onTap: () => onChiffre(n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _Teintes.de(context, surColore);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _chiffre(context, '1'),
              _chiffre(context, '2'),
              _chiffre(context, '3'),
            ],
          ),
          Row(
            children: [
              _chiffre(context, '4'),
              _chiffre(context, '5'),
              _chiffre(context, '6'),
            ],
          ),
          Row(
            children: [
              _chiffre(context, '7'),
              _chiffre(context, '8'),
              _chiffre(context, '9'),
            ],
          ),
          Row(
            children: [
              _cellule(context),
              _chiffre(context, '0'),
              _cellule(
                context,
                contenu: Icon(
                  Icons.backspace_outlined,
                  size: 26,
                  color: t.chiffre,
                ),
                onTap: onEffacer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gros bouton rond d'empreinte digitale : cercle translucide et halo
/// qui pulse. Conçu pour l'écran de verrouillage (fond brun).
class BoutonBiometrie extends StatefulWidget {
  const BoutonBiometrie({super.key, required this.onTap, this.taille = 92});

  final VoidCallback onTap;
  final double taille;

  @override
  State<BoutonBiometrie> createState() => _BoutonBiometrieState();
}

class _BoutonBiometrieState extends State<BoutonBiometrie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    final taille = widget.taille;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, enfant) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          width: taille + 36,
          height: taille + 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.texte.withValues(alpha: 0.05 + 0.07 * t),
          ),
          child: enfant,
        );
      },
      child: Material(
        color: c.voile,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            width: taille,
            height: taille,
            child: Icon(
              Icons.fingerprint,
              size: taille * 0.5,
              color: c.texte,
            ),
          ),
        ),
      ),
    );
  }
}