import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    this.isArchived = false,
    this.createdAt = '',
  });

  factory WalletModel.fromMap(Map<String, Object?> map) {
    return WalletModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'CASH',
      initialBalance: (map['initial_balance'] as int?) ?? 0,
      currentBalance: (map['current_balance'] as int?) ?? 0,
      isArchived: ((map['is_archived'] as int?) ?? 0) == 1,
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }

  final int id;
  final String name;
  final String type; // 'CASH', 'BANK', 'EWALLET'
  final int initialBalance;
  final int currentBalance;
  final bool isArchived;
  final String createdAt;

  WalletModel copyWith({
    int? id,
    String? name,
    String? type,
    int? initialBalance,
    int? currentBalance,
    bool? isArchived,
    String? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'type': type,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        type,
        initialBalance,
        currentBalance,
        isArchived,
        createdAt,
      ];
}

/// Model perhitungan 3 Indikator Kesehatan Keuangan Utama sesuai PRD Bagian 3:
/// 1. Saldo Dompet Aktif (S_dompet)
/// 2. Dana Aman Siap Pakai (D_aman = S_dompet - H_aktif)
/// 3. Kekayaan Bersih / Net Worth (W_bersih = S_dompet + P_aktif - H_aktif)
class FinancialIndicatorsModel extends Equatable {
  const FinancialIndicatorsModel({
    required this.totalWalletBalance,
    required this.displayedWalletBalance,
    required this.activeReceivables,
    required this.activePayables,
  });

  factory FinancialIndicatorsModel.calculate({
    required List<WalletModel> wallets,
    required int activeReceivables,
    required int activePayables,
    int? selectedWalletId,
  }) {
    int total = 0;
    int selected = 0;
    for (final WalletModel w in wallets) {
      if (!w.isArchived) {
        total += w.currentBalance;
        if (selectedWalletId != null && w.id == selectedWalletId) {
          selected = w.currentBalance;
        }
      }
    }
    final int displayed = selectedWalletId != null ? selected : total;
    return FinancialIndicatorsModel(
      totalWalletBalance: total,
      displayedWalletBalance: displayed,
      activeReceivables: activeReceivables,
      activePayables: activePayables,
    );
  }

  final int totalWalletBalance;
  final int displayedWalletBalance;
  final int activeReceivables;
  final int activePayables;

  /// D_aman = S_dompet - H_aktif
  int get safeToSpend => displayedWalletBalance - activePayables;

  /// W_bersih = S_dompet (total seluruh dompet) + P_aktif - H_aktif
  int get netWorth => totalWalletBalance + activeReceivables - activePayables;

  @override
  List<Object?> get props => <Object?>[
        totalWalletBalance,
        displayedWalletBalance,
        activeReceivables,
        activePayables,
      ];
}

