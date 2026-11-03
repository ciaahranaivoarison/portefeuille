import 'package:flutter/material.dart' hide Text;
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';
import '../../core/security_service.dart';
import '../../widgets/choix.dart';
import '../../widgets/pave_numerique.dart';
import '../../widgets/ui.dart';

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

  // Saisie du PIN : étape 0 = création, étape 1 = confirmation.
  int _etape = 0;
  String _saisie = '';
  String _premier = '';
  String? _erreur;
  int _secousses = 0;
  bool _enCours = false;

  // Saisie du mot de passe.
  bool _masque = true;
  final _codeCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool get _pin => _type == 'pin';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    _etape = 0;
    _saisie = '';
    _premier = '';
    _erreur = null;
    _codeCtrl.clear();
    _confirmCtrl.clear();
  }

  void _changerType(String type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _reinitialiser();
    });
  }

  void _changerLongueur(int longueur) {
    if (longueur == _longueur) return;
    setState(() {
      _longueur = longueur;
      _reinitialiser();
    });
  }

  void _toucher(String chiffre) {
    if (_enCours || _saisie.length >= _longueur) return;
    setState(() {
      _saisie += chiffre;
      _erreur = null;
    });
    if (_saisie.length == _longueur) _validerPin();
  }

  void _effacer() {
    if (_saisie.isEmpty) return;
    setState(() => _saisie = _saisie.substring(0, _saisie.length - 1));
  }

  Future<void> _validerPin() async {
    // Petite pause pour laisser voir le dernier point se remplir.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    if (_etape == 0) {
      setState(() {
        _premier = _saisie;
        _saisie = '';
        _etape = 1;
      });
    } else if (_saisie == _premier) {
      await _enregistrer(_saisie);
    } else {
      setState(() {
        _erreur = 'Les deux codes sont différents. Recommencez.';
        _saisie = '';
        _premier = '';
        _etape = 0;
        _secousses++;
      });
    }
  }

  Future<void> _enregistrer(String code) async {
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  /// Solidité d'un mot de passe : de 0 (trop court) à 4 (excellent).
  int _force(String mot) {
    if (mot.length < 6) return 0;
    var score = 1;
    if (mot.length >= 10) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(mot) && RegExp(r'\d').hasMatch(mot)) {
      score++;
    }
    final majuscule = RegExp(r'[A-Z]').hasMatch(mot);
    final minuscule = RegExp(r'[a-z]').hasMatch(mot);
    final symbole = RegExp(r'[^A-Za-z0-9]').hasMatch(mot);
    if ((majuscule && minuscule) || symbole) score++;
    return score;
  }

  Widget _jaugeForce(Palette p, String mot) {
    final score = _force(mot);
    const libelles = ['Trop court', 'Faible', 'Moyen', 'Bon', 'Excellent'];
    final couleur =
        score <= 1 ? p.depense : (score == 2 ? p.accent : p.revenu);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  decoration: BoxDecoration(
                    color: (mot.isNotEmpty && i < score)
                        ? couleur
                        : p.bordure,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          mot.isEmpty ? ' ' : 'Solidité : ${libelles[score]}',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: mot.isEmpty ? p.texteDoux : couleur,
          ),
        ),
      ],
    );
  }

  Widget _saisiePin(Palette p) {
    final titre = _etape == 0
        ? (widget.modification ? 'Créez votre nouveau code' : 'Créez votre code')
        : 'Confirmez votre code';
    return Column(
      children: [
        const SizedBox(height: 22),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            titre,
            key: ValueKey<int>(_etape),
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: p.texte,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TweenAnimationBuilder<double>(
          key: ValueKey<int>(_secousses),
          tween: Tween<double>(begin: _secousses == 0 ? 1 : 0, end: 1),
          duration: const Duration(milliseconds: 420),
          builder: (context, t, enfant) => Transform.translate(
            offset: Offset(
              (t * 7 * 3.14159).remainder(6.28318) < 3.14159
                  ? 10 * (1 - t)
                  : -10 * (1 - t),
              0,
            ),
            child: enfant,
          ),
          child: PointsPin(longueur: _longueur, remplis: _saisie.length),
        ),
        SizedBox(
          height: 44,
          child: Center(
            child: Text(
              _erreur ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.depense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        PaveNumerique(
          onChiffre: _toucher,
          onEffacer: _effacer,
          actif: !_enCours,
        ),
      ],
    );
  }

  Widget _saisieMotDePasse(Palette p) {
    final code = _codeCtrl.text;
    final confirmation = _confirmCtrl.text;
    final identiques = code == confirmation;
    final valide = code.length >= 6 && identiques;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TitreSection('Mot de passe (6 caractères minimum)'),
        TextField(
          controller: _codeCtrl,
          obscureText: _masque,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: tr('Votre mot de passe'),
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
        ),
        const SizedBox(height: 12),
        _jaugeForce(p, code),
        const TitreSection('Confirmation'),
        TextField(
          controller: _confirmCtrl,
          obscureText: _masque,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: tr('Saisissez-le à nouveau'),
            prefixIcon: const Icon(Icons.verified_outlined),
            errorText: (confirmation.isNotEmpty && !identiques)
                ? tr('Les deux saisies sont différentes.')
                : null,
          ),
        ),
        const SizedBox(height: 26),
        FilledButton(
          onPressed: (valide && !_enCours) ? () => _enregistrer(code) : null,
          child: const Text('Enregistrer le mot de passe'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modification ? 'Modifier le code' : "Protéger l'application",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: PastilleEmoji(
                _pin ? '🔢' : '🔤',
                taille: 74,
                key: ValueKey<String>(_type),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Choisissez votre méthode',
              style: TextStyle(
                fontFamily: AppTheme.fontTitre,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.texte,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CarteChoix(
                  emoji: '🔢',
                  libelle: 'Code PIN',
                  actif: _pin,
                  onTap: () => _changerType('pin'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CarteChoix(
                  emoji: '🔤',
                  libelle: 'Mot de passe',
                  actif: !_pin,
                  onTap: () => _changerType('password'),
                ),
              ),
            ],
          ),
          if (_pin) ...[
            const TitreSection('Longueur du code'),
            Row(
              children: [
                ChipChoix(
                  libelle: '4 chiffres',
                  actif: _longueur == 4,
                  onTap: () => _changerLongueur(4),
                ),
                const SizedBox(width: 8),
                ChipChoix(
                  libelle: '6 chiffres (plus sûr)',
                  actif: _longueur == 6,
                  onTap: () => _changerLongueur(6),
                ),
              ],
            ),
            _saisiePin(p),
          ] else
            _saisieMotDePasse(p),
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
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Le code n'est jamais enregistré en clair : seule une "
                    'empreinte chiffrée est conservée sur ce téléphone. '
                    "En cas d'oubli, il faut désinstaller l'application, ce "
                    'qui efface vos données. Pensez à faire une sauvegarde.',
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