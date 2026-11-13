---
name: release-and-docs-sync
description: >-
  Prosedur untuk memperbarui versi aplikasi (versioning), mencatat Changelog di README.md,
  memperbarui dokumen User Manual Typst (docs/user_manual.typ), serta memperbarui .agents.
  Gunakan skill ini setiap selesai menyelesaikan tonggak fitur (milestone), perubahan penting, atau rilis.
---

# Workflow Sinkronisasi Dokumentasi, Versioning, & User Manual (`release-and-docs-sync`)

Setiap kali menyelesaikan fitur penting, perubahan arsitektur, atau pembaruan versi di **KasKita**, jalankan langkah-langkah berikut:

## Langkah 1: Pembaruan Versi & `README.md`
1. Tentukan kenaikan versi menggunakan *Semantic Versioning* (`MAJOR.MINOR.PATCH+BUILD`):
   * `PATCH` (`0.1.x`): Perbaikan *bug*, perapian UI kecil, atau optimasi performa.
   * `MINOR` (`0.x.0`): Penambahan fitur baru (misal: selesainya modul Buku Hutang, Grafik, atau Backup/Restore).
   * `MAJOR` (`x.0.0`): Rilis MVP penuh atau perubahan skema besar.
2. Perbarui versi di `pubspec.yaml` (jika merupakan tonggak rilis) dan catat riwayat perubahannya pada tabel **Riwayat Versi (Changelog)** di [README.md](../../../README.md) secara ringkas: fokus hanya pada pembaruan/penambahan fitur tanpa mencantumkan nama file, simbol kode, atau detail teknis internal.
3. Pastikan daftar status fitur di `README.md` mencerminkan kondisi kode terkini.

## Langkah 2: Pembaruan User Manual Typst (`docs/user_manual.typ`) Beserta Gambar Layout
1. Buka file [docs/user_manual.typ](../../../docs/user_manual.typ).
2. Perbarui bagian panduan pengguna yang terdampak oleh fitur baru, termasuk **langkah-langkah penggunaan** serta **visualisasi/ilustrasi gambar layout layar aplikasi** di dalam dokumen Typst agar pembaca dapat melihat langsung bentuk antarmuka setiap fitur.
3. Perbarui nomor versi dan tanggal pembaruan pada bagian header `docs/user_manual.typ`.
4. Jika CLI `typst` tersedia di sistem, jalankan kompilasi:
   ```powershell
   typst compile docs/user_manual.typ docs/user_manual.pdf
   ```

## Langkah 3: Audit `.agents` & Komponen Reusable
1. Jika ada widget reusable baru yang ditambahkan ke `lib/core/widgets/`, pastikan namanya sudah terdaftar di `AGENTS.md`.
2. Jika ada prosedur teknis baru yang penting dan berulang, tambahkan atau perbarui *skill* di `.agents/skills/`.

## Langkah 4: Git Commit & Push per Fase (*Conventional Commits*)
Setiap menyelesaikan satu fase pengerjaan (setelah `analyze_files` = 0 error dan `run_tests` lulus), **wajib melakukan commit ke Git** sebelum memulai fase berikutnya:
* `feat: ...` – Penambahan fitur baru / penyelesaian fase
* `fix: ...` – Perbaikan *bug* atau koreksi perhitungan saldo
* `refactor: ...` – Perapian struktur kode tanpa mengubah perilaku fitur
* `docs: ...` – Pembaruan `README.md`, `docs/`, `user_manual.typ`, atau `.agents/`
* `test: ...` – Penambahan atau perbaikan *unit/widget test*

