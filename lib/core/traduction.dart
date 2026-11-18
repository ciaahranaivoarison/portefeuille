import 'dictionnaire.dart';
import 'reglages.dart';

/// Traduit un texte français dans la langue choisie ('en' ou 'mg').
/// Un texte inconnu est renvoyé tel quel.
String tr(String texte) {
  final langue = Reglages.instance.langue;
  if (langue == 'fr' || texte.isEmpty) return texte;

  final cache = _caches.putIfAbsent(langue, () => <String, String>{});
  final connu = cache[texte];
  if (connu != null) return connu;

  final resultat = _traduire(texte, langue);
  if (cache.length > 800) cache.clear();
  cache[texte] = resultat;
  return resultat;
}

final Map<String, Map<String, String>> _caches = {};

/// Textes qui ne contiennent aucune lettre à traduire (montants, dates...).
final RegExp _sansLettres = RegExp(r'^[\d\s\u00A0+\-.,:%/·→()]*(Ar)?$');

/// Début de texte formé d'un emoji : « :utensils: Alimentation ».
final RegExp _debutEmoji = RegExp(
  r'^((?::[a-z][a-z0-9-]*:)+)(\s+)(.+)$',
  unicode: true,
  dotAll: true,
);

final RegExp _coupePhrases = RegExp(r'(?<=[.!?])\s+');

/// Pour retrouver un texte écrit en MAJUSCULES (titres de section).
final Map<String, String> _indexMajuscules = {
  for (final cle in dictionnaire.keys) cle.toUpperCase(): cle,
};

String _t(String l, String en, String mg) => l == 'en' ? en : mg;

String _choisir((String, String) paire, String l) =>
    l == 'en' ? paire.$1 : paire.$2;

String _traduire(String s, String l) {
  if (_sansLettres.hasMatch(s)) return s;

  final direct = dictionnaire[s];
  if (direct != null) return _choisir(direct, l);

  if (s == s.toUpperCase() && s != s.toLowerCase()) {
    final cle = _indexMajuscules[s];
    if (cle != null) return _choisir(dictionnaire[cle]!, l).toUpperCase();
  }

  for (final (modele, fabrique) in _regles) {
    final m = modele.firstMatch(s);
    if (m != null) return fabrique(m, l);
  }

  final emoji = _debutEmoji.firstMatch(s);
  if (emoji != null) {
    return '${emoji.group(1)}${emoji.group(2)}'
        '${_traduire(emoji.group(3)!, l)}';
  }

  for (final separateur in const ['\n', ' · ', ' → ', ' + ']) {
    if (s.contains(separateur)) {
      final morceaux = s.split(separateur);
      final traduits = [for (final m in morceaux) _traduire(m, l)];
      return _recoller(morceaux, traduits, separateur) ?? s;
    }
  }

  final phrases = s.split(_coupePhrases);
  if (phrases.length > 1) {
    final traduites = [for (final p in phrases) _traduire(p, l)];
    return _recoller(phrases, traduites, ' ') ?? s;
  }

  return s;
}

/// Recolle les morceaux traduits, ou renvoie null si rien n'a changé.
String? _recoller(List<String> avant, List<String> apres, String separateur) {
  var change = false;
  for (var i = 0; i < avant.length; i++) {
    if (avant[i] != apres[i]) change = true;
  }
  return change ? apres.join(separateur) : null;
}

const _moisFr = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

const _moisEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _moisMg = [
  'Janoary',
  'Febroary',
  'Martsa',
  'Aprily',
  'Mey',
  'Jona',
  'Jolay',
  'Aogositra',
  'Septambra',
  'Oktobra',
  'Novambra',
  'Desambra',
];

String _sub(Match m, int i, String l) => _traduire(m[i]!, l);

