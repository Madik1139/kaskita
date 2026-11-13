// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KasKita';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get switchThemeTooltip => 'Switch Light / Dark Theme';

  @override
  String get switchLanguageTooltip => 'Switch Language (ID / EN)';

  @override
  String get phase1Badge => 'v0.2.0 • PHASE 1';

  @override
  String activeWalletsCount(int count) {
    return '$count Active Wallets';
  }

  @override
  String categoriesAndContactsCount(int categories, int contacts) {
    return '$categories Categories • $contacts Contacts';
  }

  @override
  String get activeWalletBalanceLabel => 'ACTIVE WALLET BALANCE';

  @override
  String get safeToSpendLabel => 'Safe to Spend';

  @override
  String get netWorthLabel => 'Net Worth';

  @override
  String get loadDemoData => 'Load Sample Data';

  @override
  String get resetDataToZero => 'Reset Data (Rp0)';

  @override
  String get emptyTransactionsTitle => 'No Transactions Recorded Yet';

  @override
  String get emptyTransactionsSubtitle =>
      'Tap \"Load Sample Data\" above to preview Money Manager-style date grouping & Split Expense, or tap (+) below.';

  @override
  String get loadDemoDataNow => 'Load Sample Data Now';

  @override
  String get quickRecord => 'Quick Add';

  @override
  String get quickInputTitle => 'Unified Quick Input (< 5 Seconds)';

  @override
  String get transactionAmountLabel => 'TRANSACTION AMOUNT';

  @override
  String walletOutflowLabel(String walletName, String amount) {
    return '$walletName • Cash Out: $amount';
  }

  @override
  String get debtBookCategoryLabel => 'Debt Ledger';

  @override
  String get nonCashLabel => 'Non-Cash';

  @override
  String get badgeUnpaid => 'UNPAID';

  @override
  String get badgePartial => 'PARTIAL';

  @override
  String get badgePaid => 'PAID';

  @override
  String get badgeGood => 'GOOD';

  @override
  String get badgeLate => 'LATE';

  @override
  String get badgeWarning => 'WARNING';

  @override
  String get defaultWalletCash => 'Cash Wallet';

  @override
  String get catFoodDrink => 'Food & Drink';

  @override
  String get catTransportFuel => 'Transport & Fuel';

  @override
  String get catDailyShopping => 'Daily Shopping';

  @override
  String get catBillsQuota => 'Bills & Data';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catSalary => 'Salary / Wage';

  @override
  String get catBusiness => 'Business Income';

  @override
  String get catBonusGift => 'Bonus / Gift';

  @override
  String get catOtherIncome => 'Other';

  @override
  String get errUnexpectedUiTitle => 'Display Error Occurred';

  @override
  String get errUnexpectedGeneral =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errDatabaseOperation =>
      'Failed to process local database storage.';

  @override
  String get errAmountMustBePositive =>
      'Transaction amount must be greater than Rp 0.';

  @override
  String get errWalletRequired => 'Please select a wallet first.';

  @override
  String get errCategoryRequired =>
      'Please select a transaction category first.';

  @override
  String get errContactRequired => 'Please select or enter a contact name.';

  @override
  String get errTransferSameWallet =>
      'Source wallet and destination wallet cannot be the same.';

  @override
  String get errInsufficientWalletBalance =>
      'Wallet balance is insufficient for this transaction.';

  @override
  String get errSplitAmountExceedsTotal =>
      'Friend\'s split portion cannot exceed the total amount paid.';

  @override
  String get errTransactionLockedHasInstallments =>
      'This transaction already has installment records. Please cancel the related installments in the Debt Ledger before editing or deleting the original transaction.';

  @override
  String get errOverpaymentExceedsRemaining =>
      'Payment amount exceeds the remaining unpaid balance.';

  @override
  String get errDuplicateContactName =>
      'Contact name already exists. Please use a different name.';

  @override
  String errLendingCapExceededWarning(String limit) {
    return 'Warning: Total active receivables will exceed your Lending Cap ($limit).';
  }

  @override
  String get errPinInvalid => 'Incorrect PIN entered. Please try again.';

  @override
  String get errBackupRestoreFailed =>
      'Backup file is invalid or failed to restore.';

  @override
  String get errOtaCheckFailed =>
      'Failed to check for updates. Please check your internet connection.';
}
