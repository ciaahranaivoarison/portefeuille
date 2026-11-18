import 'package:flutter/material.dart' as m;
import 'package:gestion_argent/core/traduction.dart';
import 'package:gestion_argent/widgets/pictogramme.dart';

export 'package:gestion_argent/core/traduction.dart' show tr;

/// Remplace le widget `Text` de Flutter : le texte est traduit dans la
/// langue choisie, puis les codes d'icônes (`:wallet:`) sont remplacés par
/// les icônes SVG correspondantes. Les écrans l'utilisent sans rien
/// changer à leur code.
class Text extends m.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.softWrap,
    this.maxLines,
  });

  final String data;
  final m.TextStyle? style;
  final m.TextAlign? textAlign;
  final m.TextOverflow? overflow;
  final bool? softWrap;
  final int? maxLines;

  @override
  m.Widget build(m.BuildContext context) {
    final texte = tr(data);

    // Texte réduit à une seule icône : on affiche l'icône seule.
    final seule = nomPictogrammeSeul(texte);
    if (seule != null) {
      final base = m.DefaultTextStyle.of(context).style.merge(style);
      return Pictogramme(
        seule,
        taille: (base.fontSize ?? 14) * 1.2,
        couleur: style?.color,
      );
    }

    if (!contientPictogramme(texte)) {
      return m.Text(
        texte,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        softWrap: softWrap,
        maxLines: maxLines,
      );
    }

    // Texte avec des icônes au milieu : l'icône suit la couleur du texte.
    final base = m.DefaultTextStyle.of(context).style.merge(style);
    return m.Text.rich(
      m.TextSpan(
        style: style,
        children: decouperPictogrammes(
          texte,
          taille: (base.fontSize ?? 14) * 1.15,
          couleur: base.color ?? m.Theme.of(context).colorScheme.onSurface,
        ),
      ),
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      maxLines: maxLines,
    );
  }
}