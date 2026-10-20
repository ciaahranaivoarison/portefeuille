import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_argent/core/formats.dart';

void main() {
  test('formatAr affiche les montants en Ariary', () {
    expect(formatAr(1250000), '1\u00A0250\u00A0000\u00A0Ar');
    expect(formatAr(0), '0\u00A0Ar');
    expect(formatAr(-25000), '-25\u00A0000\u00A0Ar');
  });
}