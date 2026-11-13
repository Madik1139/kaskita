# Aset Ikon & Logo Aplikasi KasKita

Paket ZIP ini berisi seluruh aset gambar (PNG resolusi tinggi, PNG transparan, Android Mipmap, dan vektor SVG) yang siap dipasang di project **Antigravity (Flutter / React Native / Capacitor)**.

## Struktur Folder
1. `png_master/`
   - `app_icon_1024.png` : Ikon utama aplikasi (1024x1024 px, latar belakang `#222A35`).
   - `app_icon_512.png` : Ikon aplikasi ukuran 512x512 px (cocok untuk Google Play Store / Web PWA).
   - `app_icon_adaptive_foreground_1024.png` : Layer depan transparan khusus untuk **Android Adaptive Icon**.
   - `logo_brand_white_bg_1024.png` : Logo utama KasKita dengan latar putih bersih (1024x1024 px).
   - `logo_brand_transparent_1024.png` : Logo utama KasKita dengan **latar belakang transparan** (1024x1024 px).
   - `logo_brand_cropped_transparent.png` : Logo utama transparan yang sudah di-crop rapat (siap untuk Splash Screen / AppBar).
2. `android_mipmap/`
   - Berisi `ic_launcher.png` dalam ukuran standar Android (`mdpi` 48px, `hdpi` 72px, `xhdpi` 96px, `xxhdpi` 144px, `xxxhdpi` 192px).
3. `svg_vectors/`
   - `app_icon.svg` : Versi vektor SVG ikon aplikasi.
   - `logo_horizontal.svg` : Versi vektor SVG logo horizontal untuk header aplikasi.

---

## Cara Pasang Otomatis di Flutter (`pubspec.yaml`)

Salin folder `png_master` ke dalam project Anda (misal: `assets/icons/`), lalu tambahkan konfigurasi berikut di `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icons/app_icon_1024.png"
  adaptive_icon_background: "#222A35"
  adaptive_icon_foreground: "assets/icons/app_icon_adaptive_foreground_1024.png"
  min_sdk_android: 21
```

Lalu jalankan perintah ini di terminal Antigravity:
```bash
flutter pub get
dart run flutter_launcher_icons
```
