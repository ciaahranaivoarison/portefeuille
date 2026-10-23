import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';

/// Création ou modification du code de protection (PIN ou mot de passe).
class ProtectionSetupPage extends StatefulWidget {
  const ProtectionSetupPage({super.key, this.modification = false});

  final bool modification;

  @override
  State<ProtectionSetupPage> createState() => _ProtectionSetupPageState();
}

class _ProtectionSetupPageState extends State<ProtectionSetupPage> {
  String _type = 'pin';
  int _longueur = 4;
  bool _masque = true;
  bool _enCours = false;
  final _codeCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool get _pin => _type == 'pin';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _vider() {
    _codeCtrl.clear();
    _confirmCtrl.clear();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  Future<void> _enregistrer() async {
    final code = _codeCtrl.text;
    if (_pin && code.length != _longueur) {
      _message('Le code PIN doit contenir $_longueur chiffres.');
      return;
    }
    if (!_pin && code.length < 6) {
      _message('Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (code != _confirmCtrl.text) {
      _message('Les deux saisies ne sont pas identiques.');
      return;
    }
    setState(() => _enCours = true);
    try {
      await SecurityService.instance.definirCode(
        type: _type,
        code: code,
        longueurPin: _longueur,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      _message('${e.message}');
    }
  }

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Text(
          texte.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.noyer,
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  Widget _champ(TextEditingController ctrl, String indication) {
    return TextField(
      controller: ctrl,
      obscureText: _masque,
      keyboardType:
          _pin ? TextInputType.number : TextInputType.visiblePassword,
      inputFormatters: _pin
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_longueur),
            ]
          : null,
      decoration: InputDecoration(
        hintText: indication,
        suffixIcon: IconButton(
          icon: Icon(
            _masque ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _masque = !_masque),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modification ? 'Modifier le code' : "Protéger l'application",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _titre('Méthode de protection'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pin', label: Text('Code PIN')),
              ButtonSegment(value: 'password', label: Text('Mot de passe')),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              _vider();
            }),
          ),
          if (_pin) ...[
            _titre('Longueur du code'),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 4, label: Text('4 chiffres')),
                ButtonSegment(value: 6, label: Text('6 chiffres')),
              ],
              selected: {_longueur},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                _longueur = s.first;
                _vider();
              }),
            ),
          ],
          _titre(_pin ? 'Code PIN' : 'Mot de passe (6 caractères minimum)'),
          _champ(_codeCtrl, _pin ? 'Votre code' : 'Votre mot de passe'),
          _titre('Confirmation'),
          _champ(_confirmCtrl, 'Saisissez-le à nouveau'),
          const SizedBox(height: 12),
          Text(
            "Le code n'est jamais enregistré en clair : seule une empreinte "
            'chiffrée est conservée sur ce téléphone. Notez-le bien : en cas '
            'd\'oubli, il faut désinstaller l\'application, ce qui efface vos '
            'données.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.noyer),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _enCours ? null : _enregistrer,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.noyer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}