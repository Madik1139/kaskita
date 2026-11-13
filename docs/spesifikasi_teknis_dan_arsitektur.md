# Spesifikasi Teknis & Arsitektur (Technical Design Document)
**Nama Produk:** KasKita – Pencatat Keuangan & Buku Hutang Mandiri (Offline-First)  
**Versi Dokumen:** 1.0  
**Framework & Bahasa:** Flutter 3.41+ (Dart 3.11+)  

---

## 1. Tech Stack & Daftar Dependensi Utama

Aplikasi dibangun menggunakan pendekatan ringan, cepat, dan 100% *offline-first* tanpa ketergantungan pada layanan *cloud*.

| Kebutuhan | Package Pilihan | Alasan Pemilihan |
| :--- | :--- | :--- |
| **State Management** | `flutter_riverpod` | Reaktif, *compile-safe*, mudah mengelola *async state* database lokal tanpa *boilerplate* berlebih. |
| **Database Lokal** | `sqflite` + `path` | Eksekusi langsung DDL SQLite sesuai ERD, performa tinggi (<100ms), kontrol penuh atas *database transaction* (`txn`). |
| **Format Mata Uang & Tanggal** | `intl` | Pemformatan Rupiah (`Rp150.000`) dan lokalisasi tanggal Indonesia (`13 Nov 2026`). |
| **Font & Tipografi** | `google_fonts` | Menggunakan font **Plus Jakarta Sans** dan **JetBrains Mono** (untuk elemen struk/angka tabular). |
| **Visualisasi Grafik** | `fl_chart` | Grafik batang perbandingan bulanan & *donut/bar chart* kategori pengeluaran yang ringan. |
| **Notifikasi Lokal** | `flutter_local_notifications` + `timezone` | Penjadwalan pengingat jatuh tempo hutang/piutang pada H-1 dan Hari-H pukul 09.00. |
| **Keamanan Aplikasi** | `local_auth` | Mengunci aplikasi menggunakan Biometrik (*Fingerprint/Face Unlock*) atau PIN lokal. |
| **Share & Ekspor File** | `share_plus`, `path_provider`, `file_picker`, `csv` | Membagikan *Image Receipt* (`RepaintBoundary` -> PNG) ke WhatsApp, serta *Backup/Restore* `.db`/`.json` dan ekspor `.csv`. |
| **In-App Update / OTA** | `package_info_plus` + `url_launcher` / `ota_update` | Mengecek rilis versi terbaru dari GitHub Releases JSON API dan mengunduh pembaruan aplikasi tanpa kehilangan data SQLite lokal. |

---

## 2. Arsitektur Folder (*Feature-First Layered*)

Struktur direktori di dalam `lib/` dirancang modular agar setiap fitur terisolasi dengan rapi:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/          # Konstanta kategori default, kunci pengaturan
│   ├── database/           # DatabaseHelper (SQLite init, migration, seeding)
│   ├── theme/              # Design tokens, warna Light/Dark, tipografi tabular
│   ├── utils/              # Currency formatter, date helper, image receipt renderer
│   └── widgets/            # Komponen UI bersama (CustomNumpad, TactileCard, StatusBadge)
└── features/
    ├── wallets/            # Model, Repository, Provider & UI manajemen dompet + Transfer
    ├── transactions/       # Input Satu Pintu (+), Split Expense (Talangan), Riwayat Kas
    ├── debts/              # Buku Hutang, Kontak, FIFO Cicilan, Auto-Netting, Settle Item, Struk
    ├── reports/            # Grafik bulanan, Rincian Kategori
    └── settings/           # Rem Piutang (Lending Cap), PIN/Biometrik, Backup/Restore, Tema
