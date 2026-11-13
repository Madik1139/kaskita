import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/report_models.dart';

/// Kartu Grafik Batang 6 Bulan (`fl_chart`):
/// Membandingkan Konsumsi Murni vs Uang Tertahan di Teman (Piutang).
class MonthlyComparisonChartCard extends StatelessWidget {
  const MonthlyComparisonChartCard({
    required this.points,
    super.key,
  });

  final List<MonthlyComparisonPoint> points;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final Color pureColor = AppColors.negative(context);
    final Color recColor = AppColors.positive(context);

    int maxVal = 0;
    for (final MonthlyComparisonPoint p in points) {
      maxVal = math.max(maxVal, math.max(p.pureExpense, p.receivableLent));
    }
    final double chartMaxY = maxVal <= 0 ? 100000.0 : (maxVal * 1.2);

    return TactileCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.monthlyComparisonTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _LegendDot(color: pureColor, label: l10n.legendPureExpense),
              const SizedBox(width: 14),
              _LegendDot(color: recColor, label: l10n.legendReceivablesOut),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surface(context),
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      final String label = rodIndex == 0
                          ? l10n.legendPureExpense
                          : l10n.legendReceivablesOut;
                      return BarTooltipItem(
                        '$label\n${CurrencyFormatter.format(rod.toY.round())}',
                        TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          CurrencyFormatter.formatCompact(value.round()),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary(context),
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int idx = value.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final MonthlyComparisonPoint pt = points[idx];
                        final DateTime dt = DateTime(pt.year, pt.month, 1);
                        final String mLabel =
                            DateFormat('MMM', langCode).format(dt);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            mLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(
                  points.length,
                  (int idx) {
                    final MonthlyComparisonPoint p = points[idx];
                    return BarChartGroupData(
                      x: idx,
                      barsSpace: 4,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: p.pureExpense.toDouble(),
                          width: 10,
                          color: pureColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: p.receivableLent.toDouble(),
                          width: 10,
                          color: recColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

