/// Emoji associé à une catégorie, selon son nom.
/// Une catégorie créée par l'utilisateur reçoit :tag:, sauf si son nom
/// évoque un thème connu (ex. : « Scolarité » donne :graduation-cap:).
String emojiCategorie(String? nom) {
  if (nom == null) return ':tag:';
  final n = nom.toLowerCase();
  const themes = <(String, String)>[
    ('alimentation', ':utensils:'),
    ('nourriture', ':utensils:'),
    ('repas', ':utensils:'),
    ('transport', ':bus:'),
    ('logement', ':home:'),
    ('loyer', ':home:'),
    ('santé', ':pill:'),
    ('sante', ':pill:'),
    ('téléphone', ':smartphone:'),
    ('telephone', ':smartphone:'),
    ('internet', ':smartphone:'),
    ('loisir', ':gamepad:'),
    ('shopping', ':shopping-bag:'),
    ('vêtement', ':shirt:'),
    ('scolar', ':graduation-cap:'),
    ('école', ':graduation-cap:'),
    ('ecole', ':graduation-cap:'),
    ('étude', ':graduation-cap:'),
    ('salaire', ':briefcase:'),
    ('commerce', ':shopping-cart:'),
    ('freelance', ':laptop:'),
    ('cadeau', ':gift:'),
    ('épargne', ':wallet:'),
    ('autre', ':package:'),
  ];
  for (final (mot, emoji) in themes) {
    if (n.contains(mot)) return emoji;
  }
  return ':tag:';
}

/// Emoji d'un compte, selon son type : espèces, banque ou mobile money.
String emojiCompte(String type) => switch (type) {
      'cash' => ':banknote:',
      'bank' => ':landmark:',
      _ => ':mobile-money:',
    };