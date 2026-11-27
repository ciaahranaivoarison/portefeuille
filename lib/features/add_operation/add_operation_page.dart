import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/categories.dart';
import '../../data/operations.dart';
import '../../data/repository.dart';
import '../../widgets/choix.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/pastille_categorie.dart';
import '../../widgets/pictogramme.dart';
import '../../widgets/ui.dart';
import 'choix_categorie.dart';

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
  List<CategoryInfo> _categories = [];
  int? _compteId;
  int? _versCompteId;
  int? _categorieId;
  DateTime _date = DateTime.now();

  final _montantCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool get _modification => widget.transaction != null;

  /// Catégorie actuellement choisie (null si aucune).
  CategoryInfo? get _categorieChoisie {
    for (final c in _categories) {
      if (c.id == _categorieId) return c;
    }
    return null;
  }

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
    final categories = await Categories.instance.lister(_type);
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

  /// Ouvre la feuille de choix : recherche, sélection, puis « OK ».
  Future<void> _choisirCategorie() async {
    final choisie = await choisirCategorie(
      context,
      type: _type,
      selectionId: _categorieId,
    );
    if (choisie == null || !mounted) return;
    // La feuille a pu créer une catégorie : on recharge la liste.
    final categories = await Categories.instance.lister(_type);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _categorieId = choisie.id;
    });
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

  /// Le mot « Catégorie » avec son bouton « + », puis la catégorie choisie.
  Widget _sectionCategorie() {
    final choisie = _categorieChoisie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const TitreSection('Catégorie'),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _BoutonPlus(onTap: _choisirCategorie),
            ),
          ],
        ),
        if (choisie != null)
          _CategorieChoisie(info: choisie, onTap: _choisirCategorie),
        const SizedBox(height: 4),
      ],
    );
  }

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
              tooltip: tr('Supprimer'),
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
                  emoji: ':banknote:',
                  libelle: 'Revenu',
                  actif: _type == 'income',
                  couleur: p.revenu,
                  onTap: () => _changerType('income'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CarteChoix(
                  emoji: ':expense:',
                  libelle: 'Dépense',
                  actif: _type == 'expense',
                  couleur: p.depense,
                  onTap: () => _changerType('expense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CarteChoix(
                  emoji: ':transfer:',
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
          ] else
            _sectionCategorie(),
          const TitreSection('Date'),
          Card(
            child: InkWell(
              onTap: _choisirDate,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const PastilleEmoji(':calendar:', taille: 40),
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
            decoration: InputDecoration(
              hintText: tr('Écrivez ici'),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 28),
          _BoutonEnregistrer(
            libelle: _modification
                ? 'Enregistrer les modifications'
                : 'Enregistrer',
            onTap: _enregistrer,
          ),
        ],
      ),
    );
  }
}

/// Bouton « + » rond, en dégradé brun, posé à côté du mot « Catégorie ».
class _BoutonPlus extends StatelessWidget {
  const _BoutonPlus({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tooltip(
      message: tr('Choisir une catégorie'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.principal, Color.lerp(p.principal, p.accent, 0.55)!],
          ),
          boxShadow: [
            BoxShadow(
              color: p.principal.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Icon(Icons.add_rounded, size: 22, color: p.surPrincipal),
          ),
        ),
      ),
    );
  }
}

/// Carte de la catégorie choisie : dégradé de sa couleur, icône blanche dans
/// un cercle translucide, nom en grand et bouton « Changer ».
class _CategorieChoisie extends StatelessWidget {
  const _CategorieChoisie({required this.info, required this.onTap});

  final CategoryInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final teinte = teinteCategorie(context, info.name);
    final icone = iconeCategorie(info.name);
    final lettre =
        icone.startsWith('lettre-') ? icone.substring(7).toUpperCase() : null;
    final blanc = Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(teinte, AppColors.cacao, 0.2)!,
            Color.lerp(teinte, AppColors.cacao, 0.52)!,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: teinte.withValues(alpha: 0.38),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -36,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blanc.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                Positioned(
                  right: 46,
                  bottom: -54,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blanc.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: blanc.withValues(alpha: 0.20),
                          border: Border.all(
                            color: blanc.withValues(alpha: 0.38),
                            width: 1.5,
                          ),
                        ),
                        child: lettre != null
                            ? Text(
                                lettre,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontTitre,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  color: blanc,
                                ),
                              )
                            : Pictogramme(icone, taille: 30, couleur: blanc),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              info.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTheme.fontTitre,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: blanc,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: blanc.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                info.isDefault ? 'Par défaut' : 'Personnalisée',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: blanc,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: blanc.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: blanc.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: blanc,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Changer',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: blanc,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// Bouton « Enregistrer » : dégradé brun-caramel du thème, en pilule.
class _BoutonEnregistrer extends StatelessWidget {
  const _BoutonEnregistrer({required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.principal, Color.lerp(p.principal, p.accent, 0.5)!],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: p.principal.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 22, color: p.surPrincipal),
                const SizedBox(width: 8),
                Text(
                  libelle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: p.surPrincipal,
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