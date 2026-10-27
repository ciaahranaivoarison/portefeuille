import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/budgets.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/etat_vide.dart';
import '../../widgets/ui.dart';
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

  Widget _carte(BudgetItem b, int index) {
    final (couleur, message) = _etat(b);
    final pourcentage = (b.ratio * 100).round();
    final rempli = b.ratio > 1 ? 1.0 : b.ratio;

    return Apparition(
      key: ValueKey('budget${b.id}'),
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: InkWell(
            onTap: () => _ouvrir(budget: b),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PastilleEmoji(emojiCategorie(b.categoryName), taille: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          b.categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: couleur.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$message · $pourcentage %',
                          style: TextStyle(
                            color: couleur,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: rempli),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, valeur, _) => LinearProgressIndicator(
                      value: valeur,
                      minHeight: 9,
                      color: couleur,
                      backgroundColor: AppColors.sable,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _chiffre('Prévu', formatAr(b.amount), AppColors.cacao),
                      _chiffre('Dépensé', formatAr(b.spent), couleur),
                      _chiffre(
                        b.remaining < 0 ? 'Dépassement' : 'Restant',
                        formatAr(b.remaining.abs()),
                        b.remaining < 0
                            ? AppColors.terracotta
                            : AppColors.sauge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selecteurMois() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sable),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Mois précédent',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changerMois(-1),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              libelleMois(_mois),
              key: ValueKey<DateTime>(_mois),
              style: const TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Mois suivant',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changerMois(1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _ouvrir(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau budget'),
      ),
      body: Column(
        children: [
          const EnteteEcran(
            emoji: '🎯',
            titre: 'Budgets',
            sousTitre: 'Une limite mensuelle par catégorie',
          ),
          _selecteurMois(),
          Expanded(
            child: FutureBuilder<List<BudgetItem>>(
              future: _futur,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                final budgets = snapshot.data;
                if (budgets == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (budgets.isEmpty) {
                  return const EtatVide(
                    titre: 'Aucun budget défini',
                    message: 'Appuyez sur « Nouveau budget » pour fixer '
                        'une limite mensuelle par catégorie.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  children: [
                    for (var i = 0; i < budgets.length; i++)
                      _carte(budgets[i], i),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}