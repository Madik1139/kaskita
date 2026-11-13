---
name: sqlite-schema-migration
description: >-
  Prosedur wajib saat mengubah struktur tabel, menambah kolom, atau menambah tabel baru
  di SQLite (DatabaseHelper) agar data keuangan pengguna lama tidak pernah hilang (zero data loss)
  saat aplikasi di-update (termasuk lewat OTA/In-App Update) serta menjaga kompatibilitas Backup/Restore.
---

# Workflow Migrasi Skema SQLite & Kompatibilitas Data (`sqlite-schema-migration`)

Karena **KasKita** adalah aplikasi *100% Offline-First* yang menyimpan seluruh data pengguna di memori perangkat lokal, **dilarang keras** menggunakan `DROP TABLE` pada database pengguna yang sedang berjalan ketika aplikasi mengalami pembaruan versi.

Ikuti prosedur ini setiap kali ada perubahan pada skema SQLite:

## Langkah 1: Naikkan Versi Database (`dbVersion`)
1. Buka `lib/core/database/database_helper.dart` dan [docs/erd_dan_skema_database_sqlite.md](../../../docs/erd_dan_skema_database_sqlite.md).
2. Naikkan konstanta `dbVersion` sebesar `+1` (misal: dari `1` menjadi `2`).
3. Perbarui blok `onCreate` agar pengguna baru langsung mendapatkan skema versi terbaru.

## Langkah 2: Tulis Migrasi Bertahap di `onUpgrade`
1. Di dalam fungsi `onUpgrade(Database db, int oldVersion, int newVersion)`, gunakan pola *incremental `if`* (bukan `switch-case` yang tertutup) agar pengguna yang melompat beberapa versi tetap ter-upgrade dengan berurutan:
   ```dart
   if (oldVersion < 2) {
     await db.execute('ALTER TABLE contacts ADD COLUMN late_count INTEGER NOT NULL DEFAULT 0;');
   }
   if (oldVersion < 3) {
     // Migrasi ke versi 3
   }
   ```
2. Jika menambahkan kolom `NOT NULL` pada tabel yang sudah berisi data, **wajib** sertakan nilai `DEFAULT` agar `ALTER TABLE` tidak gagal di SQLite.

## Langkah 3: Jaga Kompatibilitas Backup & Restore (`.json` / `.db`)
1. Di modul *Backup & Restore*, pastikan file `.json` menyertakan metadata `schema_version`.
2. Saat melakukan *Restore* dari file `.json` versi lama:
   * Gunakan *fallback default value* pada `Model.fromMap()` (misal: `map['late_count'] as int? ?? 0`) agar file backup versi lama tetap bisa dipulihkan ke aplikasi versi baru tanpa error.

## Langkah 4: Uji Migrasi & Perbarui Dokumentasi
1. Tulis atau jalankan *unit test* untuk memastikan `fromMap()` aman terhadap nilai `null` pada kolom baru.
2. Perbarui [docs/erd_dan_skema_database_sqlite.md](../../../docs/erd_dan_skema_database_sqlite.md) agar selalu mencerminkan skema versi terbaru.

