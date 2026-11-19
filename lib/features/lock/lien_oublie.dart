import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../widgets/couleur_securite.dart';
import 'recuperation_page.dart';

/// Lien « Code oublié ? » affiché sous le panneau de l'écran de verrouillage.
class LienOublie extends StatelessWidget {
  const LienOublie({super.key, required this.pin, required this.onRecupere});

  final bool pin;

  /// Appelée quand l'accès est retrouvé : l'application s'ouvre.
  final VoidCallback onRecupere;

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => RecuperationPage(onRecupere: onRecupere),
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: c.texte),
          child: Text(
            pin ? 'Code PIN oublié ?' : 'Mot de passe oublié ?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: c.texte,
            ),
          ),
        ),
      ),
    );
  }
}