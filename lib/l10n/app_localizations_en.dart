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
  String get phaseBadge => 'v1.1.0';

  @override
  String get navHome => 'Home';

  @override
  String get navDebtBook => 'Debt Book';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

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
  String get resetDataToZero => 'Reset Data (Rp0)';

  @override
  String get emptyTransactionsTitle => 'No Transactions Recorded Yet';

  @override
  String get emptyTransactionsSubtitle =>
      'Tap Quick Add at the bottom right or Transfer to start recording your cash flow.';

  @override
  String get recordTransactionBtn => 'Record Transaction';

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

  @override
  String get modeExpense => 'Expense';

  @override
  String get modeIncome => 'Income';

  @override
  String get modeReceivable => 'Lend';

  @override
  String get modePayable => 'Borrow';

  @override
  String get modeTransfer => 'Transfer';

  @override
  String get selectWalletLabel => 'Wallet';

  @override
  String get selectCategoryLabel => 'Category';

  @override
  String get selectContactLabel => 'Contact';

  @override
  String get contactNameHint => 'Friend\'s name (select or type new)...';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get noDueDate => 'No Due Date';

  @override
  String get transactionDateLabel => 'Date';

  @override
  String get transactionNoteHint => 'Transaction note (optional)...';

  @override
  String get splitExpenseToggleTitle => 'Split / Advance for Friend?';

  @override
  String get splitExpenseToggleSubtitle =>
      'Separate your pure consumption from your friend\'s receivable share.';

  @override
  String get splitEqual5050 => 'Split 50:50';

  @override
  String get splitFriendShareLabel => 'Friend\'s Share (Rp)';

  @override
  String splitSummaryText(
    String walletOut,
    String pureExpense,
    String contact,
    String friendShare,
  ) {
    return 'Cash Out: $walletOut -> Your Expense: $pureExpense | $contact\'s Debt: $friendShare';
  }

  @override
  String get editTransactionTitle => 'Transaction Details & Edit';

  @override
  String get deleteTransactionConfirmTitle => 'Delete This Transaction?';

  @override
  String get deleteTransactionConfirmSubtitle =>
      'Related wallet balance and debt ledger records will be automatically rolled back.';

  @override
  String get transactionSavedMsg => 'Transaction saved successfully.';

  @override
  String get transactionDeletedMsg =>
      'Transaction deleted and balances rolled back.';

  @override
  String get subTabDaily => 'Daily';

  @override
  String get subTabCalendar => 'Calendar';

  @override
  String get subTabMonthly => 'Monthly';

  @override
  String get summaryIncomeLabel => 'Income';

  @override
  String get summaryPureExpenseLabel => 'Pure Expense';

  @override
  String get summaryNetDifferenceLabel => 'Net Flow';

  @override
  String get weeklyBreakdownLabel => 'Weekly Breakdown';

  @override
  String weekRangeLabel(int week, String startDay, String endDay) {
    return 'Week $week (Day $startDay–$endDay)';
  }

  @override
  String selectedDateTransactionsLabel(String date) {
    return 'Transactions on $date';
  }

  @override
  String get noTransactionsInPeriodTitle => 'No Transactions in This Period';

  @override
  String get noTransactionsInPeriodSubtitle =>
      'Tap Record Transaction below or + Quick Add at the bottom right to record a transaction.';

  @override
  String get trxTypeReceivableOut => 'Lent Out';

  @override
  String get trxTypeDebtIn => 'Borrowed';

  @override
  String get trxTypeReceivableSettle => 'Debt Collected';

  @override
  String get trxTypePayableSettle => 'Debt Paid';

  @override
  String get nonConsumptionBookBadge => 'Debt Ledger (Not Expense)';

  @override
  String get debtHeaderReceivablesLabel => 'Total Receivables (Owed to You)';

  @override
  String get debtHeaderPayablesLabel => 'Total Payables (You Owe)';

  @override
  String get lendingCapBarTitle => 'Receivable Lending Cap';

  @override
  String get editLendingCapTitle => 'Set Receivable Lending Cap';

  @override
  String get editLendingCapSubtitle =>
      'Show an automatic warning when total active receivables exceed this limit.';

  @override
  String get filterAllContacts => 'All';

  @override
  String get filterTheyOweMe => 'They Owe Me';

  @override
  String get filterIOweThem => 'I Owe Them';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get addContactBtn => '+ Contact';

  @override
  String get addContactTitle => 'Add New Contact';

  @override
  String get contactPhoneNoteLabel => 'WhatsApp / Short Note (Optional)';

  @override
  String get contactPhoneNoteHint => 'e.g. 0812-xxxx / Office Friend';

  @override
  String get contactSavedMsg => 'Contact saved successfully.';

  @override
  String get emptyContactsTitle => 'Debt Ledger is Empty';

  @override
  String get emptyContactsSubtitle =>
      'Record a new loan or split expense via + Quick Record, or add a friend contact.';

  @override
  String get contactStatusTheyOwe => 'RECEIVABLE • Owes You';

  @override
  String get contactStatusIOwe => 'PAYABLE • You Owe';

  @override
  String get contactStatusSettled => 'SETTLED • Net Balance Rp 0';

  @override
  String openDebtsCountLabel(int count) {
    return '$count active items';
  }

  @override
  String get contactDetailTitle => 'Contact Debt Ledger Details';

  @override
  String get settleOrPayBtn => 'Settle / Pay';

  @override
  String get shareInvoiceBtn => 'Invoice Image';

  @override
  String get activeDebtsSectionTitle => 'UNPAID ITEMS';

  @override
  String get paymentHistorySectionTitle => 'INSTALLMENT & PAYMENT HISTORY';

  @override
  String get noActiveDebtsText => 'No active unpaid items for this contact.';

  @override
  String get noPaymentHistoryText =>
      'No installment or settlement history yet.';

  @override
  String initialAndRemainingLabel(String initial, String remaining) {
    return 'Initial: $initial • Remaining: $remaining';
  }

  @override
  String get settlementSheetTitleReceivable => 'Collect Receivable Installment';

  @override
  String get settlementSheetTitlePayable => 'Pay Your Payable Installment';

  @override
  String get settlementMethodCash => 'Cash / Wallet';

  @override
  String get settlementMethodItemTreat => 'Item / Treat';

  @override
  String get allocationModeFifo => 'Automatic FIFO (Oldest First)';

  @override
  String get allocationModeSpecific => 'Select Specific Item';

  @override
  String get recordTreatAsExpenseToggle => 'Record as daily personal expense?';

  @override
  String get recordTreatAsExpenseSubtitle =>
      'If checked, the treat value is recorded in your expense report without deducting wallet balance.';

  @override
  String payFullRemainingChip(String amount) {
    return 'Pay Full ($amount)';
  }

  @override
  String get settlementSuccessMsg =>
      'Settlement / installment recorded successfully.';

  @override
  String get cancelPaymentConfirmTitle => 'Cancel This Installment?';

  @override
  String get cancelPaymentConfirmSubtitle =>
      'Remaining debt and wallet balance (if cash) will be restored.';

  @override
  String get paymentCancelledMsg =>
      'Installment cancelled and balances restored.';

  @override
  String get autoNettingBannerTitle =>
      'Opposite Balance Detected (Auto-Netting)!';

  @override
  String autoNettingBannerSubtitle(String contact, String oppositeAmount) {
    return '$contact has an opposite balance of $oppositeAmount. Offset opposite balance & record wallet mutation on Home?';
  }

  @override
  String get autoNettingNonCashToggle =>
      'Non-cash (without changing wallet balance)';

  @override
  String get applyAutoNettingBtn => 'Apply Auto-Netting';

  @override
  String get invoiceHeaderTitle => 'KASKITA • DEBT LEDGER STATEMENT';

  @override
  String invoicePrintedDate(String date) {
    return 'Printed Date: $date';
  }

  @override
  String get invoiceContactName => 'Contact Name';

  @override
  String get invoiceStatusLabel => 'Status';

  @override
  String get invoiceRemainingTotal => 'NET REMAINING BALANCE';

  @override
  String get invoiceUnpaidListTitle => 'UNPAID ITEMS BREAKDOWN:';

  @override
  String get invoiceRecentPaymentsTitle => 'RECENT PAYMENT HISTORY:';

  @override
  String get invoiceFooterText => 'Generated automatically via KasKita App';

  @override
  String get shareInvoiceActionBtn => 'Share Invoice Image (PNG)';

  @override
  String get reportSectionTitle => 'MONTHLY CHARTS & REPORTS';

  @override
  String get monthlyComparisonTitle =>
      'Pure Consumption vs Funds Held (6 Months)';

  @override
  String get legendPureExpense => 'Pure Expense';

  @override
  String get legendReceivablesOut => 'Held by Friends (Receivables)';

  @override
  String get categoryBreakdownTitle => 'Expense Breakdown by Category';

  @override
  String get emptyReportChartText =>
      'No pure expense data recorded in the selected month.';

  @override
  String get securitySectionTitle => 'SECURITY & DUE DATE REMINDERS';

  @override
  String get appLockToggleTitle => 'App Lock (6-Digit PIN & Biometrics)';

  @override
  String get appLockToggleSubtitle =>
      'Protect your financial ledger when opening the app.';

  @override
  String get changePinAction => 'Change PIN';

  @override
  String get setupPinTitle => 'Set 6-Digit Security PIN';

  @override
  String get enterPinSubtitle => 'Enter your 6-digit secret PIN.';

  @override
  String get pinSetSuccessMsg =>
      'Security PIN saved and App Lock is now active.';

  @override
  String get pinDisabledMsg => 'App Lock disabled.';

  @override
  String get lockScreenTitle => 'KasKita is Locked';

  @override
  String get lockScreenSubtitle =>
      'Enter your 6-digit PIN or use Biometrics to unlock.';

  @override
  String get unlockWithBiometricBtn => 'Unlock with Biometrics';

  @override
  String get dueReminderToggleTitle => 'Due Date Reminders (09:00 AM)';

  @override
  String get dueReminderToggleSubtitle =>
      'Schedule local notifications 1 day before and on the due date.';

  @override
  String get rescheduleRemindersBtn => 'Sync Reminders Now';

  @override
  String remindersScheduledMsg(int count) {
    return '$count due-date reminders scheduled successfully.';
  }

  @override
  String get dataBackupSectionTitle => 'LOCAL BACKUP & DATA EXPORT';

  @override
  String get exportBackupJsonBtn => 'Backup (.JSON)';

  @override
  String get exportBackupDbBtn => 'Backup (.DB)';

  @override
  String get restoreBackupBtn => 'Restore Backup (.JSON / .DB)';

  @override
  String get exportCsvBtn => 'Export Report (.CSV)';

  @override
  String get backupExportedMsg =>
      'Backup file created and ready to save or share.';

  @override
  String get backupRestoredMsg =>
      'Data restored successfully! All ledgers have been synced.';

  @override
  String get otaSectionTitle => 'APP UPDATES & ABOUT';

  @override
  String get currentVersionLabel => 'Installed Version';

  @override
  String get checkUpdateBtn => 'Check for Updates (GitHub OTA)';

  @override
  String get checkingUpdateMsg => 'Checking latest GitHub release...';

  @override
  String updateAvailableTitle(String version) {
    return 'Update Available ($version)';
  }

  @override
  String alreadyLatestVersionMsg(String version) {
    return 'You are already on the latest version ($version).';
  }

  @override
  String get downloadUpdateBtn => 'Download / Open Release';

  @override
  String get preferencesSectionTitle => 'APPEARANCE & LANGUAGE';

  @override
  String get languageSettingTitle => 'App Language';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeSettingTitle => 'Display Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get ledgerManagementSectionTitle => 'WALLET & CATEGORY MANAGEMENT';

  @override
  String get walletManagementTitle => 'Manage Wallets';

  @override
  String walletManagementSubtitle(int count) {
    return '$count active wallets • Add, edit, or archive';
  }

  @override
  String categoryManagementSubtitle(int count) {
    return '$count cash categories • Add or remove custom categories';
  }

  @override
  String get walletManagementSheetTitle => 'Manage Cash Wallets';

  @override
  String get addNewWalletBtn => 'Add New Wallet';

  @override
  String get resetDataTitle => 'Reset All Data (Rp0)';

  @override
  String get resetDataSubtitle =>
      'Delete all transactions, debts, and contacts, and reset the initial wallet to Rp 0.';

  @override
  String get resetDataConfirmTitle => 'Reset All Data to Rp 0?';

  @override
  String get resetDataConfirmSubtitle =>
      'All transactions, extra wallets, contacts, and debt records will be permanently deleted. Make sure you have backed up your data if needed.';

  @override
  String get resetDataConfirmBtn => 'Yes, Reset Data';

  @override
  String get resetDataSuccessMsg => 'All data has been reset to Rp 0.';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get selectWalletTitle => 'Select Wallet';

  @override
  String get selectCategoryTitle => 'Select Category';

  @override
  String get editContactTitle => 'Edit Contact';

  @override
  String get contactUpdatedMsg => 'Contact updated successfully.';

  @override
  String get deleteContactConfirmTitle => 'Delete This Contact?';

  @override
  String deleteContactConfirmSubtitle(String name) {
    return 'Contact $name will be deleted. Wallet transactions on Home remain intact.';
  }

  @override
  String deleteContactActiveDebtsWarning(int count) {
    return 'Warning: $count active debt/receivable items for this contact will also be deleted.';
  }

  @override
  String get contactDeletedMsg => 'Contact deleted successfully.';
}
