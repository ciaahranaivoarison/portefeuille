import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_argent/main.dart';

void main() {
  testWidgets("L'accueil affiche le titre", (WidgetTester tester) async {
    await tester.pumpWidget(const GestionArgentApp());
    expect(find.text("Gestion d'argent"), findsWidgets);
  });
}