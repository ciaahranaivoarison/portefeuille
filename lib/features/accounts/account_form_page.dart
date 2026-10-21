import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../data/accounts.dart';
import '../../widgets/confirm_dialog.dart';

/// Création ou modification d'un compte.
class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.compteId});

  /// Si elle est fournie, l'écran sert à modifier ce compte.
  final int? compteId;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _nomCtrl = TextEditingController();
  final _soldeCtrl = TextEditingController();
  String _type = 'cash';
  bool _chargement = false;

  bool get _modification => widget.compteId != null;

  @override
  void initState() {
    super.initState();
    if (_modification) _charger();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _soldeCtrl.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    setState(() => _chargement = true);
    final d = await Accounts.instance.details(widget.compteId!);
    if (!mounted) return;
    setState(() {
      _nomCtrl.text = d.name;
      _soldeCtrl.text = d.initialBalance.toString();
      _type = d.type;
      _chargement = false;
    });
  }

  Future<void> _enregistrer() async {
    final messenger = ScaffoldMessenger.of(context);
    final solde = int.tryParse(_soldeCtrl.text.trim()) ?? 0;
    try {
      if (_modification) {
        await Accounts.instance.modifier(
          id: widget.compteId!,
          nom: _nomCtrl.text,
          type: _type,
          soldeInitial: solde,
        );
      } else {
        await Accounts.instance.creer(
          nom: _nomCtrl.text,
          type: _type,
          soldeInitial: solde,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  Future<void> _supprimer() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmerSuppression(
      context,
      titre: 'Supprimer ce compte ?',
      message: 'Un compte ne peut être supprimé que s\'il n\'a aucune opération.',
    );
    if (!ok) return;
    try {
      await Accounts.instance.supprimer(widget.compteId!);
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

  Widget _chip(String type) {
    final selectionne = _type == type;
    return ChoiceChip(
      label: Text(libelleTypeCompte(type)),
      selected: selectionne,
      showCheckmark: false,
      onSelected: (_) => setState(() => _type = type),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier le compte' : 'Nouveau compte'),
        actions: [
          if (_modification)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: _supprimer,
            ),
        ],
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _titre('Nom du compte'),
                TextField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ex. : MVola, Banque, Espèces',
                  ),
                ),
                _titre('Type'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('cash'),
                    _chip('bank'),
                    _chip('mobile'),
                  ],
                ),
                _titre('Solde de départ (Ar)'),
                TextField(
                  controller: _soldeCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(hintText: '0'),
                ),
                const SizedBox(height: 8),
                Text(
                  "C'est l'argent présent sur le compte avant votre première "
                  'opération. Les revenus, dépenses et transferts s\'y ajoutent.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.noyer),
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