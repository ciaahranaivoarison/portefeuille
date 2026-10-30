import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/budgets.dart';
import '../../data/operations.dart';
import '../../widgets/choix.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/ui.dart';

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
  static const _suggestions = [50000, 100000, 200000, 300000, 500000];

  List<Category> _disponibles = [];
  int? _categorieId;
  bool _chargement = true;
  final _montantCtrl = TextEditingController();

  bool get _modification => widget.budget != null;

  String get _emoji {
    final b = widget.budget;
    if (b != null) return emojiCategorie(b.categoryName);
    for (final c in _disponibles) {
      if (c.id == _categorieId) return emojiCategorie(c.name);
    }
    return '🎯';
  }

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

  @override
  Widget build(BuildContext context) {
    final p = context.pal;

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
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: PastilleEmoji(
                      _emoji,
                      taille: 78,
                      key: ValueKey<String>(_emoji),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Budget mensuel',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTitre,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: p.texte,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    "Ce budget s'applique chaque mois.",
                    style: TextStyle(fontSize: 13, color: p.texteDoux),
                  ),
                ),
                const TitreSection('Catégorie de dépenses'),
                if (_modification)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          PastilleEmoji(_emoji, taille: 40),
                          const SizedBox(width: 14),
                          Text(
                            widget.budget!.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_disponibles.isEmpty)
                  Text(
                    'Toutes les catégories ont déjà un budget.',
                    style: TextStyle(color: p.texteDoux),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _disponibles)
                        ChipChoix(
                          emoji: emojiCategorie(c.name),
                          libelle: c.name,
                          actif: _categorieId == c.id,
                          onTap: () => setState(() => _categorieId = c.id),
                        ),
                    ],
                  ),
                const TitreSection('Budget par mois (Ar)'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      children: [
                        TextField(
                          controller: _montantCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                            color: p.principal,
                          ),
                          decoration: const InputDecoration(
                            hintText: '300000',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _montantCtrl,
                          builder: (context, valeur, _) {
                            final n = int.tryParse(valeur.text) ?? 0;
                            return Text(
                              n > 0 ? '${formatAr(n)} par mois' : 'par mois',
                              style: TextStyle(
                                fontSize: 13,
                                color: p.texteDoux,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _montantCtrl,
                  builder: (context, valeur, _) {
                    final n = int.tryParse(valeur.text) ?? 0;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _suggestions)
                          ChipChoix(
                            libelle: formatAr(s),
                            actif: n == s,
                            onTap: () => _montantCtrl.text = '$s',
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: (!_modification && _disponibles.isEmpty)
                      ? null
                      : _enregistrer,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
    );
  }
}