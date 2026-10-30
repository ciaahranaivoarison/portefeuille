import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/categories.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/ui.dart';

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
    final p = context.pal;
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
          Center(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _nomCtrl,
              builder: (context, valeur, _) => PastilleEmoji(
                emojiCategorie(valeur.text),
                taille: 82,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Catégorie $_typeTexte',
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.texte,
              ),
            ),
          ),
          const TitreSection('Nom de la catégorie'),
          TextField(
            controller: _nomCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex. : Scolarité',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "L'emoji est choisi automatiquement selon le nom : "
                    '« Scolarité » donne 🎓, « Cadeau » donne 🎁. '
                    'Un nom inconnu reçoit 🏷️.',
                    style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _enregistrer,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}