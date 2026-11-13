# KasKita – Aplikasi Pencatat Keuangan & Buku Hutang Mandiri (Offline-First)

**Versi Saat Ini:** `1.0.0+7` (Rilis MVP v1.0.0 — Seluruh Fase 0–6 Selesai, End-to-End QA, Optimasi Performa `<100ms`, & Siap Rilis)  
**Platform:** Android & iOS (Flutter)  
**Penyimpanan:** 100% Lokal / *Standalone* (`SQLite`)

---

## Ringkasan Produk

**KasKita** adalah aplikasi pencatat keuangan harian dan buku hutang-piutang mandiri (*offline-first*) yang dirancang untuk menyelesaikan dua masalah utama:
1. **Memisahkan Arus Kas Dompet vs Konsumsi Riil:** Meminjamkan uang atau menalangi teman tidak lagi mengotori grafik pengeluaran bulanan Anda.
2. **Input Cepat (< 5 Detik) dengan Buku Hutang Pintar:** Satu tombol aksi (`+`) dengan *Custom Integrated Numpad* untuk mencatat pengeluaran, pemasukan, talangan makan bersama (*split expense*), cicilan otomatis (*FIFO*), potong saldo silang (*Auto-Netting*), hingga pelunasan via barang/traktiran.

---

## Arsitektur & Teknologi

* **Framework:** Flutter `3.41+` / Dart `3.11+`
* **State Management:** `flutter_riverpod` (Clean Architecture / *Feature-First Layered*)
* **Database Lokal:** `sqflite` dengan *Unified Ledger & Linked Debt Sub-ledger*
* **Gaya Desain UI/UX:** *Tactile Financial Ledger* (**Anti-AI-Slop** — mendukung *Light Mode* & *Dark Mode*, tipografi *Plus Jakarta Sans* dengan angka sejajar `tabularFigures`, dan *border* `1px solid` tegas)

---

## Struktur Dokumentasi & Konfigurasi Agent

### Dokumentasi Proyek (`docs/`)
* [PRD – Spesifikasi Kebutuhan Produk](docs/prd_aplikasi_pencatat_keuangan_dan_hutang.md)
* [ERD & Skema Database SQLite](docs/erd_dan_skema_database_sqlite.md)
* [Spesifikasi Teknis & Arsitektur](docs/spesifikasi_teknis_dan_arsitektur.md)
* [Panduan Desain UI/UX (Tactile Financial Ledger)](docs/panduan_desain_ui_ux.md)
* [Rencana Fase Pengerjaan (Roadmap MVP)](docs/rencana_fase_pengerjaan.md)
* [Buku Panduan Pengguna (Typst User Manual)](docs/user_manual.typ)

### Aturan & Skills Agent (`AGENTS.md` & `.agents/`)
* [AGENTS.md](AGENTS.md) – Aturan inti *always-on* (Clean Architecture, cek komponen reusable sebelum buat baru, *zero-regression*, sinkronisasi dokumen).
* [.agents/rules/architecture_and_ui_rules.md](.agents/rules/architecture_and_ui_rules.md) – Aturan detail pemisahan layer dan katalog komponen reusable.
* [.agents/skills/feature-development/SKILL.md](.agents/skills/feature-development/SKILL.md) – Workflow standar pembuatan fitur & komponen.
* [.agents/skills/bugfix-and-troubleshooting/SKILL.md](.agents/skills/bugfix-and-troubleshooting/SKILL.md) – Workflow *troubleshooting* dan pencegahan regresi lintas fitur (`flutter test`).
* [.agents/skills/sqlite-schema-migration/SKILL.md](.agents/skills/sqlite-schema-migration/SKILL.md) – Workflow migrasi tabel SQLite (`onUpgrade`) tanpa kehilangan data pengguna & kompatibilitas *Backup/Restore*.
* [.agents/skills/release-and-docs-sync/SKILL.md](.agents/skills/release-and-docs-sync/SKILL.md) – Workflow pembaruan versi, `README.md`, User Manual Typst, dan standar *Conventional Commits*.

---

## Cara Menjalankan Proyek

