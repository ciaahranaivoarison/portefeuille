import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/budgets.dart';
import '../../data/repository.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/ui.dart';
import '../add_operation/add_operation_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Donnees {
  const _Donnees(this.comptes, this.totaux);

  final List<AccountBalance> comptes;
  final MonthTotals totaux;

  int get total => comptes.fold(0, (somme, c) => somme + c.balance);
}

class _HomePageState extends State<HomePage> {
  late Future<_Donnees> _futur = _charger();

  Future<_Donnees> _charger() async {
    final comptes = await Repository.instance.comptes();
    final totaux = await Repository.instance.totauxDuMois(DateTime.now());
    return _Donnees(comptes, totaux);
  }

  void _rafraichir() {
    setState(() {
      _futur = _charger();
    });
  }

  Future<void> _ajouter() async {
    final ajoute = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddOperationPage()),
    );
    if (ajoute == true) _rafraichir();
  }

  List<Widget> _contenu(BuildContext context, _Donnees d) {
    final p = context.pal;
    final revenus = d.totaux.income;
    final depenses = d.totaux.expense;
    final part = revenus > 0 ? depenses / revenus : 0.0;
    final couleurPart =
        part > 1 ? p.depense : (part >= 0.8 ? p.accent : p.revenu);

    return [
      Apparition(
        index: 0,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: _ajouter,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une opération'),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Apparition(
        index: 1,
        child: Row(
          children: [
            Expanded(
              child: _CarteMini(
                emoji: '💵',
                label: 'Revenus du mois',
                montant: revenus,
                couleur: p.revenu,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CarteMini(
                emoji: '💸',
                label: 'Dépenses du mois',
                montant: depenses,
                couleur: p.depense,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Apparition(
        index: 2,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    const PastilleEmoji('🏦', taille: 42),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Argent restant',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Revenus moins dépenses du mois',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.texteDoux,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MontantAnime(
                      montant: d.totaux.remaining,
                      style: TextStyle(
                        fontFamily: AppTheme.fontTitre,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            d.totaux.remaining < 0 ? p.depense : p.texte,
                      ),
                    ),
                  ],
                ),
                if (revenus > 0) ...[
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: part > 1 ? 1.0 : part,
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, valeur, _) => LinearProgressIndicator(
                      value: valeur,
                      minHeight: 8,
                      color: couleurPart,
                      backgroundColor: p.bordure,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${(part * 100).round()} % de vos revenus du mois '
                      'sont dépensés',
                      style: TextStyle(fontSize: 12, color: p.texteDoux),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      const Apparition(index: 3, child: TitreSection('Mes comptes')),
      Apparition(
        index: 4,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                for (var i = 0; i < d.comptes.length; i++) ...[
                  if (i > 0) const Divider(height: 26),
                  _LigneCompte(
                    emoji: emojiCompte(d.comptes[i].type),
                    nom: d.comptes[i].name,
                    montant: d.comptes[i].balance,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_Donnees>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final d = snapshot.data;
          if (d == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              EnteteEcran(
                emoji: '💰',
                titre: "Gestion d'argent",
                sousTitre: 'Votre carnet de comptes',
                etiquette: 'ARGENT TOTAL DISPONIBLE',
                montant: d.total,
                badge: libelleMois(DateTime.now()),
                action: BoutonHeader(
                  icone: Icons.settings_outlined,
                  infobulle: 'Paramètres',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _contenu(context, d),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarteMini extends StatelessWidget {
  const _CarteMini({
    required this.emoji,
    required this.label,
    required this.montant,
    required this.couleur,
  });

  final String emoji;
  final String label;
  final int montant;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PastilleEmoji(emoji, taille: 40),
            const SizedBox(height: 14),
            Text(label, style: TextStyle(fontSize: 12.5, color: p.texteDoux)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MontantAnime(
                montant: montant,
                style: TextStyle(
                  fontFamily: AppTheme.fontTitre,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneCompte extends StatelessWidget {
  const _LigneCompte({
    required this.emoji,
    required this.nom,
    required this.montant,
  });

  final String emoji;
  final String nom;
  final int montant;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      children: [
        PastilleEmoji(emoji, taille: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            nom,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        MontantAnime(
          montant: montant,
          style: TextStyle(
            fontFamily: AppTheme.fontTitre,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: montant < 0 ? p.depense : p.texte,
          ),
        ),
      ],
    );
  }
}