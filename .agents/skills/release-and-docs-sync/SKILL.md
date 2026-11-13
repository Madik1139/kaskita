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
2. Perbarui versi di `pubspec.yaml` (jika merupakan tonggak rilis) dan catat riwayat perubahannya pada tabel **Riwayat Versi (Changelog)** di [README.md](../../../README.md).
3. Pastikan daftar status fitur di `README.md` mencerminkan kondisi kode terkini.

## Langkah 2: Pembaruan User Manual Typst (`docs/user_manual.typ`)
1. Buka file [docs/user_manual.typ](../../../docs/user_manual.typ).
2. Perbarui bagian panduan pengguna yang terdampak oleh fitur baru atau perubahan alur UI (misal: cara memakai Input Satu Pintu, Talangan, Auto-Netting, atau Backup Data).
3. Perbarui nomor versi dan tanggal pembaruan pada bagian header `docs/user_manual.typ`.
4. Jika CLI `typst` tersedia di sistem, jalankan kompilasi:
   ```powershell
   typst compile docs/user_manual.typ docs/user_manual.pdf
   ```

## Langkah 3: Audit `.agents` & Komponen Reusable
1. Jika ada widget reusable baru yang ditambahkan ke `lib/core/widgets/`, pastikan namanya sudah terdaftar di `AGENTS.md`.
2. Jika ada prosedur teknis baru yang penting dan berulang, tambahkan atau perbarui *skill* di `.agents/skills/`.

## Langkah 4: Standar Pesan Commit (*Conventional Commits*)
Saat menyimpan perubahan ke Git, gunakan awalan standar agar selaras dengan *Changelog*:
* `feat: ...` – Penambahan fitur baru
* `fix: ...` – Perbaikan *bug* atau koreksi perhitungan saldo
* `refactor: ...` – Perapian struktur kode tanpa mengubah perilaku fitur
* `docs: ...` – Pembaruan `README.md`, `docs/`, `user_manual.typ`, atau `.agents/`
* `test: ...` – Penambahan atau perbaikan *unit/widget test*

