# Aturan Detail Arsitektur & Komponen KasKita

## 1. Aturan Lapisan (*Layering Rules*)
1. **Models (`models/`):**
   * Wajib bersifat *immutable* (`final` fields) dan memiliki metode `copyWith`, `toMap()`, serta `factory fromMap(Map<String, dynamic> map)`.
   * Tidak boleh mengimpor `package:flutter/material.dart` (kecuali tipe dasar seperti `Color` jika diperlukan oleh helper).
2. **Repositories (`data/`):**
   * Bertanggung jawab penuh atas query SQLite (`sqflite`).
   * Tidak boleh menyimpan *UI state* atau memanggil `BuildContext`.
   * Wajib menggunakan `db.transaction` untuk operasi multi-tabel.
3. **Providers (`providers/`):**
   * Menggunakan `flutter_riverpod` (`Notifier` / `AsyncNotifier` / `Provider`).
   * Menjadi jembatan tunggal antara UI (`presentation/`) dan Repository (`data/`). UI dilarang memanggil SQLite secara langsung.
4. **Presentation (`presentation/` & `lib/core/widgets/`):**
   * Fokus 100% pada *rendering* state dan menangkap input pengguna.
   * **Dilarang keras** mengimpor `package:sqflite/sqflite.dart` atau `DatabaseHelper` di dalam file UI/Widget.
   * **Batas Ukuran File Proporsional:** Target ideal **150–300 baris**, dan batas maksimal **400 baris per file**. Pecah berdasarkan kesatuan fungsi (misal: pisahkan *Screen*, *Bottom Sheet*, dan *Card* utama) tanpa melakukan *over-fragmentation* (memecah menjadi terlalu banyak file mikro yang menyulitkan pembacaan).
   * Wajib menggunakan `context.l10n` (`lib/l10n/app_id.arb` & `app_en.arb`) untuk seluruh label dan `AppException.resolveError(err, context.l10n)` untuk seluruh pesan *error/validasi*.

## 2. Daftar Periksa Komponen Reusable (`lib/core/widgets/`)
Sebelum menulis widget baru di dalam `lib/features/*/presentation/widgets/`, periksa apakah fungsi tersebut bisa menggunakan atau memperluas widget di `lib/core/widgets/`:
* Apakah ini kartu kontainer? -> Gunakan `TactileCard`.
* Apakah ini menampilkan nominal uang? -> Gunakan `TabularCurrencyText`.
* Apakah ini label status/kategori? -> Gunakan `StatusBadge`.
* Apakah ini input angka? -> Gunakan `CustomNumpad`.
* Jika widget baru berpotensi dipakai di $\ge 2$ fitur berbeda, letakkan langsung di `lib/core/widgets/`, bukan di dalam folder fitur lokal.

## 3. Aturan Konfigurasi Build Platform (Android / Gradle)
* Karena proyek menggunakan `flutter_local_notifications` (`>= 22.x`) dan `local_auth`, file `android/app/build.gradle.kts` **wajib** selalu mengaktifkan:
  * `isCoreLibraryDesugaringEnabled = true` di dalam blok `compileOptions`
  * `multiDexEnabled = true` di dalam blok `defaultConfig`
  * `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` di dalam blok `dependencies`
* `MainActivity.kt` wajib mewarisi `FlutterFragmentActivity` agar autentikasi biometrik (`local_auth`) berjalan tanpa *crash*.

