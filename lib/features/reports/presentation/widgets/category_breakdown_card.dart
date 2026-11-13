import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/report_models.dart';

/// Kartu Rincian Persentase & Nominal Pengeluaran Konsumsi Murni per Kategori.
class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({
    required this.activePeriod,
    required this.items,
    required this.totalPureExpense,
    super.key,
  });

  final DateTime activePeriod;
  final List<CategoryBreakdownItem> items;
  final int totalPureExpense;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final String monthTitle =
        DateFormatter.fullMonthYear(activePeriod, localeCode: langCode);

    return TactileCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l10n.categoryBreakdownTitle} ($monthTitle)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (totalPureExpense > 0)
                TabularCurrencyText(
                  amount: totalPureExpense,
                  fontSize: 13,
                  semanticType: CurrencySemanticType.negative,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              l10n.emptyReportChartText,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Column(
              children: items.map((CategoryBreakdownItem item) {
                final Color barColor =
                    CategoryIconMapper.parseHexColor(item.colorHex);
                final String localizedCat =
                    LocalizationHelper.localizeCategoryName(
                  item.categoryName,
                  l10n,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            CategoryIconMapper.getIcon(item.iconName),
                            size: 15,
                            color: barColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localizedCat,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                          const SizedBox(width: 10),
                          TabularCurrencyText(
                            amount: item.totalAmount,
                            fontSize: 12.5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (item.percentage / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceSecondary(context),
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

