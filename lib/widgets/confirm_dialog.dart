import 'package:flutter/material.dart';

/// Demande une confirmation avant de supprimer quelque chose.
Future<bool> confirmerSuppression(
  BuildContext context, {
  String titre = 'Supprimer cette opération ?',
  String message = 'Les soldes seront recalculés automatiquement.',
}) async {
  final reponse = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titre),
      content: Text(message),
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