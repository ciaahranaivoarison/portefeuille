import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/empreinte_native.dart';
import '../../core/security_service.dart';
import '../../widgets/couleur_securite.dart';
import '../../widgets/pave_numerique.dart';
import 'lien_oublie.dart';

/// Écran de verrouillage : demande le code PIN ou le mot de passe, et lit
/// l'empreinte digitale automatiquement si la biométrie est activée.
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

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final _service = SecurityService.instance;
  final _motDePasseCtrl = TextEditingController();

  String _type = 'pin';
  int _longueur = 4;
  bool _biometrie = false;
  bool _natif = false;
  bool _scan = false;
  bool _pret = false;

  String _saisie = '';
  bool _masque = true;
  String? _erreur;
  String? _messageEmpreinte;
  int _echecs = 0;
  int _secousses = 0;
  int _attente = 0;
  Timer? _minuteur;
  StreamSubscription<ResultatEmpreinte>? _abonnement;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _abonnement = EmpreinteNative.instance.evenements.listen(_surEvenement);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _abonnement?.cancel();
    EmpreinteNative.instance.arreter();
    _minuteur?.cancel();
    _motDePasseCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    if (!mounted) return;
    if (etat == AppLifecycleState.resumed) {
      if (_pret && _biometrie && _natif && !_scan) _demarrerScan();
    } else if (_scan) {
      setState(() => _scan = false);
    }
  }

  Future<void> _init() async {
    final type = await _service.type();
    final longueur = await _service.longueurPin();
    final bio = widget.autoriserBiometrie && await _service.biometrieActive();
    final natif = bio && await EmpreinteNative.instance.disponible();
    if (!mounted) return;
    setState(() {
      _type = type;
      _longueur = longueur;
      _biometrie = bio;
      _natif = natif;
      _pret = true;
    });
    if (bio) {
      if (natif) {
        _demarrerScan();
      } else {
        _essayerBiometrie();
      }
    }
  }

  /// Lance la lecture d'empreinte intégrée (sans fenêtre système).
  Future<void> _demarrerScan() async {
    if (!mounted || !_natif || !_biometrie) return;
    setState(() {
      _scan = true;
      _messageEmpreinte = null;
    });
    await EmpreinteNative.instance.demarrer();
  }

  /// Solution de secours : la fenêtre d'empreinte ou de visage du système.
  Future<void> _essayerBiometrie() async {
    final ok = await _service.authentifierBiometrie(
      tr("Déverrouillez Gestion d'argent"),
    );
    if (ok && mounted) widget.onUnlocked();
  }

  void _toucherEmpreinte() {
    if (_natif) {
      _demarrerScan();
    } else {
      _essayerBiometrie();
    }
  }

  void _surEvenement(ResultatEmpreinte e) {
    if (!mounted || !_biometrie) return;
    if (e.type == 'succes') {
      widget.onUnlocked();
    } else if (e.type == 'echec') {
      setState(() {
        _messageEmpreinte = 'Empreinte non reconnue. Réessayez.';
        _secousses++;
      });
    } else if (e.type == 'erreur') {
      final code = e.detail;
      if (code == '2' || code == '3') {
        // Lecture illisible ou délai dépassé : on relance.
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _scan) _demarrerScan();
        });
      } else if (code == '7' || code == '9') {
        setState(() {
          _scan = false;
          _messageEmpreinte = "Trop d'essais d'empreinte. Utilisez votre code.";
        });
      } else {
        setState(() {
          _scan = false;
          _natif = false;
          _messageEmpreinte =
              "Capteur d'empreinte indisponible. Utilisez votre code.";
        });
      }
    }
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
      _messageEmpreinte = null;
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

  /// Champ blanc arrondi : cadenas à gauche, œil à droite.
  Widget _champMotDePasse(CouleurSecurite c) {
    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _motDePasseCtrl,
      obscureText: _masque,
      enabled: _attente == 0,
      onSubmitted: _verifier,
      cursorColor: c.surBouton,
      style: TextStyle(color: c.champ, fontSize: 17),
      decoration: InputDecoration(
        hintText: tr('Mot de passe'),
        hintStyle: TextStyle(color: c.surBouton.withValues(alpha: 0.55)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: c.surBouton),
        suffixIcon: IconButton(
          icon: Icon(
            _masque ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: c.surBouton.withValues(alpha: 0.7),
          ),
          onPressed: () => setState(() => _masque = !_masque),
        ),
        border: bordure,
        enabledBorder: bordure,
        disabledBorder: bordure,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: c.surBouton.withValues(alpha: 0.6),
            width: 1.6,
          ),
        ),
      ),
    );
  }

  /// Bouton blanc « Déverrouiller » au texte brun.
  Widget _boutonDeverrouiller(CouleurSecurite c) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed:
            _attente > 0 ? null : () => _verifier(_motDePasseCtrl.text),
        style: FilledButton.styleFrom(
          backgroundColor: c.bouton,
          foregroundColor: c.surBouton,
          disabledBackgroundColor: c.bouton.withValues(alpha: 0.5),
          disabledForegroundColor: c.surBouton.withValues(alpha: 0.6),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        child: const Text('Déverrouiller'),
      ),
    );
  }

  /// Message d'erreur. En mode PIN, sa hauteur est fixe pour que le
  /// pavé ne bouge pas quand le message apparaît.
  Widget _zoneMessage(CouleurSecurite c, String message, {required bool fixe}) {
    final texte = Text(
      message,
      key: ValueKey<String>(message),
      textAlign: TextAlign.center,
      style: TextStyle(color: c.erreur, fontWeight: FontWeight.w700),
    );
    if (fixe) {
      return SizedBox(
        height: 40,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: texte,
          ),
        ),
      );
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: message.isEmpty ? 8 : 12),
        child: message.isEmpty ? const SizedBox(height: 0) : texte,
      ),
    );
  }

  /// Cercle blanc avec cadenas brun, posé à cheval sur le panneau.
  Widget _cercleCadenas(CouleurSecurite c) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: c.surBouton.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.lock_outline_rounded, size: 40, color: c.surBouton),
    );
  }

  Widget _panneau(CouleurSecurite c, bool pin, String message) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 42),
          padding: EdgeInsets.fromLTRB(20, 58, 20, pin ? 10 : 22),
          decoration: BoxDecoration(
            color: c.panneau,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: c.bordurePanneau),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pin ? 'Saisissez votre code PIN' : 'Saisissez votre mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: c.texte,
                ),
              ),
              const SizedBox(height: 18),
              _secousse(
                child: pin
                    ? PointsPin(
                        longueur: _longueur,
                        remplis: _saisie.length,
                        erreur: _erreur != null && _saisie.isEmpty,
                        surColore: true,
                      )
                    : _champMotDePasse(c),
              ),
              _zoneMessage(c, message, fixe: pin),
              if (pin)
                PaveNumerique(
                  onChiffre: _toucher,
                  onEffacer: _effacer,
                  actif: _attente == 0,
                  surColore: true,
                  hauteur: 60,
                )
              else
                _boutonDeverrouiller(c),
            ],
          ),
        ),
        _cercleCadenas(c),
      ],
    );
  }

  /// Bouton d'empreinte : la lecture est déjà lancée automatiquement.
  Widget _blocBiometrie(CouleurSecurite c, bool pin) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BoutonBiometrie(onTap: _toucherEmpreinte, taille: pin ? 64 : 92),
        const SizedBox(height: 8),
        Text(
          _scan
              ? 'Posez votre doigt sur le capteur'
              : "Touchez pour utiliser l'empreinte",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: c.texte),
        ),
      ],
    );
  }

  Widget _pastille(CouleurSecurite c, IconData icone, String libelle) {
    return SizedBox(
      width: 104,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.voile),
            child: Icon(icone, color: c.texte, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            libelle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.2, color: c.texte),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = CouleurSecurite.de(context);
    final pin = _type == 'pin';
    final message = _attente > 0
        ? "Trop d'essais. Réessayez dans $_attente s."
        : (_erreur ?? _messageEmpreinte ?? '');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.fondBas,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.fondBas,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.fondHaut, c.fondBas],
            ),
          ),
          child: SafeArea(
            child: !_pret
                ? Center(child: CircularProgressIndicator(color: c.texte))
                : LayoutBuilder(
                    builder: (context, contraintes) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: contraintes.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.annulable)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 6, top: 2),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        color: c.texte,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 22),
                              Text(
                                widget.titre ?? "Gestion d'argent",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: c.texte,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 26),
                                child: _panneau(c, pin, message),
                              ),
                              const SizedBox(height: 22),
                              if (!widget.annulable) LienOublie(pin: pin, onRecupere: widget.onUnlocked),
                              if (_biometrie) Center(child: _blocBiometrie(c, pin)),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _pastille(
                                      c,
                                      Icons.wifi_off_rounded,
                                      'Hors ligne',
                                    ),
                                    _pastille(
                                      c,
                                      Icons.smartphone_rounded,
                                      'Données privées',
                                    ),
                                    _pastille(
                                      c,
                                      Icons.verified_user_outlined,
                                      'Sécurisé',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
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