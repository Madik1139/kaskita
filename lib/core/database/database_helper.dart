import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../utils/date_formatter.dart';

/// Singleton DatabaseHelper untuk mengelola database SQLite lokal KasKita.
/// Mematuhi aturan Atomic Ledger dan skema di docs/erd_dan_skema_database_sqlite.md.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Membuka atau mengembalikan instance database aktif.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Digunakan khusus pada Unit Test untuk menginjeksi in-memory database (FFI).
  static void overrideForTest(Database testDb) {
    _database = testDb;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: createSchemaAndSeed,
      onUpgrade: onUpgradeDatabase,
    );
  }

  /// Membuat seluruh 7 tabel, index performa (<100ms), dan melakukan seeding awal.
  static Future<void> createSchemaAndSeed(Database db, int version) async {
    await db.transaction((Transaction txn) async {
      // 1. Tabel Dompet (wallets)
      await txn.execute('''
        CREATE TABLE wallets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('CASH', 'BANK', 'EWALLET')),
          initial_balance INTEGER NOT NULL DEFAULT 0,
          current_balance INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
        );
      ''');

      // 2. Tabel Kategori (categories)
      await txn.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('INCOME', 'EXPENSE')),
          icon_name TEXT NOT NULL,
          color_hex TEXT NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0
        );
      ''');

      // 3. Tabel Kontak Teman (contacts)
      await txn.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          phone_note TEXT,
          net_balance INTEGER NOT NULL DEFAULT 0,
          trust_badge TEXT NOT NULL DEFAULT 'GOOD' CHECK (trust_badge IN ('GOOD', 'LATE', 'WARNING')),
          late_count INTEGER NOT NULL DEFAULT 0,
          updated_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
        );
      ''');

      // 4. Tabel Transaksi Utama (transactions)
      await txn.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          wallet_id INTEGER,
          target_wallet_id INTEGER,
          category_id INTEGER,
          trx_type TEXT NOT NULL CHECK (trx_type IN (
            'EXPENSE',
            'INCOME',
            'DEBT_IN',
            'RECEIVABLE_OUT',
            'RECEIVABLE_SETTLE',
            'PAYABLE_SETTLE',
            'TRANSFER'
          )),
          total_wallet_amount INTEGER NOT NULL DEFAULT 0,
          pure_consumption_amount INTEGER NOT NULL DEFAULT 0,
          note TEXT,
          trx_date TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE SET NULL,
          FOREIGN KEY (target_wallet_id) REFERENCES wallets(id) ON DELETE SET NULL,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
        );
      ''');

      // 5. Tabel Hutang & Piutang (debts)
      await txn.execute('''
        CREATE TABLE debts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          source_transaction_id INTEGER,
          debt_type TEXT NOT NULL CHECK (debt_type IN ('RECEIVABLE', 'PAYABLE')),
          principal_amount INTEGER NOT NULL CHECK (principal_amount > 0),
          remaining_amount INTEGER NOT NULL CHECK (remaining_amount >= 0),
          status TEXT NOT NULL DEFAULT 'UNPAID' CHECK (status IN ('UNPAID', 'PARTIAL', 'PAID')),
          due_date TEXT,
          note TEXT,
          created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
          FOREIGN KEY (source_transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
        );
      ''');

      // 6. Tabel Riwayat Pelunasan / Cicilan (debt_payments)
      await txn.execute('''
        CREATE TABLE debt_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          debt_id INTEGER NOT NULL,
          payment_transaction_id INTEGER,
          settlement_method TEXT NOT NULL CHECK (settlement_method IN ('CASH', 'AUTO_NETTING', 'ITEM_TREAT')),
          amount_paid INTEGER NOT NULL CHECK (amount_paid > 0),
          payment_date TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY (debt_id) REFERENCES debts(id) ON DELETE CASCADE,
          FOREIGN KEY (payment_transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
        );
      ''');

      // 7. Tabel Pengaturan Aplikasi (app_settings)
      await txn.execute('''
        CREATE TABLE app_settings (
          setting_key TEXT PRIMARY KEY,
          setting_value TEXT NOT NULL
        );
      ''');

      // Indexes untuk performa query <100ms
      await txn.execute(
        'CREATE INDEX idx_transactions_date ON transactions(trx_date DESC);',
      );
      await txn.execute(
        'CREATE INDEX idx_transactions_type ON transactions(trx_type);',
      );
      await txn.execute(
        'CREATE INDEX idx_transactions_wallet ON transactions(wallet_id, target_wallet_id);',
      );
      await txn.execute(
        'CREATE INDEX idx_debts_contact_status ON debts(contact_id, status);',
      );
      await txn.execute(
        "CREATE INDEX idx_debts_due_date ON debts(due_date) WHERE status != 'PAID';",
      );

      // Seeding Default Wallet, Default Categories, & Default Settings
      await _seedInitialDefaults(txn);
    });
  }

  static Future<void> _seedInitialDefaults(DatabaseExecutor txn) async {
    // 1. Seed Dompet Default ("Dompet Tunai")
    await txn.insert('wallets', <String, Object?>{
      'name': 'Dompet Tunai',
      'type': 'CASH',
      'initial_balance': 0,
      'current_balance': 0,
      'is_archived': 0,
    });

    // 2. Seed 6 Kategori Pengeluaran & 4 Kategori Pemasukan Default
    for (final Map<String, Object> cat in AppConstants.defaultExpenseCategories) {
      await txn.insert('categories', cat);
    }
    for (final Map<String, Object> cat in AppConstants.defaultIncomeCategories) {
      await txn.insert('categories', cat);
    }

    // 3. Seed Pengaturan Awal
    final Map<String, String> defaultSettings = <String, String>{
      AppConstants.keyLendingCapLimit: AppConstants.defaultLendingCap.toString(),
      AppConstants.keyOnboardingPromptShown: '0',
      AppConstants.keyThemeMode: 'system',
      AppConstants.keyAppLocale: 'id',
      AppConstants.keyAppLockEnabled: '0',
    };

    for (final MapEntry<String, String> entry in defaultSettings.entries) {
      await txn.insert('app_settings', <String, Object?>{
        'setting_key': entry.key,
        'setting_value': entry.value,
      });
    }
  }

  /// Prosedur migrasi bertahap sesuai skill `.agents/skills/sqlite-schema-migration/SKILL.md`.
  static Future<void> onUpgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Disiapkan untuk migrasi versi mendatang tanpa kehilangan data pengguna
    }
  }

  /// Mengisi data simulasi (Demo Data) realistis agar pengguna/tester dapat
  /// langsung mencoba tampilan Harian/Kalender/Bulanan, Talangan, dan Buku Hutang.
  Future<void> seedDemoData() async {
    final Database db = await database;
    final DateTime now = DateTime.now();
    final String today = DateFormatter.toIsoDate(now);
    final String yesterday =
        DateFormatter.toIsoDate(now.subtract(const Duration(days: 1)));
    final String threeDaysAgo =
        DateFormatter.toIsoDate(now.subtract(const Duration(days: 3)));
    final String dueTomorrow =
        DateFormatter.toIsoDate(now.add(const Duration(days: 1)));
    final String dueOverdue =
        DateFormatter.toIsoDate(now.subtract(const Duration(days: 2)));

    await db.transaction((Transaction txn) async {
      // Reset terlebih dahulu ke kondisi bersih
      await _clearUserData(txn);

      final List<Map<String, Object?>> cashWallets = await txn.query(
        'wallets',
        where: "type = 'CASH'",
        limit: 1,
      );
      final int cashId = (cashWallets.first['id'] as int?) ?? 1;

      final List<Map<String, Object?>> allCats = await txn.query('categories');
      final int catMakanId = (allCats.firstWhere(
        (Map<String, Object?> c) => c['name'] == 'Makan & Minum',
      )['id'] as int?) ?? 1;
      final int catTransportId = (allCats.firstWhere(
        (Map<String, Object?> c) => c['name'] == 'Transport & BBM',
      )['id'] as int?) ?? 2;
      final int catGajiId = (allCats.firstWhere(
        (Map<String, Object?> c) => c['name'] == 'Gaji / Upah',
      )['id'] as int?) ?? 7;

      // Update Dompet Tunai & tambah BCA + GoPay
      await txn.update(
        'wallets',
        <String, Object?>{
          'initial_balance': 1000000,
          'current_balance': 855000,
        },
        where: 'id = ?',
        whereArgs: <Object>[cashId],
      );
      final int bcaId = await txn.insert('wallets', <String, Object?>{
        'name': 'BCA',
        'type': 'BANK',
        'initial_balance': 3000000,
        'current_balance': 2900000,
        'is_archived': 0,
      });
      final int gopayId = await txn.insert('wallets', <String, Object?>{
        'name': 'GoPay',
        'type': 'EWALLET',
        'initial_balance': 250000,
        'current_balance': 225000,
        'is_archived': 0,
      });

      // Tambah Kontak Teman
      final int rikoId = await txn.insert('contacts', <String, Object?>{
        'name': 'Riko Pratama',
        'phone_note': 'Teman Kantor',
        'net_balance': 30000,
        'trust_badge': 'GOOD',
        'late_count': 0,
      });
      final int budiId = await txn.insert('contacts', <String, Object?>{
        'name': 'Budi Santoso',
        'phone_note': '0812-3456-7890',
        'net_balance': 100000,
        'trust_badge': 'LATE',
        'late_count': 1,
      });

      // Transaksi 1: Pemasukan Gaji di BCA (3 hari lalu)
      await txn.insert('transactions', <String, Object?>{
        'wallet_id': bcaId,
        'category_id': catGajiId,
        'trx_type': 'INCOME',
        'total_wallet_amount': 500000,
        'pure_consumption_amount': 500000,
        'note': 'Bonus Proyek Mingguan',
        'trx_date': threeDaysAgo,
      });

      // Transaksi 2: Pinjamkan Uang Tunai ke Budi Rp 100.000 via BCA (Kemarin)
      final int trxPinjamBudi = await txn.insert('transactions', <String, Object?>{
        'wallet_id': bcaId,
        'category_id': null,
        'trx_type': 'RECEIVABLE_OUT',
        'total_wallet_amount': 100000,
        'pure_consumption_amount': 0,
        'note': 'Pinjamkan tunai ke Budi',
        'trx_date': yesterday,
      });
      await txn.insert('debts', <String, Object?>{
        'contact_id': budiId,
        'source_transaction_id': trxPinjamBudi,
        'debt_type': 'RECEIVABLE',
        'principal_amount': 100000,
        'remaining_amount': 100000,
        'status': 'UNPAID',
        'due_date': dueOverdue,
        'note': 'Pinjam tunai via transfer BCA',
      });

      // Transaksi 3: Makan Siang + Sekalian Talangi Riko (Hari Ini)
      // Bayar kasir Rp 60.000 -> Konsumsi pribadi Rp 30.000, Piutang Riko Rp 30.000
      final int trxTalanganRiko = await txn.insert('transactions', <String, Object?>{
        'wallet_id': cashId,
        'category_id': catMakanId,
        'trx_type': 'EXPENSE',
        'total_wallet_amount': 60000,
        'pure_consumption_amount': 30000,
        'note': 'Nasi Padang (+Talangan Riko)',
        'trx_date': today,
      });
      await txn.insert('debts', <String, Object?>{
        'contact_id': rikoId,
        'source_transaction_id': trxTalanganRiko,
        'debt_type': 'RECEIVABLE',
        'principal_amount': 30000,
        'remaining_amount': 30000,
        'status': 'UNPAID',
        'due_date': dueTomorrow,
        'note': 'Talangan Nasi Padang',
      });

      // Transaksi 4: Pengeluaran BBM Murni via GoPay (Hari Ini)
      await txn.insert('transactions', <String, Object?>{
        'wallet_id': gopayId,
        'category_id': catTransportId,
        'trx_type': 'EXPENSE',
        'total_wallet_amount': 25000,
        'pure_consumption_amount': 25000,
        'note': 'Isi Pertamax Motor',
        'trx_date': today,
      });

      await txn.update(
        'app_settings',
        <String, Object?>{'setting_value': '1'},
        where: 'setting_key = ?',
        whereArgs: <Object>[AppConstants.keyOnboardingPromptShown],
      );
    });
  }

  /// Menghapus seluruh transaksi, hutang, dan kontak serta mengembalikan dompet default ke Rp0.
  Future<void> resetAllData() async {
    final Database db = await database;
    await db.transaction((Transaction txn) async {
      await _clearUserData(txn);
    });
  }

  static Future<void> _clearUserData(DatabaseExecutor txn) async {
    await txn.delete('debt_payments');
    await txn.delete('debts');
    await txn.delete('transactions');
    await txn.delete('contacts');
    await txn.delete('wallets');
    await txn.delete('categories');
    await txn.delete('app_settings');
    await txn.execute('DELETE FROM sqlite_sequence;');
    await _seedInitialDefaults(txn);
  }
}
