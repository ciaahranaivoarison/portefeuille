import 'dart:async';

import 'package:flutter/services.dart';

/// Résultat d'une lecture d'empreinte, envoyé par la partie Android.
/// [type] vaut 'succes', 'echec', 'aide' ou 'erreur'.
class ResultatEmpreinte {
  const ResultatEmpreinte(this.type, this.detail);

  final String type;
  final String? detail;
}

/// Lecture d'empreinte digitale sans fenêtre système : l'écran de
/// verrouillage dessine lui-même l'interface. Le système Android compare
/// l'empreinte ; l'application reçoit seulement le résultat.
class EmpreinteNative {
  EmpreinteNative._();
  static final EmpreinteNative instance = EmpreinteNative._();

  static const _canal = MethodChannel('mg.stage.vola/empreinte');

  final StreamController<ResultatEmpreinte> _flux =
      StreamController<ResultatEmpreinte>.broadcast();
  bool _pret = false;

  /// Flux des résultats de lecture.
  Stream<ResultatEmpreinte> get evenements {
    if (!_pret) {
      _pret = true;
      _canal.setMethodCallHandler((appel) async {
        if (appel.method == 'evenement') {
          final donnees = Map<Object?, Object?>.from(appel.arguments as Map);
          _flux.add(
            ResultatEmpreinte(
              donnees['type'] as String,
              donnees['detail'] as String?,
            ),
          );
        }
        return null;
      });
    }
    return _flux.stream;
  }

  /// Vrai si le téléphone a un capteur et au moins une empreinte enregistrée.
  Future<bool> disponible() async {
    try {
      return (await _canal.invokeMethod<String>('etat')) == 'disponible';
    } catch (_) {
      return false;
    }
  }

  Future<void> demarrer() async {
    try {
      await _canal.invokeMethod<void>('demarrer');
    } catch (_) {
      // Sans lecture possible, l'utilisateur garde son code.
    }
  }

  Future<void> arreter() async {
    try {
      await _canal.invokeMethod<void>('arreter');
    } catch (_) {
      // Rien à arrêter.
    }
  }
}