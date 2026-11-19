import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';
import '../../widgets/rubrique.dart';
import '../../widgets/ui.dart';
import '../lock/lock_screen.dart';
import 'protection_setup_page.dart';
import '../../core/recuperation_service.dart';
import 'code_recuperation_page.dart';

/// Rubrique « Paramètres de sécurité » : mot de passe, PIN et biométrie.
class SecuritePage extends StatefulWidget {
  const SecuritePage({super.key});

  @override
  State<SecuritePage> createState() => _SecuritePageState();
}

class _SecuritePageState extends State<SecuritePage> {
  final _service = SecurityService.instance;
  bool _chargement = true;
  bool _active = false;
  bool _biometrie = false;
  String _type = 'pin';
  int _longueur = 4;
  List<BiometricType> _biometries = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final active = await _service.estActive();
    final type = await _service.type();
    final longueur = await _service.longueurPin();
    final bio = active && await _service.biometrieActive();
    final dispo = await _service.biometriesDisponibles();
    if (!mounted) return;
    setState(() {
      _active = active;
      _type = type;
      _longueur = longueur;
      _biometries = dispo;
      _biometrie = bio && dispo.isNotEmpty;
      _chargement = false;
    });
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  /// Crée un nouveau code de récupération (l'ancien devient invalide)
  /// et l'affiche une seule fois.
  Future<void> _creerCodeRecuperation({bool confirmer = true}) async {
    if (confirmer && !await _confirmerIdentite()) return;
    final code = await RecuperationService.instance.generer();
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CodeRecuperationPage(code: code)),
    );
    await _charger();
  }
  /// Demande le code actuel avant une action sensible.
  Future<bool> _confirmerIdentite() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => LockScreen(
          annulable: true,
          autoriserBiometrie: false,
          titre: 'Confirmez votre identité',
          onUnlocked: () => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    return ok == true;
  }

  Future<void> _basculerProtection(bool activer) async {
    if (activer) {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ProtectionSetupPage()),
      );
      if (ok == true) {
        _message('Protection activée. Le code sera demandé au lancement.');
        await _creerCodeRecuperation(confirmer: false);
      }
    } else {
      if (!await _confirmerIdentite()) return;
      await _service.desactiver();
      _message('Protection désactivée.');
    }
    await _charger();
  }

  Future<void> _modifierCode() async {
    if (!await _confirmerIdentite()) return;
    if (!mounted) return;
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProtectionSetupPage(modification: true),
      ),
    );
    if (ok == true) _message('Code modifié.');
    await _charger();
  }

  Future<void> _basculerBiometrie(bool activer) async {
    if (activer) {
      final ok = await _service.authentifierBiometrie(
        tr("Confirmez l'activation du déverrouillage biométrique"),
      );
      if (!ok) {
        _message('Activation annulée.');
        return;
      }
    }
    await _service.definirBiometrie(activer);
    await _charger();
  }

  String get _detailProtection {
    if (!_active) return "Désactivée : l'application s'ouvre sans code.";
    final methode =
        _type == 'pin' ? 'Code PIN à $_longueur chiffres' : 'Mot de passe';
    return '$methode · demandé au lancement';
  }

  String get _texteBiometrie {
    if (_biometries.isEmpty) {
      return "Indisponible : aucune empreinte ni aucun visage n'est "
          'enregistré sur ce téléphone.';
    }
    if (!_active) return "Activez d'abord la protection par code.";
    return 'Déverrouillage par '
        '${SecurityService.libelleBiometrie(_biometries)}.';
  }

  Widget _carteEtat(Palette p) {
    final titre = _active ? 'Application protégée' : 'Application non protégée';
    final detail = _active
        ? '${_type == 'pin' ? 'Code PIN à $_longueur chiffres' : 'Mot de passe'}'
            '${_biometrie ? ' + biométrie' : ''}'
        : "N'importe qui peut ouvrir l'application. Activez un code pour "
            'protéger vos données.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroDebut, p.heroFin],
        ),
        boxShadow: [
          BoxShadow(
            color: p.heroDebut.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              _active ? ':shield-check:' : ':unlock:',
              key: ValueKey<bool>(_active),
              style: TextStyle(fontSize: 46, color: p.surHero),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.surHero,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: p.surHero.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(Palette p, String emoji, String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texte,
              style: TextStyle(fontSize: 13, color: p.texteDoux),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres de sécurité')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Apparition(index: 0, child: _carteEtat(p)),
                const TitreSection('Mot de passe et code PIN'),
                Apparition(
                  index: 1,
                  child: CarteRubriques(
                    enfants: [
                      _LigneSwitch(
                        emoji: ':key:',
                        titre: 'Protection par code',
                        sousTitre: _detailProtection,
                        valeur: _active,
                        onChanged: _basculerProtection,
                      ),
                      Opacity(
                        opacity: _active ? 1 : 0.45,
                        child: IgnorePointer(
                          ignoring: !_active,
                          child: Rubrique(
                            emoji: ':pencil:',
                            titre: 'Modifier le code',
                            sousTitre: 'Changer de code PIN ou de mot de passe',
                            onTap: _modifierCode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const TitreSection('Biométrie'),
                Apparition(
                  index: 2,
                  child: CarteRubriques(
                    enfants: [
                      _LigneSwitch(
                        emoji: ':fingerprint:',
                        titre: 'Empreinte digitale ou visage',
                        sousTitre: _texteBiometrie,
                        valeur: _biometrie,
                        onChanged: (_active && _biometries.isNotEmpty)
                            ? _basculerBiometrie
                            : null,
                      ),
                    ],
                  ),
                ),
                const TitreSection('Récupération'),
                Apparition(
                  index: 3,
                  child: CarteRubriques(
                    enfants: [
                      FutureBuilder<bool>(
                        future: RecuperationService.instance.existe(),
                        builder: (context, snapshot) {
                          final cree = snapshot.data == true;
                          return Opacity(
                            opacity: _active ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !_active,
                              child: Rubrique(
                                emoji: ':key:',
                                titre: 'Code de récupération',
                                sousTitre: cree
                                    ? "Créé · permet de retrouver l'accès si vous oubliez votre code"
                                    : "Non créé · recommandé en cas d'oubli",
                                etiquette: cree ? 'Créé' : null,
                                onTap: () => _creerCodeRecuperation(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const TitreSection('Comment ça marche ?'),
                Apparition(
                  index: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _info(
                            p,
                            ':lock:',
                            "Votre code n'est jamais enregistré en clair : "
                                'seule une empreinte chiffrée reste sur le '
                                'téléphone.',
                          ),
                          _info(
                            p,
                            ':smartphone:',
                            "L'empreinte et le visage sont gérés par Android. "
                                "L'application reçoit seulement « réussi » ou "
                                '« échoué ».',
                          ),
                          _info(
                            p,
                            ':timer:',
                            'Après 5 erreurs, le déverrouillage est bloqué '
                                'pendant 30 secondes.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Ligne avec un interrupteur.
class _LigneSwitch extends StatelessWidget {
  const _LigneSwitch({
    required this.emoji,
    required this.titre,
    required this.sousTitre,
    required this.valeur,
    required this.onChanged,
  });

  final String emoji;
  final String titre;
  final String sousTitre;
  final bool valeur;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          PastilleEmoji(emoji, taille: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sousTitre,
                  style: TextStyle(fontSize: 12.5, color: p.texteDoux),
                ),
              ],
            ),
          ),
          Switch(value: valeur, onChanged: onChanged),
        ],
      ),
    );
  }
}