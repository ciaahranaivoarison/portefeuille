import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../data/categories.dart';
import '../../widgets/pastille_categorie.dart';
import '../../widgets/pictogramme.dart';
import '../categories/category_form_page.dart';

/// Ouvre la feuille de choix d'une catégorie : recherche, sélection, puis
/// validation avec « OK ». Renvoie la catégorie validée, ou null si
/// l'utilisateur a fermé la feuille.
Future<CategoryInfo?> choisirCategorie(
  BuildContext context, {
  required String type,
  int? selectionId,
}) {
  return showModalBottomSheet<CategoryInfo>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final clavier = MediaQuery.viewInsetsOf(ctx).bottom;
      final hauteur = math.max(
        340.0,
        MediaQuery.sizeOf(ctx).height * 0.9 - clavier,
      );
      return Padding(
        padding: EdgeInsets.only(bottom: clavier),
        child: SizedBox(
          height: hauteur,
          child: _FeuilleChoix(type: type, selectionInitiale: selectionId),
        ),
      );
    },
  );
}

/// Minuscules et sans accents, pour que la recherche les ignore.
String _normaliser(String texte) {
  const avec = 'àâäáéèêëîïíôöóùûüúçñ';
  const sans = 'aaaaeeeeiiiooouuuucn';
  final sortie = StringBuffer();
  for (final r in texte.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    final i = avec.indexOf(c);
    sortie.write(i >= 0 ? sans[i] : c);
  }
  return sortie.toString();
}

/// Dégradé de la couleur d'une catégorie, assez foncé pour un texte blanc.
List<Color> _degrade(Color teinte) => [
      Color.lerp(teinte, AppColors.cacao, 0.22)!,
      Color.lerp(teinte, AppColors.cacao, 0.55)!,
    ];

/// Icône d'une catégorie (ou son initiale si le nom n'est pas reconnu).
Widget _glyphe(String nom, Color couleur, double taille) {
  final icone = iconeCategorie(nom);
  if (icone.startsWith('lettre-')) {
    return Text(
      icone.substring(7).toUpperCase(),
      style: TextStyle(
        fontFamily: AppTheme.fontTitre,
        fontSize: taille * 0.95,
        fontWeight: FontWeight.w700,
        height: 1,
        color: couleur,
      ),
    );
  }
  return Pictogramme(icone, taille: taille, couleur: couleur);
}

class _FeuilleChoix extends StatefulWidget {
  const _FeuilleChoix({required this.type, required this.selectionInitiale});

  final String type;
  final int? selectionInitiale;

  @override
  State<_FeuilleChoix> createState() => _FeuilleChoixState();
}

class _FeuilleChoixState extends State<_FeuilleChoix> {
  final _rechercheCtrl = TextEditingController();
  List<CategoryInfo> _categories = [];
  int? _selection;
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _selection = widget.selectionInitiale;
    _charger();
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger({String? nomASelectionner}) async {
    final liste = await Categories.instance.lister(widget.type);
    if (!mounted) return;
    setState(() {
      _categories = liste;
      _chargement = false;
      if (nomASelectionner != null) {
        final cible = _normaliser(nomASelectionner);
        for (final c in liste) {
          if (_normaliser(c.name) == cible) _selection = c.id;
        }
      }
    });
  }

  /// Catégories dont le nom contient la recherche (nom d'origine ou traduit).
  List<CategoryInfo> get _filtrees {
    final q = _normaliser(_rechercheCtrl.text.trim());
    if (q.isEmpty) return _categories;
    return _categories
        .where(
          (c) =>
              _normaliser(c.name).contains(q) ||
              _normaliser(tr(c.name)).contains(q),
        )
        .toList();
  }

  /// Les catégories les plus utilisées (au moins une opération).
  List<CategoryInfo> get _frequentes {
    final liste = _categories.where((c) => c.usage > 0).toList()
      ..sort((a, b) => b.usage.compareTo(a.usage));
    return liste.take(5).toList();
  }

  CategoryInfo? get _choisie {
    for (final c in _categories) {
      if (c.id == _selection) return c;
    }
    return null;
  }

  /// Crée une catégorie avec le texte tapé dans la recherche.
  Future<void> _creerDepuisRecherche() async {
    final nom = _rechercheCtrl.text.trim();
    try {
      await Categories.instance.creer(nom: nom, type: widget.type);
    } on ArgumentError catch (e) {
      setState(() => _erreur = '${e.message}');
      return;
    }
    _rechercheCtrl.clear();
    setState(() => _erreur = null);
    await _charger(nomASelectionner: nom);
  }

