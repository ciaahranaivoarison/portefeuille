import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formats.dart';
import '../../data/accounts.dart';
import '../../data/repository.dart';
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

  IconData _icone(String type) => switch (type) {
        'cash' => Icons.payments_outlined,
        'bank' => Icons.account_balance_outlined,
        _ => Icons.smartphone_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Comptes')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.noyer,
        foregroundColor: AppColors.blanc,
        onPressed: () => _ouvrir(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau compte'),
      ),
      body: FutureBuilder<List<AccountBalance>>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final comptes = snapshot.data!;
          final total = comptes.fold(0, (somme, c) => somme + c.balance);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            children: [
              Text(
                'TOTAL DE TOUS LES COMPTES',
                style: text.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.noyer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatAr(total),
                style: const TextStyle(
                  fontFamily: AppTheme.fontTitre,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cacao,
                ),
              ),
              const SizedBox(height: 20),
              if (comptes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('Aucun compte')),
                ),
              for (final c in comptes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      onTap: () => _ouvrir(compteId: c.id),
                      leading: Icon(_icone(c.type), color: AppColors.noyer),
                      title: Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(libelleTypeCompte(c.type)),
                      trailing: Text(
                        formatAr(c.balance),
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontWeight: FontWeight.w600,
                          color: c.balance < 0
                              ? AppColors.terracotta
                              : AppColors.cacao,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}