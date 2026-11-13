# KasKita – Agent Workspace Rules (`AGENTS.md`)

Dokumen ini berisi aturan inti (*always-on rules*) yang **wajib** dipatuhi oleh Agent pada setiap tugas di repositori **KasKita**.

---

## 0. Konfirmasi & Klarifikasi Sebelum Eksekusi (*Confirm Before Build*)
* **Jangan Berasumsi Sepihak:** Sebelum mulai mengubah kode fitur, UI/UX, arsitektur, atau alur kerja yang permintaannya masih terbuka atau memiliki beberapa opsi implementasi, Agent **wajib** mengklarifikasi kebutuhan dan memastikan persetujuan pengguna terlebih dahulu.
* **Sajikan Opsi & Rekomendasi Singkat:** Jika ada ambiguitas (misal: penempatan menu baru, apakah tombol lama dihapus atau dipindah, dampak terhadap data/alur pengguna), tanyakan langsung poin-poin keputusannya (gunakan `ask_question` atau pertanyaan terstruktur yang ringkas) beserta rekomendasi terbaiknya sebelum menulis kode.
* **Kapan Langsung Jalan vs Wajib Tanya:**
  * *Wajib konfirmasi dulu:* Penambahan/perubahan fitur, tata letak UI/navigasi, skema database, penghapusan fitur yang ada, atau instruksi umum yang punya lebih dari satu tafsir.
  * *Boleh langsung dikerjakan:* Perbaikan kecil yang sudah spesifik dan eksplisit disetujui pengguna (misal: menambah satu baris ke `.gitignore`, typo yang jelas, atau mengeksekusi rencana yang baru saja disetujui).

---

## 1. Prinsip Clean Code & Clean Architecture
* **Struktur *Feature-First Layered*:** Seluruh kode fitur ditempatkan di `lib/features/<nama_fitur>/` dengan pemisahan tegas antara:
  * `domain/` atau `models/` (Entitas & logika murni tanpa dependensi UI/SQLite).
  * `data/` (Repository & query SQLite `sqflite`).
  * `providers/` (State management menggunakan `flutter_riverpod`).
  * `presentation/` (Screens & Widgets).
* **Batas Panjang Baris File yang Proporsional (Ideal <= 300, Maksimal 400 Baris) & Kohesi:**
  * Mengingat struktur pohon widget Flutter yang vertikal, target ideal per file adalah **`150–300 baris`**, dengan batas maksimal (**hard limit**) **`400 baris`**.
  * Jangan memecah file secara berlebihan (*over-fragmentation*) jika kodenya masih satu kesatuan utuh di bawah 350–400 baris.
  * Pecah file berdasarkan **batas tanggung jawab fungsional** (misal: pisahkan *Screen Utama*, *Modal Bottom Sheet*, dan *Kartu Kompleks* ke file masing-masing).
* **Pemisahan Mutlak Logic vs UI (*Zero Business Logic in UI*):**
  * File di lapisan UI (`presentation/`, `screens/`, `widgets/`, `app.dart`) **dilarang keras** mengimpor `sqflite`, memanggil `DatabaseHelper`, atau menghitung rumus saldo secara langsung.
  * Seluruh komunikasi data wajib mengikuti alur satu arah: **`UI (Widget)` -> `Provider / Notifier (Riverpod)` -> `Repository (SQLite)`**.
* **Keamanan Transaksi Database (*Atomic Ledger*):** Setiap operasi tulis yang mengubah lebih dari satu tabel (misal: `transactions` + `wallets` + `debts` + `contacts`) **wajib** dieksekusi di dalam satu blok `await db.transaction((txn) async { ... })` untuk mencegah ketidakcocokan saldo.
* **Lokalisasi Dua Bahasa (`id` & `en`) Termasuk Pesan Error:**
  * Seluruh teks UI wajib didaftarkan di `lib/l10n/app_id.arb` (Bahasa Indonesia) dan `lib/l10n/app_en.arb` (English) serta diakses melalui `context.l10n.<key>`.
  * **Dilarang keras** melempar pesan error *hardcoded* (`throw Exception('teks bahasa indonesia')`). Gunakan `throw const AppException(AppErrorCode.<kode>)` dari `lib/core/errors/app_exception.dart` dan tampilkan melalui `AppException.resolveError(error, context.l10n)` agar pesan error selalu mengikuti bahasa yang dipilih pengguna.

