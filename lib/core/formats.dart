/// Affiche un montant en Ariary : 1250000 devient « 1 250 000 Ar ».
String formatAr(int montant) {
  final negatif = montant < 0;
  final chiffres = montant.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < chiffres.length; i++) {
    if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(chiffres[i]);
  }
  return '${negatif ? '-' : ''}$buffer\u00A0Ar';
}