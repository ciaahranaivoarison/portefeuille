import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../data/budgets.dart';
import '../../data/operations.dart';
import '../../widgets/confirm_dialog.dart';

/// Création ou modification du budget mensuel d'une catégorie.
class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({super.key, required this.mois, this.budget});

  final DateTime mois;

  /// Si elle est fournie, l'écran sert à modifier ce budget.
  final BudgetItem? budget;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  List<Category> _disponibles = [];
  int? _categorieId;
  bool _chargement = true;
  final _montantCtrl = TextEditingController();

  bool get _modification => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    if (b != null) {
      _categorieId = b.categoryId;
      _montantCtrl.text = b.amount.toString();
      _chargement = false;
    } else {
      _charger();
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final categories = await Operations.instance.categories('expense');
    final existants = await Budgets.instance.pourMois(widget.mois);
    final deja = existants.map((b) => b.categoryId).toSet();
    if (!mounted) return;
    setState(() {
      _disponibles = categories.where((c) => !deja.contains(c.id)).toList();
      _chargement = false;
    });
  }

  Future<void> _enregistrer() async {
    final messenger = ScaffoldMessenger.of(context);
    final montant = int.tryParse(_montantCtrl.text.trim()) ?? 0;

    if (_categorieId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie.')),
      );
      return;
    }
    try {
      await Budgets.instance.definir(
        categorieId: _categorieId!,
        montant: montant,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  Future<void> _supprimer() async {
    final ok = await confirmerSuppression(
      context,
      titre: 'Supprimer ce budget ?',
      message:
          'Les dépenses ne sont pas supprimées : seul le budget est retiré.',
    );
    if (!ok) return;
    await Budgets.instance.supprimer(widget.budget!.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Text(
          texte.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.noyer,
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  Widget _chip(Category c) {
    final selectionne = _categorieId == c.id;
    return ChoiceChip(
      label: Text(c.name),
      selected: selectionne,
      showCheckmark: false,
      onSelected: (_) => setState(() => _categorieId = c.id),
      backgroundColor: AppColors.blanc,
      selectedColor: AppColors.noyer,
      side: const BorderSide(color: AppColors.sable),
      labelStyle: TextStyle(
        color: selectionne ? AppColors.blanc : AppColors.cacao,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier le budget' : 'Nouveau budget'),
        actions: [
          if (_modification)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: _supprimer,
            ),
        ],
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Text(
                  'Budget mensuel',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ce budget s'applique chaque mois.",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.noyer),
                ),
                _titre('Catégorie de dépenses'),
                if (_modification)
                  Text(
                    widget.budget!.categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else if (_disponibles.isEmpty)
                  const Text(
                    'Toutes les catégories ont déjà un budget.',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final c in _disponibles) _chip(c)],
                  ),
                _titre('Budget par mois (Ar)'),
                TextField(
                  controller: _montantCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(hintText: '300000'),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: (!_modification && _disponibles.isEmpty)
                      ? null
                      : _enregistrer,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.noyer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
    );
  }
}