---

## 2. Kebijakan Komponen Reusable (*Check Before Create*)
* **Wajib Periksa Sebelum Membuat Baru:** Sebelum membuat widget UI baru (tombol, kartu, *badge*, input, *bottom sheet*, dialog), **periksa isi folder `lib/core/widgets/`** terlebih dahulu.
* **Gunakan Kembali & Perluas (*Extend, Don't Duplicate*):** Jika komponen serupa sudah ada, gunakan komponen tersebut atau tambahkan parameter opsional yang dibutuhkan.
* **Katalog Komponen Inti (`lib/core/widgets/`):**
  * `TactileCard`: Kartu ber-border tegas `1px solid` tanpa bayangan berlebihan.
  * `TabularCurrencyText`: Widget teks khusus nominal Rupiah dengan `FontFeature.tabularFigures()`.
  * `StatusBadge`: Badge untuk status hutang (`UNPAID`, `PARTIAL`, `PAID`) dan *Trust Badge* (`GOOD`, `LATE`, `WARNING`).
  * `CustomNumpad`: Keypad angka terintegrasi di *bottom sheet* beserta *quick chips* (`+10rb`, `+50rb`, `+100rb`).
  * `EmptyStateView`: Tampilan standar saat daftar transaksi/hutang masih kosong.

---

## 3. Pedoman Visual "Anti-AI-Slop" (*Tactile Financial Ledger*)
* Patuhi sepenuhnya spesifikasi di `@[docs/panduan_desain_ui_ux.md](docs/panduan_desain_ui_ux.md)`.
* **Dilarang keras** menggunakan gradien ungu/biru neon, bayangan tebal (*heavy drop shadow*), *glassmorphism* berlebihan, atau emoji pada label UI sistem.
* Selalu dukung **Light Mode** (`#F7F6F2` *Warm Alabaster*) dan **Dark Mode** (`#0E1014` *Carbon Slate*) melalui `Theme.of(context)`.

---

## 4. Pencegahan Regresi (*Zero-Regression Bugfixing*)
* Saat memperbaiki *bug* atau melakukan *troubleshooting*, gunakan skill `bugfix-and-troubleshooting` (`.agents/skills/bugfix-and-troubleshooting/SKILL.md`).
* **Analisis Dampak Silang:** Karena Kas Harian dan Buku Hutang saling terhubung, perubahan pada logika transaksi wajib diverifikasi dampaknya terhadap:
  1. Saldo Dompet Aktif ($S_{\text{dompet}}$)
  2. Dana Aman Siap Pakai ($D_{\text{aman}}$) & Kekayaan Bersih ($W_{\text{bersih}}$)
  3. Saldo Bersih Kontak ($B_{\text{kontak}}$) & Urutan FIFO Cicilan
* Selalu pastikan tidak ada error kompilasi maupun *warning* baru sebelum menyelesaikan tugas.

---

## 5. Pemeliharaan Dokumentasi, Versioning, & `.agents`
* **Update `README.md` & Versioning:** Setiap menyelesaikan fitur utama atau rilis versi, perbarui bagian *Changelog / Status Fitur* dan nomor versi di `@[README.md](README.md)`.
* **Update User Manual Typst (`docs/user_manual.typ`):** Setiap ada penambahan atau perubahan fitur yang terlihat oleh pengguna (*user-facing*), perbarui `@[docs/user_manual.typ](docs/user_manual.typ)`.
* **Evolusi `.agents`:** Jika ditemukan pola teknis berulang, solusi *troubleshooting* krusial, atau perubahan arsitektur penting, perbarui aturan di `.agents/` atau tambahkan/perbarui *skill* di `.agents/skills/` (hindari membuat skill baru untuk perubahan sepele agar konteks tetap ramping).
* **Wajib Git Commit di Setiap Akhir Fase:** Setiap kali satu fase pengerjaan selesai diuji (`flutter analyze` & `flutter test` lulus) dan dokumentasi diperbarui, **wajib melakukan `git commit` (dan `git push`)** sebelum melangkah ke fase berikutnya agar riwayat versi bersih dan mudah di-*rollback*.

