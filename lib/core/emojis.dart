// Icônes des catégories et des comptes.
//
// Une icône est désignée par son nom entre deux-points (`:wallet:`) ; le
// widget `Text` la remplace par le dessin SVG correspondant.

/// Icône d'un compte, selon son type : espèces, banque ou mobile money.
String emojiCompte(String type) => switch (type) {
      'cash' => ':banknote:',
      'bank' => ':landmark:',
      _ => ':mobile-money:',
    };

/// Icône d'une catégorie, choisie automatiquement d'après son nom.
///
/// 1. Si le nom contient un mot connu (accents, majuscules et pluriels
///    sont ignorés), l'icône correspondante est utilisée.
/// 2. Sinon, la catégorie reçoit un badge avec son initiale, pour rester
///    reconnaissable parmi les autres.
String emojiCategorie(String? nom) {
  if (nom == null || nom.trim().isEmpty) return ':tag:';
  final mots = _mots(nom);
  if (mots.isEmpty) return ':tag:';

  // Catégorie supprimée : icône neutre.
  if (mots.length == 2 && mots[0] == 'sans' && mots[1].startsWith('categor')) {
    return ':tag:';
  }

  for (final (icone, cles) in _themes) {
    for (final cle in cles) {
      if (mots.any((mot) => _correspond(mot, cle))) return ':$icone:';
    }
  }
  return _initiale(nom);
}

const _accents = <String, String>{
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i', 'í': 'i',
  'ô': 'o', 'ö': 'o', 'ó': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
  'ç': 'c', 'ñ': 'n', 'œ': 'oe', 'æ': 'ae',
};

String _sansAccents(String texte) {
  final sortie = StringBuffer();
  for (final r in texte.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    sortie.write(_accents[c] ?? c);
  }
  return sortie.toString();
}

List<String> _mots(String nom) => _sansAccents(nom)
    .split(RegExp(r'[^a-z0-9]+'))
    .where((m) => m.isNotEmpty)
    .toList();

/// Un mot de 3 lettres ou moins doit être identique ; un mot plus long
/// peut être suivi d'autres lettres (pluriels, féminins...).
bool _correspond(String mot, String cle) =>
    cle.length <= 3 ? mot == cle : mot.startsWith(cle);

/// Badge avec la première lettre ou le premier chiffre du nom.
String _initiale(String nom) {
  final m = RegExp(r'[a-z0-9]').firstMatch(_sansAccents(nom.trim()));
  return m == null ? ':tag:' : ':lettre-${m.group(0)}:';
}

