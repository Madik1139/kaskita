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
  String get phaseBadge => 'v0.3.0 • PHASE 2';

  @override
  String get navHome => 'Home';

  @override
  String get navDebtBook => 'Debt Book';

  @override
  String get navSummary => 'Summary';

  @override
  String get allWallets => 'All Wallets';

  @override
  String get addWallet => '+ Wallet';

  @override
  String get manageCategories => 'Categories';

  @override
  String get transferAction => 'Transfer';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeEwallet => 'E-Wallet';

  @override
  String get onboardingTitle => 'Set Initial Cash Wallet Balance?';

  @override
  String get onboardingSubtitle =>
      'Enter the cash amount you currently hold, or skip to start from Rp 0.';

  @override
  String get saveInitialBalance => 'Save Initial Balance';

  @override
  String get addWalletTitle => 'Add New Wallet';

  @override
  String get editWalletTitle => 'Edit Wallet';

  @override
  String get walletNameLabel => 'Wallet Name';

  @override
  String get walletNameHint => 'Example: BCA, Mandiri, GoPay';

  @override
  String get walletTypeLabel => 'Wallet Type';

  @override
  String get initialBalanceLabel => 'INITIAL WALLET BALANCE';

  @override
  String get transferTitle => 'Transfer Between Wallets';

  @override
  String get transferSubtitle =>
      'Internal balance mutation without affecting income/expense charts.';

  @override
  String get sourceWalletLabel => 'From Wallet (Source)';

  @override
  String get targetWalletLabel => 'To Wallet (Destination)';

  @override
  String get transferAmountLabel => 'TRANSFER AMOUNT';

  @override
  String get transferNoteHint =>
      'Transfer note (optional, e.g., ATM Cash Withdrawal)';

  @override
  String get transferSuccessMsg => 'Wallet transfer saved successfully.';

  @override
  String get walletSavedMsg => 'Wallet saved successfully.';

  @override
  String get categoryManagementTitle => 'Manage Cash Categories';

  @override
  String get expenseTab => 'Expense';

  @override
  String get incomeTab => 'Income';

  @override
  String get addCategoryHint => 'New custom category name...';

  @override
  String get addCategoryBtn => 'Add';

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
  String selectedWalletBalanceLabel(String walletName) {
    return 'WALLET BALANCE ($walletName)';
  }

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
      'Use the Transfer button above, add a new Wallet, or tap \"Load Sample Data\" to preview transactions.';

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
  String transferMutationLabel(String fromWallet, String toWallet) {
    return 'Transfer: $fromWallet -> $toWallet';
  }

  @override
  String get debtBookCategoryLabel => 'Debt Ledger';

  @override
  String get transferCategoryLabel => 'Cash Mutation';

  @override
  String get nonCashLabel => 'Non-Cash';

  @override
  String get tabDebtPlaceholderTitle => 'Debt Book Module (Phase 4)';

  @override
  String get tabDebtPlaceholderSubtitle =>
      'Will display contact directory, Net Balance, FIFO Installments, Auto-Netting, Settle with Item, and Image Receipt.';

  @override
  String get tabSummaryPlaceholderTitle =>
      'Reports & Settings Module (Phase 5)';

  @override
  String get tabSummaryPlaceholderSubtitle =>
      'Will display Monthly Charts, Lending Cap, PIN/Biometric Lock, Local Backup/Restore, and OTA Updates.';

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
  String get errAmountMustBePositive => 'Amount must be greater than Rp 0.';

  @override
  String get errWalletRequired => 'Please select a wallet first.';

  @override
  String get errWalletNameRequired => 'Wallet name cannot be empty.';

  @override
  String get errDuplicateWalletName =>
      'Wallet name is already in use. Please choose another name.';

  @override
  String get errCannotArchiveLastWallet =>
      'Cannot delete or archive the only active wallet.';

  @override
  String get errCategoryRequired =>
      'Please select a transaction category first.';

  @override
  String get errCategoryNameRequired => 'Category name cannot be empty.';

  @override
  String get errContactRequired => 'Please select or enter a contact name.';

  @override
  String get errTransferSameWallet =>
      'Source wallet and destination wallet cannot be the same.';

  @override
  String get errInsufficientWalletBalance =>
      'Source wallet balance is insufficient for this transaction.';

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
