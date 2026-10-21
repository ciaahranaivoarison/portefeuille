import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../data/operations.dart';
import '../../data/repository.dart';

class AddOperationPage extends StatefulWidget {
  const AddOperationPage({super.key});

  @override
  State<AddOperationPage> createState() => _AddOperationPageState();
}

class _AddOperationPageState extends State<AddOperationPage> {
    String _type = 'income'; // 'income', 'expense' ou 'transfer'
  List<AccountBalance> _comptes = [];
  List<Category> _categories = [];
  int? _compteId;
  int? _versCompteId;
  int? _categorieId;
  DateTime _date = DateTime.now();

  final _montantCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerComptes();
    _chargerCategories();
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerComptes() async {
    final comptes = await Repository.instance.comptes();
    if (!mounted) return;
    setState(() {
      _comptes = comptes;
      if (comptes.isNotEmpty) _compteId = comptes.first.id;
    });
  }

  Future<void> _chargerCategories() async {
    if (_type == 'transfer') {
      setState(() => _categories = []);
      return;
    }
    final categories = await Operations.instance.categories(_type);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _categorieId = null;
    });
  }

  void _changerType(String type) {
    setState(() {
      _type = type;
      _categorieId = null;
      _versCompteId = null;
    });
    _chargerCategories();
  }

  Future<void> _choisirDate() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (choisie != null) setState(() => _date = choisie);
  }

  String _dateTexte(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _enregistrer() async {
    final messenger = ScaffoldMessenger.of(context);
    final montant = int.tryParse(_montantCtrl.text.trim()) ?? 0;

    if (montant <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Saisissez un montant supérieur à 0.')),
      );
      return;
    }
    if (_compteId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez un compte.')),
      );
      return;
    }
    if (_type != 'transfer' && _categorieId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie.')),
      );
      return;
    }

    try {
      await Operations.instance.ajouter(
        type: _type,
        montant: montant,
        compteId: _compteId!,
        versCompteId: _versCompteId,
        categorieId: _categorieId,
        date: _date,
        note: _noteCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Text(
          texte.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.noyer,
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  Widget _chip(String label, bool selectionne, VoidCallback onTap) {
    return ChoiceChip(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final transfert = _type == 'transfer';
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle opération')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Revenu')),
              ButtonSegment(value: 'income', label: Text('Dépense')),
              ButtonSegment(value: 'transfer', label: Text('Transfert')),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _changerType(s.first),
          ),
          _titre('Montant (Ar)'),
          TextField(
            controller: _montantCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(hintText: '0'),
          ),
          _titre(transfert ? 'Compte de départ' : 'Compte'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _comptes)
                _chip(c.name, _compteId == c.id,
                    () => setState(() => _compteId = c.id)),
            ],
          ),
          if (transfert) ...[
            _titre("Compte d'arrivée"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _comptes)
                  _chip(c.name, _versCompteId == c.id,
                      () => setState(() => _versCompteId = c.id)),
              ],
            ),
          ] else ...[
            _titre('Catégorie'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  _chip(c.name, _categorieId == c.id,
                      () => setState(() => _categorieId = c.id)),
              ],
            ),
          ],
          _titre('Date'),
          OutlinedButton.icon(
            onPressed: _choisirDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(_dateTexte(_date)),
          ),
          _titre('Note (facultatif)'),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(hintText: 'Ex. : Déjeuner'),
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