import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Protection de l'application (section 10 de la fiche).
///
/// - Le code (PIN ou mot de passe) n'est jamais enregistré en clair :
///   seule son empreinte (hash salé) est conservée dans le stockage
///   sécurisé du téléphone.
/// - La biométrie (empreinte, visage) est gérée par le système du
///   téléphone : l'application reçoit seulement « réussi » ou « échoué ».
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static final FlutterSecureStorage _stockage = FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  static const _cleActive = 'protection_active';
  static const _cleType = 'protection_type'; // 'pin' ou 'password'
  static const _cleLongueur = 'protection_pin_longueur';
  static const _cleSel = 'protection_sel';
  static const _cleHash = 'protection_hash';
  static const _cleBiometrie = 'protection_biometrie';

  Future<String?> _lire(String cle) async {
    try {
      return await _stockage.read(key: cle);
    } catch (_) {
      // Stockage illisible (ex. : application réinstallée) : on repart à zéro.
      try {
        await _stockage.deleteAll();
      } catch (_) {}
      return null;
    }
  }

  Future<bool> estActive() async {
    final active = await _lire(_cleActive);
    final hash = await _lire(_cleHash);
    return active == 'oui' && hash != null;
  }

  Future<String> type() async => (await _lire(_cleType)) ?? 'pin';

  Future<int> longueurPin() async =>
      int.tryParse((await _lire(_cleLongueur)) ?? '') ?? 4;

  Future<bool> biometrieActive() async =>
      (await _lire(_cleBiometrie)) == 'oui';

  String _nouveauSel() {
    final hasard = Random.secure();
    return base64.encode(List<int>.generate(16, (_) => hasard.nextInt(256)));
  }

  String _empreinte(String code, String sel) {
    List<int> h = utf8.encode('$sel:$code');
    for (var i = 0; i < 20000; i++) {
      h = sha256.convert(h).bytes;
    }
    return base64.encode(h);
  }

  /// Enregistre un nouveau code et active la protection.
  Future<void> definirCode({
    required String type,
    required String code,
    int longueurPin = 4,
  }) async {
    if (type == 'pin') {
      if (code.length != longueurPin || !RegExp(r'^\d+$').hasMatch(code)) {
        throw ArgumentError('Le code PIN doit contenir $longueurPin chiffres.');
      }
    } else if (code.length < 6) {
      throw ArgumentError(
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
    }
    final sel = _nouveauSel();
    await _stockage.write(key: _cleSel, value: sel);
    await _stockage.write(key: _cleHash, value: _empreinte(code, sel));
    await _stockage.write(key: _cleType, value: type);
    await _stockage.write(key: _cleLongueur, value: '$longueurPin');
    await _stockage.write(key: _cleActive, value: 'oui');
  }

  Future<bool> verifier(String code) async {
    final sel = await _lire(_cleSel);
    final attendu = await _lire(_cleHash);
    if (sel == null || attendu == null) return false;
    return _empreinte(code, sel) == attendu;
  }

  /// Désactive la protection et efface le code et le réglage biométrique.
  Future<void> desactiver() async {
    for (final cle in [
      _cleActive,
      _cleType,
      _cleLongueur,
      _cleSel,
      _cleHash,
      _cleBiometrie,
    ]) {
      await _stockage.delete(key: cle);
    }
  }

  Future<void> definirBiometrie(bool active) async {
    await _stockage.write(key: _cleBiometrie, value: active ? 'oui' : 'non');
  }

  /// Biométries enregistrées sur le téléphone (liste vide si aucune).
  Future<List<BiometricType>> biometriesDisponibles() async {
    try {
      if (!await _auth.isDeviceSupported()) return [];
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  static String libelleBiometrie(List<BiometricType> types) {
    final empreinte = types.contains(BiometricType.fingerprint);
    final visage = types.contains(BiometricType.face);
    if (empreinte && visage) {
      return "l'empreinte digitale ou la reconnaissance faciale";
    }
    if (empreinte) return "l'empreinte digitale";
    if (visage) return 'la reconnaissance faciale';
    return 'la biométrie du téléphone';
  }

  /// Ouvre la fenêtre de sécurité du système (empreinte ou visage).
  Future<bool> authentifierBiometrie(String raison) async {
    try {
      return await _auth.authenticate(localizedReason: raison);
    } catch (_) {
      return false;
    }
  }
}