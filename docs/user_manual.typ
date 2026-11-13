// ============================================================================
// KASKITA - BUKU PANDUAN PENGGUNA & VISUALISASI LAYOUT APLIKASI (USER MANUAL)
// Format: Typst (https://typst.app)
// Cara kompilasi ke PDF: typst compile docs/user_manual.typ docs/user_manual.pdf
// ============================================================================

#set document(
  title: "Buku Panduan Pengguna & Visualisasi Layout KasKita",
  author: "Tim Pengembang KasKita",
)

#set page(
  paper: "a4",
  margin: (x: 2.0cm, y: 2.2cm),
  header: align(right)[
    #text(size: 8.5pt, fill: rgb("#686B73"))[KasKita – Buku Panduan Pengguna & Layout Antarmuka (v0.3.0)]
  ],
  footer: context [
    #line(length: 100%, stroke: 0.5pt + rgb("#E4E2DD"))
    #v(4pt)
    #grid(
      columns: (1fr, 1fr),
      align(left)[#text(size: 8.5pt, fill: rgb("#686B73"))[100% Mandiri • Offline-First • Tactile Financial Ledger]],
      align(right)[#text(size: 8.5pt, fill: rgb("#686B73"))[Halaman #counter(page).display()]],
    )
  ],
)

#set text(
  font: ("Plus Jakarta Sans", "Segoe UI", "Arial"),
  size: 10pt,
  fill: rgb("#141518"),
  lang: "id",
)

#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1.")

// ============================================================================
// KOMPONEN DESAIN & HELPER MOCKUP LAYAR HP
// ============================================================================
#let info-box(title, body, accent: rgb("#0F5247"), bg: rgb("#F7F6F2")) = {
  block(
    width: 100%,
    fill: bg,
    stroke: (left: 3pt + accent, top: 0.8pt + rgb("#E4E2DD"), right: 0.8pt + rgb("#E4E2DD"), bottom: 0.8pt + rgb("#E4E2DD")),
    inset: 10pt,
    radius: (right: 4pt),
    [
      #text(weight: "bold", fill: accent)[#title]
      #v(3pt)
      #body
    ]
  )
}

#let phone-frame(title, content) = {
  align(center)[
    #block(
      width: 82%,
      fill: rgb("#F7F6F2"),
      stroke: 1.5pt + rgb("#141518"),
      radius: 10pt,
      inset: 0pt,
      clip: true,
      [
        // Status bar & App Bar
        #block(
          width: 100%,
          fill: rgb("#0F5247"),
          inset: (x: 12pt, y: 7pt),
          grid(
            columns: (1fr, auto),
            align(left)[#text(fill: white, weight: "bold", size: 9.5pt)[#title]],
            align(right)[#text(fill: rgb("#A7F3D0"), size: 8pt)[KasKita • Offline]],
          )
        )
        // Body
        #block(
          width: 100%,
          inset: 10pt,
          align(left)[#content]
        )
      ]
    )
  ]
}

// ============================================================================
// HALAMAN JUDUL
// ============================================================================
#align(center)[
  #v(1.0cm)
  #block(
    fill: rgb("#0F5247"),
    inset: (x: 14pt, y: 6pt),
    radius: 4pt,
    text(fill: white, weight: "bold", size: 9.5pt)[PANDUAN RESMI PENGGUNA & VISUAL LAYOUT • VERSI 0.2.0]
  )
  #v(0.4cm)
  #text(size: 26pt, weight: "bold", fill: rgb("#141518"))[KasKita]
  #v(0.2cm)
  #text(size: 12.5pt, fill: rgb("#686B73"))[
    Aplikasi Pencatat Keuangan Harian & Buku Hutang Mandiri
  ]
  #v(0.6cm)
  #line(length: 40%, stroke: 1.5pt + rgb("#0F5247"))
  #v(0.6cm)
]

#info-box(
  "Mengapa KasKita Berbeda?",
  [
    Pada aplikasi catatan keuangan biasa, saat Anda meminjamkan uang atau menalangi makan teman, uang tersebut sering tercatat sebagai *Pengeluaran* sehingga laporan bulanan tampak boros. Sebaliknya, saat teman membayar hutang, sering tercatat sebagai *Pemasukan* seolah-olah Anda mendapat gaji tambahan.

    *KasKita* memisahkan secara cerdas antara *Arus Kas Dompet* (uang fisik keluar/masuk) dengan *Konsumsi Pribadi Riil*, mengelompokkannya per tanggal dan bulan ala *Money Manager*, serta menghubungkannya langsung ke *Buku Hutang* dalam satu ketukan.
  ]
)

