import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatter.dart';

/// Layanan Backup & Restore SQLite (`.json` / `.db`) serta Ekspor Laporan (`.csv`).
class BackupRestoreService {
  const BackupRestoreService(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const List<String> _orderedTables = <String>[
    'wallets',
    'categories',
    'contacts',
    'transactions',
    'debts',
    'debt_payments',
    'app_settings',
  ];

  /// Membangun string JSON terstruktur berisi seluruh data 7 tabel SQLite + versi skema.
  Future<String> buildJsonBackupString() async {
    final Database db = await _dbHelper.database;
    final Map<String, Object?> tablesData = <String, Object?>{};
    for (final String table in _orderedTables) {
      tablesData[table] = await db.query(table);
    }

    final Map<String, Object?> payload = <String, Object?>{
      'app': AppConstants.appName,
      'app_version': AppConstants.appVersion,
      'schema_version': AppConstants.dbVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': tablesData,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Memulihkan seluruh database dari string JSON dengan validasi versi skema & atomik.
  Future<void> restoreFromJsonString(String rawJson) async {
    late final Map<String, dynamic> decoded;
    try {
      final dynamic parsed = jsonDecode(rawJson);
      if (parsed is! Map<String, dynamic>) {
        throw const AppException(AppErrorCode.backupRestoreFailed);
      }
      decoded = parsed;
    } catch (_) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }

    if (decoded['app'] != AppConstants.appName) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }
    final int? schemaVersion = decoded['schema_version'] as int?;
    if (schemaVersion == null ||
        schemaVersion < 1 ||
        schemaVersion > AppConstants.dbVersion) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }

    final dynamic rawTables = decoded['tables'];
    if (rawTables is! Map<String, dynamic>) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }
    for (final String requiredTable in _orderedTables) {
      if (rawTables[requiredTable] is! List<dynamic>) {
        throw const AppException(AppErrorCode.backupRestoreFailed);
      }
    }

    final Database db = await _dbHelper.database;
    try {
      await db.transaction((Transaction txn) async {
        // Hapus urutan terbalik agar mematuhi Foreign Keys
        for (final String table in _orderedTables.reversed) {
          await txn.delete(table);
        }
        await txn.execute('DELETE FROM sqlite_sequence;');

        // Masukkan kembali data sesuai urutan relasi induk -> anak
        for (final String table in _orderedTables) {
          final List<dynamic> rows = rawTables[table] as List<dynamic>;
          for (final dynamic item in rows) {
            if (item is Map<String, dynamic>) {
              await txn.insert(
                table,
                item.map<String, Object?>(
                  (String k, dynamic v) => MapEntry<String, Object?>(k, v),
                ),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });
    } catch (_) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }
  }

  /// Membangun string laporan transaksi berformat `.csv`.
  Future<String> buildTransactionsCsv() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT 
        t.id,
        t.trx_date,
        t.trx_type,
        COALESCE(w.name, 'Non-Tunai') AS wallet_name,
        COALESCE(tw.name, '') AS target_wallet_name,
        COALESCE(c.name, 'Buku Hutang') AS category_name,
        t.total_wallet_amount,
        t.pure_consumption_amount,
        COALESCE(t.note, '') AS note
      FROM transactions t
      LEFT JOIN wallets w ON t.wallet_id = w.id
      LEFT JOIN wallets tw ON t.target_wallet_id = tw.id
      LEFT JOIN categories c ON t.category_id = c.id
      ORDER BY t.trx_date DESC, t.id DESC
    ''');

    final List<List<dynamic>> csvRows = <List<dynamic>>[
      <dynamic>[
        'ID',
        'Tanggal',
        'Tipe Transaksi',
        'Dompet Asal',
        'Dompet Tujuan',
        'Kategori',
        'Keluar/Masuk Dompet (Rp)',
        'Konsumsi/Pemasukan Murni (Rp)',
        'Catatan',
      ],
      ...rows.map((Map<String, Object?> r) {
        return <dynamic>[
          r['id'],
          r['trx_date'],
          r['trx_type'],
          r['wallet_name'],
          r['target_wallet_name'],
          r['category_name'],
          r['total_wallet_amount'],
          r['pure_consumption_amount'],
          r['note'],
        ];
      }),
    ];

    return csv.encode(csvRows);
  }

  Future<void> exportAndShareJsonBackup() async {
    final String content = await buildJsonBackupString();
    final Directory tempDir = await getTemporaryDirectory();
    final String dateTag = DateFormatter.toIsoDate(DateTime.now());
    final File outFile =
        File(p.join(tempDir.path, 'kaskita_backup_$dateTag.json'));
    await outFile.writeAsString(content, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(outFile.path)],
        text: 'KasKita Local Backup ($dateTag)',
      ),
    );
  }

  Future<void> exportAndShareDbBackup() async {
    final Database db = await _dbHelper.database;
    final Directory tempDir = await getTemporaryDirectory();
    final String dateTag = DateFormatter.toIsoDate(DateTime.now());
    final File sourceDb = File(db.path);
    if (!await sourceDb.exists()) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }
    final File copyFile =
        File(p.join(tempDir.path, 'kaskita_backup_$dateTag.db'));
    await sourceDb.copy(copyFile.path);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(copyFile.path)],
        text: 'KasKita SQLite Database Backup ($dateTag)',
      ),
    );
  }

  Future<void> exportAndShareCsvReport() async {
    final String csvContent = await buildTransactionsCsv();
    final Directory tempDir = await getTemporaryDirectory();
    final String dateTag = DateFormatter.toIsoDate(DateTime.now());
    final File outFile =
        File(p.join(tempDir.path, 'kaskita_transaksi_$dateTag.csv'));
    await outFile.writeAsString(csvContent, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(outFile.path)],
        text: 'KasKita Laporan Transaksi CSV ($dateTag)',
      ),
    );
  }

  /// Memilih file cadangan `.json` atau `.db` lalu memulihkannya.
  /// Mengembalikan `false` jika pengguna membatalkan file picker.
  Future<bool> pickAndRestoreBackupFile() async {
    final PlatformFile? pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: <String>['json', 'db'],
    );
    if (pickedFile == null) {
      return false;
    }
    final String? filePath = pickedFile.path;
    if (filePath == null) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }
    final File file = File(filePath);
    if (!await file.exists()) {
      throw const AppException(AppErrorCode.backupRestoreFailed);
    }

    if (filePath.toLowerCase().endsWith('.json')) {
      final String raw = await file.readAsString();
      await restoreFromJsonString(raw);
      return true;
    }

    if (filePath.toLowerCase().endsWith('.db')) {
      await _restoreFromDbFile(file);
      return true;
    }

    throw const AppException(AppErrorCode.backupRestoreFailed);
  }

  Future<void> _restoreFromDbFile(File sourceFile) async {
    final Database currentDb = await _dbHelper.database;
    final String targetPath = currentDb.path;
    // Validasi bahwa file adalah SQLite valid dan memiliki tabel inti KasKita
    final Database testOpen = await databaseFactory.openDatabase(
      sourceFile.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    try {
      final List<Map<String, Object?>> tables = await testOpen.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final Set<String> names = tables
          .map((Map<String, Object?> r) => (r['name'] as String?) ?? '')
          .toSet();
      if (!names.contains('wallets') || !names.contains('transactions')) {
        throw const AppException(AppErrorCode.backupRestoreFailed);
      }
    } finally {
      await testOpen.close();
    }

    await currentDb.close();
    await sourceFile.copy(targetPath);
  }
}
