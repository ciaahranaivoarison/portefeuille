import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_theme.dart';

/// Un dessin SVG : son code, son rapport largeur/hauteur, et s'il garde
/// ses propres couleurs (drapeaux) ou prend celle du thème (icônes).
class _Dessin {
  const _Dessin(this.svg, {this.ratio = 1.0, this.colore = false});

  final String svg;
  final double ratio;
  final bool colore;
}

const _entete = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
    'fill="none" stroke="#000" stroke-width="1.8" stroke-linecap="round" '
    'stroke-linejoin="round">';

/// Icône « trait » : sa couleur sera celle demandée par l'écran.
_Dessin _t(String contenu) => _Dessin('$_entete$contenu</svg>');

/// Drapeau : il garde ses couleurs.
_Dessin _drapeau(String contenu) => _Dessin(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 24">'
      '<defs><clipPath id="c"><rect width="32" height="24" rx="3.5"/>'
      '</clipPath></defs><g clip-path="url(#c)">$contenu</g>'
      '<rect x=".5" y=".5" width="31" height="23" rx="3.2" fill="none" '
      'stroke="#000" stroke-opacity=".18"/></svg>',
      ratio: 4 / 3,
      colore: true,
    );

/// Toutes les icônes de l'application, par nom (utilisées sous la forme
/// `:nom:` dans les textes).
final Map<String, _Dessin> _dessins = {
  // Catégories de dépenses
  'utensils': _t(
    '<path d="M6 3v6a2.5 2.5 0 0 0 5 0V3"/><path d="M8.5 3v18"/>'
    '<path d="M17 21V3c-2.2 1.2-3.5 3.7-3.5 6.5 0 2 1 3.5 3.5 3.5"/>',
  ),
  'bus': _t(
    '<rect x="4" y="3" width="16" height="15" rx="3"/><path d="M4 11h16"/>'
    '<path d="M8 18v2.5M16 18v2.5"/><path d="M8 14.5h.01M16 14.5h.01"/>',
  ),
  'home': _t(
    '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
  ),
  'pill': _t(
    '<path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/>'
    '<path d="m8.5 8.5 7 7"/>',
  ),
  'smartphone': _t(
    '<rect x="6" y="2" width="12" height="20" rx="3"/><path d="M11 18h2"/>',
  ),
  'gamepad': _t(
    '<rect x="2" y="7" width="20" height="11" rx="5.5"/>'
    '<path d="M7 10.5v4M5 12.5h4"/><path d="M16 11.5h.01M18.5 13.5h.01"/>',
  ),
  'shopping-bag': _t(
    '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>'
    '<path d="M3 6h18"/><path d="M16 10a4 4 0 0 1-8 0"/>',
  ),
  'shirt': _t(
    '<path d="M8 3 3 6l2 5 3-1v11h8V10l3 1 2-5-5-3a4 4 0 0 1-8 0z"/>',
  ),
  'graduation-cap': _t(
    '<path d="M2 9l10-5 10 5-10 5z"/>'
    '<path d="M6 11.5V16c0 1.5 2.7 3 6 3s6-1.5 6-3v-4.5"/><path d="M22 9v6"/>',
  ),
  'package': _t(
    '<path d="M12.89 1.45l8 4A2 2 0 0 1 22 7.24v9.53a2 2 0 0 1-1.11 1.79l-8 4a2 2 0 0 1-1.79 0l-8-4a2 2 0 0 1-1.1-1.8V7.24a2 2 0 0 1 1.11-1.79l8-4a2 2 0 0 1 1.78 0z"/>'
    '<path d="M2.32 6.16 12 11l9.68-4.84"/><path d="M12 22.76V11"/>',
  ),
  'tag': _t(
    '<path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>'
    '<path d="M7 7h.01"/>',
  ),

  // Catégories de revenus
  'briefcase': _t(
    '<rect x="2" y="7" width="20" height="14" rx="2"/>'
    '<path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>',
  ),
  'shopping-cart': _t(
    '<circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>'
    '<path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>',
  ),
  'laptop': _t(
    '<rect x="4" y="5" width="16" height="11" rx="2"/><path d="M2 20h20"/>',
  ),
  'gift': _t(
    '<path d="M20 12v10H4V12"/><rect x="2" y="7" width="20" height="5"/>'
    '<path d="M12 22V7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/>'
    '<path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>',
  ),

  // Comptes et navigation
  'wallet': _t(
    '<path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H18a1 1 0 0 1 1 1v1.5"/>'
    '<rect x="3" y="7.5" width="18" height="12" rx="2.5"/><path d="M17 13.5h.01"/>',
  ),
  'banknote': _t(
    '<rect x="2" y="6" width="20" height="12" rx="2"/>'
    '<circle cx="12" cy="12" r="2.5"/><path d="M6 12h.01M18 12h.01"/>',
  ),
  'landmark': _t(
    '<path d="M3 10 12 4l9 6"/><path d="M5 10v8M9.5 10v8M14.5 10v8M19 10v8"/>'
    '<path d="M3 21h18M4 18h16"/>',
  ),
  'mobile-money': _t(
    '<rect x="9" y="2" width="12" height="20" rx="3"/><path d="M14 18h2"/>'
    '<path d="M2.5 9H7M5 6.5 7.5 9 5 11.5"/>',
  ),
  'credit-card': _t(
    '<rect x="2" y="5" width="20" height="14" rx="2.5"/><path d="M2 10h20M6 15h4"/>',
  ),
  'receipt': _t(
    '<path d="M5 3h14v18l-2.3-1.6L14.3 21 12 19.4 9.7 21l-2.4-1.6L5 21z"/>'
    '<path d="M9 8h6M9 12h6"/>',
  ),
  'target': _t(
    '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/>'
    '<circle cx="12" cy="12" r="1"/>',
  ),
  'bar-chart': _t('<path d="M5 20v-8M12 20V5M19 20v-9"/><path d="M3 20h18"/>'),

  // Opérations
  'expense': _t(
    '<circle cx="12" cy="12" r="9"/><path d="M9 15l6-6M10 9h5v5"/>',
  ),
  'transfer': _t(
    '<path d="M17 2l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/>'
    '<path d="M7 22l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/>',
  ),
  'calendar': _t(
    '<rect x="3" y="4" width="18" height="18" rx="2"/>'
    '<path d="M16 2v4M8 2v4M3 10h18"/>',
  ),
  'calendar-week': _t(
    '<rect x="3" y="4" width="18" height="18" rx="2"/>'
    '<path d="M16 2v4M8 2v4M3 10h18"/><path d="M7 14.5h10M7 18h6"/>',
  ),
  'calendar-month': _t(
    '<rect x="3" y="4" width="18" height="18" rx="2"/>'
    '<path d="M16 2v4M8 2v4M3 10h18"/>'
    '<path d="M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01"/>',
  ),
  'sun': _t(
    '<circle cx="12" cy="12" r="5"/>'
    '<path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>',
  ),
  'moon': _t('<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>'),
  'rewind': _t(
    '<path d="M11 19 2 12l9-7z"/><path d="M22 19l-9-7 9-7z"/>',
  ),
  'sliders': _t(
    '<path d="M3 6h11M18 6h3"/><circle cx="16" cy="6" r="2"/>'
    '<path d="M3 12h3M10 12h11"/><circle cx="8" cy="12" r="2"/>'
    '<path d="M3 18h12M19 18h2"/><circle cx="17" cy="18" r="2"/>',
  ),
  'calculator': _t(
    '<rect x="5" y="2" width="14" height="20" rx="2"/><path d="M8 6h8"/>'
    '<path d="M8 11h.01M12 11h.01M16 11h.01M8 15h.01M12 15h.01M16 15h.01M8 18.5h.01M12 18.5h.01M16 18.5h.01"/>',
  ),
  'scale': _t(
    '<path d="M12 3v18M7 21h10M4 7h16"/>'
    '<path d="M4 7l-2.5 6a2.8 2.8 0 0 0 5 0z"/>'
    '<path d="M20 7l-2.5 6a2.8 2.8 0 0 0 5 0z"/>',
  ),

  // États
  'check-circle': _t('<circle cx="12" cy="12" r="9"/><path d="M8 12.5l3 3 5-6"/>'),
  'alert-triangle': _t(
    '<path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>'
    '<path d="M12 9v4M12 17h.01"/>',
  ),
  'alert-octagon': _t(
    '<path d="M7.86 2h8.28L22 7.86v8.28L16.14 22H7.86L2 16.14V7.86z"/>'
    '<path d="M12 8v4M12 16h.01"/>',
  ),
  'leaf': _t(
    '<path d="M11 20A7 7 0 0 1 4 13c0-6 6-10 16-10 0 10-4 17-9 17z"/>'
    '<path d="M4 21c3-6 6-9 10-11"/>',
  ),
  'lightbulb': _t(
    '<path d="M9 18h6M10 21.5h4"/>'
    '<path d="M12 2.5a6.5 6.5 0 0 0-4 11.6c.7.6 1 1.2 1 2V17h6v-.9c0-.8.3-1.4 1-2A6.5 6.5 0 0 0 12 2.5z"/>',
  ),

  // Paramètres et sécurité
  'palette': _t(
    '<path d="M12 3a9 9 0 1 0 0 18c1.2 0 2-.8 2-1.8 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-1 .8-1.8 1.8-1.8H17a4 4 0 0 0 4-4C21 6.6 17 3 12 3z"/>'
    '<path d="M7.5 11h.01M10.5 7.5h.01M15 7.5h.01"/>',
  ),
  'globe': _t(
    '<circle cx="12" cy="12" r="10"/><path d="M2 12h20"/>'
    '<path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>',
  ),
  'shield-check': _t(
    '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>'
    '<path d="M8.5 12l2.5 2.5 4.5-5"/>',
  ),
  'save': _t(
    '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>'
    '<path d="M17 21v-8H7v8M7 3v5h8"/>',
  ),
  'unlock': _t(
    '<rect x="3" y="11" width="18" height="11" rx="2"/>'
    '<path d="M7 11V7a5 5 0 0 1 9.9-1"/>',
  ),
  'lock': _t(
    '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
  ),
  'key': _t(
    '<circle cx="7.5" cy="15.5" r="4.5"/><path d="M10.7 12.3 21 2"/>'
    '<path d="m17 6 3 3M14 9l2 2"/>',
  ),
  'fingerprint': _t(
    '<path d="M12 10a2 2 0 0 0-2 2c0 1.02-.1 2.51-.26 4"/>'
    '<path d="M14 13.12c0 2.38 0 6.38-1 8.88"/>'
    '<path d="M17.29 21.02c.12-.6.43-2.3.5-3.02"/>'
    '<path d="M2 12a10 10 0 0 1 18-6"/><path d="M2 16h.01"/>'
    '<path d="M21.8 16c.2-2 .131-5.354 0-6"/>'
    '<path d="M5 19.5C5.5 18 6 15 6 12a6 6 0 0 1 .34-2"/>'
    '<path d="M8.65 22c.21-.66.45-1.32.57-2"/>'
    '<path d="M9 6.8a6 6 0 0 1 9 5.2v2"/>',
  ),
  'pencil': _t(
    '<path d="M17 3a2.83 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"/>',
  ),
  'timer': _t(
    '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5"/><path d="M9 2h6"/>',
  ),
  'clock': _t('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
  'hash': _t('<path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/>'),
  'type': _t('<path d="M4 7V5h16v2M9 19h6M12 5v14"/>'),

  // Drapeaux
  'flag-fr': _drapeau(
    '<rect width="11" height="24" fill="#0055A4"/>'
    '<rect x="11" width="10" height="24" fill="#FFFFFF"/>'
    '<rect x="21" width="11" height="24" fill="#EF4135"/>',
  ),
  'flag-mg': _drapeau(
    '<rect width="32" height="24" fill="#FFFFFF"/>'
    '<rect x="10.7" width="21.3" height="12" fill="#FC3D32"/>'
    '<rect x="10.7" y="12" width="21.3" height="12" fill="#007E3A"/>',
  ),
  'flag-gb': _drapeau(
    '<rect width="32" height="24" fill="#012169"/>'
    '<path d="M0 0 32 24M32 0 0 24" fill="none" stroke="#FFFFFF" stroke-width="4.8"/>'
    '<path d="M0 0 32 24M32 0 0 24" fill="none" stroke="#C8102E" stroke-width="1.6"/>'
    '<path d="M16 0v24M0 12h32" fill="none" stroke="#FFFFFF" stroke-width="8"/>'
    '<path d="M16 0v24M0 12h32" fill="none" stroke="#C8102E" stroke-width="4.8"/>',
  ),
};

final RegExp _jeton = RegExp(r':([a-z][a-z0-9-]*):');
final RegExp _jetonSeul = RegExp(r'^\s*:([a-z][a-z0-9-]*):\s*$');

/// Vrai si le texte contient au moins un code d'icône connu (`:nom:`).
bool contientPictogramme(String texte) {
  for (final m in _jeton.allMatches(texte)) {
    if (_dessins.containsKey(m.group(1))) return true;
  }
  return false;
}

/// Nom de l'icône si le texte ne contient que ce code, sinon null.
String? nomPictogrammeSeul(String texte) {
  final nom = _jetonSeul.firstMatch(texte)?.group(1);
  return (nom != null && _dessins.containsKey(nom)) ? nom : null;
}

/// Découpe un texte en morceaux de texte et en icônes.
List<InlineSpan> decouperPictogrammes(
  String texte, {
  required double taille,
  required Color couleur,
}) {
  final morceaux = <InlineSpan>[];
  var debut = 0;
  for (final m in _jeton.allMatches(texte)) {
    final nom = m.group(1)!;
    if (!_dessins.containsKey(nom)) continue;
    if (m.start > debut) {
      morceaux.add(TextSpan(text: texte.substring(debut, m.start)));
    }
    morceaux.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Pictogramme(nom, taille: taille, couleur: couleur),
      ),
    );
    debut = m.end;
  }
  if (debut < texte.length) {
    morceaux.add(TextSpan(text: texte.substring(debut)));
  }
  return morceaux;
}

/// Affiche une icône de l'application par son nom (ex. : `wallet`).
class Pictogramme extends StatelessWidget {
  const Pictogramme(this.nom, {super.key, this.taille = 22, this.couleur});

  final String nom;
  final double taille;

  /// Couleur de l'icône. Sans valeur : la couleur principale du thème.
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final dessin = _dessins[nom];
    if (dessin == null) return SizedBox(width: taille, height: taille);
    return SvgPicture.string(
      dessin.svg,
      width: taille * dessin.ratio,
      height: taille,
      colorFilter: dessin.colore
          ? null
          : ColorFilter.mode(couleur ?? context.pal.principal, BlendMode.srcIn),
    );
  }
}