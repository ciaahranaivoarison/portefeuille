import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';
import '../../widgets/sceau.dart';

/// Écran de verrouillage : demande le code PIN ou le mot de passe.
/// Sert au lancement de l'application et à confirmer son identité
/// avant de modifier ou de désactiver la protection.
class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.annulable = false,
    this.autoriserBiometrie = true,
    this.titre,
  });

  final VoidCallback onUnlocked;
  final bool annulable;
  final bool autoriserBiometrie;
  final String? titre;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _service = SecurityService.instance;
  final _motDePasseCtrl = TextEditingController();

  String _type = 'pin';
  int _longueur = 4;
  bool _biometrie = false;
  bool _pret = false;

  String _saisie = '';
  bool _masque = true;
  String? _erreur;
  int _echecs = 0;
  int _attente = 0;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final type = await _service.type();
    final longueur = await _service.longueurPin();
    final bio = widget.autoriserBiometrie && await _service.biometrieActive();
    if (!mounted) return;
    setState(() {
      _type = type;
      _longueur = longueur;
      _biometrie = bio;
      _pret = true;
    });
    if (bio) _essayerBiometrie();
  }

  Future<void> _essayerBiometrie() async {
    final ok = await _service.authentifierBiometrie(
      "Déverrouillez Gestion d'argent",
    );
    if (ok && mounted) widget.onUnlocked();
  }

  Future<void> _verifier(String code) async {
    final ok = await _service.verifier(code);
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
      return;
    }
    _echecs++;
    setState(() {
      _saisie = '';
      _motDePasseCtrl.clear();
      _erreur =
          _type == 'pin' ? 'Code incorrect.' : 'Mot de passe incorrect.';
    });
    if (_echecs >= 5) _bloquer();
  }

  void _bloquer() {
    _echecs = 0;
    setState(() => _attente = 30);
    _minuteur?.cancel();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_attente <= 1) {
        t.cancel();
        setState(() {
          _attente = 0;
          _erreur = null;
        });
      } else {
        setState(() => _attente--);
      }
    });
  }

  void _toucher(String chiffre) {
    if (_attente > 0 || _saisie.length >= _longueur) return;
    HapticFeedback.selectionClick();
    setState(() {
      _saisie += chiffre;
      _erreur = null;
    });
    if (_saisie.length == _longueur) _verifier(_saisie);
  }

  void _effacer() {
    if (_saisie.isEmpty) return;
    setState(() => _saisie = _saisie.substring(0, _saisie.length - 1));
  }

  Widget _points() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _longueur; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _saisie.length ? AppColors.noyer : Colors.transparent,
              border: Border.all(color: AppColors.noyer, width: 1.5),
            ),
          ),
      ],
    );
  }

  Widget _touche({String? texte, IconData? icone, VoidCallback? onTap}) {
    return SizedBox(
      width: 76,
      height: 76,
      child: onTap == null
          ? null
          : Material(
              color: AppColors.blanc,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.sable),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(
                  child: icone != null
                      ? Icon(icone, color: AppColors.cacao)
                      : Text(
                          texte!,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontTitre,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cacao,
                          ),
                        ),
                ),
              ),
            ),
    );
  }

  Widget _ligne(List<Widget> touches) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final t in touches)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: t,
            ),
        ],
      ),
    );
  }

  Widget _clavier() {
    Widget chiffre(String n) => _touche(texte: n, onTap: () => _toucher(n));
    return Column(
      children: [
        _ligne([chiffre('1'), chiffre('2'), chiffre('3')]),
        _ligne([chiffre('4'), chiffre('5'), chiffre('6')]),
        _ligne([chiffre('7'), chiffre('8'), chiffre('9')]),
        _ligne([
          _biometrie
              ? _touche(icone: Icons.fingerprint, onTap: _essayerBiometrie)
              : _touche(),
          chiffre('0'),
          _touche(icone: Icons.backspace_outlined, onTap: _effacer),
        ]),
      ],
    );
  }

  Widget _champMotDePasse() {
    return Column(
      children: [
        TextField(
          controller: _motDePasseCtrl,
          obscureText: _masque,
          enabled: _attente == 0,
          onSubmitted: _verifier,
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            suffixIcon: IconButton(
              icon: Icon(
                _masque
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _masque = !_masque),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _attente > 0
                ? null
                : () => _verifier(_motDePasseCtrl.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.noyer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Déverrouiller'),
          ),
        ),
        if (_biometrie)
          TextButton.icon(
            onPressed: _essayerBiometrie,
            icon: const Icon(Icons.fingerprint),
            label: const Text("Utiliser l'empreinte ou le visage"),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final message = _attente > 0
        ? "Trop d'essais. Réessayez dans $_attente s."
        : (_erreur ?? '');

    return Scaffold(
      appBar: widget.annulable ? AppBar() : null,
      body: SafeArea(
        child: !_pret
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Sceau(),
                      const SizedBox(height: 22),
                      Text(
                        widget.titre ?? "Gestion d'argent",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cacao,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _type == 'pin'
                            ? 'Saisissez votre code PIN'
                            : 'Saisissez votre mot de passe',
                        style:
                            text.bodyMedium?.copyWith(color: AppColors.noyer),
                      ),
                      const SizedBox(height: 24),
                      if (_type == 'pin') _points(),
                      SizedBox(
                        height: 44,
                        child: Center(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _type == 'pin' ? _clavier() : _champMotDePasse(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}