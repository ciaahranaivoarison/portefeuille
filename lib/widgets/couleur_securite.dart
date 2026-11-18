import 'package:flutter/material.dart';

/// Couleurs de l'écran de verrouillage : fond brun-caramel, éléments
/// blancs et translucides. Pour changer l'allure de cet écran, modifiez
/// uniquement ce fichier.
class CouleurSecurite {
  const CouleurSecurite._({
    required this.fondHaut,
    required this.fondBas,
    required this.panneau,
    required this.bordurePanneau,
    required this.voile,
    required this.texte,
    required this.douce,
    required this.bouton,
    required this.surBouton,
    required this.champ,
    required this.erreur,
  });

  /// Haut du dégradé de fond.
  final Color fondHaut;

  /// Bas du dégradé de fond.
  final Color fondBas;

  /// Panneau translucide qui contient le champ et le bouton.
  final Color panneau;

  /// Fin liseré autour du panneau.
  final Color bordurePanneau;

  /// Cercles translucides (empreinte, pastilles du bas).
  final Color voile;

  /// Titres, chiffres et icônes.
  final Color texte;

  /// Textes secondaires.
  final Color douce;

  /// Fond du bouton « Déverrouiller ».
  final Color bouton;

  /// Texte et icônes posés sur les éléments blancs.
  final Color surBouton;

  /// Couleur du mot de passe saisi.
  final Color champ;

  /// Messages d'erreur.
  final Color erreur;

  static const _clair = CouleurSecurite._(
    fondHaut: Color(0xFFC1844F),
    fondBas: Color(0xFFB27546),
    panneau: Color(0x2EFFFFFF),
    bordurePanneau: Color(0x59FFFFFF),
    voile: Color(0x38FFFFFF),
    texte: Color(0xFFFFFFFF),
    douce: Color(0xCCFFFFFF),
    bouton: Color(0xFFFFFFFF),
    surBouton: Color(0xFFB87A4C),
    champ: Color(0xFF5A3A28),
    erreur: Color(0xFFFFD9CF),
  );

  static const _sombre = CouleurSecurite._(
    fondHaut: Color(0xFF7C5539),
    fondBas: Color(0xFF63402B),
    panneau: Color(0x24FFFFFF),
    bordurePanneau: Color(0x4DFFFFFF),
    voile: Color(0x2EFFFFFF),
    texte: Color(0xFFFFF4E8),
    douce: Color(0xCCFFF4E8),
    bouton: Color(0xFFFFF4E8),
    surBouton: Color(0xFF7C5539),
    champ: Color(0xFF4A2F20),
    erreur: Color(0xFFFFB9A8),
  );

  static CouleurSecurite de(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _sombre : _clair;
}
