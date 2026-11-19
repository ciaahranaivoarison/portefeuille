import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Code de récupération : permet de retrouver l'accès si l'utilisateur
/// oublie son code PIN ou son mot de passe, sans effacer ses données.
///
/// Le code (16 caractères) n'est affiché qu'une seule fois, à sa création.
/// Seule son empreinte chiffrée (hash salé) est conservée, dans le
/// stockage sécurisé du téléphone.
class RecuperationService {
  RecuperationService._();
  static final RecuperationService instance = RecuperationService._();

  static final FlutterSecureStorage _stockage = FlutterSecureStorage();

  static const _cleSel = 'recup_sel';
  static const _cleHash = 'recup_hash';

  /// Sans 0, O, 1, I ni L : on évite les confusions à la lecture.
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

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

  /// Écrit 'AAAA-BBBB-CCCC-DDDD' à partir de 16 caractères.
  static String formater(String brut) {
    final groupes = <String>[];
    for (var i = 0; i < brut.length; i += 4) {
      final fin = i + 4 > brut.length ? brut.length : i + 4;
      groupes.add(brut.substring(i, fin));
    }
    return groupes.join('-');
  }

  /// Garde seulement les lettres et chiffres, en majuscules.
  static String normaliser(String saisie) =>
      saisie.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  /// Vrai si un code de récupération existe déjà.
  Future<bool> existe() async {
    try {
      return (await _stockage.read(key: _cleHash)) != null;
    } catch (_) {
      return false;
    }
  }

  /// Crée un nouveau code, enregistre son empreinte (l'ancien code devient
  /// invalide) et le renvoie. C'est la seule fois où il est visible.
  Future<String> generer() async {
    final hasard = Random.secure();
    final brut = List<String>.generate(
      16,
      (_) => _alphabet[hasard.nextInt(_alphabet.length)],
    ).join();
    final sel = _nouveauSel();
    await _stockage.write(key: _cleSel, value: sel);
    await _stockage.write(key: _cleHash, value: _empreinte(brut, sel));
    return formater(brut);
  }

  Future<bool> verifier(String saisie) async {
    try {
      final sel = await _stockage.read(key: _cleSel);
      final attendu = await _stockage.read(key: _cleHash);
      if (sel == null || attendu == null) return false;
      return _empreinte(normaliser(saisie), sel) == attendu;
    } catch (_) {
      return false;
    }
  }

  Future<void> effacer() async {
    await _stockage.delete(key: _cleSel);
    await _stockage.delete(key: _cleHash);
  }
}