import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../transactions/models/transaction_model.dart';
import '../../providers/debt_provider.dart';

/// Banner pintar di Form Input Transaksi untuk:
/// 1. Peringatan Rem Piutang (Lending Cap) saat total piutang melewati batas.
/// 2. Deteksi Saldo Silang (Auto-Netting) saat mencatat hutang/piutang pada kontak bersaldo lawan.
class DebtSmartAlertBanners extends ConsumerStatefulWidget {
  const DebtSmartAlertBanners({
    required this.trxType,
    required this.isSplitTalangan,
    required this.totalWalletAmount,
    required this.friendShareAmount,
    required this.selectedContact,
    required this.onApplyAutoNetting,
    super.key,
  });

  final String trxType;
  final bool isSplitTalangan;
  final int totalWalletAmount;
  final int friendShareAmount;
  final ContactOptionModel? selectedContact;
  final void Function({required bool nonCashOnly}) onApplyAutoNetting;

  @override
  ConsumerState<DebtSmartAlertBanners> createState() =>
      _DebtSmartAlertBannersState();
}

class _DebtSmartAlertBannersState extends ConsumerState<DebtSmartAlertBanners> {
  bool _nonCashOnly = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final DebtsDirectoryState? dirState =
        ref.watch(debtsDirectoryProvider).valueOrNull;

    final int addedReceivable = widget.trxType == 'RECEIVABLE_OUT'
        ? widget.totalWalletAmount
        : (widget.trxType == 'EXPENSE' && widget.isSplitTalangan
            ? widget.friendShareAmount
            : 0);

    final bool showLendingCapWarning = dirState != null &&
        addedReceivable > 0 &&
        dirState.lendingCapLimit > 0 &&
        (dirState.totalReceivables + addedReceivable) >
            dirState.lendingCapLimit;

    final ContactOptionModel? contact = widget.selectedContact;
    final bool hasOppositeBalance = contact != null &&
        ((widget.trxType == 'DEBT_IN' && contact.netBalance > 0) ||
            (widget.trxType == 'RECEIVABLE_OUT' && contact.netBalance < 0));

    if (!showLendingCapWarning && !hasOppositeBalance) {
      return const SizedBox.shrink();
    }

    final Color warningColor = AppColors.warning(context);
    final Color mutationColor = AppColors.mutation(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showLendingCapWarning) ...<Widget>[
          const SizedBox(height: 8),
          TactileCard(
            backgroundColor: warningColor.withValues(alpha: 0.1),
            borderColor: warningColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Icon(LucideIcons.triangleAlert, size: 16, color: warningColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.errLendingCapExceededWarning(
                      CurrencyFormatter.format(dirState.lendingCapLimit),
                    ),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (hasOppositeBalance) ...<Widget>[
          const SizedBox(height: 8),
          TactileCard(
            backgroundColor: mutationColor.withValues(alpha: 0.08),
            borderColor: mutationColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      LucideIcons.arrowLeftRight,
                      size: 16,
                      color: mutationColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.autoNettingBannerTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: mutationColor,
                            ),
                          ),
                          Text(
                            l10n.autoNettingBannerSubtitle(
                              contact.name,
                              CurrencyFormatter.format(
                                contact.netBalance.abs(),
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.tonal(
                      onPressed: () =>
                          widget.onApplyAutoNetting(nonCashOnly: _nonCashOnly),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        l10n.applyAutoNettingBtn,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => setState(() => _nonCashOnly = !_nonCashOnly),
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _nonCashOnly,
                          onChanged: (bool? val) =>
                              setState(() => _nonCashOnly = val ?? false),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.autoNettingNonCashToggle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

