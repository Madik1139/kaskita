import 'package:equatable/equatable.dart';

/// Entitas ringkasan Kontak Teman di Buku Hutang beserta evaluasi Trust Badge.
class ContactSummaryModel extends Equatable {
  const ContactSummaryModel({
    required this.id,
    required this.name,
    required this.phoneNote,
    required this.netBalance,
    required this.trustBadge,
    required this.lateCount,
    this.openDebtsCount = 0,
    this.earliestDueDate,
    this.maxOverdueDays = 0,
  });

  factory ContactSummaryModel.fromJoinedMap(
    Map<String, Object?> map, {
    DateTime? referenceDate,
  }) {
    final int lateCount = (map['late_count'] as int?) ?? 0;
    final String? earliestDue = map['earliest_due_date'] as String?;
    int overdueDays = 0;
    if (earliestDue != null && earliestDue.isNotEmpty) {
      final DateTime? due = DateTime.tryParse(earliestDue);
      if (due != null) {
        final DateTime now = referenceDate ?? DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime dueDay = DateTime(due.year, due.month, due.day);
        final int diff = today.difference(dueDay).inDays;
        if (diff > 0) {
          overdueDays = diff;
        }
      }
    }

    final String evaluatedBadge = evaluateTrustBadge(
      maxOverdueDays: overdueDays,
      lateCount: lateCount,
    );

    return ContactSummaryModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      phoneNote: (map['phone_note'] as String?) ?? '',
      netBalance: (map['net_balance'] as int?) ?? 0,
      trustBadge: evaluatedBadge,
      lateCount: lateCount,
      openDebtsCount: (map['open_debts_count'] as int?) ?? 0,
      earliestDueDate: earliestDue,
      maxOverdueDays: overdueDays,
    );
  }

  final int id;
  final String name;
  final String phoneNote;
  final int netBalance;
  final String trustBadge;
  final int lateCount;
  final int openDebtsCount;
  final String? earliestDueDate;
  final int maxOverdueDays;

  bool get isOverdue => maxOverdueDays > 0;

  /// Evaluasi otomatis Trust Badge sesuai aturan PRD:
  /// - `WARNING`: lewat jatuh tempo > 7 hari ATAU `late_count > 2`
  /// - `LATE`: lewat jatuh tempo 1–7 hari
  /// - `GOOD`: selain kondisi di atas
  static String evaluateTrustBadge({
    required int maxOverdueDays,
    required int lateCount,
  }) {
    if (maxOverdueDays > 7 || lateCount > 2) {
      return 'WARNING';
    }
    if (maxOverdueDays >= 1) {
      return 'LATE';
    }
    return 'GOOD';
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        phoneNote,
        netBalance,
        trustBadge,
        lateCount,
        openDebtsCount,
        earliestDueDate,
        maxOverdueDays,
      ];
}

/// Entitas item tagihan di tabel `debts`.
class DebtItemModel extends Equatable {
  const DebtItemModel({
    required this.id,
    required this.contactId,
    required this.debtType,
    required this.principalAmount,
    required this.remainingAmount,
    required this.status,
    required this.note,
    required this.createdAt,
    this.sourceTransactionId,
    this.dueDate,
  });

  factory DebtItemModel.fromMap(Map<String, Object?> map) {
    return DebtItemModel(
      id: (map['id'] as int?) ?? 0,
      contactId: (map['contact_id'] as int?) ?? 0,
      sourceTransactionId: map['source_transaction_id'] as int?,
      debtType: (map['debt_type'] as String?) ?? 'RECEIVABLE',
      principalAmount: (map['principal_amount'] as int?) ?? 0,
      remainingAmount: (map['remaining_amount'] as int?) ?? 0,
      status: (map['status'] as String?) ?? 'UNPAID',
      dueDate: map['due_date'] as String?,
      note: (map['note'] as String?) ?? '',
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }

  final int id;
  final int contactId;
  final int? sourceTransactionId;
  final String debtType; // 'RECEIVABLE' | 'PAYABLE'
  final int principalAmount;
  final int remainingAmount;
  final String status; // 'UNPAID' | 'PARTIAL' | 'PAID'
  final String? dueDate;
  final String note;
  final String createdAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        contactId,
        sourceTransactionId,
        debtType,
        principalAmount,
        remainingAmount,
        status,
        dueDate,
        note,
        createdAt,
      ];
}

/// Entitas riwayat pembayaran/cicilan di tabel `debt_payments`.
class DebtPaymentModel extends Equatable {
  const DebtPaymentModel({
    required this.id,
    required this.debtId,
    required this.settlementMethod,
    required this.amountPaid,
    required this.paymentDate,
    required this.note,
    this.paymentTransactionId,
    this.debtNote,
  });

  factory DebtPaymentModel.fromMap(Map<String, Object?> map) {
    return DebtPaymentModel(
      id: (map['id'] as int?) ?? 0,
      debtId: (map['debt_id'] as int?) ?? 0,
      paymentTransactionId: map['payment_transaction_id'] as int?,
      settlementMethod: (map['settlement_method'] as String?) ?? 'CASH',
      amountPaid: (map['amount_paid'] as int?) ?? 0,
      paymentDate: (map['payment_date'] as String?) ?? '',
      note: (map['note'] as String?) ?? '',
      debtNote: map['debt_note'] as String?,
    );
  }

  final int id;
  final int debtId;
  final int? paymentTransactionId;
  final String settlementMethod; // 'CASH' | 'AUTO_NETTING' | 'ITEM_TREAT'
  final int amountPaid;
  final String paymentDate;
  final String note;
  final String? debtNote;

  @override
  List<Object?> get props => <Object?>[
        id,
        debtId,
        paymentTransactionId,
        settlementMethod,
        amountPaid,
        paymentDate,
        note,
        debtNote,
      ];
}

/// Data lengkap halaman Detail Kontak.
class ContactDetailStateModel extends Equatable {
  const ContactDetailStateModel({
    required this.contact,
    required this.activeDebts,
    required this.paymentHistory,
  });

  final ContactSummaryModel contact;
  final List<DebtItemModel> activeDebts;
  final List<DebtPaymentModel> paymentHistory;

  @override
  List<Object?> get props => <Object?>[
        contact,
        activeDebts,
        paymentHistory,
      ];
}

