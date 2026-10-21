import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/categories.dart';
import '../../widgets/confirm_dialog.dart';

/// Création ou modification d'une catégorie de l'utilisateur.
class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key, required this.type, this.categorie});

  final String type; // 'expense' ou 'income'
  final CategoryInfo? categorie;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nomCtrl = TextEditingController();

  bool get _modification => widget.categorie != null;
  String get _typeTexte =>
      widget.type == 'income' ? 'de revenus' : 'de dépenses';

  @override
  void initState() {
    super.initState();
    _nomCtrl.text = widget.categorie?.name ?? '';
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_modification) {
        await Categories.instance.modifier(
          id: widget.categorie!.id,
          nom: _nomCtrl.text,
          type: widget.type,
        );
      } else {
        await Categories.instance.creer(
          nom: _nomCtrl.text,
          type: widget.type,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  Future<void> _supprimer() async {
    final c = widget.categorie!;
    final message = c.usage > 0
        ? '${c.usage} opération(s) deviendront « Sans catégorie ». '
            'Les budgets de cette catégorie seront retirés.'
        : 'Cette catégorie sera supprimée.';
    final ok = await confirmerSuppression(
      context,
      titre: 'Supprimer cette catégorie ?',
      message: message,
    );
    if (!ok) return;
    await Categories.instance.supprimer(c.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modification ? 'Modifier la catégorie' : 'Nouvelle catégorie',
        ),
        actions: [
          if (_modification)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: _supprimer,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Catégorie $_typeTexte',
            style: const TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NOM DE LA CATÉGORIE',
            style: text.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: AppColors.noyer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nomCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Ex. : Scolarité'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _enregistrer,
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