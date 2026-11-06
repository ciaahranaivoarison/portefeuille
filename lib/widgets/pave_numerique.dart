import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'couleur_securite.dart';

/// Points qui se remplissent au fil de la saisie d'un code PIN.
class PointsPin extends StatelessWidget {
  const PointsPin({
    super.key,
    required this.longueur,
    required this.remplis,
    this.erreur = false,
  });

  final int longueur;
  final int remplis;

  /// Si vrai, tous les points deviennent rouges.
  final bool erreur;

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    final couleur = erreur ? c.erreur : c.principal;

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
                    : couleur.withValues(alpha: 0.22),
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
  });

  final ValueChanged<String> onChiffre;
  final VoidCallback onEffacer;
  final bool actif;

  Widget _cellule(
    BuildContext context, {
    Widget? contenu,
    VoidCallback? onTap,
  }) {
    final c = CouleurSecurite.de(context);
    return Expanded(
      child: SizedBox(
        height: 68,
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
                splashColor: c.principal.withValues(alpha: 0.18),
                highlightColor: c.principal.withValues(alpha: 0.10),
                child: Center(child: contenu),
              ),
      ),
    );
  }

  Widget _chiffre(BuildContext context, String n) {
    final c = CouleurSecurite.de(context);
    return _cellule(
      context,
      contenu: Text(
        n,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: c.texte,
        ),
      ),
      onTap: () => onChiffre(n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  color: c.texte,
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

/// Gros bouton rond d'empreinte digitale, avec un halo qui pulse.
class BoutonBiometrie extends StatefulWidget {
  const BoutonBiometrie({super.key, required this.onTap, this.taille = 84});

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
          width: taille + 32,
          height: taille + 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.principal.withValues(alpha: 0.08 + 0.08 * t),
          ),
          child: enfant,
        );
      },
      child: Material(
        color: c.principal,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            width: taille,
            height: taille,
            child: Icon(
              Icons.fingerprint,
              size: taille * 0.55,
              color: c.surPrincipal,
            ),
          ),
        ),
      ),
    );
  }
}