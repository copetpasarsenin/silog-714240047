# Jurnal Praktikum Pemrograman IV - Modul 06

## 1. Identitas

| Keterangan | Isi |
| --- | --- |
| Nama | Richard Firmansyah |
| NIM | 714240047 |
| Kelas | 3C-D4-TI |
| Modul | Modul 06 - Pembangunan Antarmuka Berbasis Widget |
| Tanggal praktikum | 28 Oktober 2026 |

## 2. Tujuan Praktikum

1. Membangun layar daftar dan detail pengiriman berbasis widget Flutter.
2. Menerapkan `Row`, `Column`, `Expanded`, `Container`, `Card`, dan `ListView.builder`.
3. Menerapkan navigasi dari daftar menuju detail dan kembali ke daftar.
4. Menerapkan tema aplikasi melalui `ThemeData` dan `ColorScheme.fromSeed`.
5. Menambahkan filter tab serta ringkasan jumlah dan nilai pengiriman.

## 3. Alat dan Bahan

| Alat | Versi/Keterangan |
| --- | --- |
| macOS | 27.2 |
| Flutter SDK | 3.47.4 stable |
| Dart SDK | 3.13.3 |
| Google Chrome | 156.0.8078.48 |
| Figma Desktop | Wireframe 2 layar (`Daftar Pengiriman` & `Detail Pengiriman`) |
| GitHub | https://github.com/copetpasarsenin/silog-714240047 |

## 4. Langkah Kerja

1. Membuat branch `praktikum/modul-06` dari branch `praktikum/modul-05`.
2. Merancang wireframe 2 layar (`Daftar Pengiriman` dan `Detail Pengiriman`) di Figma dengan warna abu-abu.
3. Membuat `lib/data/data_contoh.dart` berisi tiga objek `Pengiriman`.
4. Membuat widget reusable `KartuPengiriman` pada `lib/widget/kartu_pengiriman.dart`.
5. Membuat `DaftarPengirimanPage` dengan `DefaultTabController`, `TabBar`, `TabBarView`, ringkasan, serta `ListView.builder`.
6. Membuat `DetailPengirimanPage` dengan `SingleChildScrollView` dan tombol kembali.
7. Mengganti halaman awal aplikasi pada `lib/main.dart` menjadi `DaftarPengirimanPage` serta menetapkan tema hijau Material 3.
8. Menulis widget test terlebih dahulu, lalu menjalankan formatter, analisis statis, seluruh test, build web release, serta pemeriksaan tampilan di Chrome (lebar penuh, 400 px, dan Flutter Widget Inspector).

## 5. Struktur Widget

| Berkas | Tanggung jawab |
| --- | --- |
| `lib/data/data_contoh.dart` | Data gudang, pelanggan, barang, dan tiga pengiriman contoh. |
| `lib/widget/kartu_pengiriman.dart` | Kartu reusable untuk satu pengiriman dan status berwarna. |
| `lib/tampilan/daftar_pengiriman_page.dart` | Ringkasan, filter tiga tab, daftar pengiriman, dan navigasi. |
| `lib/tampilan/detail_pengiriman_page.dart` | Informasi lengkap pengiriman yang dapat digulir. |
| `lib/main.dart` | `MaterialApp`, tema global, dan halaman awal. |
| `test/widget_test.dart` | Verifikasi daftar, filter tab, navigasi detail, dan kembali. |

Widget kartu menggunakan `Expanded` pada kolom teks agar status tetap terlihat dan teks rute tidak menyebabkan overflow. `ListView.builder` membangun kartu sesuai kebutuhan viewport. Layar detail memakai `SingleChildScrollView` agar data tetap dapat dibaca pada jendela sempit (400 px).

## 6. Implementasi Tugas Praktikum

### 6.1 Filter Tab

Terdapat tiga tab: `Semua`, `Dalam Perjalanan`, dan `Diterima`. Fungsi `_filter` menerima status nullable. Nilai `null` mengembalikan semua data, sedangkan status tertentu menyaring dengan `where`.

### 6.2 Ringkasan

Bagian atas daftar menampilkan jumlah pengiriman dan total nilai barang. Total dihitung dengan `fold<double>` dari properti `nilaiBarang` milik setiap objek `Pengiriman`.

Data contoh menghasilkan:

