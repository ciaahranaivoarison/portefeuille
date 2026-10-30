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

  /// Couleur, message et emoji selon la part du budget déjà dépensée.
  (Color, String, String) _etat(Palette p, BudgetItem b) {
    if (b.ratio > 1) return (p.depense, 'Dépassé', '🚨');
    if (b.ratio >= 0.8) return (p.accent, 'Presque atteint', '⚠️');
    return (p.revenu, 'Dans le budget', '✅');
  }

  Widget _chiffre(
    BuildContext context,
    String label,
    String valeur,
    Color couleur,
  ) {
    final p = context.pal;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, color: p.texteDoux)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valeur,
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: couleur,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barre(Palette p, double valeur, Color couleur, double hauteur) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: valeur > 1 ? 1.0 : valeur),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => LinearProgressIndicator(
        value: v,
        minHeight: hauteur,
        color: couleur,
        backgroundColor: p.bordure,
        borderRadius: BorderRadius.circular(hauteur / 2),
      ),
    );
  }

  Widget _selecteurMois(BuildContext context) {
    final p = context.pal;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.bordure),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Mois précédent',
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _changerMois(-1),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              libelleMois(_mois),
              key: ValueKey<DateTime>(_mois),
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: p.texte,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Mois suivant',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => _changerMois(1),
          ),
        ],
      ),
    );
  }

  Widget _resume(BuildContext context, int prevu, int depense) {
    final p = context.pal;
    final ratio = prevu > 0 ? depense / prevu : 0.0;
    final couleur =
        ratio > 1 ? p.depense : (ratio >= 0.8 ? p.accent : p.revenu);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const PastilleEmoji('🧮', taille: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ensemble des budgets',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatAr(depense)} dépensés sur ${formatAr(prevu)}',
                        style: TextStyle(fontSize: 12, color: p.texteDoux),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(ratio * 100).round()} %',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: couleur,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _barre(p, ratio, couleur, 8),
          ],
        ),
      ),
    );
  }

  Widget _carte(BuildContext context, BudgetItem b, int index) {
    final p = context.pal;
    final (couleur, message, emojiEtat) = _etat(p, b);
    final pourcentage = (b.ratio * 100).round();

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
                      PastilleEmoji(emojiCategorie(b.categoryName), taille: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: couleur.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$emojiEtat $message · $pourcentage %',
                                style: TextStyle(
                                  color: couleur,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _barre(p, b.ratio, couleur, 9),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _chiffre(context, 'Prévu', formatAr(b.amount), p.texte),
                      _chiffre(context, 'Dépensé', formatAr(b.spent), couleur),
                      _chiffre(
                        context,
                        b.remaining < 0 ? 'Dépassement' : 'Restant',
                        formatAr(b.remaining.abs()),
                        b.remaining < 0 ? p.depense : p.revenu,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BudgetItem>>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final budgets = snapshot.data;
          if (budgets == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final n = budgets.length;
          final prevu = budgets.fold<int>(0, (s, b) => s + b.amount);
          final depense = budgets.fold<int>(0, (s, b) => s + b.spent);

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              EnteteEcran(
                emoji: '🎯',
                titre: 'Budgets',
                sousTitre: 'Une limite mensuelle par catégorie',
                etiquette: n > 0 ? 'BUDGET MENSUEL TOTAL' : null,
                montant: n > 0 ? prevu : null,
                action: BoutonHeader(
                  icone: Icons.add_rounded,
                  infobulle: 'Nouveau budget',
                  onTap: () => _ouvrir(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _selecteurMois(context),
                    const SizedBox(height: 14),
                    if (n == 0)
                      const EtatVide(
                        titre: 'Aucun budget défini',
                        message: 'Fixez une limite mensuelle par catégorie, '
                            'par exemple 300 000 Ar pour l\'alimentation.',
                      ),
                    if (n > 0) ...[
                      Apparition(
                        index: 0,
                        child: _resume(context, prevu, depense),
                      ),
                      const SizedBox(height: 12),
                    ],
                    for (var i = 0; i < n; i++)
                      _carte(context, budgets[i], i + 1),
                    Apparition(
                      index: n + 1,
                      child: CarteAjout(
                        libelle: 'Nouveau budget',
                        onTap: () => _ouvrir(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}