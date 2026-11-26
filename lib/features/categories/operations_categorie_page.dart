import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/formats.dart';
import '../../data/categories.dart';
import '../../data/operations.dart';
import '../../widgets/etat_vide.dart';
import '../../widgets/pastille_categorie.dart';

/// Liste des opérations d'une catégorie, avec leur total.
class OperationsCategoriePage extends StatelessWidget {
  const OperationsCategoriePage({super.key, required this.info});

  final CategoryInfo info;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final couleur = info.type == 'income' ? p.revenu : p.depense;

    return Scaffold(
      appBar: AppBar(title: Text(info.name)),
      body: FutureBuilder<List<TransactionItem>>(
        future: Operations.instance.lister(categorieId: info.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final items = snapshot.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const EtatVide(
              titre: 'Aucune opération',
              message: 'Aucune opération dans cette catégorie.',
            );
          }

          final total = items.fold<int>(0, (somme, t) => somme + t.amount);
          final nombre = items.length > 1
              ? '${items.length} opérations'
              : '${items.length} opération';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      PastilleCategorie(info.name, taille: 50),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: p.texteDoux,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatAr(total),
                              style: TextStyle(
                                fontFamily: AppTheme.fontTitre,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: couleur,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        nombre,
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final t in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        formatDate(t.date),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        <String>[t.accountName, ?t.note].join(' · '),
                        maxLines: 2,
                      ),
                      trailing: Text(
                        formatAr(t.amount),
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontWeight: FontWeight.w600,
                          color: couleur,
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