# Panduan Desain UI/UX & Design System
**Nama Produk:** KasKita – Pencatat Keuangan & Buku Hutang Mandiri  
**Gaya Visual:** *Tactile Financial Ledger* (Inspirasi: Wise, Linear, Buku Kas Modern)  
**Mode Tampilan:** *Adaptive Light & Dark Mode* (Mengikuti Sistem atau Pilihan Manual)

---

## 1. Filosofi Desain: "Anti-AI-Slop" (*Crafted & Tactile*)

Untuk memastikan antarmuka terlihat seperti produk finansial yang dirancang secara serius dan bukan hasil *template AI generik*, seluruh layar wajib mematuhi aturan berikut:

### Yang Dilarang (*Anti-Patterns*):
* **Tanpa Gradien Ungu/Biru Neon:** Dilarang menggunakan gradien khas AI (`#6366F1` -> `#A855F7`) pada kartu saldo maupun tombol utama.
* **Tanpa Bayangan Kabur Berlebihan (*Heavy Drop Shadows*):** Hindari `BoxShadow` tebal yang membuat kartu tampak melayang secara artifisial.
* **Tanpa Efek *Glassmorphism* Berlebihan:** Jangan gunakan latar transparan buram (`BackdropFilter`) yang menurunkan keterbacaan angka.
* **Tanpa Emoji pada Label Sistem:** Gunakan ikon *outline/duotone* yang konsisten (`Lucide` / `Material Symbols Rounded` ukuran `18px–20px`), bukan emoji di judul kartu atau tombol.

### Karakter Utama (*Tactile Financial Ledger*):
1. **Permukaan Kertas & Tinta (*Warm Stone & Crisp Ink*):** Pada *Light Mode*, latar belakang menggunakan warna kertas hangat (`#F7F6F2`), bukan putih menyilaukan (`#FFFFFF`). Kartu menggunakan putih bersih dengan garis tepi (*border*) tegas `1px solid` (`#E4E2DD`).
2. **Angka Sejajar (*Tabular Figures*):** Seluruh nominal Rupiah wajib mengaktifkan `FontFeature.tabularFigures()` agar digit satuan, ribuan, dan jutaan sejajar lurus secara vertikal saat berada di dalam daftar transaksi.
3. **Kepadatan Informasi Tinggi namun Lega:** Baris transaksi ringkas (tinggi `60px–68px`) sehingga pengguna dapat melihat 6–8 transaksi sekaligus tanpa perlu *scrolling* panjang.

---

## 2. Palet Warna (*Color Tokens*)

| Elemen | Light Mode | Dark Mode | Kegunaan |
| :--- | :--- | :--- | :--- |
| **Background Primary** | `#F7F6F2` (Warm Alabaster) | `#0E1014` (Carbon Slate) | Latar belakang utama layar |
| **Surface / Card** | `#FFFFFF` (Pure White) | `#161920` (Elevated Slate) | Kartu saldo, daftar transaksi, bottom sheet |
| **Surface Secondary** | `#EFECE6` (Soft Stone) | `#1F242D` (Muted Slate) | Chip filter, latar numpad, kartu sekunder |
| **Border / Divider** | `#E4E2DD` (`1px solid`) | `#282E3A` (`1px solid`) | Garis tepi kartu & pemisah baris |
| **Text Primary** | `#141518` (Deep Ink) | `#F3F4F6` (Crisp White) | Judul, nama transaksi, nominal utama |
| **Text Secondary** | `#686B73` (Slate Grey) | `#9CA3AF` (Cool Grey) | Tanggal, sub-judul, nama dompet |
| **Primary Accent** | `#0F5247` (Deep Forest Teal) | `#2DD4BF` (Mint Teal) | Tombol aksi utama (`+`), tab aktif, fokus |
| **Semantic: Positive / Piutang** | `#0D7A5F` (Emerald Ink) | `#34D399` (Emerald Light) | Pemasukan (`+`), Teman Berhutang ($B_{\text{kontak}} > 0$) |
| **Semantic: Negative / Hutang** | `#C83349` (Crimson Terra) | `#FB7185` (Rose Light) | Pengeluaran (`-`), Saya Berhutang ($B_{\text{kontak}} < 0$) |
| **Semantic: Neutral Mutation** | `#1D4ED8` (Ledger Blue) | `#60A5FA` (Sky Blue) | Mutasi Transfer / Pelunasan Kas |
| **Semantic: Warning / Cap** | `#B45309` (Amber Ochre) | `#FBBF24` (Warm Amber) | Peringatan Rem Piutang & *Trust Badge* `LATE` |

