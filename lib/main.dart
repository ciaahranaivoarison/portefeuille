import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'core/reglages.dart';
import 'data/app_database.dart';
import 'features/lock/app_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  await Reglages.instance.charger();
  runApp(const GestionArgentApp());
}

class GestionArgentApp extends StatelessWidget {
  const GestionArgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Reglages.instance,
      builder: (context, _) => MaterialApp(
        title: "Gestion d'argent",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: Reglages.instance.mode,
        locale: Reglages.instance.locale,
        supportedLocales: const [Locale('fr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppGate(),
      ),
    );
  }
}