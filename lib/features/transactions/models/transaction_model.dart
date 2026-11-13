import 'package:equatable/equatable.dart';

/// Entitas transaksi lengkap beserta relasi Dompet, Kategori, dan Sub-ledger Hutang.
class TransactionItemModel extends Equatable {
  const TransactionItemModel({
    required this.id,
    required this.trxType,
    required this.totalWalletAmount,
    required this.pureConsumptionAmount,
    required this.note,
    required this.trxDate,
    this.walletId,
    this.walletName,
    this.targetWalletId,
    this.targetWalletName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.contactId,
    this.contactName,
    this.linkedDebtId,
    this.linkedDebtPrincipal = 0,
    this.linkedDebtRemaining = 0,
    this.dueDate,
    this.hasInstallments = false,
  });

  factory TransactionItemModel.fromJoinedMap(Map<String, Object?> map) {
    final int installmentCount = (map['installment_count'] as int?) ?? 0;
    final int principal = (map['debt_principal'] as int?) ?? 0;
    final int remaining = (map['debt_remaining'] as int?) ?? 0;
    return TransactionItemModel(
      id: (map['id'] as int?) ?? 0,
      walletId: map['wallet_id'] as int?,
      walletName: map['wallet_name'] as String?,
      targetWalletId: map['target_wallet_id'] as int?,
      targetWalletName: map['target_wallet_name'] as String?,
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      trxType: (map['trx_type'] as String?) ?? 'EXPENSE',
      totalWalletAmount: (map['total_wallet_amount'] as int?) ?? 0,
      pureConsumptionAmount: (map['pure_consumption_amount'] as int?) ?? 0,
      note: (map['note'] as String?) ?? '',
      trxDate: (map['trx_date'] as String?) ?? '',
      contactId: map['contact_id'] as int?,
      contactName: map['contact_name'] as String?,
      linkedDebtId: map['debt_id'] as int?,
      linkedDebtPrincipal: principal,
      linkedDebtRemaining: remaining,
      dueDate: map['due_date'] as String?,
      hasInstallments: installmentCount > 0 || (principal > 0 && remaining < principal),
    );
  }

  final int id;
  final int? walletId;
  final String? walletName;
  final int? targetWalletId;
  final String? targetWalletName;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String trxType;
  final int totalWalletAmount;
  final int pureConsumptionAmount;
  final String note;
  final String trxDate;
  final int? contactId;
  final String? contactName;
  final int? linkedDebtId;
  final int linkedDebtPrincipal;
  final int linkedDebtRemaining;
  final String? dueDate;
  final bool hasInstallments;

  /// Apakah transaksi berupa pengeluaran sekaligus menalangi teman (Split Expense).
  bool get isSplitTalangan =>
      trxType == 'EXPENSE' &&
      linkedDebtId != null &&
      totalWalletAmount > pureConsumptionAmount;

  @override
  List<Object?> get props => <Object?>[
        id,
        walletId,
        walletName,
        targetWalletId,
        targetWalletName,
        categoryId,
        categoryName,
        categoryIcon,
        trxType,
        totalWalletAmount,
        pureConsumptionAmount,
        note,
        trxDate,
        contactId,
        contactName,
        linkedDebtId,
        linkedDebtPrincipal,
        linkedDebtRemaining,
        dueDate,
        hasInstallments,
      ];
}

/// Pengelompokan transaksi per tanggal (Gaya Money Manager Realbyte).
class DailyTransactionGroupModel extends Equatable {
  const DailyTransactionGroupModel({
    required this.date,
    required this.isoDate,
    required this.totalIncome,
    required this.totalPureExpense,
    required this.items,
  });

  final DateTime date;
  final String isoDate;
  final int totalIncome;
  final int totalPureExpense;
  final List<TransactionItemModel> items;

  @override
  List<Object?> get props => <Object?>[
        date,
        isoDate,
        totalIncome,
        totalPureExpense,
        items,
      ];
}

/// Rincian mingguan di dalam satu bulan (Sub-Tab Bulanan).
class WeeklyBreakdownModel extends Equatable {
  const WeeklyBreakdownModel({
    required this.weekNumber,
    required this.startDay,
    required this.endDay,
    required this.totalIncome,
    required this.totalPureExpense,
  });

  final int weekNumber;
  final int startDay;
  final int endDay;
  final int totalIncome;
  final int totalPureExpense;

  int get netDifference => totalIncome - totalPureExpense;

  @override
  List<Object?> get props => <Object?>[
        weekNumber,
        startDay,
        endDay,
        totalIncome,
        totalPureExpense,
      ];
}

/// Rekapitulasi per bulan dalam satu tahun (Sub-Tab Bulanan).
class MonthlySummaryModel extends Equatable {
  const MonthlySummaryModel({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalPureExpense,
    required this.weeks,
  });

  final int year;
  final int month;
  final int totalIncome;
  final int totalPureExpense;
  final List<WeeklyBreakdownModel> weeks;

  int get netDifference => totalIncome - totalPureExpense;

  @override
  List<Object?> get props => <Object?>[
        year,
        month,
        totalIncome,
        totalPureExpense,
        weeks,
      ];
}

/// Opsi kontak teman untuk pemilih kontekstual Piutang / Hutang / Talangan.
class ContactOptionModel extends Equatable {
  const ContactOptionModel({
    required this.id,
    required this.name,
    required this.netBalance,
    required this.trustBadge,
  });

  factory ContactOptionModel.fromMap(Map<String, Object?> map) {
    return ContactOptionModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      netBalance: (map['net_balance'] as int?) ?? 0,
      trustBadge: (map['trust_badge'] as String?) ?? 'GOOD',
    );
  }

  final int id;
  final String name;
  final int netBalance;
  final String trustBadge;

  @override
  List<Object?> get props => <Object?>[id, name, netBalance, trustBadge];
}
