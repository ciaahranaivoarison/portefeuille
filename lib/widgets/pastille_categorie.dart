import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/emojis.dart';
import 'pictogramme.dart';

/// Teintes chaudes et douces, accordées au thème brun de l'application.
/// Pour tout remettre en brun, faites renvoyer `p.principal` à la fonction
/// [teinteCategorie].
const List<Color> _teintes = [
  Color(0xFFB87A4C), // 0 caramel
  Color(0xFFA9573E), // 1 terre cuite
  Color(0xFF6F8F6A), // 2 sauge
  Color(0xFFC09434), // 3 ocre
  Color(0xFF7A5A48), // 4 cacao
  Color(0xFF9A6B7B), // 5 vieux rose
  Color(0xFF4F7F86), // 6 bleu canard doux
  Color(0xFF8E7B4E), // 7 olive dorée
];

/// Teinte imposée pour les icônes des catégories par défaut, afin qu'elles
/// soient toutes différentes les unes des autres.
const Map<String, int> _teintesFixes = {
  'utensils': 1,
  'bus': 6,
  'home': 0,
  'pill': 2,
  'smartphone': 4,
  'gamepad': 5,
  'shopping-bag': 3,
  'package': 7,
  'briefcase': 4,
  'shopping-cart': 3,
  'laptop': 6,
  'gift': 5,
};

/// Nom de l'icône (sans les deux-points) associée à une catégorie.
String iconeCategorie(String nom) {
  final jeton = emojiCategorie(nom);
  return jeton.length > 2 ? jeton.substring(1, jeton.length - 1) : 'tag';
}

/// Teinte propre à une catégorie : toujours la même pour la même icône.
Color teinteCategorie(BuildContext context, String nom) {
  final icone = iconeCategorie(nom);
  var indice = _teintesFixes[icone];
  if (indice == null) {
    var h = 0;
    for (final r in icone.runes) {
      h = (h * 31 + r) & 0x7fffffff;
    }
    indice = h % _teintes.length;
  }
  final base = _teintes[indice];
  final sombre = Theme.of(context).brightness == Brightness.dark;
  return sombre ? Color.lerp(base, Colors.white, 0.35)! : base;
}

/// Pastille ronde de catégorie : fond dégradé léger, fin contour et icône
/// de la teinte de la catégorie. Les catégories sans icône connue montrent
/// leur initiale.
class PastilleCategorie extends StatelessWidget {
  const PastilleCategorie(this.nom, {super.key, this.taille = 46});

  final String nom;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final teinte = teinteCategorie(context, nom);
    final icone = iconeCategorie(nom);
    final lettre =
        icone.startsWith('lettre-') ? icone.substring(7).toUpperCase() : null;

    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            teinte.withValues(alpha: 0.24),
            teinte.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: teinte.withValues(alpha: 0.28)),
      ),
      child: lettre != null
          ? Text(
              lettre,
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: taille * 0.42,
                fontWeight: FontWeight.w700,
                color: teinte,
                height: 1,
              ),
            )
          : Pictogramme(icone, taille: taille * 0.5, couleur: teinte),
    );
  }
}