import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/security_service.dart';
import '../../widgets/couleur_securite.dart';
import '../../widgets/pave_numerique.dart';

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
      tr("Déverrouillez Gestion d'argent"),
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

  Widget _champMotDePasse(CouleurSecurite c, bool sombre) {
    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c.principal.withValues(alpha: 0.35)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextField(
        controller: _motDePasseCtrl,
        obscureText: _masque,
        enabled: _attente == 0,
        onSubmitted: _verifier,
        style: TextStyle(color: c.texte, fontSize: 16),
        decoration: InputDecoration(
          hintText: tr('Mot de passe'),
          hintStyle: TextStyle(color: c.douce),
          filled: true,
          fillColor: sombre
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.85),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: c.douce),
          suffixIcon: IconButton(
            icon: Icon(
              _masque
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: c.douce,
            ),
            onPressed: () => setState(() => _masque = !_masque),
          ),
          border: bordure,
          enabledBorder: bordure,
          disabledBorder: bordure,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: c.principal, width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _boutonDeverrouiller(CouleurSecurite c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FilledButton(
        onPressed:
            _attente > 0 ? null : () => _verifier(_motDePasseCtrl.text),
        style: FilledButton.styleFrom(
          backgroundColor: c.principal,
          foregroundColor: c.surPrincipal,
        ),
        child: const Text('Déverrouiller'),
      ),
    );
  }

  /// Gros bouton d'empreinte si la biométrie est active, sinon un cadenas.
  Widget _zoneCentrale(CouleurSecurite c, bool pin) {
    if (_biometrie) {
      return Center(child: BoutonBiometrie(onTap: _essayerBiometrie));
    }
    if (!pin) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.principal.withValues(alpha: 0.10),
        ),
        child: Icon(Icons.lock_outline_rounded, size: 42, color: c.principal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final pin = _type == 'pin';
    final message = _attente > 0
        ? "Trop d'essais. Réessayez dans $_attente s."
        : (_erreur ?? '');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (sombre ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.fond,
        systemNavigationBarIconBrightness:
            sombre ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.fond,
        appBar: widget.annulable
            ? AppBar(
                backgroundColor: c.fond,
                foregroundColor: c.texte,
                elevation: 0,
                scrolledUnderElevation: 0,
              )
            : null,
        body: SafeArea(
          child: !_pret
              ? Center(child: CircularProgressIndicator(color: c.principal))
              : LayoutBuilder(
                  builder: (context, contraintes) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: contraintes.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 28),
                            Text(
                              widget.titre ?? "Gestion d'argent",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: c.douce,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              pin
                                  ? 'Saisissez votre code PIN'
                                  : 'Saisissez votre mot de passe',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                color: c.texte,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _secousse(
                              child: pin
                                  ? PointsPin(
                                      longueur: _longueur,
                                      remplis: _saisie.length,
                                      erreur:
                                          _erreur != null && _saisie.isEmpty,
                                    )
                                  : _champMotDePasse(c, sombre),
                            ),
                            SizedBox(
                              height: 48,
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    message,
                                    key: ValueKey<String>(message),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: c.erreur,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            _zoneCentrale(c, pin),
                            const Spacer(),
                            if (pin)
                              PaveNumerique(
                                onChiffre: _toucher,
                                onEffacer: _effacer,
                                actif: _attente == 0,
                              )
                            else
                              _boutonDeverrouiller(c),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}