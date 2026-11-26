import 'dart:math' as math;

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

  /// Compte choisi (compte débité ou crédité, ou compte de départ).
  AccountBalance? get _compteChoisi {
    for (final c in _comptes) {
      if (c.id == _compteId) return c;
    }
    return null;
  }

  /// Compte d'arrivée d'un transfert.
  AccountBalance? get _compteArrivee {
    for (final c in _comptes) {
      if (c.id == _versCompteId) return c;
    }
    return null;
  }

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

  /// Inverse le compte de départ et le compte d'arrivée.
  void _echanger() {
    if (_compteId == null || _versCompteId == null) return;
    setState(() {
      final depart = _compteId;
      _compteId = _versCompteId;
      _versCompteId = depart;
    });
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
    if (_type == 'transfer' && _versCompteId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Choisissez le compte d'arrivée.")),
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

  // ─────────────────────────── Comptes ───────────────────────────

  /// Section des comptes : cartes à faire défiler (revenu ou dépense) ou
  /// panneau « de... vers... » (transfert).
  Widget _sectionComptes() {
    if (_type == 'transfer') return _panneauTransfert();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitreSection(
          _type == 'income' ? 'Compte à créditer' : 'Compte à débiter',
        ),
        _RangeeComptes(
          comptes: _comptes,
          selection: _compteId,
          debordement: true,
          onChoisir: (id) => setState(() => _compteId = id),
        ),
        const SizedBox(height: 12),
        _resumeSolde(),
      ],
    );
  }

  /// Solde du compte choisi, avant et après l'opération.
  Widget _resumeSolde() {
    final compte = _compteChoisi;
    if (compte == null) return const SizedBox.shrink();

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _montantCtrl,
      builder: (context, valeur, _) {
        final n = int.tryParse(valeur.text) ?? 0;
        final apres =
            _type == 'income' ? compte.balance + n : compte.balance - n;
        return _BandeauSolde(
          libelle: n > 0 ? 'Solde après opération' : 'Solde actuel',
          montant: n > 0 ? apres : compte.balance,
          alerte: n > 0 && apres < 0,
        );
      },
    );
  }

  Widget _panneauTransfert() {
    final p = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitreSection('Transfert'),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: p.bordure),
            boxShadow: [
              BoxShadow(
                color: p.principal.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                const _EtiquettePanneau(
                  icone: Icons.north_east_rounded,
                  libelle: 'Compte de départ',
                ),
                const SizedBox(height: 10),
                _RangeeComptes(
                  comptes: _comptes,
                  selection: _compteId,
                  desactive: _versCompteId,
                  margeH: 14,
                  onChoisir: (id) => setState(() => _compteId = id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: p.bordure)),
                      const SizedBox(width: 10),
                      _BoutonEchange(onTap: _echanger),
                      const SizedBox(width: 10),
                      Expanded(child: Divider(color: p.bordure)),
                    ],
                  ),
                ),
                const _EtiquettePanneau(
                  icone: Icons.south_west_rounded,
                  libelle: "Compte d'arrivée",
                ),
                const SizedBox(height: 10),
                _RangeeComptes(
                  comptes: _comptes,
                  selection: _versCompteId,
                  desactive: _compteId,
                  margeH: 14,
                  onChoisir: (id) => setState(() => _versCompteId = id),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _resumeTransfert(),
      ],
    );
  }

  /// Soldes des deux comptes avant et après le transfert.
  Widget _resumeTransfert() {
    final depart = _compteChoisi;
    final arrivee = _compteArrivee;
    if (depart == null || arrivee == null) return const SizedBox.shrink();
    final p = context.pal;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _montantCtrl,
      builder: (context, valeur, _) {
        final n = int.tryParse(valeur.text) ?? 0;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: p.surfaceDouce,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              _LigneTransfert(
                nom: depart.name,
                avant: depart.balance,
                apres: n > 0 ? depart.balance - n : null,
              ),
              Divider(height: 20, color: p.bordure),
              _LigneTransfert(
                nom: arrivee.name,
                avant: arrivee.balance,
                apres: n > 0 ? arrivee.balance + n : null,
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── Catégorie ─────────────────────────

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
          _sectionComptes(),
          if (!transfert) _sectionCategorie(),
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

// ═══════════════════════ Éléments de la section Comptes ═══════════════════════

/// Cartes de comptes à faire défiler, en une seule ligne.
class _RangeeComptes extends StatefulWidget {
  const _RangeeComptes({
    required this.comptes,
    required this.selection,
    required this.onChoisir,
    this.desactive,
    this.debordement = false,
    this.margeH = 0,
  });

  final List<AccountBalance> comptes;
  final int? selection;

  /// Compte grisé et non touchable (déjà pris de l'autre côté du transfert).
  final int? desactive;

  /// Si vrai, les cartes dépassent des marges de la page en défilant.
  final bool debordement;
  final double margeH;
  final ValueChanged<int> onChoisir;

  @override
  State<_RangeeComptes> createState() => _RangeeComptesState();
}

class _RangeeComptesState extends State<_RangeeComptes> {
  static const _largeur = 156.0;
  static const _ecart = 10.0;

  final _ctrl = ScrollController();
  bool _positionne = false;

  @override
  void initState() {
    super.initState();
    _planifier();
  }

  @override
  void didUpdateWidget(covariant _RangeeComptes ancien) {
    super.didUpdateWidget(ancien);
    if (!_positionne) _planifier();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _planifier() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _positionner());
  }

  /// Amène le compte choisi dans la vue (une seule fois, à l'ouverture).
  void _positionner() {
    if (!mounted || _positionne || !_ctrl.hasClients) return;
    final i = widget.comptes.indexWhere((c) => c.id == widget.selection);
    if (i < 0) return;
    _positionne = true;
    final cible = i * (_largeur + _ecart) - 24;
    _ctrl.jumpTo(math.max(0.0, math.min(cible, _ctrl.position.maxScrollExtent)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        clipBehavior: widget.debordement ? Clip.none : Clip.hardEdge,
        padding: EdgeInsets.symmetric(horizontal: widget.margeH),
        itemCount: widget.comptes.length,
        separatorBuilder: (context, index) => const SizedBox(width: _ecart),
        itemBuilder: (context, i) {
          final c = widget.comptes[i];
          return _CarteCompte(
            compte: c,
            largeur: _largeur,
            selectionne: c.id == widget.selection,
            desactive: c.id == widget.desactive,
            onTap: () => widget.onChoisir(c.id),
          );
        },
      ),
    );
  }
}

/// Carte d'un compte : icône, nom et solde. Le compte choisi passe en
/// dégradé brun avec une coche.
class _CarteCompte extends StatelessWidget {
  const _CarteCompte({
    required this.compte,
    required this.largeur,
    required this.selectionne,
    required this.desactive,
    required this.onTap,
  });

  final AccountBalance compte;
  final double largeur;
  final bool selectionne;
  final bool desactive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const duree = Duration(milliseconds: 240);
    final surFond = selectionne ? p.surPrincipal : p.texte;
    final negatif = compte.balance < 0;

    return Opacity(
      opacity: desactive ? 0.38 : 1,
      child: SizedBox(
        width: largeur,
        child: AnimatedContainer(
          duration: duree,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: selectionne
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      p.principal,
                      Color.lerp(p.principal, p.accent, 0.55)!,
                    ],
                  )
                : null,
            color: selectionne ? null : p.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selectionne ? Colors.transparent : p.bordure,
            ),
            boxShadow: [
              BoxShadow(
                color: (selectionne ? p.principal : p.texte)
                    .withValues(alpha: selectionne ? 0.28 : 0.06),
                blurRadius: selectionne ? 18 : 10,
                offset: Offset(0, selectionne ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: desactive ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PastilleEmoji(emojiCompte(compte.type), taille: 38),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: duree,
                          child: selectionne
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  key: const ValueKey<String>('coche'),
                                  size: 22,
                                  color: surFond,
                                )
                              : const SizedBox(
                                  key: ValueKey<String>('vide'),
                                  width: 22,
                                  height: 22,
                                ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          compte.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: surFond,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatAr(compte.balance),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: negatif
                                ? (selectionne
                                    ? const Color(0xFFFFD2C4)
                                    : p.depense)
                                : surFond,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandeau « solde actuel » ou « solde après opération ».
class _BandeauSolde extends StatelessWidget {
  const _BandeauSolde({
    required this.libelle,
    required this.montant,
    required this.alerte,
  });

  final String libelle;
  final int montant;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final couleur = alerte ? p.depense : p.texte;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: alerte
            ? p.depense.withValues(alpha: 0.10)
            : p.surfaceDouce,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            alerte
                ? Icons.warning_amber_rounded
                : Icons.account_balance_wallet_outlined,
            size: 20,
            color: alerte ? p.depense : p.texteDoux,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              libelle,
              style: TextStyle(fontSize: 13, color: p.texteDoux),
            ),
          ),
          Text(
            formatAr(montant),
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

/// Petite étiquette au-dessus d'une rangée du panneau de transfert.
class _EtiquettePanneau extends StatelessWidget {
  const _EtiquettePanneau({required this.icone, required this.libelle});

  final IconData icone;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.principal.withValues(alpha: 0.12),
            ),
            child: Icon(icone, size: 15, color: p.principal),
          ),
          const SizedBox(width: 10),
          Text(
            libelle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.texteDoux,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton rond qui inverse départ et arrivée (il fait un demi-tour).
class _BoutonEchange extends StatefulWidget {
  const _BoutonEchange({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BoutonEchange> createState() => _BoutonEchangeState();
}

class _BoutonEchangeState extends State<_BoutonEchange> {
  double _tours = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Tooltip(
      message: tr('Inverser'),
      child: AnimatedRotation(
        turns: _tours,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: Material(
          color: p.surface,
          elevation: 2,
          shadowColor: p.principal.withValues(alpha: 0.3),
          shape: CircleBorder(side: BorderSide(color: p.bordure)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              setState(() => _tours += 0.5);
              widget.onTap();
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.swap_vert_rounded, size: 22, color: p.principal),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ligne du récapitulatif de transfert : solde avant, puis après.
class _LigneTransfert extends StatelessWidget {
  const _LigneTransfert({
    required this.nom,
    required this.avant,
    required this.apres,
  });

  final String nom;
  final int avant;
  final int? apres;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final negatif = apres != null && apres! < 0;
    final texte = apres == null
        ? formatAr(avant)
        : '${formatAr(avant)} → ${formatAr(apres!)}';

    return Row(
      children: [
        Expanded(
          child: Text(
            nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            texte,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: negatif ? p.depense : p.texteDoux,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════ Éléments de la section Catégorie ═══════════════════════

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

/// Carte de la catégorie choisie : teintée de sa couleur, avec sa pastille,
/// son nom, sa mention et un bouton « Changer ».
class _CategorieChoisie extends StatelessWidget {
  const _CategorieChoisie({required this.info, required this.onTap});

  final CategoryInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final teinte = teinteCategorie(context, info.name);

    return Container(
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(teinte.withValues(alpha: 0.14), p.surface),
            p.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: teinte.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: teinte.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -26,
                  top: -26,
                  child: Container(
                    width: 106,
                    height: 106,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: teinte.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      PastilleCategorie(info.name, taille: 54),
                      const SizedBox(width: 14),
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
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: p.texte,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: p.accent.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                info.isDefault ? 'Par défaut' : 'Personnalisée',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: p.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: p.principal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: p.principal,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Changer',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: p.principal,
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