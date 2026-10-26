import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/emojis.dart';
import '../../core/formats.dart';
import '../../data/budgets.dart';
import '../../data/stats.dart';

const _periodes = [
  ('jour', "Aujourd'hui"),
  ('semaine', 'Cette semaine'),
  ('mois', 'Ce mois'),
  ('precedent', 'Mois précédent'),
  ('perso', 'Période personnalisée'),
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

/// Couleurs des catégories : tons bruns, caramel, terracotta et sauge.
const _couleurs = [
  AppColors.noyer,
  AppColors.caramel,
  AppColors.terracotta,
  AppColors.sauge,
  Color(0xFF8C6A4F),
  Color(0xFFD9B382),
  Color(0xFFA65E44),
  Color(0xFF7A8F6A),
  Color(0xFF5B4636),
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

  Widget _titre(String texte) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 10),
        child: Text(
          texte.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.noyer,
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  Widget _vide() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Aucune dépense sur cette période.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.noyer),
        ),
      );

  Widget _selecteurPeriode() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final p in _periodes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.$2),
                selected: _periode == p.$1,
                showCheckmark: false,
                onSelected: (_) => _choisir(p.$1),
                backgroundColor: AppColors.blanc,
                selectedColor: AppColors.noyer,
                side: const BorderSide(color: AppColors.sable),
                labelStyle: TextStyle(
                  color: _periode == p.$1 ? AppColors.blanc : AppColors.cacao,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ligneResume(String label, int montant, Color couleur) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          formatAr(montant),
          style: TextStyle(
            fontFamily: AppTheme.fontTitre,
            fontWeight: FontWeight.w600,
            color: couleur,
          ),
        ),
      ],
    );
  }

  Widget _resume(PeriodStats s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ligneResume('Revenus', s.income, AppColors.sauge),
            const Divider(height: 24),
            _ligneResume('Dépenses', s.expense, AppColors.terracotta),
            const Divider(height: 24),
            _ligneResume(
              'Solde de la période',
              s.balance,
              s.balance < 0 ? AppColors.terracotta : AppColors.cacao,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligneCategorie(int i, CategoryTotal c, int total) {
    final pct = c.amount * 100 / total;
    final pctTexte = pct < 1 ? '< 1 %' : '${pct.round()} %';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _couleurs[i % _couleurs.length],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('${emojiCategorie(c.name)} ${c.name}')),
          Text(
            formatAr(c.amount),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitre,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              pctTexte,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.noyer),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _repartition(PeriodStats s) {
    return [
      SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 70,
                borderData: FlBorderData(show: false),
                sections: [
                  for (var i = 0; i < s.categories.length; i++)
                    PieChartSectionData(
                      value: s.categories[i].amount.toDouble(),
                      color: _couleurs[i % _couleurs.length],
                      radius: 36,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.noyer),
                ),
                const SizedBox(height: 2),
                Text(
                  formatAr(s.expense),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitre,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cacao,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < s.categories.length; i++)
        _ligneCategorie(i, s.categories[i], s.expense),
    ];
  }

  List<Widget> _evolution(PeriodStats s) {
    final points = s.points;
    final pic = points.reduce((a, b) => b.amount > a.amount ? b : a);
    if (pic.amount == 0) return [_vide()];

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
                    final p = points[i];
                    final label = s.monthly
                        ? _moisCourt[p.date.month - 1]
                        : '${p.date.day}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.noyer,
                        ),
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
                      color: AppColors.noyer,
                      width: largeur,
                      borderRadius: BorderRadius.circular(2),
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
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.noyer),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plageTexte = _debut.isAtSameMomentAs(_fin)
        ? formatDate(_debut)
        : '${formatDate(_debut)} → ${formatDate(_fin)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Column(
        children: [
          _selecteurPeriode(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                plageTexte,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.noyer),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<PeriodStats>(
              future: _futur,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final s = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    _resume(s),
                    _titre('Dépenses par catégorie'),
                    if (s.expense == 0) _vide() else ..._repartition(s),
                    _titre('Évolution des dépenses'),
                    if (s.expense == 0) _vide() else ..._evolution(s),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}