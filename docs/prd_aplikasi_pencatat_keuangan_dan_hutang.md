# Product Requirements Document (PRD)
**Nama Produk:** Aplikasi Pencatat Keuangan & Buku Hutang Mandiri (Offline-First)  
**Versi Dokumen:** 1.0 (MVP)  
**Platform Target:** Mobile (Android & iOS)  
**Arsitektur Penyimpanan:** 100% Lokal / *Standalone* (SQLite)

---

## 1. Ringkasan Eksekutif & Tujuan Produk
Aplikasi ini dirancang untuk menyelesaikan dua masalah utama dalam pengelolaan keuangan harian:
1. **Bias Laporan Pengeluaran akibat Hutang-Piutang:** Pada aplikasi keuangan konvensional, meminjamkan uang ke teman sering tercatat sebagai "Pengeluaran" (membuat grafik tampak boros), dan saat dilunasi tercatat sebagai "Pemasukan" (membuat seolah-olah ada pendapatan tambahan).
2. **Kerumitan Mencatat Talangan & Hutang Saling Silang:** Pengguna membutuhkan cara mencatat transaksi harian sekaligus piutang teman dalam waktu kurang dari 5 detik tanpa perlu koneksi internet atau integrasi antar-aplikasi yang rumit.

---

## 2. Prinsip Desain Utama
* **100% Mandiri (*Offline-First*):** Seluruh data tersimpan di memori internal perangkat pengguna. Tidak membutuhkan login akun, server eksternal, atau koneksi ke aplikasi pihak ketiga.
* **Input Satu Pintu (*Unified Input*):** Satu tombol aksi utama untuk mencatat pengeluaran, pemasukan, hutang, piutang, hingga talangan makan bersama.
* **Pemisahan Arus Kas (*Cashflow*) vs Konsumsi Riil:** Membedakan secara tegas antara "uang keluar dari dompet karena habis dipakai" dengan "uang keluar dari dompet karena dipinjam teman".

---

## 3. Rumus & Logika Keuangan Inti

Aplikasi menampilkan tiga indikator kesehatan keuangan utama di halaman Beranda menggunakan perhitungan berikut:

### 3.1. Saldo Dompet Aktif ($S_{\text{dompet}}$)
Total uang riil (tunai maupun saldo rekening/e-wallet) yang benar-benar dipegang pengguna saat ini:
$$S_{\text{dompet}} = S_{\text{awal}} + \sum \text{Pemasukan} - \sum \text{Pengeluaran} - \sum \text{Piutang Keluar} + \sum \text{Pelunasan Piutang} + \sum \text{Hutang Masuk} - \sum \text{Pelunasan Hutang}$$

### 3.2. Dana Aman Siap Pakai ($D_{\text{aman}}$)
Indikator uang yang benar-benar aman dibelanjakan tanpa mengganggu kewajiban membayar hutang aktif pengguna:
$$D_{\text{aman}} = S_{\text{dompet}} - H_{\text{aktif}}$$
*(Di mana $H_{\text{aktif}}$ adalah total sisa hutang pengguna kepada orang lain yang belum lunas).*

### 3.3. Kekayaan Bersih / *Net Worth* ($W_{\text{bersih}}$)
Total nilai uang pengguna jika seluruh piutang di teman tertagih dan seluruh hutang dilunasi:
$$W_{\text{bersih}} = S_{\text{dompet}} + P_{\text{aktif}} - H_{\text{aktif}}$$
*(Di mana $P_{\text{aktif}}$ adalah total sisa piutang teman kepada pengguna).*

### 3.4. Saldo Bersih per Kontak / *Auto-Netting* ($B_{\text{kontak}}$)
Setiap teman hanya memiliki satu angka status akhir agar tidak membingungkan:
$$B_{\text{kontak}} = \sum P_{\text{kontak}} - \sum H_{\text{kontak}}$$
* Jika $B_{\text{kontak}} > 0$: Teman masih berhutang kepada pengguna (Warna Hijau/Biru).
* Jika $B_{\text{kontak}} < 0$: Pengguna masih berhutang kepada teman (Warna Merah/Oranye).
* Jika $B_{\text{kontak}} = 0$: Lunas / Impas (Warna Abu-abu).

---

## 4. Spesifikasi Fitur Fungsional (Functional Requirements)

### F1. Input Transaksi Terpadu (4 Mode dalam 1 Tombol `+`)
Pengguna menekan tombol `+` untuk memilih salah satu dari 4 mode transaksi:

| Mode | Efek ke $S_{\text{dompet}}$ | Efek ke Grafik Bulanan | Efek ke Buku Hutang |
| :--- | :--- | :--- | :--- |
| **1. Pengeluaran** | Berkurang | Menambah Pengeluaran | Tidak berubah (kecuali fitur *Talangan* aktif) |
| **2. Pemasukan** | Bertambah | Menambah Pemasukan | Tidak berubah |
| **3. Piutang (Pinjamkan)** | Berkurang | **Tidak dihitung pengeluaran** | Menambah piutang pada kontak terpilih |
| **4. Hutang (Meminjam)** | Bertambah | **Tidak dihitung pemasukan** | Menambah hutang pada kontak terpilih |

