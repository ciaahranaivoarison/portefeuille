import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/categories.dart';
import 'category_form_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _type = 'expense';
  late Future<List<CategoryInfo>> _futur = Categories.instance.lister(_type);

  void _rafraichir() {
    setState(() {
      _futur = Categories.instance.lister(_type);
    });
  }

  void _changerType(String type) {
    setState(() {
      _type = type;
      _futur = Categories.instance.lister(type);
    });
  }

  Future<void> _ouvrir({CategoryInfo? categorie}) async {
    final change = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryFormPage(type: _type, categorie: categorie),
      ),
    );
    if (change == true) _rafraichir();
  }

  Widget _carte(CategoryInfo c) {
    final operations = '${c.usage} opération(s)';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          onTap: () {
            if (c.isDefault) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Les catégories par défaut ne peuvent pas être modifiées.',
                  ),
                ),
              );
            } else {
              _ouvrir(categorie: c);
            }
          },
          leading: Icon(
            c.isDefault ? Icons.lock_outline : Icons.label_outline,
            color: AppColors.noyer,
          ),
          title: Text(
            '${emojiCategorie(c.name)} ${c.name}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            c.isDefault ? 'Par défaut · $operations' : operations,
          ),
          trailing: c.isDefault ? null : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.noyer,
        foregroundColor: AppColors.blanc,
        onPressed: () => _ouvrir(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Dépenses')),
                ButtonSegment(value: 'income', label: Text('Revenus')),
              ],
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _changerType(s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Les catégories par défaut sont verrouillées. '
                'Ajoutez les vôtres, puis modifiez-les ou supprimez-les.',
                style: text.bodySmall?.copyWith(color: AppColors.noyer),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CategoryInfo>>(
              future: _futur,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  children: [for (final c in categories) _carte(c)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}