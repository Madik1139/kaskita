import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Header modal, pemilih mode transaksi (Pengeluaran/Pemasukan/Piutang/Hutang/Transfer),
/// serta kartu layar nominal & pemilih tanggal transaksi.
class TransactionFormHeader extends StatelessWidget {
  const TransactionFormHeader({
    required this.isEditing,
    required this.isSubmitting,
    required this.trxType,
    required this.totalWalletAmount,
    required this.trxDate,
    required this.editingFriendShare,
    required this.onSelectMode,
    required this.onOpenTransfer,
    required this.onFocusTotalAmount,
    required this.onPickTrxDate,
    required this.onDelete,
    required this.onClose,
    super.key,
  });

  final bool isEditing;
  final bool isSubmitting;
  final String trxType;
  final int totalWalletAmount;
  final DateTime trxDate;
  final bool editingFriendShare;
  final ValueChanged<String> onSelectMode;
  final VoidCallback onOpenTransfer;
  final VoidCallback onFocusTotalAmount;
  final VoidCallback onPickTrxDate;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                isEditing ? l10n.editTransactionTitle : l10n.quickInputTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (isEditing)
              IconButton(
                tooltip: l10n.delete,
                onPressed: isSubmitting ? null : onDelete,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColors.negative(context),
                ),
              ),
            IconButton(
              tooltip: l10n.close,
              onPressed: onClose,
              icon: const Icon(LucideIcons.x, size: 18),
            ),
          ],
        ),
        if (!isEditing) ...<Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _buildModeChip(l10n.modeExpense, 'EXPENSE'),
                const SizedBox(width: 6),
                _buildModeChip(l10n.modeIncome, 'INCOME'),
                const SizedBox(width: 6),
                _buildModeChip(l10n.modeReceivable, 'RECEIVABLE_OUT'),
                const SizedBox(width: 6),
                _buildModeChip(l10n.modePayable, 'DEBT_IN'),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(LucideIcons.arrowLeftRight, size: 14),
                  label: Text(l10n.modeTransfer),
                  visualDensity: VisualDensity.compact,
                  onPressed: onOpenTransfer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: onFocusTotalAmount,
          borderRadius: BorderRadius.circular(8),
          child: TactileCard(
            backgroundColor: AppColors.surfaceSecondary(context),
            borderColor: !editingFriendShare
                ? AppColors.accent(context)
                : AppColors.border(context),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.transactionAmountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onPickTrxDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              LucideIcons.calendar,
                              size: 13,
                              color: AppColors.accent(context),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                DateFormatter.mediumDate(
                                  trxDate,
                                  localeCode: langCode,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: TabularCurrencyText(
                      amount: totalWalletAmount,
                      fontSize: 28,
                      semanticType: trxType == 'INCOME'
                          ? CurrencySemanticType.positive
                          : trxType == 'EXPENSE'
                              ? CurrencySemanticType.negative
                              : CurrencySemanticType.mutation,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, String modeValue) {
    return ChoiceChip(
      label: Text(label),
      selected: trxType == modeValue,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onSelectMode(modeValue),
    );
  }
}
