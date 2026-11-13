import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization_helper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/tabular_currency_text.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/debt_models.dart';
import '../providers/debt_provider.dart';
import 'widgets/clean_invoice_receipt_sheet.dart';
import 'widgets/debt_settlement_sheet.dart';

/// Halaman Detail Kontak Buku Hutang:
/// Menampilkan Saldo Bersih, Trust Badge, Daftar Tagihan Aktif (FIFO),
/// Riwayat Pembayaran/Cicilan, serta tombol Struk Gambar (PNG).
class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({
    required this.contactId,
    super.key,
  });

  final int contactId;

  Future<void> _confirmCancelPayment(
    BuildContext context,
    WidgetRef ref,
    DebtPaymentModel payment,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.cancelPaymentConfirmTitle),
        content: Text(l10n.cancelPaymentConfirmSubtitle),
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
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(debtsDirectoryProvider.notifier)
            .cancelDebtPayment(payment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paymentCancelledMsg)),
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<ContactDetailStateModel> detailAsync =
        ref.watch(contactDetailProvider(contactId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactDetailTitle),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: EmptyStateView(
              icon: LucideIcons.triangleAlert,
              title: l10n.errUnexpectedUiTitle,
              subtitle: AppException.resolveError(err, l10n),
            ),
          ),
        ),
        data: (ContactDetailStateModel detail) {
          final ContactSummaryModel contact = detail.contact;
          final String statusSubtitle = contact.netBalance > 0
              ? l10n.contactStatusTheyOwe
              : contact.netBalance < 0
                  ? l10n.contactStatusIOwe
                  : l10n.contactStatusSettled;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TactileCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                contact.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (contact.phoneNote.isNotEmpty)
                                Text(
                                  contact.phoneNote,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        StatusBadge.fromTrustBadge(
                          contact.trustBadge,
                          l10n: l10n,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Text(
                      statusSubtitle,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    TabularCurrencyText(
                      amount: contact.netBalance,
                      fontSize: 28,
                      showPlusSign: contact.netBalance > 0,
                      semanticType: contact.netBalance > 0
                          ? CurrencySemanticType.positive
                          : contact.netBalance < 0
                              ? CurrencySemanticType.negative
                              : CurrencySemanticType.neutral,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: detail.activeDebts.isEmpty
                                ? null
                                : () => DebtSettlementSheet.show(
                                      context,
                                      contact: contact,
                                      activeDebts: detail.activeDebts,
                                    ),
                            icon: const Icon(LucideIcons.check, size: 16),
                            label: Text(l10n.settleOrPayBtn),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => CleanInvoiceReceiptSheet.show(
                              context,
                              detail: detail,
                            ),
                            icon: const Icon(LucideIcons.receiptText, size: 16),
                            label: Text(l10n.shareInvoiceBtn),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.activeDebtsSectionTitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              if (detail.activeDebts.isEmpty)
                TactileCard(
                  child: Text(
                    l10n.noActiveDebtsText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                TactileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0;
                          i < detail.activeDebts.length;
                          i++) ...<Widget>[
                        if (i > 0) const Divider(),
                        _ActiveDebtRow(
                          item: detail.activeDebts[i],
                          l10n: l10n,
                          onTap: () => DebtSettlementSheet.show(
                            context,
                            contact: contact,
                            activeDebts: detail.activeDebts,
                            initialSpecificDebt: detail.activeDebts[i],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentHistorySectionTitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              if (detail.paymentHistory.isEmpty)
                TactileCard(
                  child: Text(
                    l10n.noPaymentHistoryText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                TactileCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      for (int i = 0;
                          i < detail.paymentHistory.length;
                          i++) ...<Widget>[
                        if (i > 0) const Divider(),
                        ListTile(
                          dense: true,
                          title: Text(
                            detail.paymentHistory[i].note,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${detail.paymentHistory[i].paymentDate} • ${detail.paymentHistory[i].settlementMethod}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TabularCurrencyText(
                                amount: detail.paymentHistory[i].amountPaid,
                                fontSize: 13,
                                semanticType: CurrencySemanticType.mutation,
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: l10n.delete,
                                onPressed: () => _confirmCancelPayment(
                                  context,
                                  ref,
                                  detail.paymentHistory[i],
                                ),
                                icon: Icon(
                                  LucideIcons.rotateCcw,
                                  size: 15,
                                  color: AppColors.negative(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _ActiveDebtRow extends StatelessWidget {
  const _ActiveDebtRow({
    required this.item,
    required this.l10n,
    required this.onTap,
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
