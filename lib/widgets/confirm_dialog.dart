import 'package:flutter/material.dart';

/// Demande une confirmation avant de supprimer une opération.
Future<bool> confirmerSuppression(BuildContext context) async {
  final reponse = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cette opération ?'),
      content: const Text('Les soldes seront recalculés automatiquement.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return reponse ?? false;
}