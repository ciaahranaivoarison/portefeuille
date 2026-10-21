import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formats.dart';
import '../../data/budgets.dart';
import 'budget_form_page.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  late DateTime _mois = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<BudgetItem>> _futur = Budgets.instance.pourMois(_mois);

  void _rafraichir() {
    setState(() {
      _futur = Budgets.instance.pourMois(_mois);
    });
  }

  void _changerMois(int delta) {
    setState(() {
      _mois = DateTime(_mois.year, _mois.month + delta);
      _futur = Budgets.instance.pourMois(_mois);
    });
  }

  Future<void> _ouvrir({BudgetItem? budget}) async {
    final change = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BudgetFormPage(mois: _mois, budget: budget),
      ),
    );
    if (change == true) _rafraichir();
  }

  /// Couleur et message selon la part du budget déjà dépensée.
  (Color, String) _etat(BudgetItem b) {
    if (b.ratio > 1) return (AppColors.terracotta, 'Dépassé');
    if (b.ratio >= 0.8) return (AppColors.caramel, 'Presque atteint');
    return (AppColors.sauge, 'Dans le budget');
  }

  Widget _chiffre(String label, String valeur, Color couleur) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.noyer),
          ),
          const SizedBox(height: 2),
          Text(
            valeur,
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carte(BudgetItem b) {
    final (couleur, message) = _etat(b);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _ouvrir(budget: b),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color: couleur,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: b.ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  color: couleur,
                  backgroundColor: AppColors.sable,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _chiffre('Prévu', formatAr(b.amount), AppColors.cacao),
                    _chiffre('Dépensé', formatAr(b.spent), couleur),
                    _chiffre(
                      b.remaining < 0 ? 'Dépassement' : 'Restant',
                      formatAr(b.remaining.abs()),
                      b.remaining < 0 ? AppColors.terracotta : AppColors.sauge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.noyer,
        foregroundColor: AppColors.blanc,
        onPressed: () => _ouvrir(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau budget'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Mois précédent',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changerMois(-1),
                ),
                Text(
                  libelleMois(_mois),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  tooltip: 'Mois suivant',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changerMois(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BudgetItem>>(
              future: _futur,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final budgets = snapshot.data!;
                if (budgets.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Aucun budget défini.\n'
                        'Appuyez sur « Nouveau budget » pour en définir un.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  children: [for (final b in budgets) _carte(b)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}