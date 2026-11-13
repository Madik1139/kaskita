---
name: feature-development
description: >-
  Prosedur standar untuk membangun fitur baru atau menambahkan komponen UI di proyek KasKita.
  Gunakan skill ini setiap kali akan mengimplementasikan fitur dari PRD, menambah layar baru,
  atau membuat widget reusable.
---

# Workflow Pengembangan Fitur & Komponen (`feature-development`)

Ikuti langkah-langkah berikut secara berurutan setiap kali membangun fitur baru di **KasKita**:

## Langkah 1: Audit Komponen & Skema yang Sudah Ada
1. Periksa isi folder `lib/core/widgets/` dan `lib/features/` untuk memastikan tidak membuat duplikasi *widget*, *model*, atau *helper* yang sudah ada.
2. Baca spesifikasi fitur terkait di:
   * [prd_aplikasi_pencatat_keuangan_dan_hutang.md](../../../docs/prd_aplikasi_pencatat_keuangan_dan_hutang.md)
   * [erd_dan_skema_database_sqlite.md](../../../docs/erd_dan_skema_database_sqlite.md)
   * [spesifikasi_teknis_dan_arsitektur.md](../../../docs/spesifikasi_teknis_dan_arsitektur.md)
   * [panduan_desain_ui_ux.md](../../../docs/panduan_desain_ui_ux.md)

## Langkah 2: Implementasi Lapisan Data & Domain (Clean Architecture)
1. Buat atau perbarui **Model** (`models/`) lengkap dengan `toMap()` dan `fromMap()`.
2. Buat atau perbarui **Repository** (`data/`):
   * Pastikan setiap operasi tulis lintas tabel (`transactions`, `wallets`, `debts`, `debt_payments`, `contacts`) dibungkus dalam `await db.transaction((txn) async { ... })`.
   * Pastikan query menggunakan kolom yang sudah di-indeks agar waktu eksekusi $< 100\text{ ms}$.

## Langkah 3: Implementasi Provider (Riverpod)
1. Buat atau perbarui provider di `providers/`.
2. Ketika sebuah transaksi atau pelunasan disimpan, pastikan provider me-*refresh* state terkait secara menyeluruh (misal: memperbarui daftar transaksi, saldo dompet, sekaligus daftar buku hutang/kontak).

## Langkah 4: Implementasi UI (*Tactile Financial Ledger*)
1. Gunakan komponen bersama dari `lib/core/widgets/` (`TactileCard`, `TabularCurrencyText`, `StatusBadge`, `CustomNumpad`).
2. Jika membuat komponen UI baru yang bersifat umum, simpan di `lib/core/widgets/` dan daftarkan di `AGENTS.md`.
3. Pastikan mendukung **Light Mode** & **Dark Mode**, menggunakan border `1px solid`, tanpa gradien neon, dan angka menggunakan `FontFeature.tabularFigures()`.

## Langkah 5: Unit Testing Logika Keuangan & Sinkronisasi Dokumentasi
1. Untuk fitur yang menyentuh kalkulasi uang ($S_{\text{dompet}}, D_{\text{aman}}, W_{\text{bersih}}, B_{\text{kontak}}$), pembagian porsi *Talangan Teman*, atau algoritma *FIFO Cicilan & Auto-Netting*, buat atau perbarui **Unit Test** di folder `test/` dan jalankan `flutter test`.
2. Pastikan kode bebas dari error analisis statis (`flutter analyze`) dan tidak merusak fitur yang sudah berjalan.
3. Jika fitur baru mengubah skema database SQLite, jalankan prosedur di skill `sqlite-schema-migration`.
4. Jika fitur baru mengubah perilaku pengguna, jalankan prosedur di skill `release-and-docs-sync` untuk memperbarui `README.md` dan `docs/user_manual.typ`.