---

## 3. Tipografi & Hierarki Angka

Menggunakan kombinasi **Plus Jakarta Sans** untuk teks UI dan dukungan `tabularFigures` pada seluruh angka:

* **Hero Balance ($S_{\text{dompet}}$):** `28sp`, `FontWeight.w700`, `letterSpacing: -0.5`, `tabularFigures`.
* **Sub-Indicator ($D_{\text{aman}}$ & $W_{\text{bersih}}$):** `15sp`, `FontWeight.w600`, `tabularFigures`.
* **Section Header:** `13sp`, `FontWeight.w600`, `letterSpacing: 0.4` (Huruf kapital / *Overline* untuk pengelompokan tanggal transaksi: misal `HARI INI • 13 NOV`).
* **Transaction Row Title:** `15sp`, `FontWeight.w600`.
* **Transaction Nominal:** `15sp`, `FontWeight.w700`, `tabularFigures`.

---

## 4. Spesifikasi Interaksi Utama

### 4.1. Input Satu Pintu (`+`) dengan *Custom Integrated Numpad* (< 5 Detik)
Menekan tombol `+` membuka *Modal Bottom Sheet* berkecepatan tinggi tanpa memicu keyboard bawaan OS (sehingga tidak ada jeda animasi *layout shift*):

1. **Segmented Mode Switcher (Bagian Atas):**
   * 4 Tab utama + 1 ikon Transfer: `Pengeluaran` | `Pemasukan` | `Piutang` | `Hutang` | `⇄ Transfer`.
2. **Layar Nominal Besar + Chip Cepat:**
   * Menampilkan angka yang sedang diketik (`Rp 0`) dengan ukuran `32sp`.
   * Di bawah nominal terdapat **Quick Nominal Chips**: `+10rb`, `+20rb`, `+50rb`, `+100rb`, dan `Reset`.
3. **Pemilih Kontekstual Satu Baris (Horizontal Scroll):**
   * Pilih **Dompet** (misal: `[Dompet Tunai ▾]`) dan **Kategori** (atau **Kontak Teman** jika mode Piutang/Hutang).
4. **Toggle "Sekalian Talangi Teman" (Khusus Mode Pengeluaran):**
   * Saat diaktifkan, muncul baris input kontak teman + tombol **`Bagi Rata (50:50)`** atau input porsi manual.
   * Menampilkan ringkasan *real-time*: *"Keluar Dompet: Rp60.000 -> Konsumsi Kamu: Rp30.000 | Piutang Riko: Rp30.000"*.
5. **Custom Numpad Grid (`4x4`):**
   * Tombol angka `0–9`, `000`, `⌫ (Hapus)`, dan tombol **`Simpan`** berukuran besar di sudut kanan bawah.

---

### 4.2. Kartu Beranda & Pengelompokan Transaksi (Gaya *Money Manager Realbyte*)
Tab 1 (Beranda) menggabungkan **Kartu Indikator KasKita** dengan pola navigasi waktu & pengelompokan tanggal/bulan ala **Money Manager (Realbyte)**:

1. **Kartu Buku Kas Terpadu (*Unified Ledger Card*):**
   * **Baris Atas:** Filter pill dompet (`Semua Dompet`, `Dompet Tunai`, `BCA`, dst.) + Tombol pintas `⇄ Transfer`.
   * **Baris Tengah:** **Saldo Dompet Aktif ($S_{\text{dompet}}$)** berukuran besar.
   * **Baris Bawah (2 Kolom Garis `1px`):** **Dana Aman Siap Pakai ($D_{\text{aman}}$)** | **Kekayaan Bersih ($W_{\text{bersih}}$)**.

2. **Navigasi Periode & Sub-Tab Tampilan (Ala *Money Manager*):**
   * **Pemilih Periode Bulan/Tahun:** `◀  Nov 2026  ▶` (atau `◀ 2026 ▶` saat berada di tab *Bulanan*).
   * **Sub-Tab Tampilan:** `Harian` | `Kalender` | `Bulanan`.
   * **Bar Ringkasan 3 Kolom Bulan Berjalan:**
     * Kolom 1: **Pemasukan** (Warna Hijau `#0D7A5F`)
     * Kolom 2: **Pengeluaran Murni** (Warna Merah `#C83349` — *hanya konsumsi pribadi, tidak tercemar pinjaman teman*)
     * Kolom 3: **Selisih Bersih** (`Pemasukan - Pengeluaran Murni`)