```powershell
# 1. Ambil semua dependensi paket
flutter pub get

# 2. Analisis kualitas kode
flutter analyze

# 3. Jalankan aplikasi di perangkat / emulator
flutter run

# 4. (Opsional) Kompilasi User Manual Typst menjadi PDF
typst compile docs/user_manual.typ docs/user_manual.pdf
```

---

## Status Fitur MVP

- [x] Perancangan PRD, ERD SQLite, Spesifikasi Arsitektur, & Design System
- [x] Konfigurasi Workspace `.agents` (Rules & Skills) dan User Manual Typst (beserta gambar layout aplikasi)
- [x] Lapisan Inti (`core/`): Tema Light/Dark, DatabaseHelper SQLite (`DemoDataSeeder`), CI/CD GitHub Actions, & Komponen Reusable (`TactileCard`, `CustomNumpad`, `TabularCurrencyText`, `StatusBadge`, `EmptyStateView`)
- [x] Fitur Dompet (`wallets/`): Onboarding Saldo Awal, Multi-Dompet, Kategori Kustom, & Transfer Antar Dompet
- [x] Fitur Transaksi (`transactions/`): Input Satu Pintu (`+`), Talangan Teman (*Split Expense*), Rollback Edit/Hapus, & Riwayat Kas Harian/Kalender/Bulanan
- [x] Fitur Buku Hutang (`debts/`): Kontak, Cicilan FIFO, *Auto-Netting*, Lunas via Traktiran, Rem Piutang, & *Clean Invoice Receipt*
- [x] Fitur Laporan & Pengaturan (`reports/` & `settings/`): Grafik Bulanan, Notifikasi Jatuh Tempo, PIN/Biometrik, & Backup/Restore (`.db`/`.json`/`.csv`)
- [x] Final QA (`v1.0.0`): Uji Regresi & E2E Light/Dark (`flutter test`), Optimasi Query `<100ms`, Audit Panjang File & Pemisahan Layer, serta Finalisasi Dokumentasi

---

## Riwayat Versi (Versioning & Changelog)

