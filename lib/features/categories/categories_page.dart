import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/categories.dart';
import '../../widgets/ui.dart';
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

  Widget _tuile(BuildContext context, CategoryInfo c, double largeur, int i) {
    final p = context.pal;
    final operations =
        c.usage > 1 ? '${c.usage} opérations' : '${c.usage} opération';

    return Apparition(
      key: ValueKey('categorie${c.id}'),
      index: i,
      child: SizedBox(
        width: largeur,
        child: Card(
          child: InkWell(
            onTap: () {
              if (c.isDefault) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Les catégories par défaut ne peuvent pas être '
                      'modifiées.',
                    ),
                  ),
                );
              } else {
                _ouvrir(categorie: c);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PastilleEmoji(emojiCategorie(c.name), taille: 44),
                      const Spacer(),
                      Icon(
                        c.isDefault
                            ? Icons.lock_outline_rounded
                            : Icons.edit_outlined,
                        size: 18,
                        color: p.texteDoux,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    operations,
                    style: TextStyle(fontSize: 12, color: p.texteDoux),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.isDefault ? 'Par défaut' : 'Personnalisée',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.accent,
                    ),
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
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        actions: [
          IconButton(
            tooltip: 'Nouvelle catégorie',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _ouvrir(),
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryInfo>>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final categories = snapshot.data;
          if (categories == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('💸 Dépenses')),
                  ButtonSegment(value: 'income', label: Text('💵 Revenus')),
                ],
                selected: {_type},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _changerType(s.first),
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
                        'Les catégories par défaut sont verrouillées. '
                        'Ajoutez les vôtres, puis modifiez-les ou '
                        'supprimez-les.',
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, contraintes) {
                  final largeur = (contraintes.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < categories.length; i++)
                        _tuile(context, categories[i], largeur, i),
                      SizedBox(
                        width: contraintes.maxWidth,
                        child: CarteAjout(
                          libelle: 'Nouvelle catégorie',
                          onTap: () => _ouvrir(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}