#v(0.4cm)
#outline(title: "Daftar Isi", indent: 1.5em)
#pagebreak()

// ============================================================================
// BAB 1: MENGENAL 3 INDIKATOR & LAYOUT BERANDA (GAYA MONEY MANAGER)
// ============================================================================
= Mengenal Layar Beranda & 3 Indikator Kesehatan Keuangan

Di halaman *Beranda (Tab 1)*, KasKita menggabungkan **Kartu Buku Kas Terpadu** dengan pengelompokan transaksi berdasarkan tanggal dan bulan ala *Money Manager*.

== Penjelasan 3 Indikator Utama
1. *Saldo Dompet Aktif ($S_"dompet"$):* Total uang riil yang benar-benar ada di tangan Anda saat ini (gabungan uang tunai, bank, dan e-wallet).
2. *Dana Aman Siap Pakai ($D_"aman"$):* Uang yang benar-benar aman dibelanjakan tanpa mengganggu kewajiban membayar hutang Anda ($D_"aman" = S_"dompet" - H_"aktif"$).
3. *Kekayaan Bersih ($W_"bersih"$):* Nilai uang Anda secara utuh jika seluruh piutang di teman sudah tertagih dan seluruh hutang Anda dilunasi ($W_"bersih" = S_"dompet" + P_"aktif" - H_"aktif"$).

