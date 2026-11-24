import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../data/categories.dart';
import '../../widgets/tuile_categorie.dart';
import '../../widgets/ui.dart';
import 'category_form_page.dart';
import 'options_categorie.dart';

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

  Future<void> _nouvelle() async {
    final change = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CategoryFormPage(type: _type)),
    );
    if (change == true) _rafraichir();
  }

  Future<void> _ouvrirOptions(CategoryInfo c) async {
    final resultat = await gererCategorie(context, c);
    if (!mounted || resultat == null) return;
    _rafraichir();
    if (resultat == ResultatCategorie.supprimee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catégorie supprimée.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        actions: [
          IconButton(
            tooltip: tr('Nouvelle catégorie'),
            icon: const Icon(Icons.add_rounded),
            onPressed: _nouvelle,
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
                  ButtonSegment(
                    value: 'expense',
                    label: Text(':expense: Dépenses'),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(':banknote: Revenus'),
                  ),
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
                    Icon(Icons.touch_app_outlined, size: 20, color: p.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Touchez une catégorie pour voir ses opérations, '
                        'la modifier ou la supprimer. Les catégories par '
                        'défaut sont verrouillées.',
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
                        Apparition(
                          key: ValueKey('categorie${categories[i].id}'),
                          index: i,
                          child: TuileCategorie(
                            info: categories[i],
                            largeur: largeur,
                            onTap: () => _ouvrirOptions(categories[i]),
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