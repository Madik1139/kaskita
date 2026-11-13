---
name: bugfix-and-troubleshooting
description: >-
  Prosedur sistematis untuk mencari akar masalah (troubleshooting) dan memperbaiki bug di KasKita
  tanpa menimbulkan bug baru (zero-regression). Gunakan skill ini saat memperbaiki error,
  ketidakcocokan saldo, atau masalah UI/state.
---

# Workflow Perbaikan Bug & Pencegahan Regresi (`bugfix-and-troubleshooting`)

Gunakan prosedur ini setiap kali memperbaiki *bug* atau melakukan *troubleshooting*:

## Langkah 1: Isolasi Akar Masalah (*Root Cause Analysis*)
1. Identifikasi lapisan tempat *bug* terjadi:
   * **Database/Query SQLite:** Apakah karena kurang `db.transaction`, salah tanda `+/-` pada `current_balance`, atau `NULL` handling?
   * **State/Riverpod:** Apakah karena provider terkait belum di-*invalidate* / di-*refresh* setelah mutasi data?
   * **UI/Presentation:** Apakah karena masalah tema Light/Dark, *overflow* pada layar kecil, atau *formatting* angka?
2. Jangan menambal gejala di lapisan UI jika akar masalahnya berada di Repository atau kalkulasi saldo.

## Langkah 2: Matriks Cek Dampak Silang (*Cross-Feature Impact Check*)
Sebelum menerapkan perbaikan pada logika keuangan/database, periksa dampaknya terhadap 5 skenario inti:
1. **Pengeluaran / Pemasukan Murni:** Apakah `total_wallet_amount` dan `pure_consumption_amount` tetap sinkron?
2. **Talangan Teman (*Split Expense*):** Apakah dompet berkurang sebesar total bayar kasir, namun grafik konsumsi hanya bertambah sebesar porsi pribadi?
3. **Cicilan FIFO & *Auto-Netting*:** Apakah pemotongan saldo tetap memprioritaskan tagihan terlama (`ORDER BY created_at ASC, id ASC`) dan memperbarui `contacts.net_balance` dengan tepat?
4. **Lunas via Traktiran (`ITEM_TREAT`):** Apakah saldo dompet tetap utuh (`wallet_id = NULL`, `total_wallet_amount = 0`) sementara sisa hutang berkurang?
5. **Edit / Hapus Transaksi:** Apakah penguncian transaksi yang sudah dicicil tetap berfungsi?

## Langkah 3: Verifikasi Otomatis (`flutter test`) & Evaluasi Pembelajaran (`.agents` Update)
1. Jalankan `flutter test` dan `flutter analyze` untuk memastikan perbaikan tidak merusak rumus keuangan maupun fitur lama. Tambahkan *test case* baru untuk skenario *bug* yang baru saja diperbaiki agar *bug* yang sama tidak pernah muncul kembali.
2. **Evaluasi Pembaruan `.agents`:**
   * Jika *bug* disebabkan oleh jebakan teknis yang berpotensi terulang di masa depan (misal: aturan SQLite spesifik atau *lifecycle* Riverpod), catat solusinya ke dalam `.agents/rules/` atau buat/perbarui *skill* yang relevan.