| Versi | Tanggal | Ringkasan Perubahan |
| :--- | :--- | :--- |
| **`1.0.0+7`** | 13 Nov 2026 | **Fase 6 Selesai (Rilis MVP `v1.0.0`):** Pengujian *End-to-End QA* (`test/phase6_e2e_qa_test.dart`) lintas Tab 1–3, Light/Dark Mode, Bahasa ID/EN, & Input Cepat `+`; perbaikan responsif *overflow* UI di layar `360dp` (`AppBar`, `PeriodSummaryHeader`, `DailyTransactionGroupCard`, `DebtDirectoryTabView`, `TransactionFormHeader`); *benchmark* performa SQLite **150 transaksi `<100ms`**; *refactoring* `TransactionRollbackHelper` & `TransactionFormHeader` agar 100% file `lib/` mematuhi batas `<= 400 baris` & nol logika SQLite di UI; serta `flutter test` lulus **23/23** dan `flutter analyze` **0 error**. |
| **`0.6.0+6`** | 13 Nov 2026 | **Fase 5 Selesai:** Implementasi modul `lib/features/reports/` dan `lib/features/settings/` (Tab 3 *Ringkasan & Pengaturan*), **Grafik Batang 6 Bulan (`fl_chart`)** membandingkan *Konsumsi Murni* vs *Uang Tertahan di Teman*, **Rincian Pengeluaran per Kategori** (% + *tabular Rupiah*), **Notifikasi Pengingat Jatuh Tempo** otomatis (H-1 & Hari-H pukul 09.00 via `flutter_local_notifications` & `timezone`), **Kunci Aplikasi (PIN 6 Digit di `FlutterSecureStorage` & Biometrik via `local_auth`)** serta persistensi Tema & Bahasa di `app_settings`, **Backup/Restore SQLite (`.json`/`.db` dengan validasi `schema_version`) & Ekspor Laporan (`.csv`)**, **Cek Update OTA GitHub Releases**, serta penambahan *unit test* Fase 5 (`flutter test` lulus 100% - 21/21 test). |
| **`0.5.0+5`** | 13 Nov 2026 | **Fase 4 Selesai:** Implementasi modul `lib/features/debts/` (Tab 2 *Buku Hutang*), **Direktori Kontak** dengan satu angka **Saldo Bersih ($B_{\text{kontak}}$)** dan evaluasi otomatis **Trust Badge (`GOOD`, `LATE`, `WARNING`)**, **Halaman Detail Kontak** dengan **Pelunasan/Cicilan Otomatis FIFO** maupun **Pilih Tagihan Spesifik**, pembatalan cicilan (*rollback*), **Saling Silang Saldo Otomatis (*Auto-Netting*)**, **Lunas via Barang/Traktiran (`ITEM_TREAT`)** beserta opsi catat ke konsumsi harian, **Indikator & Banner Peringatan Rem Piutang (*Lending Cap*)**, **Bagikan Struk Tagihan Bersih (*Clean Invoice Receipt* PNG)** via `RepaintBoundary` & `share_plus`, serta penambahan *unit/widget test* Fase 4 (`flutter test` lulus 100% - 17/17 test). |
| **`0.4.0+4`** | 13 Nov 2026 | **Fase 3 Selesai:** Implementasi modul `lib/features/transactions/`, **Input Satu Pintu (`< 5 Detik`)** dengan 5 mode (`Pengeluaran`, `Pemasukan`, `Piutang`, `Hutang`, `Transfer`), fitur **"Sekalian Talangi Teman" (*Inline Split Expense*)** beserta tombol **Bagi Rata (50:50)**, **Tampilan Beranda Gaya *Money Manager (Realbyte)*** (Navigasi Periode, Ringkasan 3 Kolom, Sub-Tab `Harian`, `Kalender` interaktif dengan `TableCalendar`, dan `Bulanan` dengan rincian mingguan *expandable*), **Edit & Hapus Transaksi dengan Rollback Otomatis** serta proteksi kunci jika sudah ada cicilan, dan penambahan *unit test* Fase 3 (`flutter test` lulus 100% - 13/13 test). |
| **`0.3.0+3`** | 13 Nov 2026 | **Fase 2 Selesai:** Implementasi modul `lib/features/wallets/` (Model, Repository, Riverpod Provider, dan UI Bottom Sheets), **Onboarding Saldo Awal Dompet Tunai**, **Manajemen Multi-Dompet (`CASH`, `BANK`, `EWALLET`)**, **Transfer Antar Dompet (`trx_type = 'TRANSFER'`)** atomik tanpa mengotori konsumsi murni, **Kelola Kategori Kustom**, **Filter Pill Dompet Interaktif pada Kartu Buku Kas Terpadu**, kerangka navigasi 3 Tab (`Beranda`, `Buku Hutang`, `Ringkasan`), serta penambahan *unit test* Fase 2 (`flutter test` lulus 100% - 10/10 test). |
| **`0.2.0+2`** | 13 Nov 2026 | **Fase 1 Selesai:** Instalasi seluruh library standar industri, konfigurasi `AndroidManifest.xml` & `FlutterFragmentActivity`, workflow CI/CD GitHub Actions (`.github/workflows/ci_and_release.yml`), penambahan visualisasi layout layar di `docs/user_manual.typ`, implementasi **Lokalisasi 2 Bahasa (`id` & `en`) beserta Pesan Error Terlokalisasi (`AppException`)**, `DatabaseHelper` SQLite (7 tabel + `DemoDataSeeder`), tema *Light/Dark* (`AppColors` & `AppTheme`), 5 komponen reusable di `lib/core/widgets/`, serta *unit/widget test* (`flutter test` lulus 100% - 7/7 test). |
| **`0.1.0+1`** | 13 Nov 2026 | Inisialisasi proyek Flutter `kaskita`, penyempurnaan skema ERD (`RECEIVABLE_SETTLE`, `PAYABLE_SETTLE`, `TRANSFER`), pembuatan dokumen arsitektur teknis & UI/UX *Tactile Financial Ledger*, setup `.agents` (Rules & Skills), serta pembuatan `docs/user_manual.typ`. |
