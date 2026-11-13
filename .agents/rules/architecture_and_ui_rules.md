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
   * Fokus pada *rendering* state dan menangkap input pengguna.
   * Hindari logika kalkulasi bisnis di dalam metode `build()`.

## 2. Daftar Periksa Komponen Reusable (`lib/core/widgets/`)
Sebelum menulis widget baru di dalam `lib/features/*/presentation/widgets/`, periksa apakah fungsi tersebut bisa menggunakan atau memperluas widget di `lib/core/widgets/`:
* Apakah ini kartu kontainer? -> Gunakan `TactileCard`.
* Apakah ini menampilkan nominal uang? -> Gunakan `TabularCurrencyText`.
* Apakah ini label status/kategori? -> Gunakan `StatusBadge`.
* Apakah ini input angka? -> Gunakan `CustomNumpad`.
* Jika widget baru berpotensi dipakai di $\ge 2$ fitur berbeda, letakkan langsung di `lib/core/widgets/`, bukan di dalam folder fitur lokal.