/// Règles pour les textes qui contiennent des chiffres ou des morceaux
/// variables (« 5 comptes », « Octobre 2026 », « 3 opérations »...).
final List<(RegExp, String Function(Match, String))> _regles = [
  (
    RegExp(r'^Erreur : (.*)$', dotAll: true),
    (m, l) => '${_t(l, 'Error', 'Hadisoana')} : ${_sub(m, 1, l)}',
  ),
  (
    RegExp(r'^(\d+) comptes?$'),
    (m, l) {
      final n = int.parse(m[1]!);
      return _t(l, n == 1 ? '1 account' : '$n accounts', '$n kaonty');
    },
  ),
  (
    RegExp(r'^(\d+) opérations?$'),
    (m, l) {
      final n = int.parse(m[1]!);
      return _t(l, n == 1 ? '1 transaction' : '$n transactions', '$n hetsika');
    },
  ),
  (
    RegExp(r'^(\d+) % du total$'),
    (m, l) => _t(l, '${m[1]} % of the total', '${m[1]} % amin’ny totaliny'),
  ),
  (
    RegExp(r'^(\d+) % de vos revenus du mois sont dépensés$'),
    (m, l) => _t(
          l,
          '${m[1]} % of this month’s income is spent',
          '${m[1]} % amin’ny fidiram-bolanao amin’ity volana ity no lany',
        ),
  ),
  (
    RegExp(r'^(.+) dépensés sur (.+)$'),
    (m, l) => _t(l, '${m[1]} spent of ${m[2]}', '${m[1]} lany tamin’ny ${m[2]}'),
  ),
  (
    RegExp(r'^(.+) par mois$'),
    (m, l) => _t(l, '${m[1]} per month', '${m[1]} isam-bolana'),
  ),
  (
    RegExp('^(${_moisFr.join('|')}) (\\d{4})\$'),
    (m, l) {
      final i = _moisFr.indexOf(m[1]!);
      return '${l == 'en' ? _moisEn[i] : _moisMg[i]} ${m[2]}';
    },
  ),
  (
    RegExp(r'^Mois le plus dépensier : (.+)$'),
    (m, l) => _t(
          l,
          'Highest-spending month: ${_sub(m, 1, l)}',
          'Volana nandany be indrindra : ${_sub(m, 1, l)}',
        ),
  ),
  (
    RegExp(r'^Plus forte dépense du jour : (.+)$'),
    (m, l) => _t(
          l,
          'Biggest spending day: ${m[1]}',
          'Andro nandany be indrindra : ${m[1]}',
        ),
  ),
  (
    RegExp(r'^Solidité : (.+)$'),
    (m, l) => _t(
          l,
          'Strength: ${_sub(m, 1, l)}',
          'Hatanjahana : ${_sub(m, 1, l)}',
        ),
  ),
  (
    RegExp(r'^Code PIN à (\d+) chiffres$'),
    (m, l) => _t(l, '${m[1]}-digit PIN code', 'Kaody PIN ${m[1]} isa'),
  ),
  (
    RegExp(r'^(\d+) chiffres$'),
    (m, l) => _t(l, '${m[1]} digits', '${m[1]} isa'),
  ),
  (
    RegExp(r'^Déverrouillage par (.+)\.$'),
    (m, l) => _t(
          l,
          'Unlock with ${_sub(m, 1, l)}.',
          'Fanokafana amin’ny ${_sub(m, 1, l)}.',
        ),
  ),
  (
    RegExp(r'^(\d{2}/\d{2}/\d{4}) à (\d{2}:\d{2})$'),
    (m, l) => _t(l, '${m[1]} at ${m[2]}', '${m[1]} tamin’ny ${m[2]}'),
  ),
  (
    RegExp(r'^Sauvegarde du (.+)\.$'),
    (m, l) => _t(
          l,
          'Backup from ${_sub(m, 1, l)}.',
          'Fitehirizana tamin’ny ${_sub(m, 1, l)}.',
        ),
  ),
  (
    RegExp(
      r'^Ce fichier contient (\d+) compte\(s\), (\d+) catégorie\(s\), '
      r'(\d+) budget\(s\) et (\d+) opération\(s\)\.$',
    ),
    (m, l) => _t(
          l,
          'This file contains ${m[1]} account(s), ${m[2]} categories, '
              '${m[3]} budget(s) and ${m[4]} transaction(s).',
          'Ity rakitra ity dia misy kaonty ${m[1]}, sokajy ${m[2]}, '
              'tetibola ${m[3]} ary hetsika ${m[4]}.',
        ),
  ),
  (
    RegExp(
      r'^Ce compte contient (\d+) opération\(s\)\. '
      r"Supprimez-les ou modifiez-les d'abord\.$",
    ),
    (m, l) => _t(
          l,
          'This account contains ${m[1]} transaction(s). '
              'Delete or edit them first.',
          'Misy hetsika ${m[1]} ity kaonty ity. Fafao na ovay aloha izy ireo.',
        ),
  ),
  (
    RegExp(r'^(\d+) opération\(s\) deviendront « Sans catégorie »\.$'),
    (m, l) => _t(
          l,
          '${m[1]} transaction(s) will become “No category”.',
          'Hetsika ${m[1]} no ho « Tsy misy sokajy ».',
        ),
  ),
  (
    RegExp(r'^Le code PIN doit contenir (\d+) chiffres\.$'),
    (m, l) => _t(
          l,
          'The PIN code must contain ${m[1]} digits.',
          'Ny kaody PIN dia tsy maintsy misy isa ${m[1]}.',
        ),
  ),
  (
    RegExp(r"^Trop d'essais\. Réessayez dans (\d+) s\.$"),
    (m, l) => _t(
          l,
          'Too many attempts. Try again in ${m[1]} s.',
          'Be loatra ny andrana. Andramo indray afaka ${m[1]} s.',
        ),
  ),
  (
    RegExp(r'^La sauvegarde a échoué : (.+)$', dotAll: true),
    (m, l) => _t(
          l,
          'The backup failed: ${m[1]}',
          'Tsy nahomby ny fitehirizana : ${m[1]}',
        ),
  ),
  (
    RegExp(r'^Le partage a échoué : (.+)$', dotAll: true),
    (m, l) => _t(
          l,
          'Sharing failed: ${m[1]}',
          'Tsy nahomby ny fizarana : ${m[1]}',
        ),
  ),
  (
    RegExp(r'^La restauration a échoué : (.+)$', dotAll: true),
    (m, l) => _t(
          l,
          'The restore failed: ${m[1]}',
          'Tsy nahomby ny famerenana : ${m[1]}',
        ),
  ),
  (
    RegExp(r'^Sauvegarde incomplète : « (.+) » est absent\.$'),
    (m, l) => _t(
          l,
          'Incomplete backup: “${m[1]}” is missing.',
          'Tsy feno ny tahiry : « ${m[1]} » tsy hita.',
        ),
  ),
  (
    RegExp(r"^L'emoji est choisi automatiquement", dotAll: true),
    (m, l) => _t(
          l,
          'The emoji is chosen automatically from the name: “Tuition” gives '
              ':graduation-cap:, “Gift” gives :gift:. An unknown name gets :tag:.',
          'Ny emoji dia voafidy ho azy araka ny anarana: « Sekoly » dia :graduation-cap:, '
              '« Fanomezana » dia :gift:. Ny anarana tsy fantatra dia :tag:.',
        ),
  ),
];