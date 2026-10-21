import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formats.dart';
import '../../data/repository.dart';
import '../add_operation/add_operation_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion d'argent")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.noyer,
        foregroundColor: AppColors.blanc,
        onPressed: () async {
          final ajoute = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddOperationPage()),
          );
          if (ajoute == true) _rafraichir();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: FutureBuilder<_Donnees>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [
              Text(
                'ARGENT TOTAL DISPONIBLE',
                style: text.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.noyer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatAr(d.total),
                style: const TextStyle(
                  fontFamily: AppTheme.fontTitre,
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
                    children: [
                      _Ligne(
                        label: 'Revenus du mois',
                        montant: formatAr(d.totaux.income),
                        couleur: AppColors.sauge,
                      ),
                      const Divider(height: 24),
                      _Ligne(
                        label: 'Dépenses du mois',
                        montant: formatAr(d.totaux.expense),
                        couleur: AppColors.terracotta,
                      ),
                      const Divider(height: 24),
                      _Ligne(
                        label: 'Argent restant',
                        montant: formatAr(d.totaux.remaining),
                        couleur: AppColors.cacao,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'MES COMPTES',
                style: text.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.noyer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (var i = 0; i < d.comptes.length; i++) ...[
                        if (i > 0) const Divider(height: 24),
                        _Ligne(
                          label: d.comptes[i].name,
                          montant: formatAr(d.comptes[i].balance),
                          couleur: d.comptes[i].balance < 0
                              ? AppColors.terracotta
                              : AppColors.cacao,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Boutons provisoires de test',
                style: text.bodySmall?.copyWith(color: AppColors.noyer),
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
          );
        },
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
            fontFamily: AppTheme.fontTitre,
            fontWeight: FontWeight.w600,
            color: couleur,
          ),
        ),
      ],
    );
  }
}