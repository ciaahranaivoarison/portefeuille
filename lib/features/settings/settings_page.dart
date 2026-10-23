import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';
import '../categories/categories_page.dart';
import '../lock/lock_screen.dart';
import 'protection_setup_page.dart';

/// Écran Paramètres : protection de l'application et catégories.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _service = SecurityService.instance;
  bool _chargement = true;
  bool _active = false;
  bool _biometrie = false;
  List<BiometricType> _biometries = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final active = await _service.estActive();
    final bio = active && await _service.biometrieActive();
    final dispo = await _service.biometriesDisponibles();
    if (!mounted) return;
    setState(() {
      _active = active;
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
        _message(
          'Protection activée. Le code sera demandé au prochain lancement.',
        );
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
        "Confirmez l'activation du déverrouillage biométrique",
      );
      if (!ok) {
        _message('Activation annulée.');
        return;
      }
    }
    await _service.definirBiometrie(activer);
    await _charger();
  }

  String get _texteBiometrie {
    if (_biometries.isEmpty) {
      return "Non disponible : aucune empreinte ni aucun visage n'est "
          'enregistré sur ce téléphone.';
    }
    if (!_active) return "Activez d'abord la protection de l'application.";
    return 'Utiliser ${SecurityService.libelleBiometrie(_biometries)} pour '
        'déverrouiller. Les données restent gérées par le téléphone.';
  }

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(
          texte.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.noyer,
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _titre('Protection'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _active,
                        onChanged: _basculerProtection,
                        secondary: const Icon(
                          Icons.lock_outline,
                          color: AppColors.noyer,
                        ),
                        title: const Text(
                          "Protection de l'application",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          _active
                              ? 'Un code est demandé au lancement.'
                              : "Désactivée : l'application s'ouvre sans code.",
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        enabled: _active,
                        leading: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.noyer,
                        ),
                        title: const Text(
                          'Modifier le code',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text('PIN ou mot de passe'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _active ? _modifierCode : null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: _biometrie,
                        onChanged: (_active && _biometries.isNotEmpty)
                            ? _basculerBiometrie
                            : null,
                        secondary: const Icon(
                          Icons.fingerprint,
                          color: AppColors.noyer,
                        ),
                        title: const Text(
                          'Empreinte digitale ou visage',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(_texteBiometrie),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _titre('Gestion'),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.category_outlined,
                      color: AppColors.noyer,
                    ),
                    title: const Text(
                      'Catégories',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Ajouter, modifier ou supprimer vos catégories',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}