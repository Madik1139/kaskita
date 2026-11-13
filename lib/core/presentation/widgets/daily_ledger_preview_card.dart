import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../models/ledger_summary_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tabular_currency_text.dart';
import '../../widgets/tactile_card.dart';

/// Kartu pengelompokan transaksi harian bergaya Money Manager (Realbyte).
class DailyLedgerPreviewCard extends StatelessWidget {
  const DailyLedgerPreviewCard({
    required this.date,
    required this.transactions,
    super.key,
  });

  final DateTime date;
  final List<LedgerPreviewItem> transactions;

  @override
  Widget build(BuildContext context) {
    final String langCode = context.currentLanguageCode;

    int totalIncome = 0;
    int totalPureExpense = 0;
    for (final LedgerPreviewItem item in transactions) {
      if (item.trxType == 'INCOME') {
        totalIncome += item.pureConsumptionAmount;
      } else if (item.trxType == 'EXPENSE') {
        totalPureExpense += item.pureConsumptionAmount;
      }
    }

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      DateFormatter.dayNumber(date),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: DateFormatter.shortDayName(
                        date,
                        localeCode: langCode,
                      ),
                      compact: true,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.monthYearDot(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    TabularCurrencyText(
                      amount: totalIncome,
                      fontSize: 13,
                      semanticType: CurrencySemanticType.positive,
                      showPlusSign: true,
                    ),
                    const SizedBox(width: 10),
                    TabularCurrencyText(
                      amount: -totalPureExpense,
                      fontSize: 13,
                      semanticType: CurrencySemanticType.negative,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          for (int i = 0; i < transactions.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            _TransactionPreviewRow(item: transactions[i]),
          ],
        ],
      ),
    );
  }
}

class _TransactionPreviewRow extends StatelessWidget {
  const _TransactionPreviewRow({required this.item});

  final LedgerPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isTransfer = item.trxType == 'TRANSFER';
    final String rawWalletName = item.walletName ?? l10n.nonCashLabel;
    final String walletName =
        LocalizationHelper.localizeWalletName(rawWalletName, l10n);
    final String targetWalletName = item.targetWalletName != null
        ? LocalizationHelper.localizeWalletName(item.targetWalletName!, l10n)
        : '';
    final String categoryName = isTransfer
        ? l10n.transferCategoryLabel
        : LocalizationHelper.localizeCategoryName(
            item.categoryName,
            l10n,
          );

    final bool isIncome = item.trxType == 'INCOME';
    final bool isExpense = item.trxType == 'EXPENSE';
    final bool hasSplitTalangan =
        isExpense && item.totalWalletAmount > item.pureConsumptionAmount;

    final String subtitleText = isTransfer
        ? l10n.transferMutationLabel(walletName, targetWalletName)
        : hasSplitTalangan
            ? l10n.walletOutflowLabel(
                walletName,
                CurrencyFormatter.format(item.totalWalletAmount),
              )
            : '$walletName • ${item.trxDate}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TabularCurrencyText(
            amount: isIncome
                ? item.pureConsumptionAmount
                : isExpense
                    ? -item.pureConsumptionAmount
                    : item.totalWalletAmount,
            showPlusSign: isIncome,
            semanticType: isIncome
                ? CurrencySemanticType.positive
                : isExpense
                    ? CurrencySemanticType.negative
                    : CurrencySemanticType.mutation,
          ),
        ],
      ),
    );
  }
}

