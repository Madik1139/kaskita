import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/tabular_currency_text.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/debt_models.dart';
import '../../providers/debt_provider.dart';
import 'contact_and_cap_sheets.dart';

/// Kartu Ringkasan Total Piutang vs Hutang dan Indikator Rem Piutang (Lending Cap).
class DebtOverviewHeaderCard extends StatelessWidget {
  const DebtOverviewHeaderCard({
    required this.state,
    required this.l10n,
    super.key,
  });

  final DebtsDirectoryState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final Color warningColor = AppColors.warning(context);
    final Color accentColor = AppColors.accent(context);

    return TactileCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.debtHeaderReceivablesLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: state.totalReceivables,
                          fontSize: 18,
                          semanticType: CurrencySemanticType.positive,
                          showPlusSign: state.totalReceivables > 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.debtHeaderPayablesLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        TabularCurrencyText(
                          amount: -state.totalPayables,
                          fontSize: 18,
                          semanticType: CurrencySemanticType.negative,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.lendingCapBarTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => LendingCapSheet.show(
                        context,
                        initialLimit: state.lendingCapLimit,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          children: <Widget>[
                            TabularCurrencyText(
                              amount: state.lendingCapLimit,
                              fontSize: 12,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.pencil,
                              size: 12,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.lendingCapProgress,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceSecondary(context),
                    color: state.isLendingCapExceeded
                        ? warningColor
                        : accentColor,
                  ),
                ),
                if (state.isLendingCapExceeded) ...<Widget>[
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(
                        LucideIcons.triangleAlert,
                        size: 14,
                        color: warningColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.errLendingCapExceededWarning(
                            CurrencyFormatter.format(state.lendingCapLimit),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris Kontak pada Direktori Buku Hutang beserta menu aksi Edit & Hapus.
class ContactDirectoryRow extends StatelessWidget {
  const ContactDirectoryRow({
    required this.contact,
    required this.l10n,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ContactSummaryModel contact;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = contact.netBalance > 0;
    final bool isNegative = contact.netBalance < 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
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
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.fromTrustBadge(
                        contact.trustBadge,
                        l10n: l10n,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${l10n.openDebtsCountLabel(contact.openDebtsCount)}'
                    '${contact.earliestDueDate != null ? " • ${l10n.dueDateLabel}: ${contact.earliestDueDate}" : ""}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TabularCurrencyText(
              amount: contact.netBalance,
              showPlusSign: isPositive,
              semanticType: isPositive
                  ? CurrencySemanticType.positive
                  : isNegative
                      ? CurrencySemanticType.negative
                      : CurrencySemanticType.neutral,
            ),
            PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.ellipsisVertical,
                size: 17,
                color: AppColors.textSecondary(context),
              ),
              padding: EdgeInsets.zero,
              onSelected: (String value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: <Widget>[
                      const Icon(LucideIcons.pencil, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppColors.negative(ctx),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.delete,
                        style: TextStyle(color: AppColors.negative(ctx)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