### F2. Fitur "Sekalian Talangi Teman" (*Inline Split Expense*)
Di dalam form **Pengeluaran**, terdapat *toggle* **"Ada titipan / talangan teman?"**:
* **Input:** Pengguna memasukkan total bayar di kasir ($T_{\text{bayar}}$), memilih kategori (misal: *Makan*), lalu memasukkan nama teman dan nominal porsi teman ($P_{\text{teman}}$) atau menekan tombol **Bagi Rata**.
* **Output Otomatis:**
  1. Saldo dompet ($S_{\text{dompet}}$) berkurang sebesar $T_{\text{bayar}}$.
  2. Grafik pengeluaran konsumsi pengguna hanya bertambah sebesar $T_{\text{bayar}} - \sum P_{\text{teman}}$.
  3. Buku hutang masing-masing teman otomatis bertambah piutang sebesar $P_{\text{teman}}$.

### F3. Manajemen Buku Hutang & Pelunasan Fleksibel
1. **Pembayaran Parsial (Cicilan):** Pengguna dapat memasukkan nominal bayar sebagian. Sistem memperbarui sisa tagihan dan menampilkan *progress bar* persentase pelunasan.
2. **Saling Silang Saldo Otomatis (*Auto-Netting*):** Ketika pengguna mencatat hutang baru kepada teman yang sebenarnya masih memiliki piutang belum lunas, sistem otomatis menawarkan opsi **"Potong dari piutang sebelumnya"** sehingga langsung mengurangi sisa piutang tanpa memindahkan uang fisik.
3. **Lunas via Barang / Traktiran (*Settle with Item*):** Opsi melunasi piutang teman tanpa uang tunai (misal: teman membayar hutang Rp50.000 dengan membelikan makan siang).
   * Piutang teman berkurang Rp50.000.
   * Saldo dompet ($S_{\text{dompet}}$) **tidak berubah** (karena tidak ada uang tunai masuk).
   * Tercatat sebagai Pengeluaran Makan Rp50.000 (opsional melalui *checkbox* "Catat sebagai konsumsi harian").

### F4. Rem Piutang (*Lending Cap*) & Pengingat Lokal
* **Rem Piutang:** Pengguna dapat menetapkan batas maksimal total uang yang boleh dipinjamkan ke luar ($L_{\text{maks}}$). Jika $P_{\text{aktif}} + \text{Piutang Baru} > L_{\text{maks}}$, muncul *banner* peringatan di form input sebelum transaksi disimpan.
* **Notifikasi Lokal:** Menggunakan *local push notification* bawaan sistem operasi untuk mengingatkan jatuh tempo hutang/piutang pada H-1 dan Hari-H pukul 09.00 pagi.
* **Kartu Ringkasan Gambar (Image Receipt):** Tombol untuk men-generate gambar ringkasan riwayat hutang satu kontak ke galeri HP (atau *share sheet* bawaan OS) jika pengguna ingin menunjukkannya ke teman.

### F5. Kategori Minimalis
* **Pengeluaran (6 Kategori Tetap + Kustom):** Makan & Minum, Transport & BBM, Belanja Harian, Tagihan & Kuota, Hiburan & Nongkrong, Lainnya.
* **Pemasukan (4 Kategori Tetap + Kustom):** Gaji / Upah, Hasil Usaha, Bonus / Pemberian, Lainnya.

---

## 5. Struktur Navigasi & Antarmuka (3 Tab Utama)

### Tab 1: Beranda (Kas Harian)
* **Header:** Kartu utama menampilkan *Saldo Dompet Aktif* ($S_{\text{dompet}}$), *Dana Aman Siap Pakai* ($D_{\text{aman}}$), dan filter pemilihan dompet (Semua / Tunai / Bank).
* **Sub-Header:** Ringkasan total Pemasukan vs Pengeluaran Murni bulan berjalan.
* **Body:** Daftar kronologis transaksi harian dengan kode warna jelas (Merah: Pengeluaran, Hijau: Pemasukan, Biru: Mutasi Hutang/Piutang).

### Tab 2: Buku Hutang
* **Header:** Total Piutang di Teman ($P_{\text{aktif}}$) vs Total Hutang Saya ($H_{\text{aktif}}$), serta status indikator *Rem Piutang*.
* **Filter Cepat:** *Semua*, *Mereka Hutang*, *Saya Hutang*, *Jatuh Tempo*.
* **Body:** Daftar kartu kontak dengan nilai saldo bersih ($B_{\text{kontak}}$). Jika diklik, membuka halaman detail kontak yang berisi riwayat pinjam-meminjam dan tombol **Bayar / Cicil**.

### Tab 3: Ringkasan & Pengaturan Data
* **Visualisasi:** Diagram batang sederhana perbandingan Pengeluaran Murni vs Uang Tertahan di Teman per bulan, serta rincian persentase kategori pengeluaran.
* **Manajemen Data Lokal:** Fitur *Backup & Restore* database ke file lokal (`.json` / `.db`) dan ekspor laporan ke `.csv`.

---

## 6. Kebutuhan Non-Fungsional (Non-Functional Requirements)
1. **Kecepatan Input:** Alur pencatatan transaksi dari membuka aplikasi hingga klik simpan maksimal membutuhkan 3 ketukan (*tap*) dan selesai di bawah 5 detik.
2. **Performa Query Lokal:** Waktu muat daftar transaksi dan kalkulasi agregat saldo di bawah $100\text{ ms}$ untuk hingga $50.000$ baris transaksi.
3. **Privasi & Keamanan:** Opsi penguncian aplikasi menggunakan PIN atau Biometrik (*Fingerprint/Face Unlock*) bawaan perangkat.