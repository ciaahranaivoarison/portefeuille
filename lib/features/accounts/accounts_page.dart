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

  Widget _contenu(AsyncSnapshot<List<AccountBalance>> snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text('Erreur : ${snapshot.error}'));
    }
    final comptes = snapshot.data;
    if (comptes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (comptes.isEmpty) {
      return const EtatVide(
        titre: 'Aucun compte',
        message: 'Appuyez sur « Nouveau compte » pour en créer un.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        for (var i = 0; i < comptes.length; i++)
          Apparition(
            key: ValueKey('compte${comptes[i].id}'),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  onTap: () => _ouvrir(compteId: comptes[i].id),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: PastilleEmoji(emojiCompte(comptes[i].type)),
                  title: Text(
                    comptes[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(libelleTypeCompte(comptes[i].type)),
                  trailing: MontantAnime(
                    montant: comptes[i].balance,
                    style: TextStyle(
                      fontFamily: AppTheme.fontTitre,
                      fontWeight: FontWeight.w600,
                      color: comptes[i].balance < 0
                          ? AppColors.terracotta
                          : AppColors.cacao,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _ouvrir(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau compte'),
      ),
      body: FutureBuilder<List<AccountBalance>>(
        future: _futur,
        builder: (context, snapshot) {
          final total = snapshot.data
              ?.fold<int>(0, (somme, c) => somme + c.balance);
          return Column(
            children: [
              EnteteEcran(
                emoji: '💳',
                titre: 'Comptes',
                etiquette: 'TOTAL DE TOUS LES COMPTES',
                montant: total,
              ),
              Expanded(child: _contenu(snapshot)),
            ],
          );
        },
      ),
    );
  }
}