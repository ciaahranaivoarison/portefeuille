import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../categories/categories_page.dart';

/// Écran Paramètres : il accueillera aussi la protection et la sauvegarde.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.category_outlined,
                color: AppColors.noyer,
              ),
              title: const Text(
                'Catégories',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Ajouter, modifier ou supprimer vos catégories',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}