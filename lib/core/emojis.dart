/// Emoji associé à une catégorie, selon son nom.
/// Une catégorie créée par l'utilisateur reçoit 🏷️, sauf si son nom
/// évoque un thème connu (ex. : « Scolarité » donne 🎓).
String emojiCategorie(String? nom) {
  if (nom == null) return '🏷️';
  final n = nom.toLowerCase();
  const themes = <(String, String)>[
    ('alimentation', '🍽️'),
    ('nourriture', '🍽️'),
    ('repas', '🍽️'),
    ('transport', '🚌'),
    ('logement', '🏠'),
    ('loyer', '🏠'),
    ('santé', '💊'),
    ('sante', '💊'),
    ('téléphone', '📱'),
    ('telephone', '📱'),
    ('internet', '📱'),
    ('loisir', '🎮'),
    ('shopping', '🛍️'),
    ('vêtement', '👕'),
    ('scolar', '🎓'),
    ('école', '🎓'),
    ('ecole', '🎓'),
    ('étude', '🎓'),
    ('salaire', '💼'),
    ('commerce', '🛒'),
    ('freelance', '💻'),
    ('cadeau', '🎁'),
    ('épargne', '💰'),
    ('autre', '📦'),
  ];
  for (final (mot, emoji) in themes) {
    if (n.contains(mot)) return emoji;
  }
  return '🏷️';
}