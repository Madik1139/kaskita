# KasKita – Agent Workspace Rules (`AGENTS.md`)

Dokumen ini berisi aturan inti (*always-on rules*) yang **wajib** dipatuhi oleh Agent pada setiap tugas di repositori **KasKita**.

---

## 1. Prinsip Clean Code & Clean Architecture
* **Struktur *Feature-First Layered*:** Seluruh kode fitur ditempatkan di `lib/features/<nama_fitur>/` dengan pemisahan tegas antara:
  * `domain/` atau `models/` (Entitas & logika murni tanpa dependensi UI/SQLite).
  * `data/` (Repository & query SQLite `sqflite`).
  * `providers/` (State management menggunakan `flutter_riverpod`).
  * `presentation/` (Screens & Widgets).
* **Single Responsibility:** Satu file/kelas hanya memiliki satu tanggung jawab utama. Hindari *God Widget* (> 300 baris); pecah menjadi sub-widget yang terfokus.
* **Keamanan Transaksi Database (*Atomic Ledger*):** Setiap operasi tulis yang mengubah lebih dari satu tabel (misal: `transactions` + `wallets` + `debts` + `contacts`) **wajib** dieksekusi di dalam satu blok `await db.transaction((txn) async { ... })` untuk mencegah ketidakcocokan saldo.

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