== Gambar Layout 1: Layar Beranda & Blok Harian (Gaya Money Manager)
#v(4pt)
#phone-frame("Tab 1: Beranda (Kas Harian)")[
  // Kartu Saldo Terpadu
  #block(
    width: 100%,
    fill: white,
    stroke: 1pt + rgb("#E4E2DD"),
    radius: 6pt,
    inset: 8pt,
    [
      #grid(
        columns: (1fr, auto),
        [#text(size: 8pt, fill: rgb("#0F5247"), weight: "bold")[Semua Dompet ▾] #h(4pt) #text(size: 8pt, fill: rgb("#686B73"))[| Dompet Tunai | BCA]],
        [#text(size: 8pt, fill: rgb("#1D4ED8"), weight: "bold")[⇄ Transfer]],
      )
      #v(4pt)
      #text(size: 8pt, fill: rgb("#686B73"))[SALDO DOMPET AKTIF]
      #linebreak()
      #text(size: 16pt, weight: "bold", fill: rgb("#141518"))[Rp 2.450.000]
      #v(4pt)
      #line(length: 100%, stroke: 0.6pt + rgb("#E4E2DD"))
      #v(4pt)
      #grid(
        columns: (1fr, 1fr),
        [#text(size: 7.5pt, fill: rgb("#686B73"))[Dana Aman Siap Pakai]\ #text(size: 10pt, weight: "bold", fill: rgb("#0D7A5F"))[Rp 2.250.000]],
        [#text(size: 7.5pt, fill: rgb("#686B73"))[Kekayaan Bersih (Net Worth)]\ #text(size: 10pt, weight: "bold", fill: rgb("#141518"))[Rp 2.580.000]],
      )
    ]
  )
  #v(6pt)
  // Navigasi Bulan & Sub-Tab Money Manager
  #block(
    width: 100%,
    fill: rgb("#EFECE6"),
    stroke: 0.8pt + rgb("#E4E2DD"),
    radius: 4pt,
    inset: 6pt,
    [
      #align(center)[#text(weight: "bold", size: 9pt)[◀   November 2026   ▶]]
      #v(3pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(center)[#block(fill: rgb("#0F5247"), inset: 3pt, radius: 3pt, width: 90%)[#text(fill: white, size: 8pt, weight: "bold")[Harian]]],
        align(center)[#text(size: 8pt, fill: rgb("#686B73"))[Kalender]],
        align(center)[#text(size: 8pt, fill: rgb("#686B73"))[Bulanan]],
      )
      #v(4pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(center)[#text(size: 7.5pt, fill: rgb("#686B73"))[Pemasukan]\ #text(size: 8.5pt, weight: "bold", fill: rgb("#0D7A5F"))[+Rp 5.000.000]],
        align(center)[#text(size: 7.5pt, fill: rgb("#686B73"))[Pengeluaran Murni]\ #text(size: 8.5pt, weight: "bold", fill: rgb("#C83349"))[-Rp 1.250.000]],
        align(center)[#text(size: 7.5pt, fill: rgb("#686B73"))[Selisih]\ #text(size: 8.5pt, weight: "bold", fill: rgb("#141518"))[+Rp 3.750.000]],
      )
    ]
  )
  #v(6pt)
  // Blok Tanggal Harian ala Money Manager
  #block(
    width: 100%,
    fill: white,
    stroke: 1pt + rgb("#E4E2DD"),
    radius: 6pt,
    inset: 8pt,
    [
      #grid(
        columns: (1fr, auto),
        [#text(size: 13pt, weight: "bold")[13] #box(fill: rgb("#EFECE6"), inset: (x: 4pt, y: 1pt), radius: 2pt)[#text(size: 7.5pt, weight: "bold")[Jum]] #text(size: 8pt, fill: rgb("#686B73"))[11.2026]],
        [#text(size: 8.5pt, weight: "bold", fill: rgb("#0D7A5F"))[+Rp 500.000] #h(6pt) #text(size: 8.5pt, weight: "bold", fill: rgb("#C83349"))[-Rp 55.000]],
      )
      #v(4pt)
      #line(length: 100%, stroke: 0.6pt + rgb("#E4E2DD"))
      #v(4pt)
      #grid(
        columns: (1.1fr, 1.8fr, auto),
        [#text(size: 8pt, fill: rgb("#686B73"))[Makan & Minum]],
        [#text(size: 8.5pt, weight: "bold")[Nasi Padang (+Talangan Riko)]\ #text(size: 7.5pt, fill: rgb("#686B73"))[Dompet Tunai • Kas Keluar: Rp 60.000]],
        align(right)[#text(size: 8.5pt, weight: "bold", fill: rgb("#C83349"))[-Rp 30.000]],
      )
      #v(3pt)
      #line(length: 100%, stroke: 0.4pt + rgb("#E4E2DD"))
      #v(3pt)
      #grid(
        columns: (1.1fr, 1.8fr, auto),
        [#text(size: 8pt, fill: rgb("#1D4ED8"))[Piutang Keluar]],
        [#text(size: 8.5pt, weight: "bold")[Pinjamkan Tunai ke Budi]\ #text(size: 7.5pt, fill: rgb("#686B73"))[BCA • Masuk Buku Hutang]],
        align(right)[#text(size: 8.5pt, weight: "bold", fill: rgb("#1D4ED8"))[[Rp 100.000]]],
      )
    ]
  )
]

== Cara Membaca & Menggunakan Navigasi Beranda
1. *Memilih Filter Dompet:* Ketuk pill *Semua Dompet* di bagian paling atas untuk memfilter mutasi dompet tertentu (misal hanya `Dompet Tunai` atau `BCA`), atau tekan *+ Dompet* untuk menambah dompet baru.
2. *Berpindah Periode & Tampilan:*
   - Gunakan panah `◀` dan `▶` untuk berpindah bulan.
   - Pilih tab *Harian* untuk melihat rincian per blok tanggal, *Kalender* untuk tampilan kotak tanggal sebulan penuh, atau *Bulanan* untuk rekapitulasi Januari–Desember beserta rincian mingguan.

#pagebreak()

// ============================================================================
// BAB 2: INPUT SATU PINTU (< 5 DETIK) & TALANGAN TEMAN
// ============================================================================
= Mencatat Transaksi & Talangan Teman (< 5 Detik)

Menekan tombol utama *`+`* di bagian bawah layar akan membuka *Bottom Sheet* berkecepatan tinggi dengan **Custom Numpad Terintegrasi** (tanpa perlu menunggu keyboard bawaan HP muncul).

== Gambar Layout 2: Form Input Satu Pintu (`+`) & Sekalian Talangi Teman
#v(4pt)
#phone-frame("Bottom Sheet: Input Transaksi Cepat (+)")[
  // Mode Switcher
  #block(
    width: 100%,
    fill: rgb("#EFECE6"),
    inset: 4pt,
    radius: 4pt,
    grid(
      columns: (1.1fr, 1fr, 0.9fr, 0.9fr, 0.9fr),
      align(center)[#block(fill: rgb("#C83349"), inset: 3pt, radius: 3pt, width: 95%)[#text(fill: white, size: 7.5pt, weight: "bold")[Pengeluaran]]],
      align(center)[#text(size: 7.5pt)[Pemasukan]],
      align(center)[#text(size: 7.5pt)[Piutang]],
      align(center)[#text(size: 7.5pt)[Hutang]],
      align(center)[#text(size: 7.5pt)[⇄ Transfer]],
    )
  )
  #v(5pt)
  // Layar Nominal & Quick Chips
  #block(
    width: 100%,
    fill: white,
    stroke: 1pt + rgb("#E4E2DD"),
    radius: 5pt,
    inset: 8pt,
    [
      #align(right)[
        #text(size: 7.5pt, fill: rgb("#686B73"))[TOTAL BAYAR DI KASIR]
        #linebreak()
        #text(size: 18pt, weight: "bold", fill: rgb("#C83349"))[Rp 60.000]
      ]
      #v(3pt)
      #grid(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr),
        gutter: 4pt,
        align(center)[#block(fill: rgb("#EFECE6"), width: 100%, inset: 3pt, radius: 3pt)[#text(size: 7.5pt, weight: "bold")[+10rb]]],
        align(center)[#block(fill: rgb("#EFECE6"), width: 100%, inset: 3pt, radius: 3pt)[#text(size: 7.5pt, weight: "bold")[+20rb]]],
        align(center)[#block(fill: rgb("#EFECE6"), width: 100%, inset: 3pt, radius: 3pt)[#text(size: 7.5pt, weight: "bold")[+50rb]]],
        align(center)[#block(fill: rgb("#EFECE6"), width: 100%, inset: 3pt, radius: 3pt)[#text(size: 7.5pt, weight: "bold")[+100rb]]],
        align(center)[#block(fill: rgb("#FEE2E2"), width: 100%, inset: 3pt, radius: 3pt)[#text(size: 7.5pt, fill: rgb("#C83349"), weight: "bold")[Reset]]],
      )
    ]
  )
  #v(5pt)
  // Pemilih Dompet & Kategori
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 4pt,
    block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 5pt, radius: 4pt, width: 100%)[#text(size: 7.5pt)[Dompet: *Tunai ▾*]],
    block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 5pt, radius: 4pt, width: 100%)[#text(size: 7.5pt)[Kat: *Makan ▾*]],
    block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 5pt, radius: 4pt, width: 100%)[#text(size: 7.5pt)[Tgl: *Hari Ini ▾*]],
  )
  #v(5pt)
  // Toggle Sekalian Talangi Teman
  #block(
    width: 100%,
    fill: rgb("#ECFDF5"),
    stroke: 0.8pt + rgb("#0D7A5F"),
    radius: 5pt,
    inset: 6pt,
    [
      #grid(
        columns: (1fr, auto),
        [#text(size: 8pt, weight: "bold", fill: rgb("#0F5247"))[✓ Sekalian Talangi Teman (Split Expense)]],
        [#box(fill: rgb("#0F5247"), inset: (x: 5pt, y: 2pt), radius: 3pt)[#text(fill: white, size: 7pt, weight: "bold")[Bagi Rata 50:50]]],
      )
      #v(3pt)
      #text(size: 7.5pt, fill: rgb("#141518"))[Teman: *Riko* • Porsi Riko: *Rp 30.000* | Konsumsi Pribadi Anda: *Rp 30.000*]
    ]
  )
  #v(5pt)
  // Custom Numpad Grid 4x4
  #grid(
    columns: (1fr, 1fr, 1fr, 1.1fr),
    gutter: 4pt,
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[7]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[8]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[9]]],
    block(fill: rgb("#EFECE6"), stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[⌫]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[4]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[5]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[6]]],
    block(fill: rgb("#EFECE6"), stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold", size: 8pt)[000]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[1]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[2]]],
    block(fill: white, stroke: 0.6pt + rgb("#E4E2DD"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(weight: "bold")[3]]],
    block(fill: rgb("#0F5247"), inset: 5pt, radius: 3pt, width: 100%)[#align(center)[#text(fill: white, weight: "bold", size: 8.5pt)[SIMPAN]]],
  )
]

== Langkah-Langkah Mencatat Transaksi & Talangan
1. *Mencatat Pengeluaran/Pemasukan Biasa (3 Ketukan):*
   - Ketuk tombol *`+`* -> tekan tombol angka atau chip cepat (`+10rb`, `+50rb`) -> pilih Kategori -> ketuk *SIMPAN*.
2. *Mencatat Makan Bersama / Talangan Teman:*
   - Pada tab *Pengeluaran*, masukkan total uang yang Anda bayarkan di kasir (misal `Rp 60.000`).
   - Aktifkan kotak *"Sekalian Talangi Teman"*, pilih nama kontak (`Riko`), lalu ketuk *Bagi Rata 50:50* (atau ketik nominal porsi teman).
   - Ketuk *SIMPAN*. KasKita otomatis memotong dompet `Rp 60.000`, mencatat pengeluaran makan pribadi `Rp 30.000`, dan menambah piutang Riko `Rp 30.000`.

#pagebreak()

// ============================================================================
// BAB 3: BUKU HUTANG, CICILAN FIFO, AUTO-NETTING, & STRUK GAMBAR
// ============================================================================
= Mengelola Buku Hutang, Cicilan FIFO, & Struk Tagihan

Pada *Tab 2 (Buku Hutang)*, setiap teman hanya memiliki **satu angka Saldo Bersih ($B_"kontak"$)** agar Anda tidak pernah bingung menghitung hutang-piutang yang saling silang.

== Gambar Layout 3: Layar Buku Hutang & Kartu Struk Tagihan (Image Receipt)
#v(4pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  // Kiri: Tab Buku Hutang
  block(
    width: 100%,
    fill: rgb("#F7F6F2"),
    stroke: 1.2pt + rgb("#141518"),
    radius: 8pt,
    inset: 8pt,
    [
      #block(fill: rgb("#0F5247"), width: 100%, inset: 5pt, radius: 3pt)[
        #text(fill: white, weight: "bold", size: 8pt)[Tab 2: Buku Hutang & Rem Piutang]
      ]
      #v(4pt)
      #block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 6pt, radius: 4pt, width: 100%)[
        #grid(
          columns: (1fr, 1fr),
          [#text(size: 7pt, fill: rgb("#686B73"))[Piutang di Teman]\ #text(size: 9pt, weight: "bold", fill: rgb("#0D7A5F"))[+Rp 330.000]],
          [#text(size: 7pt, fill: rgb("#686B73"))[Hutang Saya]\ #text(size: 9pt, weight: "bold", fill: rgb("#C83349"))[-Rp 200.000]],
        )
        #v(3pt)
        #text(size: 7pt, fill: rgb("#B45309"))[Rem Piutang: Rp 330rb / Rp 1.000.000 (Aman 33%)]
      ]
      #v(4pt)
      #block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 6pt, radius: 4pt, width: 100%)[
        #grid(
          columns: (1fr, auto),
          [#text(size: 8.5pt, weight: "bold")[Budi Santoso] #box(fill: rgb("#FEF3C7"), inset: 2pt, radius: 2pt)[#text(size: 6.5pt, fill: rgb("#B45309"), weight: "bold")[LATE]]\ #text(size: 7pt, fill: rgb("#686B73"))[2 tagihan belum lunas]],
          align(right)[#text(size: 8.5pt, weight: "bold", fill: rgb("#0D7A5F"))[+Rp 130.000]\ #text(size: 6.5pt, fill: rgb("#0F5247"))[[Bayar / Cicil]]],
        )
      ]
      #v(4pt)
      #block(fill: white, stroke: 0.8pt + rgb("#E4E2DD"), inset: 6pt, radius: 4pt, width: 100%)[
        #grid(
          columns: (1fr, auto),
          [#text(size: 8.5pt, weight: "bold")[Riko Pratama] #box(fill: rgb("#D1FAE5"), inset: 2pt, radius: 2pt)[#text(size: 6.5pt, fill: rgb("#0D7A5F"), weight: "bold")[GOOD]]\ #text(size: 7pt, fill: rgb("#686B73"))[Talangan Makan Siang]],
          align(right)[#text(size: 8.5pt, weight: "bold", fill: rgb("#0D7A5F"))[+Rp 30.000]\ #text(size: 6.5pt, fill: rgb("#0F5247"))[[Bayar / Cicil]]],
        )
      ]
    ]
  ),
  // Kanan: Clean Invoice Receipt (PNG)
  block(
    width: 100%,
    fill: rgb("#F7F6F2"),
    stroke: 1.2pt + rgb("#141518"),
    radius: 8pt,
    inset: 8pt,
    [
      #block(fill: rgb("#141518"), width: 100%, inset: 5pt, radius: 3pt)[
        #text(fill: white, weight: "bold", size: 8pt)[Hasil Gambar Struk (Share WhatsApp)]
      ]
      #v(4pt)
      #block(fill: white, stroke: 0.8pt + rgb("#141518"), inset: 6pt, radius: 2pt, width: 100%)[
        #text(size: 7.5pt, weight: "bold")[KASKITA • CATATAN BUKU HUTANG]
        #linebreak()
        #text(size: 6.5pt, fill: rgb("#686B73"))[Tanggal Cetak: 13 Nov 2026, 10:45]
        #v(2pt)
        #line(length: 100%, stroke: 0.5pt + rgb("#E4E2DD"))
        #v(2pt)
        #text(size: 7.5pt)[Kontak: *BUDI SANTOSO*]\
        #text(size: 8.5pt, weight: "bold", fill: rgb("#0D7A5F"))[SISA TAGIHAN: Rp 130.000]
        #v(2pt)
        #line(length: 100%, stroke: 0.5pt + rgb("#E4E2DD"))
        #v(2pt)
        #text(size: 7pt, weight: "bold")[RINCIAN BELUM LUNAS:]\
        #text(size: 7pt)[• 05 Nov - Talangan Makan (Sisa: Rp 30.000)]\
        #text(size: 7pt)[• 10 Nov - Pinjam Tunai (Sisa: Rp 100.000)]
        #v(2pt)
        #text(size: 7pt, weight: "bold")[CICILAN TERAKHIR:]\
        #text(size: 7pt, fill: rgb("#0D7A5F"))[✓ 08 Nov - Cicilan Tunai (-Rp 20.000)]
      ]
    ]
  )
)

== 3 Metode Pelunasan Fleksibel
1. *Cicilan Tunai Otomatis FIFO (First-In, First-Out):*
   - Ketuk nama teman -> tekan tombol *Bayar / Cicil* -> masukkan nominal uang yang dibayarkan.
   - Secara otomatis, sistem memotong dari tagihan yang paling lama terlebih dahulu (atau Anda bisa memilih satu tagihan spesifik).
2. *Potong Saldo Silang Otomatis (Auto-Netting):*
   - Saat Anda mencatat hutang baru kepada teman yang masih memiliki piutang belum lunas di tempat Anda, aktifkan opsi *"Potong langsung dari piutang sebelumnya"*. Saldo langsung terpotong otomatis tanpa perlu memindahkan uang dompet.
3. *Lunas via Barang / Traktiran (Settle with Item):*
   - Di menu *Bayar / Cicil*, pilih tab *Traktiran / Barang*. Piutang teman otomatis berkurang tanpa mengubah saldo uang tunai di dompet Anda, dan dapat langsung dicatat sebagai konsumsi makan/belanja Anda.

// ============================================================================
// BAB 4: LAPORAN GRAFIK, KEAMANAN, BACKUP, & UPDATE OTA
// ============================================================================
= Laporan Bulanan, Keamanan, Backup, & Update OTA

Di *Tab 3 (Ringkasan & Pengaturan)*, Anda dapat memantau kesehatan finansial sekaligus mengamankan data lokal Anda:
1. *Grafik Konsumsi Murni vs Uang Tertahan di Teman:* Membandingkan pengeluaran pribadi Anda dengan nominal uang yang sedang dipinjam teman setiap bulannya.
2. *Kunci Aplikasi (PIN 6 Digit & Biometrik):* Lindungi privasi catatan kas Anda dengan sidik jari/wajah atau PIN terenkripsi.
3. *Backup & Restore Lokal (`.json` / `.db`) & Ekspor `.csv`:* Cadangkan seluruh database ke penyimpanan HP atau pulihkan kapan saja saat berganti perangkat.
4. *Cek Pembaruan Otomatis (OTA via GitHub Releases):* Ketuk menu *Cek Pembaruan Aplikasi* untuk memeriksa dan mengunduh versi terbaru KasKita secara langsung tanpa kehilangan data catatan keuangan Anda.
