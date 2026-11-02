import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/reglages.dart';
import '../../core/security_service.dart';
import '../../widgets/rubrique.dart';
import '../../widgets/ui.dart';
import '../categories/categories_page.dart';
import 'apparence_page.dart';
import 'backup_page.dart';
import 'securite_page.dart';

/// Écran Paramètres : un point d'entrée vers chaque rubrique.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _protection = false;
  String _type = 'pin';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final active = await SecurityService.instance.estActive();
    final type = await SecurityService.instance.type();
    if (!mounted) return;
    setState(() {
      _protection = active;
      _type = type;
    });
  }

  Future<void> _ouvrir(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) await _charger();
  }

  String get _libelleMode => switch (Reglages.instance.mode) {
        ThemeMode.light => 'Mode clair',
        ThemeMode.dark => 'Mode sombre',
        ThemeMode.system => 'Automatique (selon le téléphone)',
      };

  String get _detailSecurite => _protection
      ? (_type == 'pin' ? 'Code PIN activé' : 'Mot de passe activé')
      : 'Mot de passe, code PIN, biométrie';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const TitreSection('Personnalisation'),
          Apparition(
            index: 0,
            child: CarteRubriques(
              enfants: [
                Rubrique(
                  emoji: '🎨',
                  titre: 'Apparence',
                  sousTitre: _libelleMode,
                  onTap: () => _ouvrir(const ApparencePage()),
                ),
              ],
            ),
          ),
          const TitreSection('Sécurité'),
          Apparition(
            index: 1,
            child: CarteRubriques(
              enfants: [
                Rubrique(
                  emoji: '🛡️',
                  titre: 'Paramètres de sécurité',
                  sousTitre: _detailSecurite,
                  etiquette: _protection ? 'Activée' : null,
                  onTap: () => _ouvrir(const SecuritePage()),
                ),
              ],
            ),
          ),
          const TitreSection('Données'),
          Apparition(
            index: 2,
            child: CarteRubriques(
              enfants: [
                Rubrique(
                  emoji: '🏷️',
                  titre: 'Catégories',
                  sousTitre: 'Ajouter, modifier ou supprimer les vôtres',
                  onTap: () => _ouvrir(const CategoriesPage()),
                ),
                Rubrique(
                  emoji: '💾',
                  titre: 'Sauvegarde et restauration',
                  sousTitre: 'Sauvegarder vos données ou les restaurer',
                  onTap: () => _ouvrir(const BackupPage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "Gestion d'argent · version 1.0",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.texteDoux,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Projet de stage L3 · fonctionne hors ligne',
              style: TextStyle(fontSize: 12, color: p.texteDoux),
            ),
          ),
        ],
      ),
    );
  }
}