3. **Blok Pengelompokan Harian (*Daily Grouped Ledger*):**
   Setiap tanggal yang memiliki transaksi ditampilkan dalam satu blok ber-border tegas `1px` dengan *Header Tanggal* khas *Money Manager*:

```text
┌──────────────────────────────────────────────────────────┐
│  13  [Jum] 11.2026          +Rp 500.000    -Rp 55.000    │
├──────────────────────────────────────────────────────────┤
│  Makan & Minum    Nasi Padang (+Talangan Riko) -Rp 30.000│
│                   Dompet Tunai • Keluar Kas: Rp 60.000   │
├──────────────────────────────────────────────────────────┤
│  Transport & BBM  Isi Pertamax                 -Rp 25.000│
│                   GoPay                                  │
├──────────────────────────────────────────────────────────┤
│  Piutang Keluar   Pinjamkan ke Budi           [Rp 100.000]│
│                   BCA • Buku Hutang (Bukan Pengeluaran)  │
└──────────────────────────────────────────────────────────┘
```
* **Detail Header Tanggal:**
  * **Kiri:** Angka tanggal ukuran besar (`20sp`, `FontWeight.w700`, `tabularFigures`), *badge* hari (`Sen`, `Sel`, `Rab`, `Kam`, `Jum`, `Sab`, `Min`), serta keterangan `BB.TTTT` (`11.2026`).
  * **Kanan:** Total Pemasukan hari tersebut (Hijau) dan Total Pengeluaran Murni hari tersebut (Merah).
* **Tampilan Sub-Tab `Bulanan`:**
  * Mengelompokkan rekapitulasi per bulan (`Jan`, `Feb`, ..., `Nov`, `Des`) dalam tahun terpilih (`◀ 2026 ▶`). Jika salah satu baris bulan diketuk (*expand*), menampilkan rincian mingguan di dalam bulan tersebut beserta total Pemasukan, Pengeluaran Murni, dan Selisih.
* **Tampilan Sub-Tab `Kalender`:**
  * Menampilkan grid kalender bulanan di mana setiap sel tanggal menampilkan ringkasan kecil angka Pemasukan & Pengeluaran pada hari itu. Mengetuk tanggal pada kalender langsung menampilkan rincian transaksi pada tanggal tersebut di bagian bawah.

---

### 4.3. Desain Kartu Ringkasan Gambar (*Clean Invoice Receipt*)
Saat pengguna menekan tombol **"Bagikan Struk / Ringkasan"** di halaman Detail Kontak, aplikasi me-render widget khusus melalui `RepaintBoundary` menjadi gambar PNG beresolusi tajam dengan format **Struk Tagihan Bersih (*Clean Invoice*)**:

```text
┌──────────────────────────────────────────────┐
│ KASKITA • CATATAN BUKU HUTANG                │
│ Tanggal Cetak: 13 Nov 2026, 10:45            │
├──────────────────────────────────────────────┤
│ Nama Kontak : BUDI SANTOSO                   │
│ Status      : PIUTANG (Budi Berhutang)       │
│ SISA TAGIHAN: Rp 130.000                     │
├──────────────────────────────────────────────┤
│ RINCIAN TAGIHAN BELUM LUNAS:                 │
│ • 05 Nov 2026 - Talangan Makan Siang         │
│   Awal: Rp 50.000 | Sisa: Rp 30.000          │
│ • 10 Nov 2026 - Pinjam Tunai                 │
│   Awal: Rp 100.000 | Sisa: Rp 100.000        │
├──────────────────────────────────────────────┤
│ RIWAYAT PEMBAYARAN TERAKHIR:                 │
│ ✓ 08 Nov 2026 - Cicilan Tunai (-Rp 20.000)   │
├──────────────────────────────────────────────┤
│ Dibuat otomatis melalui aplikasi KasKita     │
└──────────────────────────────────────────────┘
```
* Desain selalu menggunakan tema terang (*Warm Paper* `#F7F6F2` dengan teks hitam `#141518` dan garis putus-putus/solid tegas) agar mudah dibaca saat dikirimkan ke WhatsApp baik oleh pengguna *Light Mode* maupun *Dark Mode*.

