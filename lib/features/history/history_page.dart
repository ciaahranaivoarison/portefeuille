import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/operations.dart';
import '../../data/repository.dart';
import '../../widgets/choix.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/etat_vide.dart';
import '../../widgets/ui.dart';
import '../add_operation/add_operation_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

/// Résultat de la fenêtre « Filtres ».
class _Choix {
  const _Choix(this.compteId, this.categorieId);

  final int? compteId;
  final int? categorieId;
}

class _HistoryPageState extends State<HistoryPage> {
  static const _periodes = [
    ('tout', '📅', 'Toutes les dates'),
    ('jour', '☀️', "Aujourd'hui"),
    ('semaine', '🗓️', 'Cette semaine'),
    ('mois', '📆', 'Ce mois'),
    ('precedent', '⏪', 'Mois précédent'),
    ('perso', '🎛️', 'Personnalisée'),
  ];

  final _rechercheCtrl = TextEditingController();
  List<TransactionItem> _items = [];
  List<AccountBalance> _comptes = [];
  List<Category> _categories = [];
  int? _compteId;
  int? _categorieId;
  String _periode = 'tout';
  DateTime? _debut;
  DateTime? _fin;
  bool _chargement = true;

  int get _nbFiltres =>
      (_compteId != null ? 1 : 0) + (_categorieId != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final comptes = await Repository.instance.comptes();
    final categories = await Operations.instance.toutesCategories();
    if (!mounted) return;
    setState(() {
      _comptes = comptes;
      _categories = categories;
    });
    await _charger();
  }

