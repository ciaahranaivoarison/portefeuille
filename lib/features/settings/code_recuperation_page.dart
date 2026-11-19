import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:gestion_argent/widgets/texte.dart';

import '../../core/app_theme.dart';

/// Affiche le code de récupération, une seule fois. L'utilisateur doit
/// confirmer qu'il l'a noté avant de pouvoir continuer.
class CodeRecuperationPage extends StatefulWidget {
  const CodeRecuperationPage({super.key, required this.code});

  final String code;

  @override
  State<CodeRecuperationPage> createState() => _CodeRecuperationPageState();
}

class _CodeRecuperationPageState extends State<CodeRecuperationPage> {
  bool _note = false;

  Future<void> _copier() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final groupes = widget.code.split('-');
    final ligne1 = groupes.take(2).join('-');
    final ligne2 = groupes.skip(2).join('-');

    final styleCode = TextStyle(
      fontFamily: 'monospace',
      fontSize: 30,
      letterSpacing: 3,
      fontWeight: FontWeight.w700,
      color: p.principal,
    );

    return PopScope(
      canPop: _note,
      onPopInvokedWithResult: (didPop, resultat) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cochez la case pour confirmer que vous avez noté le code.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Code de récupération'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.surfaceDouce,
                  border: Border.all(color: p.bordure),
                ),
                child: Icon(Icons.key_rounded, size: 34, color: p.principal),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Notez ce code maintenant',
                style: TextStyle(
                  fontFamily: AppTheme.fontTitre,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: p.texte,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "C'est la seule façon de retrouver l'accès si vous oubliez "
              'votre code, sans effacer vos données. Il ne sera plus jamais '
              'affiché.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: p.texteDoux),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: p.accent, width: 1.6),
              ),
              child: Column(
                children: [
                  SelectableText(ligne1, style: styleCode),
                  const SizedBox(height: 8),
                  SelectableText(ligne2, style: styleCode),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _copier,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copier le code'),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.depense.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: p.depense),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Écrivez-le sur papier et gardez-le hors du téléphone. '
                      'Ne le partagez avec personne.',
                      style: TextStyle(fontSize: 12.5, color: p.texte),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              value: _note,
              onChanged: (v) => setState(() => _note = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: p.principal,
              title: const Text("J'ai noté ce code en lieu sûr"),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _note ? () => Navigator.of(context).pop(true) : null,
              child: const Text('Terminer'),
            ),
          ],
        ),
      ),
    );
  }
}