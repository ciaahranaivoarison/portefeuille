import 'package:flutter/material.dart';

import '../../core/security_service.dart';
import '../../widgets/sceau.dart';
import '../shell/app_shell.dart';
import 'lock_screen.dart';

/// Porte d'entrée : affiche l'écran de verrouillage au lancement si la
/// protection est activée, sinon ouvre directement l'application.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool? _verrouille;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final active = await SecurityService.instance.estActive();
    if (!mounted) return;
    setState(() => _verrouille = active);
  }

  @override
  Widget build(BuildContext context) {
    final verrouille = _verrouille;
    if (verrouille == null) {
      return const Scaffold(body: Center(child: Sceau()));
    }
    if (verrouille) {
      return LockScreen(
        onUnlocked: () => setState(() => _verrouille = false),
      );
    }
    return const AppShell();
  }
}