import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/recuperation_service.dart';
import '../../core/security_service.dart';
import '../../data/app_database.dart';
import '../settings/code_recuperation_page.dart';
import '../settings/protection_setup_page.dart';

/// Page « Accès perdu ? » : retrouver l'accès avec le code de
/// récupération, ou réinitialiser l'application en dernier recours.
class RecuperationPage extends StatefulWidget {
  const RecuperationPage({super.key, required this.onRecupere});

  /// Appelée quand l'accès est retrouvé : l'application s'ouvre.
  final VoidCallback onRecupere;

  @override
  State<RecuperationPage> createState() => _RecuperationPageState();
}

class _RecuperationPageState extends State<RecuperationPage> {
  final _codeCtrl = TextEditingController();
  String? _erreur;
  bool _enCours = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  /// Ferme cette page et l'écran de verrouillage : l'application s'ouvre.
  void _terminer() {
    if (!mounted) return;
    final fin = widget.onRecupere;
    Navigator.of(context).popUntil((route) => route.isFirst);
    fin();
  }

  Future<void> _verifier() async {
    final saisie = _codeCtrl.text;
    if (RecuperationService.normaliser(saisie).length != 16) {
      setState(() => _erreur = 'Le code contient 16 caractères.');
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    final ok = await RecuperationService.instance.verifier(saisie);
    if (!mounted) return;
    setState(() => _enCours = false);
    if (!ok) {
      setState(() => _erreur = 'Code de récupération incorrect.');
      return;
    }

    // Code correct : l'utilisateur choisit un nouveau code d'accès.
    final defini = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProtectionSetupPage(modification: true),
      ),
    );
    if (defini != true || !mounted) return;

    // Le code de récupération utilisé est remplacé par un nouveau.
    final nouveau = await RecuperationService.instance.generer();
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CodeRecuperationPage(code: nouveau)),
    );
    _terminer();
  }

  Future<bool> _confirmerReinitialisation() async {
    final ctrl = TextEditingController();
    final reponse = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, majDialogue) {
          final pret = ctrl.text.trim().toUpperCase() == 'SUPPRIMER';
          return AlertDialog(
            title: const Text('Tout effacer ?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tous vos comptes, opérations, budgets et catégories '
                  'personnalisées seront supprimés définitivement. '
                  'Cette action est irréversible.',
                ),
                const SizedBox(height: 14),
                const Text('Tapez SUPPRIMER pour confirmer :'),
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => majDialogue(() {}),
                  decoration: const InputDecoration(hintText: 'SUPPRIMER'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: pret ? () => Navigator.of(ctx).pop(true) : null,
                child: const Text('Tout effacer'),
              ),
            ],
          );
        },
      ),
    );
    ctrl.dispose();
    return reponse ?? false;
  }

  Future<void> _reinitialiser() async {
    final confirme = await _confirmerReinitialisation();
    if (!confirme || !mounted) return;
    setState(() => _enCours = true);
    try {
      await AppDatabase.instance.reinitialiser();
      await SecurityService.instance.desactiver();
      await RecuperationService.instance.effacer();
    } catch (_) {
      if (!mounted) return;
      setState(() => _enCours = false);
      _message('La réinitialisation a échoué.');
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Application réinitialisée'),
        content: const Text(
          'Vos données ont été effacées. Vous pouvez restaurer une '
          'sauvegarde depuis les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    _terminer();
  }

  Widget _rond(Palette p, IconData icone, {double taille = 74, Color? couleur}) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surfaceDouce,
        border: Border.all(color: p.bordure),
      ),
      child: Icon(icone, size: taille * 0.46, color: couleur ?? p.principal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(title: const Text('Accès perdu ?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: _rond(p, Icons.vpn_key_outlined)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              "Choisissez comment retrouver l'accès à votre application.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.texte,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 1. Avec le code de récupération
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _rond(p, Icons.key_rounded, taille: 42),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "J'ai mon code de récupération",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Saisissez-le pour choisir un nouveau code. '
                    'Vos données sont conservées.',
                    style: TextStyle(fontSize: 13, color: p.texteDoux),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codeCtrl,
                    enabled: !_enCours,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [_FormatCode()],
                    style: const TextStyle(
                      fontSize: 17,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXXX-XXXX-XXXX-XXXX',
                      errorText: _erreur == null ? null : tr(_erreur!),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _enCours ? null : _verifier,
                      child: const Text('Vérifier et choisir un nouveau code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Sans code : réinitialisation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _rond(
                        p,
                        Icons.warning_amber_rounded,
                        taille: 42,
                        couleur: p.depense,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Je n'ai plus mon code de récupération",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'La seule solution est de tout effacer et de repartir de '
                    'zéro. Si vous avez une sauvegarde, vous pourrez la '
                    'restaurer ensuite.',
                    style: TextStyle(fontSize: 13, color: p.texteDoux),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _enCours ? null : _reinitialiser,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text("Réinitialiser l'application"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.depense,
                        side: BorderSide(
                          color: p.depense.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: p.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pensez à faire une sauvegarde régulière : elle permet de '
                    'tout restaurer après une réinitialisation.',
                    style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Met la saisie en majuscules et ajoute un tiret tous les 4 caractères.
class _FormatCode extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue ancien,
    TextEditingValue nouveau,
  ) {
    final brut = RecuperationService.normaliser(nouveau.text);
    final coupe = brut.length > 16 ? brut.substring(0, 16) : brut;
    final texte = RecuperationService.formater(coupe);
    return TextEditingValue(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}