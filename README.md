# KasKita – Aplikasi Pencatat Keuangan & Buku Hutang Mandiri (Offline-First)

**Versi Saat Ini:** `0.2.0+2` (Fase 1 Selesai: Fondasi Inti, Database SQLite, Tema, & Komponen Reusable)  
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
- [ ] Fitur Dompet (`wallets/`): Onboarding Saldo Awal, Multi-Dompet, & Transfer Antar Dompet
- [ ] Fitur Transaksi (`transactions/`): Input Satu Pintu (`+`), Talangan Teman (*Split Expense*), & Riwayat Kas Harian
- [ ] Fitur Buku Hutang (`debts/`): Kontak, Cicilan FIFO, *Auto-Netting*, Lunas via Traktiran, Rem Piutang, & *Clean Invoice Receipt*
- [ ] Fitur Laporan & Pengaturan (`reports/` & `settings/`): Grafik Bulanan, Notifikasi Jatuh Tempo, PIN/Biometrik, & Backup/Restore (`.db`/`.json`/`.csv`)

---

## Riwayat Versi (Versioning & Changelog)

| Versi | Tanggal | Ringkasan Perubahan |
| :--- | :--- | :--- |
| **`0.2.0+2`** | 13 Nov 2026 | **Fase 1 Selesai:** Instalasi seluruh library standar industri, konfigurasi `AndroidManifest.xml` & `FlutterFragmentActivity`, workflow CI/CD GitHub Actions (`.github/workflows/ci_and_release.yml`), penambahan visualisasi layout layar di `docs/user_manual.typ`, implementasi **Lokalisasi 2 Bahasa (`id` & `en`) beserta Pesan Error Terlokalisasi (`AppException`)**, `DatabaseHelper` SQLite (7 tabel + `DemoDataSeeder`), tema *Light/Dark* (`AppColors` & `AppTheme`), 5 komponen reusable di `lib/core/widgets/`, serta *unit/widget test* (`flutter test` lulus 100% - 7/7 test). |
| **`0.1.0+1`** | 13 Nov 2026 | Inisialisasi proyek Flutter `kaskita`, penyempurnaan skema ERD (`RECEIVABLE_SETTLE`, `PAYABLE_SETTLE`, `TRANSFER`), pembuatan dokumen arsitektur teknis & UI/UX *Tactile Financial Ledger*, setup `.agents` (Rules & Skills), serta pembuatan `docs/user_manual.typ`. |