```text
3 Pengiriman
Total nilai barang Rp24325000
Richard Firmansyah • 714240047
```

### 6.3 Tema dan Const

Tema aplikasi memakai `ColorScheme.fromSeed(seedColor: Color(0xFF1B5E20))`, `CardThemeData`, dan `AppBarTheme`. Widget yang tidak bergantung pada data runtime, misalnya `Text`, `Icon`, `SizedBox`, `Divider`, `Tab`, dan halaman awal, ditandai `const`.

Manfaat `const` adalah Flutter dapat menggunakan kembali instance widget immutable sehingga alokasi dan rebuild yang tidak perlu berkurang. Penandaan `const` tidak digunakan pada widget yang memakai `Theme.of(context)`, data pengiriman, atau callback runtime.

## 7. Hasil Pengujian

Perintah yang dijalankan:

```text
dart format lib/tampilan/daftar_pengiriman_page.dart
flutter analyze
flutter test
flutter build web --release
```

Hasil yang terverifikasi:

```text
Analyzing silog_app...
No issues found!

flutter test
00:03 +12: All tests passed!

flutter build web --release
✓ Built build/web
```

Ringkasan skenario pengujian:

| ID | Skenario | Hasil |
| --- | --- | --- |
| M06-01 | Daftar awal menampilkan tiga resi dan ringkasan | Lulus |
| M06-02 | Tab `Diterima` menyaring data; kartu membuka detail; tombol kembali membuka daftar | Lulus |
| M06-03 | Analisis statis proyek | Lulus: `No issues found!` |
| M06-04 | Seluruh regression test proyek | Lulus: 12 test |
| M06-05 | Build web release | Lulus: `build/web` terbentuk |

## 8. Bukti Visual Eksekusi

1. **Wireframe Figma 2 Layar (`Daftar Pengiriman` & `Detail Pengiriman`)**
   ![Wireframe Figma](bukti_visual_modul06/01_wireframe_figma.png)

2. **Layar Daftar Pengiriman — Ukuran Lebar Penuh (Tab Semua)**
   ![Daftar Lebar Penuh](bukti_visual_modul06/02_daftar_lebar_penuh.png)

3. **Layar Detail Pengiriman (`SLG-2026-0001`) — Ukuran Lebar Penuh**
   ![Detail Lebar Penuh](bukti_visual_modul06/03_detail_lebar_penuh.png)

4. **Navigasi Kembali ke Daftar & Filter Tab `Dalam Perjalanan`**
   ![Filter Dalam Perjalanan](bukti_visual_modul06/04_filter_dalam_perjalanan.png)

5. **Filter Tab `Diterima` (`SLG-2026-0003`)**
   ![Filter Diterima](bukti_visual_modul06/05_filter_diterima.png)

6. **Layar Daftar Pengiriman — Ukuran Sempit (`400 x 725` piksel, Tanpa Overflow)**
   ![Daftar 400px](bukti_visual_modul06/06_daftar_400px.png)

7. **Layar Detail Pengiriman — Ukuran Sempit (`400 x 725` piksel, Tanpa Overflow)**
   ![Detail 400px](bukti_visual_modul06/07_detail_400px.png)

8. **Flutter DevTools Widget Inspector (`SiLogApp -> DaftarPengirimanPage -> KartuPengiriman`)**
   ![Flutter Widget Inspector](bukti_visual_modul06/08_widget_inspector.png)

## 9. Kesimpulan dan Kendala

Antarmuka SiLog Modul 06 berhasil dibangun dengan widget Flutter terpisah dan dapat digunakan ulang. Wireframe Figma, layar daftar dan detail pengiriman pada lebar penuh maupun sempit (400 piksel), navigasi kembali, tema global Material 3, filter tiga tab, ringkasan nilai barang, serta inspeksi pohon widget melalui Flutter Widget Inspector telah diverifikasi tanpa error overflow.

Kendala yang ditemukan saat menulis test adalah selector `find.text('Diterima')` bersifat ambigu karena teks yang sama muncul sebagai tab dan badge status. Solusinya memakai `.last` untuk memilih tab. Tombol kembali pada detail berada di luar viewport test, sehingga test memakai `ensureVisible` sebelum `tap`.

## 10. Repositori

- Repositori: https://github.com/copetpasarsenin/silog-714240047
- Branch: `praktikum/modul-06`
