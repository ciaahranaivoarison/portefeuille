import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';
import '../../widgets/pave_numerique.dart';
import '../../widgets/sceau.dart';
import '../../widgets/ui.dart';

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
  int _secousses = 0;
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
      _erreur = _type == 'pin' ? 'Code incorrect.' : 'Mot de passe incorrect.';
      _secousses++;
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

  /// Fait trembler son contenu à chaque nouvelle erreur.
  Widget _secousse({required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(_secousses),
      tween: Tween<double>(begin: _secousses == 0 ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (context, t, enfant) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 7) * 12 * (1 - t), 0),
        child: enfant,
      ),
      child: child,
    );
  }

  Widget _champMotDePasse() {
    return TextField(
      controller: _motDePasseCtrl,
      obscureText: _masque,
      enabled: _attente == 0,
      onSubmitted: _verifier,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _masque
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _masque = !_masque),
        ),
      ),
    );
  }

  Widget _actionsMotDePasse() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _attente > 0
                ? null
                : () => _verifier(_motDePasseCtrl.text),
            child: const Text('Déverrouiller'),
          ),
        ),
        if (_biometrie)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton.icon(
              onPressed: _essayerBiometrie,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Utiliser l'empreinte ou le visage"),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final message = _attente > 0
        ? "Trop d'essais. Réessayez dans $_attente s."
        : (_erreur ?? '');
    final pin = _type == 'pin';

    return Scaffold(
      appBar: widget.annulable ? AppBar() : null,
      body: SafeArea(
        child: !_pret
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Apparition(child: Sceau(taille: 88)),
                      const SizedBox(height: 18),
                      Text(
                        widget.titre ?? "Gestion d'argent",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontTitre,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: p.texte,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pin
                            ? 'Saisissez votre code PIN'
                            : 'Saisissez votre mot de passe',
                        style: TextStyle(color: p.texteDoux),
                      ),
                      const SizedBox(height: 26),
                      _secousse(
                        child: pin
                            ? PointsPin(
                                longueur: _longueur,
                                remplis: _saisie.length,
                              )
                            : _champMotDePasse(),
                      ),
                      SizedBox(
                        height: 46,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              message,
                              key: ValueKey<String>(message),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: p.depense,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (pin)
                        PaveNumerique(
                          onChiffre: _toucher,
                          onEffacer: _effacer,
                          onBiometrie: _biometrie ? _essayerBiometrie : null,
                          actif: _attente == 0,
                        )
                      else
                        _actionsMotDePasse(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}