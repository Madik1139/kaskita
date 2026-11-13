// ============================================================================
// KASKITA - BUKU PANDUAN PENGGUNA (USER MANUAL)
// Format: Typst (https://typst.app)
// Cara kompilasi ke PDF: typst compile docs/user_manual.typ docs/user_manual.pdf
// ============================================================================

#set document(
  title: "Buku Panduan Pengguna KasKita",
  author: "Tim Pengembang KasKita",
)

#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2.5cm),
  header: align(right)[
    #text(size: 9pt, fill: rgb("#686B73"))[KasKita – Buku Panduan Pengguna (v0.1.0)]
  ],
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#E4E2DD"))
    #v(4pt)
    #grid(
      columns: (1fr, 1fr),
      align(left)[#text(size: 9pt, fill: rgb("#686B73"))[100% Mandiri • Offline-First]],
      align(right)[#text(size: 9pt, fill: rgb("#686B73"))[Halaman #counter(page).display()]],
    )
  ],
)

#set text(
  font: ("Plus Jakarta Sans", "Segoe UI", "Arial"),
  size: 10.5pt,
  fill: rgb("#141518"),
  lang: "id",
)

#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1.")

// Komponen Kotak Info (Tactile Box)
#let info-box(title, body, accent: rgb("#0F5247"), bg: rgb("#F7F6F2")) = {
  block(
    width: 100%,
    fill: bg,
    stroke: (left: 3pt + accent, top: 0.8pt + rgb("#E4E2DD"), right: 0.8pt + rgb("#E4E2DD"), bottom: 0.8pt + rgb("#E4E2DD")),
    inset: 12pt,
    radius: (right: 4pt),
    [
      #text(weight: "bold", fill: accent)[#title]
      #v(4pt)
      #body
    ]
  )
}

// ============================================================================
// HALAMAN JUDUL
// ============================================================================
#align(center)[
  #v(1.5cm)
  #block(
    fill: rgb("#0F5247"),
    inset: (x: 14pt, y: 6pt),
    radius: 4pt,
    text(fill: white, weight: "bold", size: 10pt)[PANDUAN RESMI PENGGUNA • VERSI 0.1.0]
  )
  #v(0.5cm)
  #text(size: 26pt, weight: "bold", fill: rgb("#141518"))[KasKita]
  #v(0.2cm)
  #text(size: 13pt, fill: rgb("#686B73"))[
    Aplikasi Pencatat Keuangan Harian & Buku Hutang Mandiri
  ]
  #v(0.8cm)
  #line(length: 40%, stroke: 1.5pt + rgb("#0F5247"))
  #v(0.8cm)
]

#info-box(
  "Mengapa KasKita Berbeda?",
  [
    Pada aplikasi catatan keuangan biasa, saat Anda meminjamkan uang atau menalangi makan teman, uang tersebut sering tercatat sebagai *Pengeluaran* sehingga laporan bulanan tampak boros. Sebaliknya, saat teman membayar hutang, sering tercatat sebagai *Pemasukan* seolah-olah Anda mendapat gaji tambahan.

    *KasKita* memisahkan secara cerdas antara *Arus Kas Dompet* (uang fisik keluar/masuk) dengan *Konsumsi Pribadi Riil*, serta menghubungkannya langsung ke *Buku Hutang* dalam satu ketukan.
  ]
)

#v(0.5cm)
#outline(title: "Daftar Isi", indent: 1.5em)
#pagebreak()

// ============================================================================
// BAB 1: MENGENAL 3 INDIKATOR KEUANGAN UTAMA
// ============================================================================
= Mengenal 3 Indikator Kesehatan Keuangan

Di halaman *Beranda*, KasKita menampilkan tiga angka utama agar Anda tidak pernah salah menilai sisa uang Anda:

== Saldo Dompet Aktif ($S_"dompet"$)
Total uang riil yang benar-benar ada di tangan Anda saat ini (gabungan uang tunai di dompet, saldo rekening bank, dan e-wallet).
- Bertambah saat ada Pemasukan, Pinjaman Masuk, atau Teman Melunasi Piutang.
- Berkurang saat ada Pengeluaran, Meminjamkan Uang ke Teman, atau Membayar Hutang.

== Dana Aman Siap Pakai ($D_"aman"$)
Nominal uang yang *benar-benar aman untuk Anda belanjakan* tanpa mengganggu kewajiban membayar hutang Anda kepada orang lain.
$ D_"aman" = S_"dompet" - "Total Hutang Aktif Saya" $

