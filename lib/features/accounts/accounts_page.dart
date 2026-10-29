import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/accounts.dart';
import '../../data/repository.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/etat_vide.dart';
import '../../widgets/ui.dart';
import 'account_form_page.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Future<List<AccountBalance>> _futur = Repository.instance.comptes();

  void _rafraichir() {
    setState(() {
      _futur = Repository.instance.comptes();
    });
  }

  Future<void> _ouvrir({int? compteId}) async {
    final change = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AccountFormPage(compteId: compteId)),
    );
    if (change == true) _rafraichir();
  }

  Widget _carte(BuildContext context, AccountBalance c, int total, int index) {
    final p = context.pal;
    final part = (total > 0 && c.balance > 0) ? c.balance / total : 0.0;

    return Apparition(
      key: ValueKey('compte${c.id}'),
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: InkWell(
            onTap: () => _ouvrir(compteId: c.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      PastilleEmoji(emojiCompte(c.type), taille: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              libelleTypeCompte(c.type),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: p.texteDoux,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MontantAnime(
                        montant: c.balance,
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.balance < 0 ? p.depense : p.texte,
                        ),
                      ),
                    ],
                  ),
                  if (part > 0) ...[
                    const SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: part),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, valeur, _) =>
                          LinearProgressIndicator(
                        value: valeur,
                        minHeight: 6,
                        color: p.accent,
                        backgroundColor: p.bordure,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${(part * 100).round()} % du total',
                        style: TextStyle(fontSize: 11.5, color: p.texteDoux),
                      ),
                    ),
                  ],
                ],
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
      body: FutureBuilder<List<AccountBalance>>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final comptes = snapshot.data;
          if (comptes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = comptes.fold<int>(0, (somme, c) => somme + c.balance);
          final n = comptes.length;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              EnteteEcran(
                emoji: '💳',
                titre: 'Comptes',
                sousTitre: n > 1 ? '$n comptes' : '$n compte',
                etiquette: 'TOTAL DE TOUS LES COMPTES',
                montant: total,
                action: BoutonHeader(
                  icone: Icons.add_rounded,
                  infobulle: 'Nouveau compte',
                  onTap: () => _ouvrir(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (n == 0)
                      const EtatVide(
                        titre: 'Aucun compte',
                        message: 'Créez votre premier compte ci-dessous.',
                      ),
                    for (var i = 0; i < n; i++)
                      _carte(context, comptes[i], total, i),
                    Apparition(
                      index: n,
                      child: CarteAjout(
                        libelle: 'Ajouter un compte',
                        onTap: () => _ouvrir(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}