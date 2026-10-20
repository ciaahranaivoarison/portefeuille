import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';

void main() {
  runApp(const GestionArgentApp());
}

class GestionArgentApp extends StatelessWidget {
  const GestionArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gestion d'argent",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    );
  }
}

/// Écran d'accueil provisoire : les chiffres sont ceux de l'exemple de la fiche.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion d'argent")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'ARGENT TOTAL DISPONIBLE',
            style: text.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: AppColors.noyer,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1 250 000 Ar',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 38,
              fontWeight: FontWeight.w600,
              color: AppColors.cacao,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _Ligne(
                    label: 'Revenus du mois',
                    montant: '2 000 000 Ar',
                    couleur: AppColors.sauge,
                  ),
                  Divider(height: 24),
                  _Ligne(
                    label: 'Dépenses du mois',
                    montant: '750 000 Ar',
                    couleur: AppColors.terracotta,
                  ),
                  Divider(height: 24),
                  _Ligne(
                    label: 'Argent restant',
                    montant: '1 250 000 Ar',
                    couleur: AppColors.cacao,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.label,
    required this.montant,
    required this.couleur,
  });

  final String label;
  final String montant;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          montant,
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            color: couleur,
          ),
        ),
      ],
    );
  }
}