== Kekayaan Bersih / Net Worth ($W_"bersih"$)
Total nilai uang Anda secara utuh apabila seluruh piutang di teman sudah tertagih dan seluruh hutang Anda sudah dilunasi.
$ W_"bersih" = S_"dompet" + "Total Piutang di Teman" - "Total Hutang Aktif Saya" $

// ============================================================================
// BAB 2: PERSIAPAN AWAL & MANAJEMEN DOMPET
// ============================================================================
= Persiapan Awal & Manajemen Dompet

== Mengatur Saldo Awal Saat Pertama Kali Buka
1. Saat aplikasi pertama kali dibuka, KasKita otomatis menyediakan *"Dompet Tunai"*.
2. Sebuah jendela dialog singkat akan muncul untuk menanyakan *Saldo Awal* Anda saat ini.
3. Masukkan jumlah uang tunai yang Anda pegang sekarang, lalu tekan *Simpan* (atau pilih *Lewati* jika ingin mulai dari Rp0).

== Menambah Dompet Baru (Bank / E-Wallet)
1. Pada bagian atas halaman *Beranda*, ketuk daftar filter dompet lalu pilih tombol *+ Dompet*.
2. Masukkan nama dompet (misal: `BCA`, `Mandiri`, `GoPay`), pilih tipe (`Tunai`, `Bank`, atau `E-Wallet`), dan masukkan saldo awalnya.

== Transfer Antar Dompet (Tarik Tunai / Top-Up)
Untuk memindahkan uang antar dompet (misal: tarik tunai dari ATM BCA ke Dompet Tunai) tanpa mengotori grafik pengeluaran/pemasukan:
1. Tekan tombol utama *`+`* atau tombol pintas *`⇄ Transfer`* di kartu Beranda.
2. Pilih *Dompet Asal* dan *Dompet Tujuan*.
3. Masukkan nominal menggunakan keypad angka cepat, lalu tekan *Simpan*.

// ============================================================================
// BAB 3: INPUT TRANSAKSI SATU PINTU (< 5 DETIK)
// ============================================================================
= Mencatat Transaksi Harian & Talangan Teman

Seluruh pencatatan dilakukan melalui satu tombol utama *`+`* di bagian bawah layar. Keypad angka sudah terintegrasi langsung beserta tombol cepat (`+10rb`, `+20rb`, `+50rb`, `+100rb`) agar Anda dapat mencatat di bawah 5 detik.

== 4 Mode Input Transaksi
#table(
  columns: (1.2fr, 1.2fr, 1.3fr, 1.3fr),
  inset: 8pt,
  stroke: 0.7pt + rgb("#E4E2DD"),
  fill: (x, y) => if y == 0 { rgb("#EFECE6") } else { white },
  [*Mode*], [*Efek ke Dompet*], [*Efek ke Grafik Bulanan*], [*Efek ke Buku Hutang*],
  [1. Pengeluaran], [Berkurang], [Menambah Pengeluaran], [Tetap (kecuali Talangan aktif)],
  [2. Pemasukan], [Bertambah], [Menambah Pemasukan], [Tidak berubah],
  [3. Piutang (Pinjamkan)], [Berkurang], [*Tidak dihitung pengeluaran*], [Menambah piutang teman],
  [4. Hutang (Meminjam)], [Bertambah], [*Tidak dihitung pemasukan*], [Menambah hutang saya],
)

== Fitur "Sekalian Talangi Teman" (Split Expense)
Gunakan fitur ini saat Anda membayar tagihan di kasir untuk makan bersama atau titipan teman:
1. Buka tombol *`+`* -> pastikan berada di tab *Pengeluaran*.
2. Masukkan total uang yang Anda bayarkan di kasir (misal: `Rp60.000`) dan pilih kategori *Makan & Minum*.
3. Aktifkan sakelar *"Ada titipan / talangan teman?"*.
4. Pilih nama teman (misal: `Riko`) dan tekan tombol *Bagi Rata* (atau ketik porsi teman `Rp30.000`).
5. Tekan *Simpan*.
   - *Hasil Otomatis:* Saldo dompet Anda berkurang `Rp60.000`, namun grafik pengeluaran makan Anda hanya bertambah `Rp30.000`, dan Buku Hutang Riko otomatis bertambah piutang `Rp30.000`!

== Tampilan Harian, Kalender, & Bulanan (Gaya Buku Kas Terkelompok)
Di halaman *Beranda*, seluruh catatan dikelompokkan berdasarkan periode waktu agar rapi dan mudah ditelusuri:
- *Navigasi Bulan (`< Nov 2026 >`):* Geser bulan ke kiri atau kanan untuk melihat riwayat transaksi per periode.
- *Sub-Tab Harian:* Mengelompokkan transaksi ke dalam blok per tanggal (lengkap dengan angka tanggal besar, nama hari, serta subtotal Pemasukan dan Pengeluaran pada hari tersebut).
- *Sub-Tab Kalender:* Menampilkan kalender satu bulan penuh dengan ringkasan angka harian di setiap kotak tanggal.
- *Sub-Tab Bulanan:* Menampilkan rekapitulasi total Pemasukan, Pengeluaran Murni, dan Selisih dari Januari hingga Desember beserta rincian mingguannya.

