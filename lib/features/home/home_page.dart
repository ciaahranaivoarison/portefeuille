import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/repository.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/ui.dart';
import '../add_operation/add_operation_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Donnees {
  const _Donnees(this.comptes, this.totaux);

  final List<AccountBalance> comptes;
  final MonthTotals totaux;

  int get total => comptes.fold(0, (somme, c) => somme + c.balance);
}

class _HomePageState extends State<HomePage> {
  late Future<_Donnees> _futur = _charger();

  Future<_Donnees> _charger() async {
    final comptes = await Repository.instance.comptes();
    final totaux = await Repository.instance.totauxDuMois(DateTime.now());
    return _Donnees(comptes, totaux);
  }

  void _rafraichir() {
    setState(() {
      _futur = _charger();
    });
  }

  Future<void> _ajouter() async {
    final ajoute = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddOperationPage()),
    );
    if (ajoute == true) _rafraichir();
  }

  Widget _contenu(AsyncSnapshot<_Donnees> snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text('Erreur : ${snapshot.error}'));
    }
    final d = snapshot.data;
    if (d == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Apparition(
          index: 0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _Ligne(
                    emoji: '💵',
                    label: 'Revenus du mois',
                    montant: d.totaux.income,
                    couleur: AppColors.sauge,
                  ),
                  const Divider(height: 26),
                  _Ligne(
                    emoji: '💸',
                    label: 'Dépenses du mois',
                    montant: d.totaux.expense,
                    couleur: AppColors.terracotta,
                  ),
                  const Divider(height: 26),
                  _Ligne(
                    emoji: '🏦',
                    label: 'Argent restant',
                    montant: d.totaux.remaining,
                    couleur: AppColors.cacao,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Apparition(index: 1, child: TitreSection('Mes comptes')),
        Apparition(
          index: 2,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  for (var i = 0; i < d.comptes.length; i++) ...[
                    if (i > 0) const Divider(height: 26),
                    _Ligne(
                      emoji: emojiCompte(d.comptes[i].type),
                      label: d.comptes[i].name,
                      montant: d.comptes[i].balance,
                      couleur: d.comptes[i].balance < 0
                          ? AppColors.terracotta
                          : AppColors.cacao,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Visible seulement pendant le développement (flutter run).
        // La version finale de l'application ne contient pas ces boutons.
        if (kDebugMode) ...[
          const SizedBox(height: 32),
          Text(
            'Mode développement (absent de la version finale)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.noyer),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              await Repository.instance.chargerExemple();
              _rafraichir();
            },
            child: const Text("Charger l'exemple de la fiche"),
          ),
          TextButton(
            onPressed: () async {
              await Repository.instance.viderOperations();
              _rafraichir();
            },
            child: const Text('Effacer les opérations de test'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _ajouter,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: FutureBuilder<_Donnees>(
        future: _futur,
        builder: (context, snapshot) {
          return Column(
            children: [
              EnteteEcran(
                emoji: '💰',
                titre: "Gestion d'argent",
                etiquette: 'ARGENT TOTAL DISPONIBLE',
                montant: snapshot.data?.total,
                action: IconButton(
                  tooltip: 'Paramètres',
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.creme,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ),
              Expanded(child: _contenu(snapshot)),
            ],
          );
        },
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.emoji,
    required this.label,
    required this.montant,
    required this.couleur,
  });

  final String emoji;
  final String label;
  final int montant;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PastilleEmoji(emoji, taille: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        MontantAnime(
          montant: montant,
          style: TextStyle(
            fontFamily: AppTheme.fontTitre,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: couleur,
          ),
        ),
      ],
    );
  }
}