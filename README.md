# KasKita – Aplikasi Pencatat Keuangan & Buku Hutang Mandiri (Offline-First)

**Versi Saat Ini:** `1.1.0+8` (Rilis Pembaruan v1.1.0)  
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
- [x] Fitur Transaksi (`transactions/`): Form Catatan Layar Penuh (`+`) dengan Pilihan Grid Dompet & Kategori, Pemisahan Tanggal, Talangan Teman (*Split Expense*), Rollback Edit/Hapus, & Riwayat Kas Harian/Kalender/Bulanan
- [x] Fitur Buku Hutang (`debts/`): Kontak (Tambah/Edit/Hapus), Cicilan FIFO, *Auto-Netting* Berbasis Dompet, Lunas via Traktiran, Rem Piutang, & *Clean Invoice Receipt*
- [x] Fitur Laporan & Pengaturan (`reports/` & `settings/`): Navigasi 4 Tab Terpisah (Laporan & Pengaturan), Grafik Bulanan, Notifikasi Jatuh Tempo, Preferensi Bahasa & Tema, Manajemen Dompet & Kategori, Reset Data, PIN/Biometrik, & Backup/Restore (`.db`/`.json`/`.csv`)
- [x] Pembaruan `v1.1.0`: Form transaksi layar penuh, tab Pengaturan khusus, Edit/Hapus kontak, penajaman tab navigasi aktif, serta Uji Regresi & E2E (`flutter test`)

---

## Riwayat Versi (Versioning & Changelog)

| Versi | Tanggal | Ringkasan Perubahan |
| :--- | :--- | :--- |
| **`1.1.0+8`** | 13 Nov 2026 | **Peningkatan UI/UX & Pengaturan:** Pemisahan tab **Laporan** dan **Pengaturan** (4 tab navigasi utama), pemindahan manajemen dompet/kategori/bahasa/tema/reset data ke Pengaturan, form catat transaksi layar penuh dengan pemisah kolom tanggal serta pemilih grid dompet dan kategori, fitur ubah dan hapus kontak, perbaikan tombol simpan saldo awal, dan penajaman indikator tab navigasi aktif. |
| **`1.0.0+7`** | 13 Nov 2026 | **Rilis MVP v1.0.0:** Perbaikan tampilan responsif di layar kecil, peningkatan performa daftar transaksi, serta penambahan font offline dan ikon aplikasi. |
| **`0.6.0+6`** | 13 Nov 2026 | **Laporan & Pengaturan:** Grafik batang 6 bulan (*konsumsi murni* vs *uang tertahan di teman*), rincian pengeluaran per kategori, pengingat jatuh tempo otomatis, kunci aplikasi (PIN & biometrik), tema & bahasa persisten, backup/restore & ekspor CSV, serta cek pembaruan aplikasi. |
| **`0.5.0+5`** | 13 Nov 2026 | **Buku Hutang:** Direktori kontak dengan saldo bersih & *trust badge*, pelunasan/cicilan otomatis FIFO maupun pilih tagihan, pembatalan cicilan, potong saldo silang (*auto-netting*), pelunasan via barang/traktiran, batas aman piutang (*lending cap*), serta bagikan struk tagihan gambar. |
| **`0.4.0+4`** | 13 Nov 2026 | **Transaksi & Beranda:** Input cepat satu pintu 5 mode, fitur talangan teman (*split expense*) dengan bagi rata 50:50, tampilan beranda harian, kalender, & bulanan, serta edit/hapus transaksi dengan *rollback* otomatis. |
| **`0.3.0+3`** | 13 Nov 2026 | **Dompet & Navigasi:** Onboarding saldo awal, manajemen multi-dompet (Tunai, Bank, E-Wallet), transfer antar dompet, kelola kategori kustom, filter dompet pada kartu saldo, dan navigasi 3 tab utama. |
| **`0.2.0+2`** | 13 Nov 2026 | **Fondasi Aplikasi:** Dukungan 2 bahasa (Indonesia & Inggris), tema Light & Dark Mode, penyimpanan lokal offline, dan komponen antarmuka inti. |
| **`0.1.0+1`** | 13 Nov 2026 | **Inisialisasi Proyek:** Perancangan produk, skema database, panduan desain UI/UX, dan panduan pengguna. |
