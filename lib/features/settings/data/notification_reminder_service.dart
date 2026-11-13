import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../../core/database/database_helper.dart';
import '../../../core/utils/currency_formatter.dart';

/// Layanan Notifikasi Lokal Jatuh Tempo (H-1 dan Hari-H pukul 09.00 pagi).
class NotificationReminderService {
  NotificationReminderService(this._dbHelper);

  final DatabaseHelper _dbHelper;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'kaskita_due_reminders';
  static const String _channelName = 'Pengingat Jatuh Tempo Hutang';

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tz_data.initializeTimeZones();
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const DarwinInitializationSettings darwinSettings =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: androidSettings,
            iOS: darwinSettings,
          ),
        );
      }
      _initialized = true;
    } catch (_) {
      // Aman di lingkungan unit test atau desktop tanpa channel notifikasi native
    }
  }

  /// Menjadwalkan pengingat H-1 dan Hari-H (pukul 09:00) untuk seluruh tagihan
  /// belum lunas yang memiliki tanggal jatuh tempo (`due_date`) ke depan.
  /// Mengembalikan jumlah pengingat yang dijadwalkan.
  Future<int> syncDueDateReminders({required String languageCode}) async {
    await initialize();

    final Database db = await _dbHelper.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT 
        d.id,
        d.debt_type,
        d.remaining_amount,
        d.due_date,
        d.note,
        c.name AS contact_name
      FROM debts d
      INNER JOIN contacts c ON d.contact_id = c.id
      WHERE d.status != 'PAID'
        AND d.due_date IS NOT NULL
        AND d.due_date != ''
    ''');

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _plugin.cancelAll();
      }
    } catch (_) {}

    final DateTime now = DateTime.now();
    int scheduledCount = 0;

    for (final Map<String, Object?> row in rows) {
      final int debtId = (row['id'] as int?) ?? 0;
      final String debtType = (row['debt_type'] as String?) ?? 'RECEIVABLE';
      final int remaining = (row['remaining_amount'] as int?) ?? 0;
      final String contactName = (row['contact_name'] as String?) ?? '';
      final String dueStr = (row['due_date'] as String?) ?? '';
      final DateTime? dueDate = DateTime.tryParse(dueStr);
      if (dueDate == null || remaining <= 0) {
        continue;
      }

      final DateTime hMinus1 = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - 1,
        9,
        0,
      );
      final DateTime dayD = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9,
        0,
      );

      final String amountText = CurrencyFormatter.format(remaining);
      final bool isId = languageCode == 'id';

      if (hMinus1.isAfter(now)) {
        final String title = isId
            ? 'Pengingat H-1 Jatuh Tempo'
            : 'Due Tomorrow Reminder';
        final String body = debtType == 'RECEIVABLE'
            ? (isId
                ? 'Besok jatuh tempo piutang $contactName ($amountText).'
                : 'Tomorrow $contactName owes you $amountText due.')
            : (isId
                ? 'Besok jatuh tempo hutang Anda ke $contactName ($amountText).'
                : 'Tomorrow your payable to $contactName ($amountText) is due.');
        await _scheduleAt(
          id: debtId * 10 + 1,
          when: hMinus1,
          title: title,
          body: body,
        );
        scheduledCount++;
      }

      if (dayD.isAfter(now)) {
        final String title = isId
            ? 'Jatuh Tempo Hari Ini'
            : 'Due Today Reminder';
        final String body = debtType == 'RECEIVABLE'
            ? (isId
                ? 'Hari ini jatuh tempo piutang $contactName ($amountText).'
                : 'Today $contactName owes you $amountText due.')
            : (isId
                ? 'Hari ini jatuh tempo hutang Anda ke $contactName ($amountText).'
                : 'Today your payable to $contactName ($amountText) is due.');
        await _scheduleAt(
          id: debtId * 10 + 2,
          when: dayD,
          title: title,
          body: body,
        );
        scheduledCount++;
      }
    }

    return scheduledCount;
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }
    try {
      final tz.TZDateTime tzWhen = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tzWhen,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }
}

