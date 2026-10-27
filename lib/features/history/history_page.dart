import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/operations.dart';
import '../../data/repository.dart';
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

class _HistoryPageState extends State<HistoryPage> {
  static const _periodes = [
    ('tout', 'Tout'),
    ('jour', "Aujourd'hui"),
    ('semaine', 'Cette semaine'),
    ('mois', 'Ce mois'),
    ('precedent', 'Mois précédent'),
    ('perso', 'Période…'),
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

  Future<void> _choisirPeriode(String p) async {
    final maintenant = DateTime.now();
    final jour = DateTime(maintenant.year, maintenant.month, maintenant.day);
    DateTime? debut;
    DateTime? fin;

    switch (p) {
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
      _periode = p;
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

  Future<void> _modifier(TransactionItem t) async {
    final modifie = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddOperationPage(transaction: t)),
    );
    if (modifie == true) _charger();
  }

  Widget _chip(String label, bool selectionne, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectionne,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.blanc,
        selectedColor: AppColors.noyer,
        side: const BorderSide(color: AppColors.sable),
        labelStyle: TextStyle(
          color: selectionne ? AppColors.blanc : AppColors.cacao,
        ),
      ),
    );
  }

  Widget _ligne(TransactionItem t, int index) {
    final couleur = switch (t.type) {
      'income' => AppColors.sauge,
      'expense' => AppColors.terracotta,
      _ => AppColors.noyer,
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
    final details = [
      formatDate(t.date),
      compte,
      if (t.note != null) t.note!,
    ].join(' · ');

    return Apparition(
      key: ValueKey('operation${t.id}'),
      index: index < 8 ? index : 0,
      child: Dismissible(
        key: ValueKey(t.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.blanc),
        ),
        confirmDismiss: (_) => confirmerSuppression(context),
        onDismissed: (_) {
          setState(() => _items.removeWhere((x) => x.id == t.id));
          Operations.instance.supprimer(t.id);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              onTap: () => _modifier(t),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: PastilleEmoji(emoji, taille: 40),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          EnteteEcran(
            emoji: '🧾',
            titre: 'Historique',
            sousTitre: _chargement
                ? 'Chargement…'
                : '${_items.length} opération(s)',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _rechercheCtrl,
              onChanged: (_) => _charger(),
              decoration: const InputDecoration(
                hintText: 'Rechercher (note, catégorie, compte)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final p in _periodes)
                  _chip(
                    _libellePeriode(p.$1, p.$2),
                    _periode == p.$1,
                    () => _choisirPeriode(p.$1),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _compteId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Compte'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tous'),
                      ),
                      for (final c in _comptes)
                        DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _compteId = v);
                      _charger();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _categorieId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Toutes'),
                      ),
                      for (final c in _categories)
                        DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(
                            '${emojiCategorie(c.name)} ${c.name} '
                            '(${c.type == 'income' ? 'revenu' : 'dépense'})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _categorieId = v);
                      _charger();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const EtatVide(
                        titre: 'Aucune opération',
                        message: "Appuyez sur « Ajouter » à l'accueil pour "
                            'saisir votre première opération.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: _items.length,
                        itemBuilder: (context, i) => _ligne(_items[i], i),
                      ),
          ),
        ],
      ),
    );
  }
}