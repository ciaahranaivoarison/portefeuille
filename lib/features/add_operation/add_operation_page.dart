import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/operations.dart';
import '../../data/repository.dart';
import '../../widgets/choix.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/ui.dart';

class AddOperationPage extends StatefulWidget {
  const AddOperationPage({super.key, this.transaction});

  /// Si elle est fournie, l'écran sert à modifier cette opération.
  final TransactionItem? transaction;

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

  bool get _modification => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _type = t.type;
      _compteId = t.accountId;
      _versCompteId = t.toAccountId;
      _categorieId = t.categoryId;
      _date = t.date;
      _montantCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
    }
    _chargerComptes();
    _chargerCategories(garder: true);
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
      if (comptes.isNotEmpty && _compteId == null) {
        _compteId = comptes.first.id;
      }
    });
  }

  Future<void> _chargerCategories({bool garder = false}) async {
    if (_type == 'transfer') {
      setState(() => _categories = []);
      return;
    }
    final categories = await Operations.instance.categories(_type);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      if (!garder) _categorieId = null;
    });
  }

  void _changerType(String type) {
    if (type == _type) return;
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
      if (_modification) {
        await Operations.instance.modifier(
          id: widget.transaction!.id,
          type: _type,
          montant: montant,
          compteId: _compteId!,
          versCompteId: _versCompteId,
          categorieId: _categorieId,
          date: _date,
          note: _noteCtrl.text,
        );
      } else {
        await Operations.instance.ajouter(
          type: _type,
          montant: montant,
          compteId: _compteId!,
          versCompteId: _versCompteId,
          categorieId: _categorieId,
          date: _date,
          note: _noteCtrl.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  Future<void> _supprimer() async {
    final ok = await confirmerSuppression(context);
    if (!ok) return;
    await Operations.instance.supprimer(widget.transaction!.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Color _couleurType(Palette p) => switch (_type) {
        'income' => p.revenu,
        'expense' => p.depense,
        _ => p.principal,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final couleur = _couleurType(p);
    final transfert = _type == 'transfer';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modification ? "Modifier l'opération" : 'Nouvelle opération',
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
          Row(
            children: [
              Expanded(
                child: CarteChoix(
                  emoji: '💵',
                  libelle: 'Revenu',
                  actif: _type == 'income',
                  couleur: p.revenu,
                  onTap: () => _changerType('income'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CarteChoix(
                  emoji: '💸',
                  libelle: 'Dépense',
                  actif: _type == 'expense',
                  couleur: p.depense,
                  onTap: () => _changerType('expense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CarteChoix(
                  emoji: '🔁',
                  libelle: 'Transfert',
                  actif: transfert,
                  couleur: p.principal,
                  onTap: () => _changerType('transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  Text(
                    'MONTANT (AR)',
                    style: TextStyle(
                      fontSize: 11.5,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: p.texteDoux,
                    ),
                  ),
                  TextField(
                    controller: _montantCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontTitre,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: couleur,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _montantCtrl,
                    builder: (context, valeur, _) {
                      final n = int.tryParse(valeur.text) ?? 0;
                      return Text(
                        n > 0 ? formatAr(n) : 'Saisissez un montant',
                        style: TextStyle(fontSize: 13, color: p.texteDoux),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          TitreSection(transfert ? 'Compte de départ' : 'Compte'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _comptes)
                ChipChoix(
                  emoji: emojiCompte(c.type),
                  libelle: c.name,
                  actif: _compteId == c.id,
                  onTap: () => setState(() => _compteId = c.id),
                ),
            ],
          ),
          if (transfert) ...[
            const SizedBox(height: 14),
            Center(
              child: Icon(
                Icons.arrow_downward_rounded,
                color: p.texteDoux,
              ),
            ),
            const TitreSection("Compte d'arrivée"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _comptes)
                  ChipChoix(
                    emoji: emojiCompte(c.type),
                    libelle: c.name,
                    actif: _versCompteId == c.id,
                    onTap: () => setState(() => _versCompteId = c.id),
                  ),
              ],
            ),
          ] else ...[
            const TitreSection('Catégorie'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  ChipChoix(
                    emoji: emojiCategorie(c.name),
                    libelle: c.name,
                    actif: _categorieId == c.id,
                    onTap: () => setState(() => _categorieId = c.id),
                  ),
              ],
            ),
          ],
          const TitreSection('Date'),
          Card(
            child: InkWell(
              onTap: _choisirDate,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const PastilleEmoji('📅', taille: 40),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        formatDate(_date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: p.texteDoux),
                  ],
                ),
              ),
            ),
          ),
          const TitreSection('Note (facultatif)'),
          TextField(
            controller: _noteCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex. : Déjeuner',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _enregistrer,
            style: FilledButton.styleFrom(backgroundColor: couleur),
            child: Text(
              _modification ? 'Enregistrer les modifications' : 'Enregistrer',
            ),
          ),
        ],
      ),
    );
  }
}