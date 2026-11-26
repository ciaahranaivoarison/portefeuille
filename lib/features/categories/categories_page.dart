import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../data/categories.dart';
import '../../widgets/pastille_categorie.dart';
import '../../widgets/pictogramme.dart';
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
    if (type == _type) return;
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

  /// En-tête vedette : nombre de catégories, personnalisées, opérations.
  Widget _recap(Palette p, List<CategoryInfo> categories) {
    final depenses = _type == 'expense';
    final perso = categories.where((c) => !c.isDefault).length;
    final operations = categories.fold<int>(0, (s, c) => s + c.usage);
    final premiers = categories.take(3).toList();
    final doux = p.surPrincipal.withValues(alpha: 0.82);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.principal, Color.lerp(p.principal, p.accent, 0.55)!],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: p.principal.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -34,
              top: -34,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.surPrincipal.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: -44,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.surPrincipal.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              depenses
                                  ? 'CATÉGORIES DE DÉPENSES'
                                  : 'CATÉGORIES DE REVENUS',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.w700,
                                color: doux,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${categories.length}',
                              style: TextStyle(
                                fontFamily: AppTheme.fontTitre,
                                fontSize: 44,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                                color: p.surPrincipal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (premiers.isNotEmpty)
                        SizedBox(
                          width: 44 + (premiers.length - 1) * 26.0,
                          height: 44,
                          child: Stack(
                            children: [
                              for (var i = 0; i < premiers.length; i++)
                                Positioned(
                                  left: i * 26.0,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.alphaBlend(
                                        p.surPrincipal.withValues(alpha: 0.2),
                                        p.principal,
                                      ),
                                      border: Border.all(
                                        color: p.surPrincipal
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Pictogramme(
                                      iconeCategorie(premiers[i].name),
                                      taille: 22,
                                      couleur: p.surPrincipal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _puce(p, '$perso ${tr('Personnalisées')}'),
                      _puce(p, '$operations ${tr('Opérations')}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _puce(Palette p, String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.surPrincipal.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: p.surPrincipal,
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
          final usageMax =
              categories.fold<int>(0, (m, c) => math.max(m, c.usage));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              _Bascule(type: _type, onChange: _changerType),
              const SizedBox(height: 16),
              _recap(p, categories),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.touch_app_outlined, size: 18, color: p.accent),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, contraintes) {
                  final largeur = (contraintes.maxWidth - 14) / 2;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (var i = 0; i < categories.length; i++)
                        Apparition(
                          key: ValueKey('categorie${categories[i].id}'),
                          index: i,
                          child: TuileCategorie(
                            info: categories[i],
                            largeur: largeur,
                            part: categories[i].usage == 0 || usageMax == 0
                                ? 0
                                : math.max(
                                    0.06,
                                    categories[i].usage / usageMax,
                                  ),
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

/// Interrupteur Dépenses / Revenus : une pastille brune glisse de l'un à
/// l'autre.
class _Bascule extends StatelessWidget {
  const _Bascule({required this.type, required this.onChange});

  final String type;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: p.surfaceDouce,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.bordure),
      ),
      child: LayoutBuilder(
        builder: (context, contraintes) {
          final moitie = contraintes.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: type == 'expense' ? 0 : moitie,
                top: 0,
                bottom: 0,
                width: moitie,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.principal,
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: p.principal.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _Onglet(
                      libelle: ':expense: Dépenses',
                      actif: type == 'expense',
                      onTap: () => onChange('expense'),
                    ),
                  ),
                  Expanded(
                    child: _Onglet(
                      libelle: ':banknote: Revenus',
                      actif: type == 'income',
                      onTap: () => onChange('income'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Center(
        child: Text(
          libelle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: actif ? p.surPrincipal : p.texteDoux,
          ),
        ),
      ),
    );
  }
}