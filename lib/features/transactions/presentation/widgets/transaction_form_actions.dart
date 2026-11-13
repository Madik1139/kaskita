import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../debts/providers/debt_provider.dart';
import '../../../wallets/models/category_model.dart';
import '../../../wallets/models/wallet_model.dart';
import '../../../wallets/providers/wallet_provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

/// Helper eksekusi submit, hapus, & auto-netting untuk form Transaksi.
class TransactionFormActions {
  const TransactionFormActions._();

  static int? resolveEffectiveWalletId(
    int? explicitWalletId,
    WidgetRef ref,
    List<WalletModel> wallets,
  ) =>
      explicitWalletId ??
      ref.read(selectedWalletIdProvider) ??
      (wallets.isNotEmpty ? wallets.first.id : null);

  static Future<bool> submitTransaction({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required TransactionItemModel? editingItem,
    required String trxType,
    required List<WalletModel> wallets,
    required List<CategoryModel> categories,
    required int? explicitWalletId,
    required int? explicitCategoryId,
    required int totalWalletAmount,
    required DateTime trxDate,
    required String note,
    required bool isSplitTalangan,
    required int friendShareAmount,
    required int? contactId,
    required String newContactName,
    required DateTime? dueDate,
  }) async {
    final int? walletId =
        resolveEffectiveWalletId(explicitWalletId, ref, wallets);
    if (walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errWalletRequired)),
      );
      return false;
    }

    int? effectiveCatId = explicitCategoryId;
    if (trxType == 'EXPENSE' || trxType == 'INCOME') {
      final List<CategoryModel> matching =
          categories.where((CategoryModel c) => c.type == trxType).toList();
      if (effectiveCatId == null ||
          !matching.any((CategoryModel c) => c.id == effectiveCatId)) {
        effectiveCatId = matching.isNotEmpty ? matching.first.id : null;
      }
    }

    return _runAction(
      context: context,
      l10n: l10n,
      successMessage: l10n.transactionSavedMsg,
      action: () async {
        final bool isSplit = trxType == 'EXPENSE' && isSplitTalangan;
        if (editingItem == null) {
          await ref.read(transactionsProvider.notifier).recordTransaction(
                trxType: trxType,
                walletId: walletId,
                totalWalletAmount: totalWalletAmount,
                trxDate: trxDate,
                categoryId: effectiveCatId,
                note: note,
                isSplitTalangan: isSplit,
                friendShareAmount: friendShareAmount,
                contactId: contactId,
                newContactName: newContactName,
                dueDate: dueDate,
              );
        } else {
          await ref.read(transactionsProvider.notifier).updateTransaction(
                transactionId: editingItem.id,
                walletId: walletId,
                totalWalletAmount: totalWalletAmount,
                trxDate: trxDate,
                categoryId: effectiveCatId,
                note: note,
                isSplitTalangan: isSplit,
                friendShareAmount: friendShareAmount,
                contactId: contactId,
                newContactName: newContactName,
                dueDate: dueDate,
              );
        }
        await ref.read(debtsDirectoryProvider.notifier).refresh();
      },
    );
  }

  static Future<bool> deleteTransaction({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required int transactionId,
  }) =>
      _runAction(
        context: context,
        l10n: l10n,
        successMessage: l10n.transactionDeletedMsg,
        action: () async {
          await ref
              .read(transactionsProvider.notifier)
              .deleteTransaction(transactionId);
          await ref.read(debtsDirectoryProvider.notifier).refresh();
        },
      );

  static Future<bool> applyAutoNetting({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required List<WalletModel> wallets,
    required int? explicitWalletId,
    required int? contactId,
    required String trxType,
    required int amount,
    required DateTime trxDate,
    required String note,
    required DateTime? dueDate,
    required bool nonCashOnly,
  }) async {
    if (contactId == null) return false;
    final int? walletId = nonCashOnly
        ? null
        : resolveEffectiveWalletId(explicitWalletId, ref, wallets);
    if (!nonCashOnly && walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errWalletRequired)),
      );
      return false;
    }
    return _runAction(
      context: context,
      l10n: l10n,
      successMessage: l10n.settlementSuccessMsg,
      action: () => ref
          .read(debtsDirectoryProvider.notifier)
          .recordDebtWithAutoNetting(
            contactId: contactId,
            newDebtType: trxType == 'DEBT_IN' ? 'PAYABLE' : 'RECEIVABLE',
            amount: amount,
            date: trxDate,
            walletId: walletId,
            note: note,
            dueDate: dueDate,
          ),
    );
  }

  static Future<bool> _runAction({
    required BuildContext context,
    required AppLocalizations l10n,
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.resolveError(error, l10n))),
        );
      }
      return false;
    }
  }
}