  /// Ouvre le formulaire complet de création, puis sélectionne la nouvelle.
  Future<void> _creerAvecFormulaire() async {
    final avant = _categories.map((c) => c.id).toSet();
    final cree = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CategoryFormPage(type: widget.type)),
    );
    if (cree != true || !mounted) return;
    final liste = await Categories.instance.lister(widget.type);
    if (!mounted) return;
    setState(() {
      _categories = liste;
      final nouvelles = liste.where((c) => !avant.contains(c.id)).toList();
      if (nouvelles.isNotEmpty) _selection = nouvelles.last.id;
      _rechercheCtrl.clear();
    });
  }

  Widget _vide(Palette p, String saisie) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surfaceDouce,
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: p.texteDoux),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucune catégorie trouvée.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.texteDoux, fontSize: 15),
            ),
            if (saisie.isNotEmpty) ...[
              const SizedBox(height: 18),
              _BoutonDegrade(
                icone: Icons.add_rounded,
                libelle: '${tr('Créer')} « $saisie »',
                onTap: _creerDepuisRecherche,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final saisie = _rechercheCtrl.text.trim();
    final filtrees = _filtrees;
    final frequentes = _frequentes;
    final choisie = _choisie;
    final depenses = widget.type == 'expense';
    final couleurType = depenses ? p.depense : p.revenu;

    final bordureRecherche = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: p.bordure),
    );

    return SafeArea(
      child: Column(
        children: [
          // En-tête : titre, type et bouton de création
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 10, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir une catégorie',
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: p.texte,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: couleurType.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: couleurType,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              depenses ? 'Dépenses' : 'Revenus',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: couleurType,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: tr('Nouvelle catégorie'),
                  child: Material(
                    color: p.surfaceDouce,
                    shape: CircleBorder(side: BorderSide(color: p.bordure)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _creerAvecFormulaire,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.add_rounded,
                          size: 24,
                          color: p.principal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          // Recherche en pilule
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (_) => setState(() => _erreur = null),
              decoration: InputDecoration(
                hintText: tr('Rechercher une catégorie'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: saisie.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _rechercheCtrl.clear();
                          setState(() => _erreur = null);
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: bordureRecherche,
                enabledBorder: bordureRecherche,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: p.principal, width: 1.6),
                ),
              ),
            ),
          ),
          if (_erreur != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _erreur!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: p.depense,
                  ),
                ),
              ),
            ),
          // Les plus utilisées
          if (saisie.isEmpty && frequentes.length >= 2) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'LES PLUS UTILISÉES',
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: p.texteDoux,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: frequentes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) => _PuceFrequente(
                  info: frequentes[i],
                  selectionnee: frequentes[i].id == _selection,
                  onTap: () => setState(() => _selection = frequentes[i].id),
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Grille de bulles
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator())
                : filtrees.isEmpty
                    ? _vide(p, saisie)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: filtrees.length,
                        itemBuilder: (context, i) => _Bulle(
                          info: filtrees[i],
                          selectionnee: filtrees[i].id == _selection,
                          onTap: () =>
                              setState(() => _selection = filtrees[i].id),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _BoutonDegrade(
              icone: Icons.check_rounded,
              libelle: 'OK',
              actif: choisie != null,
              onTap: () => Navigator.of(context).pop(choisie),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une catégorie en bulle : grand cercle coloré avec son icône, nom dessous.
/// La bulle choisie se remplit en dégradé, grossit et reçoit une coche.
class _Bulle extends StatelessWidget {
  const _Bulle({
    required this.info,
    required this.selectionnee,
    required this.onTap,
  });

  final CategoryInfo info;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final teinte = teinteCategorie(context, info.name);
    const duree = Duration(milliseconds: 260);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selectionnee ? 1.08 : 1.0,
              duration: duree,
              curve: Curves.easeOutBack,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: duree,
                    curve: Curves.easeOutCubic,
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: selectionnee
                            ? _degrade(teinte)
                            : [
                                teinte.withValues(alpha: 0.22),
                                teinte.withValues(alpha: 0.08),
                              ],
                      ),
                      border: Border.all(
                        color: selectionnee
                            ? p.principal
                            : teinte.withValues(alpha: 0.28),
                        width: selectionnee ? 2.5 : 1,
                      ),
                      boxShadow: selectionnee
                          ? [
                              BoxShadow(
                                color: teinte.withValues(alpha: 0.42),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: _glyphe(
                      info.name,
                      selectionnee ? Colors.white : teinte,
                      30,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedScale(
                      scale: selectionnee ? 1.0 : 0.0,
                      duration: duree,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.principal,
                          border: Border.all(color: p.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: p.surPrincipal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(
              info.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.15,
                fontWeight: selectionnee ? FontWeight.w700 : FontWeight.w600,
                color: selectionnee ? p.principal : p.texte,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petite puce d'accès rapide aux catégories les plus utilisées.
class _PuceFrequente extends StatelessWidget {
  const _PuceFrequente({
    required this.info,
    required this.selectionnee,
    required this.onTap,
  });

  final CategoryInfo info;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final teinte = teinteCategorie(context, info.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selectionnee
            ? Color.alphaBlend(teinte.withValues(alpha: 0.14), p.surface)
            : p.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: selectionnee ? teinte : p.bordure,
          width: selectionnee ? 1.8 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PastilleCategorie(info.name, taille: 32),
                const SizedBox(width: 8),
                Text(
                  info.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.texte,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grand bouton en dégradé brun (grisé quand il n'est pas actif).
class _BoutonDegrade extends StatelessWidget {
  const _BoutonDegrade({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.actif = true,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final premier = actif ? p.principal : p.bordure;
    final second = actif ? Color.lerp(p.principal, p.accent, 0.5)! : p.bordure;
    final surBouton = actif ? p.surPrincipal : p.texteDoux;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [premier, second],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: actif
            ? [
                BoxShadow(
                  color: p.principal.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: actif ? onTap : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone, size: 22, color: surBouton),
                const SizedBox(width: 8),
                Text(
                  libelle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: surBouton,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}