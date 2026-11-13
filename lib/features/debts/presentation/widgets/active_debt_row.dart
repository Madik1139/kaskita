import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/debt_models.dart';

/// Baris Tagihan Aktif pada halaman Detail Kontak.
class ActiveDebtRow extends StatelessWidget {
  const ActiveDebtRow({
    required this.item,
    required this.l10n,
    required this.onTap,
    super.key,
  });

  final DebtItemModel item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isReceivable = item.debtType == 'RECEIVABLE';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: <Widget>[
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
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      StatusBadge.fromDebtStatus(item.status, l10n: l10n),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.initialAndRemainingLabel(
                      CurrencyFormatter.format(item.principalAmount),
                      CurrencyFormatter.format(item.remainingAmount),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (item.dueDate != null && item.dueDate!.isNotEmpty)
                    Text(
                      '${l10n.dueDateLabel}: ${item.dueDate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
            TabularCurrencyText(
              amount: isReceivable
                  ? item.remainingAmount
                  : -item.remainingAmount,
              showPlusSign: isReceivable,
              semanticType: isReceivable
                  ? CurrencySemanticType.positive
                  : CurrencySemanticType.negative,
            ),
          ],
        ),
      ),
    );
  }
}