// ============================================================================
// BAB 4: BUKU HUTANG, CICILAN FIFO, & PELUNASAN PINTAR
// ============================================================================
= Mengelola Buku Hutang & Pelunasan

Buka tab *Buku Hutang* untuk melihat daftar teman beserta satu angka *Saldo Bersih* per orang:
- *Warna Hijau:* Teman masih berhutang kepada Anda (Piutang).
- *Warna Merah:* Anda masih berhutang kepada teman (Hutang).

== Mencicil atau Melunasi Tagihan (Otomatis FIFO)
1. Ketuk kartu nama teman untuk membuka halaman *Detail Kontak*.
2. Tekan tombol *Bayar / Cicil*.
3. Masukkan nominal uang yang diterima/dibayarkan.
4. Secara default, sistem menggunakan metode *FIFO (First-In, First-Out)* yang otomatis memotong tagihan paling lama lebih dulu. Anda juga dapat memilih tagihan spesifik jika diinginkan.

== Potong Saldo Silang Otomatis (Auto-Netting)
Jika seorang teman masih punya hutang belum lunas kepada Anda (misal `Rp50.000`), lalu hari ini Anda meminjam uang atau meminta dia menalangi Anda `Rp20.000`:
- Saat Anda mencatat di mode *Hutang*, aplikasi akan menampilkan opsi *"Potong langsung dari piutang sebelumnya (Auto-Netting)"*.
- Jika diaktifkan, sisa piutang teman langsung berkurang menjadi `Rp30.000` tanpa perlu memindahkan uang fisik.

== Lunas via Barang / Traktiran (Settle with Item)
Jika teman melunasi hutangnya bukan dengan uang tunai, melainkan dengan membelikan Anda makanan atau barang:
1. Buka halaman *Detail Kontak* teman -> tekan *Bayar / Cicil*.
2. Pilih metode pelunasan *Traktiran / Barang*.
3. Masukkan nilai traktiran (misal `Rp50.000`) dan centang *"Catat sebagai konsumsi harian"* (pilih kategori *Makan & Minum*).
4. *Hasil Otomatis:* Piutang teman berkurang `Rp50.000`, saldo dompet Anda tidak berubah (karena tidak ada uang tunai masuk), dan pengeluaran makan Anda tercatat secara akurat.

== Membagikan Kartu Ringkasan Struk (Image Receipt)
Di halaman *Detail Kontak*, ketuk tombol *Bagikan Struk* di pojok kanan atas untuk menghasilkan gambar ringkasan tagihan berformat struk bersih yang siap dikirimkan ke WhatsApp teman.

// ============================================================================
// BAB 5: KEAMANAN, REM PIUTANG, & BACKUP DATA
// ============================================================================
= Rem Piutang, Keamanan, & Backup Data

1. *Rem Piutang (Lending Cap):* Atur batas maksimal total uang yang boleh Anda pinjamkan ke luar di tab *Ringkasan & Pengaturan*. Jika total piutang aktif melewati batas ini, muncul peringatan otomatis sebelum Anda meminjamkan uang lagi.
2. *Indikator Kepercayaan Kontak (Trust Badge):*
   - `GOOD`: Pembayaran lancar dan tepat waktu.
   - `LATE`: Melewati tanggal jatuh tempo (1–7 hari).
   - `WARNING`: Terlambat lebih dari 7 hari atau sudah lebih dari 2 kali terlambat membayar.
3. *Kunci Aplikasi (PIN & Biometrik):* Aktifkan penguncian sidik jari/wajah atau PIN 6 digit di menu Pengaturan untuk menjaga privasi catatan keuangan Anda.
4. *Backup & Restore Lokal:* Seluruh data tersimpan di memori internal HP Anda. Gunakan menu *Backup Data* untuk mengekspor file cadangan (`.db` / `.json`) atau laporan transaksi (`.csv`) ke penyimpanan perangkat kapan saja.
5. *Pembaruan Aplikasi Otomatis (In-App Update / OTA):* Melalui menu *Cek Pembaruan Aplikasi* di tab Pengaturan, Anda dapat memeriksa dan mengunduh versi terbaru aplikasi secara langsung tanpa kehilangan data catatan keuangan lokal Anda.

