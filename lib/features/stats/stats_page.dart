import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/budgets.dart';
import '../../data/stats.dart';
import '../../widgets/choix.dart';
import '../../widgets/entete_ecran.dart';
import '../../widgets/ui.dart';

const _periodes = [
  ('jour', '☀️', "Aujourd'hui"),
  ('semaine', '🗓️', 'Cette semaine'),
  ('mois', '📆', 'Ce mois'),
  ('precedent', '⏪', 'Mois précédent'),
  ('perso', '🎛️', 'Personnalisée'),
];

const _moisCourt = [
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Juin',
  'Juil',
  'Août',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

/// Couleurs des catégories : bruns, dorés, terracotta et sauge.
const _couleurs = [
  Color(0xFF8B5E3C),
  Color(0xFFC08A4A),
  Color(0xFFB5523B),
  Color(0xFF5E7F5B),
  Color(0xFFA9794F),
  Color(0xFFD9B382),
  Color(0xFFCB7B63),
  Color(0xFF8DA37E),
  Color(0xFF6F4A33),
  Color(0xFFB8A58E),
];

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _periode = 'mois';
  late DateTime _debut;
  late DateTime _fin;
  late Future<PeriodStats> _futur;

  @override
  void initState() {
    super.initState();
    final plage = _plage('mois');
    _debut = plage.$1;
    _fin = plage.$2;
    _futur = Stats.instance.pour(_debut, _fin);
  }

  (DateTime, DateTime) _plage(String code) {
    final n = DateTime.now();
    final jour = DateTime(n.year, n.month, n.day);
    switch (code) {
      case 'jour':
        return (jour, jour);
      case 'semaine':
        final lundi =
            DateTime(jour.year, jour.month, jour.day - (jour.weekday - 1));
        return (lundi, DateTime(lundi.year, lundi.month, lundi.day + 6));
      case 'precedent':
        return (
          DateTime(jour.year, jour.month - 1, 1),
          DateTime(jour.year, jour.month, 0),
        );
      default:
        return (
          DateTime(jour.year, jour.month, 1),
          DateTime(jour.year, jour.month + 1, 0),
        );
    }
  }

  Future<void> _choisir(String code) async {
    var plage = _plage(code);
    if (code == 'perso') {
      final choisie = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDateRange: DateTimeRange(start: _debut, end: _fin),
      );
      if (choisie == null) return;
      plage = (choisie.start, choisie.end);
    }
    setState(() {
      _periode = code;
      _debut = plage.$1;
      _fin = plage.$2;
      _futur = Stats.instance.pour(_debut, _fin);
    });
  }

  String _libelle(String code, String libelle) {
    if (code == 'perso' && _periode == 'perso') {
      return '${formatDate(_debut)} → ${formatDate(_fin)}';
    }
    return libelle;
  }

  Widget _bandePeriodes() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final per in _periodes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChipChoix(
                emoji: per.$2,
                libelle: _libelle(per.$1, per.$3),
                actif: _periode == per.$1,
                onTap: () => _choisir(per.$1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '🌿 Aucune dépense sur cette période.',
        style: TextStyle(color: context.pal.texteDoux),
      ),
    );
  }

  Widget _ligneCategorie(
    BuildContext context,
    int i,
    CategoryTotal c,
    int total,
  ) {
    final p = context.pal;
    final pct = c.amount * 100 / total;
    final pctTexte = pct < 1 ? '< 1 %' : '${pct.round()} %';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _couleurs[i % _couleurs.length],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('${emojiCategorie(c.name)} ${c.name}')),
          Text(
            formatAr(c.amount),
            style: TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontWeight: FontWeight.w600,
              color: p.texte,
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              pctTexte,
              textAlign: TextAlign.right,
              style: TextStyle(color: p.texteDoux),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _repartition(BuildContext context, PeriodStats s) {
    final p = context.pal;
    return [
      SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 72,
                borderData: FlBorderData(show: false),
                sections: [
                  for (var i = 0; i < s.categories.length; i++)
                    PieChartSectionData(
                      value: s.categories[i].amount.toDouble(),
                      color: _couleurs[i % _couleurs.length],
                      radius: 34,
                      showTitle: false,
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dépenses',
                  style: TextStyle(fontSize: 12, color: p.texteDoux),
                ),
                const SizedBox(height: 2),
                Text(
                  formatAr(s.expense),
                  style: TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: p.texte,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      for (var i = 0; i < s.categories.length; i++)
        _ligneCategorie(context, i, s.categories[i], s.expense),
    ];
  }

  List<Widget> _evolution(BuildContext context, PeriodStats s) {
    final p = context.pal;
    final points = s.points;
    final pic = points.reduce((a, b) => b.amount > a.amount ? b : a);
    if (pic.amount == 0) return [_vide(context)];

    final picIndex = points.indexOf(pic);
    final n = points.length;
    final pas = n <= 10 ? 1 : (n <= 16 ? 2 : 5);
    final largeur = n <= 7 ? 22.0 : (n <= 16 ? 12.0 : 6.0);

    final pointFort = s.monthly
        ? 'Mois le plus dépensier : ${libelleMois(pic.date)}'
        : 'Plus forte dépense du jour : ${formatDate(pic.date)}';

    return [
      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: pic.amount * 1.15,
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= n || i % pas != 0) {
                      return const SizedBox.shrink();
                    }
                    final pt = points[i];
                    final label = s.monthly
                        ? _moisCourt[pt.date.month - 1]
                        : '${pt.date.day}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 11, color: p.texteDoux),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < n; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: points[i].amount.toDouble(),
                      color: i == picIndex ? p.accent : p.principal,
                      width: largeur,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        '$pointFort · ${formatAr(pic.amount)}',
        style: TextStyle(fontSize: 12.5, color: p.texteDoux),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final plageTexte = _debut.isAtSameMomentAs(_fin)
        ? formatDate(_debut)
        : '${formatDate(_debut)} → ${formatDate(_fin)}';

    return Scaffold(
      body: FutureBuilder<PeriodStats>(
        future: _futur,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final s = snapshot.data;
          if (s == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              EnteteEcran(
                emoji: '📊',
                titre: 'Statistiques',
                sousTitre: plageTexte,
                etiquette: 'SOLDE DE LA PÉRIODE',
                montant: s.balance,
              ),
              const SizedBox(height: 10),
              _bandePeriodes(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Apparition(
                      index: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: _CarteMini(
                              emoji: '💵',
                              label: 'Revenus',
                              montant: s.income,
                              couleur: p.revenu,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CarteMini(
                              emoji: '💸',
                              label: 'Dépenses',
                              montant: s.expense,
                              couleur: p.depense,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Apparition(
                      index: 1,
                      child: TitreSection('Dépenses par catégorie'),
                    ),
                    Apparition(
                      index: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: s.expense == 0
                                ? [_vide(context)]
                                : _repartition(context, s),
                          ),
                        ),
                      ),
                    ),
                    const Apparition(
                      index: 3,
                      child: TitreSection('Évolution des dépenses'),
                    ),
                    Apparition(
                      index: 4,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: s.expense == 0
                                ? [_vide(context)]
                                : _evolution(context, s),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarteMini extends StatelessWidget {
  const _CarteMini({
    required this.emoji,
    required this.label,
    required this.montant,
    required this.couleur,
  });

  final String emoji;
  final String label;
  final int montant;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PastilleEmoji(emoji, taille: 40),
            const SizedBox(height: 14),
            Text(label, style: TextStyle(fontSize: 12.5, color: p.texteDoux)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MontantAnime(
                montant: montant,
                style: TextStyle(
                  fontFamily: AppTheme.fontTitre,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: couleur,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}