/// Icônes et mots qui les déclenchent. Le premier thème qui correspond
/// l'emporte : les plus précis sont placés avant les plus généraux.
const List<(String, List<String>)> _themes = [
  ('utensils', [
    'alimentation', 'nourriture', 'repas', 'restaurant', 'resto', 'manger',
    'cantine', 'snack', 'boulangerie', 'sakafo', 'vary', 'traiteur',
  ]),
  ('shopping-cart', [
    'commerce', 'vente', 'negoce', 'business', 'entreprise', 'revente',
    'course', 'epicerie', 'supermarche', 'marche', 'approvisionnement',
  ]),
  ('bus', [
    'transport', 'taxi', 'bus', 'minibus', 'taxibe', 'moto', 'pousse',
    'deplacement', 'trajet', 'navette',
  ]),
  ('fuel', ['carburant', 'essence', 'gasoil', 'diesel', 'fuel']),
  ('car', ['voiture', 'vehicule', 'garage', 'parking', 'mecanique']),
  ('plane', [
    'voyage', 'vacances', 'avion', 'hotel', 'sejour', 'tourisme', 'billet',
    'excursion', 'vol',
  ]),
  ('home', [
    'logement', 'loyer', 'maison', 'habitation', 'immobilier', 'location',
    'hypotheque', 'menage', 'domicile', 'appartement', 'chambre',
  ]),
  ('zap', [
    'electricite', 'jirama', 'courant', 'lumiere', 'energie', 'gaz',
    'solaire', 'batterie',
  ]),
  ('droplet', ['eau', 'plomberie', 'douche', 'lessive']),
  ('wrench', [
    'reparation', 'travaux', 'bricolage', 'outil', 'menuiserie',
    'maintenance', 'entretien', 'construction', 'materiaux',
  ]),
  ('smartphone', [
    'telephone', 'mobile', 'recharge', 'telma', 'airtel', 'orange',
    'portable', 'forfait', 'sms',
  ]),
  ('wifi', ['internet', 'wifi', 'connexion', 'fibre', 'data']),
  ('pill', [
    'sante', 'medecin', 'docteur', 'pharmacie', 'medicament', 'hopital',
    'clinique', 'soin', 'dentiste', 'analyse', 'consultation', 'medical',
    'lunettes',
  ]),
  ('dumbbell', [
    'sport', 'gym', 'fitness', 'musculation', 'football', 'basket',
    'natation', 'entrainement',
  ]),
  ('gamepad', [
    'loisir', 'jeu', 'jeux', 'game', 'gaming', 'sortie', 'divertissement',
    'soiree', 'boite', 'bar', 'fete',
  ]),
  ('film', [
    'cinema', 'film', 'netflix', 'serie', 'streaming', 'abonnement', 'canal',
    'video', 'spectacle',
  ]),
  ('music', ['musique', 'concert', 'spotify', 'chant', 'instrument', 'radio']),
  ('book', [
    'livre', 'lecture', 'librairie', 'magazine', 'journal', 'bible',
    'papeterie',
  ]),
  ('coffee', ['cafe', 'the', 'boisson', 'biere', 'jus']),
  ('shopping-bag', ['shopping', 'achat', 'boutique', 'magasin']),
  ('shirt', [
    'vetement', 'habit', 'chaussure', 'tenue', 'friperie', 'couture',
    'tissu', 'linge', 'pagne', 'lamba',
  ]),
  ('scissors', [
    'beaute', 'coiffure', 'coiffeur', 'salon', 'maquillage', 'cosmetique',
    'parfum', 'esthetique', 'manucure',
  ]),
  ('graduation-cap', [
    'scolarite', 'scolaire', 'scolar', 'ecole', 'etude', 'universite',
    'formation', 'cours', 'fourniture', 'lycee', 'college', 'ecolage',
    'minerval', 'examen', 'stage',
  ]),
  ('smile', [
    'enfant', 'bebe', 'creche', 'nounou', 'jouet', 'jouets', 'garderie',
    'naissance', 'couche', 'lait',
  ]),
  ('users', ['famille', 'parents', 'proches', 'amis', 'visite']),
  ('heart', [
    'animal', 'animaux', 'chien', 'chat', 'veterinaire', 'veto', 'betail',
    'zebu', 'poule', 'volaille', 'association', 'solidarite', 'benevolat',
  ]),
  ('wallet', [
    'epargne', 'economie', 'tontine', 'coffre', 'reserve', 'placement',
    'fonds',
  ]),
  ('trending-up', [
    'investissement', 'bourse', 'actions', 'capital', 'rendement',
    'dividende', 'interet',
  ]),
  ('landmark', [
    'impot', 'taxe', 'douane', 'amende', 'redevance', 'tva', 'irsa', 'mairie',
    'etat', 'administration', 'tribunal', 'banque', 'agios',
  ]),
  ('shield-check', ['assurance', 'securite', 'mutuelle', 'garantie', 'protection']),
  ('credit-card', [
    'dette', 'pret', 'emprunt', 'remboursement', 'credit', 'carte',
    'echeance',
  ]),
  ('receipt', ['facture', 'quittance', 'recu']),
  ('gift', [
    'cadeau', 'don', 'offrande', 'dime', 'charite', 'mariage', 'anniversaire',
    'funerailles', 'deces', 'obseques', 'famadihana', 'bapteme', 'noel',
    'pourboire',
  ]),
  ('briefcase', [
    'salaire', 'travail', 'emploi', 'paie', 'remuneration', 'traitement',
    'job', 'poste',
  ]),
  ('laptop', [
    'freelance', 'pigiste', 'consultant', 'mission', 'prestation',
    'informatique', 'ordinateur', 'numerique', 'web', 'logiciel', 'ordi',
  ]),
  ('banknote', [
    'revenu', 'prime', 'bonus', 'commission', 'pension', 'retraite',
    'allocation', 'virement',
  ]),
  ('alert-triangle', ['urgence', 'imprevu', 'accident', 'panne']),
  ('package', ['autre', 'divers', 'inconnu', 'reste', 'colis', 'livraison', 'stock']),
];