  Future<void> _charger() async {
    final items = await Operations.instance.lister(
      recherche: _rechercheCtrl.text,
      compteId: _compteId,
      categorieId: _categorieId,
      debut: _debut,
      fin: _fin,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
      _chargement = false;
    });
  }

  Future<void> _choisirPeriode(String code) async {
    final maintenant = DateTime.now();
    final jour = DateTime(maintenant.year, maintenant.month, maintenant.day);
    DateTime? debut;
    DateTime? fin;

    switch (code) {
      case 'jour':
        debut = jour;
        fin = jour;
      case 'semaine':
        final lundi = jour.subtract(Duration(days: jour.weekday - 1));
        debut = lundi;
        fin = lundi.add(const Duration(days: 6));
      case 'mois':
        debut = DateTime(jour.year, jour.month, 1);
        fin = DateTime(jour.year, jour.month + 1, 0);
      case 'precedent':
        debut = DateTime(jour.year, jour.month - 1, 1);
        fin = DateTime(jour.year, jour.month, 0);
      case 'perso':
        final plage = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: (_debut != null && _fin != null)
              ? DateTimeRange(start: _debut!, end: _fin!)
              : null,
        );
        if (plage == null) return;
        debut = plage.start;
        fin = plage.end;
    }

    setState(() {
      _periode = code;
      _debut = debut;
      _fin = fin;
    });
    await _charger();
  }

  String _libellePeriode(String code, String libelle) {
    if (code == 'perso' && _periode == 'perso' && _debut != null) {
      return '${formatDate(_debut!)} → ${formatDate(_fin!)}';
    }
    return libelle;
  }

  Future<void> _ouvrirFiltres() async {
    final choix = await showModalBottomSheet<_Choix>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FiltresSheet(
        comptes: _comptes,
        categories: _categories,
        compteId: _compteId,
        categorieId: _categorieId,
      ),
    );
    if (choix == null) return;
    setState(() {
      _compteId = choix.compteId;
      _categorieId = choix.categorieId;
    });
    await _charger();
  }

  Future<void> _effacerFiltres() async {
    setState(() {
      _compteId = null;
      _categorieId = null;
    });
    await _charger();
  }

  Future<void> _modifier(TransactionItem t) async {
    final modifie = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddOperationPage(transaction: t)),
    );
    if (modifie == true) _charger();
  }

  String _nomCompte(int id) {
    for (final c in _comptes) {
      if (c.id == id) return '${emojiCompte(c.type)} ${c.name}';
    }
    return 'Compte';
  }

  String _nomCategorie(int id) {
    for (final c in _categories) {
      if (c.id == id) return '${emojiCategorie(c.name)} ${c.name}';
    }
    return 'Catégorie';
  }

  String _libelleJour(DateTime d) {
    final n = DateTime.now();
    final aujourdhui = DateTime(n.year, n.month, n.day);
    final jour = DateTime(d.year, d.month, d.day);
    final ecart = aujourdhui.difference(jour).inDays;
    if (ecart == 0) return "Aujourd'hui";
    if (ecart == 1) return 'Hier';
    return formatDate(d);
  }

  Widget _boutonFiltres(Palette p) {
    final n = _nbFiltres;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BoutonHeader(
          icone: Icons.tune_rounded,
          infobulle: 'Filtres',
          onTap: _ouvrirFiltres,
        ),
        if (n > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent),
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: p.surPrincipal,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _barreRecherche() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: TextField(
        controller: _rechercheCtrl,
        onChanged: (_) => _charger(),
        decoration: InputDecoration(
          hintText: 'Rechercher une note, une catégorie, un compte',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _rechercheCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _rechercheCtrl.clear();
                    _charger();
                  },
                ),
        ),
      ),
    );
  }

  Widget _bandePeriodes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final per in _periodes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChipChoix(
                emoji: per.$2,
                libelle: _libellePeriode(per.$1, per.$3),
                actif: _periode == per.$1,
                onTap: () => _choisirPeriode(per.$1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filtresActifs(Palette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (_compteId != null)
            _FiltreActif(
              libelle: _nomCompte(_compteId!),
              onRetirer: () {
                setState(() => _compteId = null);
                _charger();
              },
            ),
          if (_categorieId != null)
            _FiltreActif(
              libelle: _nomCategorie(_categorieId!),
              onRetirer: () {
                setState(() => _categorieId = null);
                _charger();
              },
            ),
          GestureDetector(
            onTap: _effacerFiltres,
            child: Text(
              'Tout effacer',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.principal,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resume(Palette p) {
    final revenus = _items
        .where((t) => t.type == 'income')
        .fold<int>(0, (somme, t) => somme + t.amount);
    final depenses = _items
        .where((t) => t.type == 'expense')
        .fold<int>(0, (somme, t) => somme + t.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _PetiteStat(
              emoji: '💵',
              valeur: '+ ${formatAr(revenus)}',
              couleur: p.revenu,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PetiteStat(
              emoji: '💸',
              valeur: '- ${formatAr(depenses)}',
              couleur: p.depense,
            ),
          ),
        ],
      ),
    );
  }

  Widget _enteteJour(Palette p, DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        _libelleJour(date).toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w700,
          color: p.texteDoux,
        ),
      ),
    );
  }

  Widget _ligne(Palette p, TransactionItem t, int rang) {
    final couleur = switch (t.type) {
      'income' => p.revenu,
      'expense' => p.depense,
      _ => p.principal,
    };
    final signe = t.type == 'income'
        ? '+ '
        : t.type == 'expense'
            ? '- '
            : '';
    final titre = t.type == 'transfer'
        ? 'Transfert'
        : (t.categoryName ?? 'Sans catégorie');
    final emoji = t.type == 'transfer' ? '🔁' : emojiCategorie(t.categoryName);
    final compte = t.type == 'transfer'
        ? '${t.accountName} → ${t.toAccountName ?? ''}'
        : t.accountName;
    final details = <String>[compte, ?t.note].join(' · ');

    return Apparition(
      key: ValueKey('operation${t.id}'),
      index: rang < 8 ? rang : 0,
      child: Dismissible(
        key: ValueKey(t.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          decoration: BoxDecoration(
            color: p.depense,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        confirmDismiss: (_) => confirmerSuppression(context),
        onDismissed: (_) {
          setState(() => _items.removeWhere((x) => x.id == t.id));
          Operations.instance.supprimer(t.id);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Card(
            child: ListTile(
              onTap: () => _modifier(t),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: PastilleEmoji(emoji, taille: 42),
              title: Text(
                titre,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(details, maxLines: 2),
              trailing: Text(
                '$signe${formatAr(t.amount)}',
                style: TextStyle(
                  fontFamily: AppTheme.fontTitre,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _construire(Palette p) {
    final elements = <Widget>[
      EnteteEcran(
        emoji: '🧾',
        titre: 'Historique',
        sousTitre: _chargement
            ? 'Chargement…'
            : (_items.length > 1
                ? '${_items.length} opérations'
                : '${_items.length} opération'),
        action: _boutonFiltres(p),
      ),
      _barreRecherche(),
      _bandePeriodes(),
      if (_nbFiltres > 0) _filtresActifs(p),
      if (_items.isNotEmpty) _resume(p),
    ];

    if (_chargement) {
      elements.add(
        const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
      return elements;
    }

    if (_items.isEmpty) {
      final filtre = _nbFiltres > 0 ||
          _periode != 'tout' ||
          _rechercheCtrl.text.isNotEmpty;
      elements.add(
        EtatVide(
          titre: filtre ? 'Aucun résultat' : 'Aucune opération',
          message: filtre
              ? 'Modifiez la recherche ou effacez les filtres.'
              : "Appuyez sur « Ajouter une opération » à l'accueil pour "
                  'saisir la première.',
        ),
      );
      return elements;
    }

    String? jourCourant;
    var rang = 0;
    for (final t in _items) {
      final cle = formatDate(t.date);
      if (cle != jourCourant) {
        jourCourant = cle;
        elements.add(_enteteJour(p, t.date));
      }
      elements.add(_ligne(p, t, rang));
      rang++;
    }
    return elements;
  }

  @override
  Widget build(BuildContext context) {
    final elements = _construire(context.pal);
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: elements.length,
        itemBuilder: (context, i) => elements[i],
      ),
    );
  }
}

class _PetiteStat extends StatelessWidget {
  const _PetiteStat({
    required this.emoji,
    required this.valeur,
    required this.couleur,
  });

  final String emoji;
  final String valeur;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valeur,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: couleur,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltreActif extends StatelessWidget {
  const _FiltreActif({required this.libelle, required this.onRetirer});

  final String libelle;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      onTap: onRetirer,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
        decoration: BoxDecoration(
          color: p.accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              libelle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.texte,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.close_rounded, size: 16, color: p.texteDoux),
          ],
        ),
      ),
    );
  }
}

/// Fenêtre « Filtres » : compte et catégorie en pastilles.
class _FiltresSheet extends StatefulWidget {
  const _FiltresSheet({
    required this.comptes,
    required this.categories,
    required this.compteId,
    required this.categorieId,
  });

  final List<AccountBalance> comptes;
  final List<Category> categories;
  final int? compteId;
  final int? categorieId;

  @override
  State<_FiltresSheet> createState() => _FiltresSheetState();
}

class _FiltresSheetState extends State<_FiltresSheet> {
  late int? _compte = widget.compteId;
  late int? _categorie = widget.categorieId;

  @override
  Widget build(BuildContext context) {
    final depenses =
        widget.categories.where((c) => c.type == 'expense').toList();
    final revenus = widget.categories.where((c) => c.type == 'income').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtres',
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: context.pal.texte,
            ),
          ),
          const TitreSection('Compte'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipChoix(
                emoji: '🏷️',
                libelle: 'Tous',
                actif: _compte == null,
                onTap: () => setState(() => _compte = null),
              ),
              for (final c in widget.comptes)
                ChipChoix(
                  emoji: emojiCompte(c.type),
                  libelle: c.name,
                  actif: _compte == c.id,
                  onTap: () => setState(() => _compte = c.id),
                ),
            ],
          ),
          const TitreSection('Catégories de dépenses'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipChoix(
                emoji: '🏷️',
                libelle: 'Toutes',
                actif: _categorie == null,
                onTap: () => setState(() => _categorie = null),
              ),
              for (final c in depenses)
                ChipChoix(
                  emoji: emojiCategorie(c.name),
                  libelle: c.name,
                  actif: _categorie == c.id,
                  onTap: () => setState(() => _categorie = c.id),
                ),
            ],
          ),
          const TitreSection('Catégories de revenus'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in revenus)
                ChipChoix(
                  emoji: emojiCategorie(c.name),
                  libelle: c.name,
                  actif: _categorie == c.id,
                  onTap: () => setState(() => _categorie = c.id),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const _Choix(null, null)),
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_Choix(_compte, _categorie)),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}