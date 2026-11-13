import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_form_sheet.dart';

/// Kartu Pengelompokan Harian (Daily Grouped Ledger) bergaya Money Manager.
class DailyTransactionGroupCard extends ConsumerWidget {
  const DailyTransactionGroupCard({
    required this.group,
    super.key,
  });

  final DailyTransactionGroupModel group;

  Future<void> _handleRowTap(
    BuildContext context,
    WidgetRef ref,
    TransactionItemModel item,
  ) async {
    if (item.trxType == 'TRANSFER' ||
        item.trxType == 'RECEIVABLE_SETTLE' ||
        item.trxType == 'PAYABLE_SETTLE') {
      final AppLocalizations l10n = context.l10n;
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          title: Text(l10n.deleteTransactionConfirmTitle),
          content: Text(l10n.deleteTransactionConfirmSubtitle),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (shouldDelete == true && context.mounted) {
        try {
          await ref
              .read(transactionsProvider.notifier)
              .deleteTransaction(item.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.transactionDeletedMsg)),
            );
          }
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppException.resolveError(error, l10n))),
            );
          }
        }
      }
      return;
    }

    await TransactionFormSheet.show(context, editingItem: item);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String langCode = context.currentLanguageCode;

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
                      DateFormatter.dayNumber(group.date),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: DateFormatter.shortDayName(
                        group.date,
                        localeCode: langCode,
                      ),
                      compact: true,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.monthYearDot(group.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TabularCurrencyText(
                            amount: group.totalIncome,
                            fontSize: 13,
                            semanticType: CurrencySemanticType.positive,
                            showPlusSign: true,
                          ),
                          const SizedBox(width: 10),
                          TabularCurrencyText(
                            amount: -group.totalPureExpense,
                            fontSize: 13,
                            semanticType: CurrencySemanticType.negative,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          for (int i = 0; i < group.items.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            _TransactionItemRow(
              item: group.items[i],
              onTap: () => _handleRowTap(context, ref, group.items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionItemRow extends StatelessWidget {
  const _TransactionItemRow({
    required this.item,
    required this.onTap,
  });

  final TransactionItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isTransfer = item.trxType == 'TRANSFER';
    final bool isIncome = item.trxType == 'INCOME';
    final bool isExpense = item.trxType == 'EXPENSE';

    final String rawWalletName = item.walletName ?? l10n.nonCashLabel;
    final String walletName =
        LocalizationHelper.localizeWalletName(rawWalletName, l10n);
    final String targetWalletName = item.targetWalletName != null
        ? LocalizationHelper.localizeWalletName(item.targetWalletName!, l10n)
        : '';

    String categoryLabel;
    if (isTransfer) {
      categoryLabel = l10n.transferCategoryLabel;
    } else if (item.trxType == 'RECEIVABLE_OUT') {
      categoryLabel = l10n.trxTypeReceivableOut;
    } else if (item.trxType == 'DEBT_IN') {
      categoryLabel = l10n.trxTypeDebtIn;
    } else if (item.trxType == 'RECEIVABLE_SETTLE') {
      categoryLabel = l10n.trxTypeReceivableSettle;
    } else if (item.trxType == 'PAYABLE_SETTLE') {
      categoryLabel = l10n.trxTypePayableSettle;
    } else {
      categoryLabel = LocalizationHelper.localizeCategoryName(
        item.categoryName,
        l10n,
      );
    }

    String subtitleText;
    if (isTransfer) {
      subtitleText = l10n.transferMutationLabel(walletName, targetWalletName);
    } else if (item.isSplitTalangan) {
      subtitleText = l10n.walletOutflowLabel(
        walletName,
        CurrencyFormatter.format(item.totalWalletAmount),
      );
    } else if (!isIncome && !isExpense) {
      final String contactPart =
          (item.contactName != null && item.contactName!.isNotEmpty)
              ? '${item.contactName} • '
              : '';
      subtitleText =
          '$walletName • $contactPart${l10n.nonConsumptionBookBadge}';
    } else {
      subtitleText = walletName;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 96,
              child: Text(
                categoryLabel,
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
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          item.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      if (item.hasInstallments) ...<Widget>[
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.lock,
                          size: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