```

---

## 3. Spesifikasi Algoritma & Aturan Bisnis Inti

### 3.1. Alur Pertama Kali Buka (*Onboarding & Seeding*)
Saat database pertama kali dibuat (`onCreate`):
1. Sistem otomatis melakukan *seeding* **1 Dompet Default**: `"Dompet Tunai"` (`type: 'CASH'`, `initial_balance: 0`, `current_balance: 0`).
2. Sistem melakukan *seeding* **6 Kategori Pengeluaran Default** (*Makan & Minum*, *Transport & BBM*, *Belanja Harian*, *Tagihan & Kuota*, *Hiburan & Nongkrong*, *Lainnya*) dan **4 Kategori Pemasukan Default** (*Gaji / Upah*, *Hasil Usaha*, *Bonus / Pemberian*, *Lainnya*).
3. Saat masuk ke Beranda untuk pertama kali (`onboarding_prompt_shown == '0'`), muncul *bottom sheet* singkat nan bersih: **"Atur Saldo Awal Dompet Tunai?"** (pengguna bisa langsung mengetik nominal saldo saat ini atau klik *"Lewati"*).

---

### 3.2. Mekanisme Cicilan & *Auto-Netting* dengan FIFO (*First-In, First-Out*)
Ketika pengguna mencatat pelunasan/cicilan atau mengaktifkan opsi **Potong dari Piutang/Hutang Sebelumnya (*Auto-Netting*)** pada suatu kontak:

1. **Mode Default (Otomatis FIFO per Kontak):**
   * Sistem mengambil seluruh baris `debts` milik `contact_id` terkait yang berstatus `'UNPAID'` atau `'PARTIAL'`, diurutkan dari yang paling lama: `ORDER BY created_at ASC, id ASC`.
   * Nominal pembayaran ($N_{\text{bayar}}$) dialokasikan secara berurutan ke tagihan terlama hingga $N_{\text{bayar}}$ habis:
     * Untuk setiap tagihan $i$, nominal yang dipotong adalah $P_i = \min(N_{\text{sisa}}, \text{remaining\_amount}_i)$.
     * Sistem membuat baris di `debt_payments` sebesar $P_i$, memperbarui `remaining_amount` pada tagihan $i$, dan mengubah statusnya menjadi `'PAID'` (jika sisa $0$) atau `'PARTIAL'`.
   * Jika pada skenario *Auto-Netting* nominal hutang baru lebih besar daripada total piutang lama yang dimiliki teman ($N_{\text{hutang\_baru}} > \sum \text{remaining\_amount}_{\text{piutang}}$), maka seluruh piutang lama lunas (`PAID`), dan selisih sisanya otomatis dicatat sebagai item hutang baru (`PAYABLE`).

2. **Mode Pilih Tagihan Spesifik (Opsional):**
   * Di halaman Detail Kontak, pengguna juga dapat menekan tombol **"Cicil / Bayar"** langsung pada kartu item tagihan tertentu jika ingin melunasi tagihan spesifik di luar urutan FIFO.

---

### 3.3. Fitur Transfer Antar Dompet (`trx_type = 'TRANSFER'`)
Digunakan untuk memindahkan saldo antar dompet pengguna (misal: Tarik Tunai dari Bank BCA ke Dompet Tunai) tanpa mengotori grafik Pemasukan maupun Pengeluaran:
* **Validasi:** Dompet asal (`wallet_id`) dan dompet tujuan (`target_wallet_id`) tidak boleh sama, serta nominal transfer $> 0$.
* **Eksekusi Atomik (`db.transaction`):**
  1. Insert ke `transactions` dengan `trx_type = 'TRANSFER'`, `wallet_id` = ID Dompet Asal, `target_wallet_id` = ID Dompet Tujuan, `total_wallet_amount` = Nominal, `pure_consumption_amount` = `0`.
  2. Kurangi `current_balance` pada dompet asal (`wallet_id`) sebesar Nominal.
  3. Tambah `current_balance` pada dompet tujuan (`target_wallet_id`) sebesar Nominal.
* **Efek ke Saldo Total ($S_{\text{dompet}}$):** Saat filter dompet = *"Semua Dompet"*, total $S_{\text{dompet}}$ tetap sama. Saat filter memilih salah satu dompet, mutasi masuk/keluar tampil secara akurat.

---

### 3.4. Aturan Otomatis *Trust Badge* Kontak (`GOOD`, `LATE`, `WARNING`)
Status kredibilitas kontak (`trust_badge`) dievaluasi secara otomatis setiap kali daftar kontak dimuat atau saat ada perubahan transaksi hutang/piutang:

1. **`WARNING` (Perhatian Khusus / Sering Telat):**
   * Kontak memiliki piutang aktif (`RECEIVABLE` dengan `status != 'PAID'`) yang sudah melewati `due_date` lebih dari **7 hari** ($\text{Hari Ini} - \text{due\_date} > 7\text{ hari}$), **ATAU**
   * Kolom `late_count` (riwayat telat melunasi melewati jatuh tempo) bernilai **$> 2$ kali**.
2. **`LATE` (Jatuh Tempo Terlewat):**
   * Kontak memiliki piutang aktif yang sudah melewati `due_date` ($1\text{ s.d. }7\text{ hari}$), dan belum memenuhi syarat `WARNING`.
3. **`GOOD` (Lancar / Aman):**
   * Tidak ada piutang yang melewati jatuh tempo dan `late_count` $\le 2$.
*(Catatan: Saat sebuah piutang dilunasi pada tanggal $\text{payment\_date} > \text{due\_date}$, kolom `late_count` pada kontak bertambah $+1$).*

---

### 3.5. Aturan Edit & Hapus Transaksi (*Rollback Safety*)
Untuk menjaga integritas antara buku kas (`wallets`), grafik konsumsi (`transactions`), dan buku hutang (`debts`):

1. **Transaksi Biasa (`EXPENSE` murni, `INCOME`, `TRANSFER`):**
   * Dapat diedit atau dihapus kapan saja. Saat dihapus/diedit, sistem melakukan *rollback* pada `current_balance` dompet terkait di dalam satu *database transaction*.
2. **Transaksi yang Menghasilkan Hutang/Piutang (`RECEIVABLE_OUT`, `DEBT_IN`, atau `EXPENSE` dengan Talangan):**
   * Sistem mengecek apakah baris `debts` yang memiliki `source_transaction_id` tersebut sudah memiliki riwayat cicilan di tabel `debt_payments` (atau `remaining_amount < principal_amount`).
   * **Jika BELUM ada cicilan:** Transaksi **boleh diedit/dihapus**. Menghapus transaksi akan otomatis menghapus baris `debts` terkait (`ON DELETE CASCADE`), mengembalikan `current_balance` dompet, dan menghitung ulang `net_balance` kontak.
   * **Jika SUDAH ada cicilan masuk:** Transaksi **dikunci** dari penghapusan/pengubahan nominal langsung. Sistem menampilkan pesan informatif: *"Transaksi ini sudah memiliki riwayat cicilan. Batalkan cicilan terkait di Buku Hutang terlebih dahulu jika ingin mengubah/menghapus transaksi awal."*
3. **Pembatalan Cicilan (`debt_payments`):**
   * Pengguna dapat menghapus riwayat cicilan dari halaman Detail Kontak -> sistem mengembalikan `remaining_amount` pada `debts`, memperbarui `status` (`PARTIAL`/`UNPAID`), mengembalikan saldo dompet (jika metode `CASH`), dan memperbarui `net_balance` kontak.

