import 'package:equatable/equatable.dart';

class LedgerPreviewItem extends Equatable {
  const LedgerPreviewItem({
    required this.id,
    required this.trxType,
    required this.totalWalletAmount,
    required this.pureConsumptionAmount,
    required this.note,
    required this.trxDate,
    this.walletName,
    this.categoryName,
  });

  factory LedgerPreviewItem.fromMap(Map<String, Object?> map) {
    return LedgerPreviewItem(
      id: (map['id'] as int?) ?? 0,
      trxType: (map['trx_type'] as String?) ?? 'EXPENSE',
      totalWalletAmount: (map['total_wallet_amount'] as int?) ?? 0,
      pureConsumptionAmount: (map['pure_consumption_amount'] as int?) ?? 0,
      note: (map['note'] as String?) ?? '-',
      trxDate: (map['trx_date'] as String?) ?? '',
      walletName: map['wallet_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  final int id;
  final String trxType;
  final int totalWalletAmount;
  final int pureConsumptionAmount;
  final String note;
  final String trxDate;
  final String? walletName;
  final String? categoryName;

  @override
  List<Object?> get props => <Object?>[
        id,
        trxType,
        totalWalletAmount,
        pureConsumptionAmount,
        note,
        trxDate,
        walletName,
        categoryName,
      ];
}

class LedgerOverviewState extends Equatable {
  const LedgerOverviewState({
    required this.walletBalance,
    required this.safeToSpend,
    required this.netWorth,
    required this.walletCount,
    required this.categoryCount,
    required this.contactCount,
    required this.recentTransactions,
  });

  final int walletBalance;
  final int safeToSpend;
  final int netWorth;
  final int walletCount;
  final int categoryCount;
  final int contactCount;
  final List<LedgerPreviewItem> recentTransactions;

  @override
  List<Object?> get props => <Object?>[
        walletBalance,
        safeToSpend,
        netWorth,
        walletCount,
        categoryCount,
        contactCount,
        recentTransactions,
      ];
}
