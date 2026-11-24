import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../data/categories.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/ui.dart';
import 'category_form_page.dart';
import 'operations_categorie_page.dart';

/// Ce que l'utilisateur a fait avec une catégorie.
enum ResultatCategorie { choisie, modifiee, supprimee }

enum _Action { choisir, voir, modifier, supprimer }

/// Affiche les options d'une catégorie (feuille qui monte du bas) et
/// exécute l'action choisie. Renvoie null si rien n'a changé.
///
/// Avec [avecChoix], une option « Choisir cette catégorie » est proposée
/// (écran Nouvelle opération).
Future<ResultatCategorie?> gererCategorie(
  BuildContext context,
  CategoryInfo info, {
  bool avecChoix = false,
}) async {
  final action = await showModalBottomSheet<_Action>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FeuilleOptions(info: info, avecChoix: avecChoix),
  );
  if (action == null || !context.mounted) return null;

  switch (action) {
    case _Action.choisir:
      return ResultatCategorie.choisie;

    case _Action.voir:
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => OperationsCategoriePage(info: info)),
      );
      return null;

    case _Action.modifier:
      {
        final change = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                CategoryFormPage(type: info.type, categorie: info),
          ),
        );
        return change == true ? ResultatCategorie.modifiee : null;
      }

    case _Action.supprimer:
      {
        final message = info.usage > 0
            ? '${info.usage} opération(s) deviendront « Sans catégorie ». '
                'Les budgets de cette catégorie seront retirés.'
            : 'Cette catégorie sera supprimée.';
        final ok = await confirmerSuppression(
          context,
          titre: 'Supprimer cette catégorie ?',
          message: message,
        );
        if (!ok) return null;
        await Categories.instance.supprimer(info.id);
        return ResultatCategorie.supprimee;
      }
  }
}

class _FeuilleOptions extends StatelessWidget {
  const _FeuilleOptions({required this.info, required this.avecChoix});

  final CategoryInfo info;
  final bool avecChoix;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final operations = info.usage > 1
        ? '${info.usage} opérations'
        : '${info.usage} opération';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PastilleEmoji(emojiCategorie(info.name), taille: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: p.texte,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$operations · '
                        '${info.isDefault ? 'Par défaut' : 'Personnalisée'}',
                        style: TextStyle(fontSize: 13, color: p.texteDoux),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (avecChoix) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(_Action.choisir),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Choisir cette catégorie'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            _LigneOption(
              icone: Icons.receipt_long_outlined,
              titre: 'Voir les opérations',
              sousTitre: operations,
              onTap: () => Navigator.of(context).pop(_Action.voir),
            ),
            if (!info.isDefault) ...[
              _LigneOption(
                icone: Icons.edit_outlined,
                titre: 'Modifier le nom',
                onTap: () => Navigator.of(context).pop(_Action.modifier),
              ),
              _LigneOption(
                icone: Icons.delete_outline_rounded,
                titre: 'Supprimer',
                couleur: p.depense,
                onTap: () => Navigator.of(context).pop(_Action.supprimer),
              ),
            ] else
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18, color: p.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Catégorie par défaut : elle ne peut être ni '
                        'modifiée ni supprimée.',
                        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LigneOption extends StatelessWidget {
  const _LigneOption({
    required this.icone,
    required this.titre,
    required this.onTap,
    this.sousTitre,
    this.couleur,
  });

  final IconData icone;
  final String titre;
  final String? sousTitre;
  final Color? couleur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final teinte = couleur ?? p.principal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: teinte.withValues(alpha: 0.12),
                  ),
                  child: Icon(icone, size: 20, color: teinte),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: couleur ?? p.texte,
                        ),
                      ),
                      if (sousTitre != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            sousTitre!,
                            style: TextStyle(fontSize: 12, color: p.texteDoux),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.texteDoux),
              ],
            ),
          ),
        ),
      ),
    );
  }
}