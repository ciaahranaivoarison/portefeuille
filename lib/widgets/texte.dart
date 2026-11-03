import 'package:flutter/material.dart' as m;
import 'package:gestion_argent/core/traduction.dart';

export 'package:gestion_argent/core/traduction.dart' show tr;

/// Remplace le widget `Text` de Flutter : le texte est traduit dans la
/// langue choisie avant d'être affiché. Les écrans l'utilisent sans rien
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
    return m.Text(
      tr(data),
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      maxLines: maxLines,
    );
  }
}