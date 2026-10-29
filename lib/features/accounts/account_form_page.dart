import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/accounts.dart';
import '../../widgets/choix.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/ui.dart';

/// Création ou modification d'un compte.
class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key, this.compteId});

  /// Si elle est fournie, l'écran sert à modifier ce compte.
  final int? compteId;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  static const _types = ['cash', 'bank', 'mobile'];

  static const _suggestions = [
    ('Espèces', 'cash'),
    ('Banque', 'bank'),
    ('MVola', 'mobile'),
    ('Orange Money', 'mobile'),
    ('Airtel Money', 'mobile'),
  ];

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
      message:
          "Un compte ne peut être supprimé que s'il n'a aucune opération.",
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

  @override
  Widget build(BuildContext context) {
    final p = context.pal;

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
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: PastilleEmoji(
                      emojiCompte(_type),
                      taille: 78,
                      key: ValueKey<String>(_type),
                    ),
                  ),
                ),
                const TitreSection('Nom du compte'),
                TextField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ex. : MVola, Banque, Espèces',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                if (!_modification) ...[
                  const SizedBox(height: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nomCtrl,
                    builder: (context, valeur, _) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _suggestions)
                          ChipChoix(
                            emoji: emojiCompte(s.$2),
                            libelle: s.$1,
                            actif: valeur.text.trim().toLowerCase() ==
                                s.$1.toLowerCase(),
                            onTap: () => setState(() {
                              _nomCtrl.text = s.$1;
                              _type = s.$2;
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
                const TitreSection('Type de compte'),
                Row(
                  children: [
                    for (var i = 0; i < _types.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: CarteChoix(
                          emoji: emojiCompte(_types[i]),
                          libelle: libelleTypeCompte(_types[i]),
                          actif: _type == _types[i],
                          onTap: () => setState(() => _type = _types[i]),
                        ),
                      ),
                    ],
                  ],
                ),
                const TitreSection('Solde de départ (Ar)'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Column(
                      children: [
                        TextField(
                          controller: _soldeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: p.principal,
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
                          valueListenable: _soldeCtrl,
                          builder: (context, valeur, _) => Text(
                            formatAr(int.tryParse(valeur.text) ?? 0),
                            style: TextStyle(
                              fontSize: 13,
                              color: p.texteDoux,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "C'est l'argent présent sur le compte avant votre première "
                  "opération. Les revenus, dépenses et transferts s'y ajoutent.",
                  style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _enregistrer,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
    );
  }
}