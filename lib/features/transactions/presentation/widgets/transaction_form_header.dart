import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Bagian atas form Transaksi:
/// - Pemilih Mode Transaksi (tanpa geser horizontal)
/// - Field Tanggal terpisah (dengan tombol cepat Hari Ini / Kemarin & kalender)
/// - Field Nominal terpisah
class TransactionFormHeader extends StatelessWidget {
  const TransactionFormHeader({
    required this.isEditing,
    required this.trxType,
    required this.totalWalletAmount,
    required this.trxDate,
    required this.isAmountFocused,
    required this.onSelectMode,
    required this.onOpenTransfer,
    required this.onFocusTotalAmount,
    required this.onPickTrxDate,
    required this.onSelectQuickDate,
    super.key,
  });

  final bool isEditing;
  final String trxType;
  final int totalWalletAmount;
  final DateTime trxDate;
  final bool isAmountFocused;
  final ValueChanged<String> onSelectMode;
  final VoidCallback onOpenTransfer;
  final VoidCallback onFocusTotalAmount;
  final VoidCallback onPickTrxDate;
  final ValueChanged<DateTime> onSelectQuickDate;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String langCode = context.currentLanguageCode;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final bool isToday = _isSameDay(trxDate, today);
    final bool isYesterday = _isSameDay(trxDate, yesterday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!isEditing) ...<Widget>[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _buildModeChip(l10n.modeExpense, 'EXPENSE'),
              _buildModeChip(l10n.modeIncome, 'INCOME'),
              _buildModeChip(l10n.modeReceivable, 'RECEIVABLE_OUT'),
              _buildModeChip(l10n.modePayable, 'DEBT_IN'),
              ActionChip(
                avatar: const Icon(LucideIcons.arrowLeftRight, size: 14),
                label: Text(l10n.modeTransfer),
                visualDensity: VisualDensity.compact,
                onPressed: onOpenTransfer,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        // Field Tanggal Terpisah
        TactileCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: onPickTrxDate,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        LucideIcons.calendar,
                        size: 17,
                        color: AppColors.accent(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.transactionDateLabel.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              DateFormatter.mediumDate(
                                trxDate,
                                localeCode: langCode,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _QuickDatePill(
                label: l10n.dateYesterday,
                selected: isYesterday,
                onTap: () => onSelectQuickDate(yesterday),
              ),
              const SizedBox(width: 4),
              _QuickDatePill(
                label: l10n.dateToday,
                selected: isToday,
                onTap: () => onSelectQuickDate(today),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Field Nominal Terpisah
        InkWell(
          onTap: onFocusTotalAmount,
          borderRadius: BorderRadius.circular(8),
          child: TactileCard(
            backgroundColor: AppColors.surfaceSecondary(context),
            borderColor: isAmountFocused
                ? AppColors.accent(context)
                : AppColors.border(context),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.transactionAmountLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isAmountFocused
                            ? AppColors.accent(context)
                            : AppColors.textSecondary(context),
                      ),
                ),
                const SizedBox(width: 12),
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

class _QuickDatePill extends StatelessWidget {
  const _QuickDatePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.14)
              : AppColors.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? accent : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}
