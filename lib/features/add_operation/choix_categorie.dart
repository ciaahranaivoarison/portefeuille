import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../data/categories.dart';
import '../../widgets/pastille_categorie.dart';
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
        320.0,
        MediaQuery.sizeOf(ctx).height * 0.85 - clavier,
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
            Icon(Icons.search_off_rounded, size: 40, color: p.texteDoux),
            const SizedBox(height: 10),
            Text(
              'Aucune catégorie trouvée.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.texteDoux),
            ),
            if (saisie.isNotEmpty) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _creerDepuisRecherche,
                icon: const Icon(Icons.add_rounded),
                label: Text('${tr('Créer')} « $saisie »'),
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
    final choisie = _choisie;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choisir une catégorie',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTitre,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: p.texte,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: tr('Nouvelle catégorie'),
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _creerAvecFormulaire,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
              ),
            ),
          ),
          if (_erreur != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
          const SizedBox(height: 8),
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator())
                : filtrees.isEmpty
                    ? _vide(p, saisie)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        itemCount: filtrees.length,
                        itemBuilder: (context, i) => _LigneChoix(
                          info: filtrees[i],
                          selectionnee: filtrees[i].id == _selection,
                          onTap: () =>
                              setState(() => _selection = filtrees[i].id),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: choisie == null
                    ? null
                    : () => Navigator.of(context).pop(choisie),
                child: const Text('OK'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneChoix extends StatelessWidget {
  const _LigneChoix({
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
    const duree = Duration(milliseconds: 220);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: duree,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selectionnee
              ? Color.alphaBlend(teinte.withValues(alpha: 0.09), p.surface)
              : p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selectionnee ? p.principal : p.bordure,
            width: selectionnee ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: teinte.withValues(alpha: selectionnee ? 0.20 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              child: Row(
                children: [
                  PastilleCategorie(info.name, taille: 46),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            color: p.texte,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: info.isDefault ? p.accent : teinte,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              info.isDefault ? 'Par défaut' : 'Personnalisée',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: p.texteDoux,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: duree,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectionnee ? p.principal : Colors.transparent,
                      border: Border.all(
                        color: selectionnee ? p.principal : p.bordure,
                        width: 1.6,
                      ),
                    ),
                    child: AnimatedOpacity(
                      duration: duree,
                      opacity: selectionnee ? 1 : 0,
                      child: Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: p.surPrincipal,
                      ),
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
}