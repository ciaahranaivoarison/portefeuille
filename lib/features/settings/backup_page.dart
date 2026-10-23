import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_theme.dart';
import '../../core/formats.dart';
import '../../core/security_service.dart';
import '../../data/backup_service.dart';
import '../lock/lock_screen.dart';
import '../shell/app_shell.dart';

/// Sauvegarde et restauration des données (section 11 de la fiche).
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _service = BackupService.instance;
  DateTime? _derniere;
  bool _enCours = false;

  @override
  void initState() {
    super.initState();
    _chargerDate();
  }

  Future<void> _chargerDate() async {
    final d = await _service.derniereSauvegarde();
    if (!mounted) return;
    setState(() => _derniere = d);
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  String _dateHeure(DateTime d) =>
      '${formatDate(d)} à ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  /// Si la protection est activée, demande le code avant de continuer.
  Future<bool> _confirmerIdentite() async {
    if (!await SecurityService.instance.estActive()) return true;
    if (!mounted) return false;
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

  Future<void> _enregistrerSurTelephone() async {
    if (!await _confirmerIdentite()) return;
    setState(() => _enCours = true);
    try {
      final octets = await _service.exporter();
      final emplacement = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer la sauvegarde',
        fileName: _service.nomFichier(),
        bytes: octets,
      );
      if (emplacement == null) {
        _message('Sauvegarde annulée.');
      } else {
        await _service.noterSauvegarde();
        _message('Sauvegarde enregistrée.');
        await _chargerDate();
      }
    } catch (e) {
      _message("La sauvegarde a échoué : $e");
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _partager() async {
    if (!await _confirmerIdentite()) return;
    setState(() => _enCours = true);
    try {
      final octets = await _service.exporter();
      final dossier = await getTemporaryDirectory();
      final fichier = File('${dossier.path}/${_service.nomFichier()}');
      await fichier.writeAsBytes(octets, flush: true);

      final resultat = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(fichier.path, mimeType: 'application/json')],
          subject: "Sauvegarde Gestion d'argent",
        ),
      );
      if (resultat.status != ShareResultStatus.dismissed) {
        await _service.noterSauvegarde();
        await _chargerDate();
      }
    } catch (e) {
      _message("Le partage a échoué : $e");
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<bool> _confirmerRestauration(BackupSummary r) async {
    final date = r.date == null
        ? ''
        : 'Sauvegarde du ${_dateHeure(r.date!.toLocal())}.\n\n';
    final reponse = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remplacer les données ?'),
        content: Text(
          '$date'
          'Ce fichier contient ${r.accounts} compte(s), '
          '${r.categories} catégorie(s), ${r.budgets} budget(s) et '
          '${r.transactions} opération(s).\n\n'
          'La restauration remplace toutes les données actuelles de '
          "l'application. Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    return reponse ?? false;
  }

  Future<void> _restaurer() async {
    if (!await _confirmerIdentite()) return;
    setState(() => _enCours = true);
    try {
      final fichier = await FilePicker.pickFile();
      if (fichier == null) return;

      final octets = await fichier.readAsBytes();
      if (octets.length > 30 * 1024 * 1024) {
        _message('Ce fichier est trop volumineux pour être une sauvegarde.');
        return;
      }

      final BackupSummary resume;
      try {
        resume = _service.analyser(octets);
      } on ArgumentError catch (e) {
        _message('${e.message} Vos données actuelles sont intactes.');
        return;
      }

      if (!mounted) return;
      if (!await _confirmerRestauration(resume)) return;

      try {
        await _service.restaurer(octets);
      } catch (_) {
        _message(
          'Fichier invalide ou corrompu. '
          "Vos données actuelles n'ont pas été modifiées.",
        );
        return;
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restauration terminée'),
          content: const Text('Vos données ont été restaurées.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      // Repart d'un écran neuf pour afficher les données restaurées.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    } catch (e) {
      _message('La restauration a échoué : $e');
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
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
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde et restauration')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'La sauvegarde contient vos comptes, catégories, budgets et '
                'opérations, dans un fichier .json. Elle se fait sans '
                'connexion Internet. Le code de protection n\'en fait pas '
                'partie.\n\n'
                "Le fichier n'est pas chiffré : conservez-le dans un endroit "
                'sûr.',
                style: text.bodyMedium,
              ),
            ),
          ),
          _titre('Sauvegarder mes données'),
          Text(
            _derniere == null
                ? 'Dernière sauvegarde : jamais'
                : 'Dernière sauvegarde : ${_dateHeure(_derniere!)}',
            style: text.bodySmall?.copyWith(color: AppColors.noyer),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _enCours ? null : _enregistrerSurTelephone,
            icon: const Icon(Icons.save_alt),
            label: const Text('Enregistrer sur le téléphone'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.noyer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _enCours ? null : _partager,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Partager (Drive, WhatsApp, e-mail…)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          _titre('Restaurer mes données'),
          Text(
            'Choisissez un fichier de sauvegarde. Il remplacera toutes les '
            'données actuelles.',
            style: text.bodySmall?.copyWith(color: AppColors.noyer),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _enCours ? null : _restaurer,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurer depuis un fichier'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (_enCours)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}