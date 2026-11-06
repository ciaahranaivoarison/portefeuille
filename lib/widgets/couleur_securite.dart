import 'package:flutter/material.dart';

/// Couleurs propres aux écrans de sécurité (code PIN, mot de passe,
/// biométrie) : volontairement différentes du brun du reste de
/// l'application. Pour changer la couleur de toute la sécurité,
/// modifiez uniquement ce fichier.
class CouleurSecurite {
  const CouleurSecurite._({
    required this.principal,
    required this.surPrincipal,
    required this.fond,
    required this.texte,
    required this.douce,
    required this.erreur,
  });

  /// Couleur des points, du bouton d'empreinte et des boutons.
  final Color principal;

  /// Couleur de l'icône posée sur le bouton principal.
  final Color surPrincipal;

  /// Fond de l'écran de verrouillage.
  final Color fond;

  /// Couleur des chiffres et des titres.
  final Color texte;

  /// Couleur des textes secondaires.
  final Color douce;

  /// Couleur des erreurs.
  final Color erreur;

  static const _clair = CouleurSecurite._(
    principal: Color(0xFF2F80ED),
    surPrincipal: Color(0xFFFFFFFF),
    fond: Color(0xFFEAF2FF),
    texte: Color(0xFF1D2B44),
    douce: Color(0xFF6C7A93),
    erreur: Color(0xFFE5534B),
  );

  static const _sombre = CouleurSecurite._(
    principal: Color(0xFF6AA9FF),
    surPrincipal: Color(0xFF14233B),
    fond: Color(0xFF1F2B3F),
    texte: Color(0xFFEAF1FF),
    douce: Color(0xFFA9B8D1),
    erreur: Color(0xFFFF8A80),
  );

  static CouleurSecurite de(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _sombre : _clair;
}