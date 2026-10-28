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
| GitHub | https://github.com/copetpasarsenin/silog-714240047 |

## 4. Langkah Kerja

1. Membuat branch `praktikum/modul-06` dari branch `praktikum/modul-05`.
2. Membuat `lib/data/data_contoh.dart` berisi tiga objek `Pengiriman`.
3. Membuat widget reusable `KartuPengiriman` pada `lib/widget/kartu_pengiriman.dart`.
4. Membuat `DaftarPengirimanPage` dengan `DefaultTabController`, `TabBar`, `TabBarView`, ringkasan, serta `ListView.builder`.
5. Membuat `DetailPengirimanPage` dengan `SingleChildScrollView` dan tombol kembali.
6. Mengganti halaman awal aplikasi pada `lib/main.dart` menjadi `DaftarPengirimanPage` serta menetapkan tema hijau Material 3.
7. Menulis widget test terlebih dahulu. Test awal gagal karena kelas `SiLogApp` belum tersedia. Setelah implementasi, test daftar, filter tab, navigasi detail, dan kembali ke daftar lulus.
8. Menjalankan formatter, analisis statis, seluruh test, dan build web release.

## 5. Struktur Widget

| Berkas | Tanggung jawab |
| --- | --- |
| `lib/data/data_contoh.dart` | Data gudang, pelanggan, barang, dan tiga pengiriman contoh. |
| `lib/widget/kartu_pengiriman.dart` | Kartu reusable untuk satu pengiriman dan status berwarna. |
| `lib/tampilan/daftar_pengiriman_page.dart` | Ringkasan, filter tiga tab, daftar pengiriman, dan navigasi. |
| `lib/tampilan/detail_pengiriman_page.dart` | Informasi lengkap pengiriman yang dapat digulir. |
| `lib/main.dart` | `MaterialApp`, tema global, dan halaman awal. |
| `test/widget_test.dart` | Verifikasi daftar, filter tab, navigasi detail, dan kembali. |

Widget kartu menggunakan `Expanded` pada kolom teks agar status tetap terlihat dan teks rute tidak menyebabkan overflow. `ListView.builder` membangun kartu sesuai kebutuhan viewport. Layar detail memakai `SingleChildScrollView` agar data tetap dapat dibaca pada jendela sempit.

## 6. Implementasi Tugas Praktikum

### 6.1 Filter Tab

Terdapat tiga tab: `Semua`, `Dalam Perjalanan`, dan `Diterima`. Fungsi `_filter` menerima status nullable. Nilai `null` mengembalikan semua data, sedangkan status tertentu menyaring dengan `where`.

### 6.2 Ringkasan

Bagian atas daftar menampilkan jumlah pengiriman dan total nilai barang. Total dihitung dengan `fold<double>` dari properti `nilaiBarang` milik setiap objek `Pengiriman`.

Data contoh menghasilkan:

```text
3 Pengiriman
Total nilai barang Rp24325000
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

Dua widget test khusus Modul 06 lulus:

| ID | Skenario | Hasil |
| --- | --- | --- |
| M06-01 | Daftar awal menampilkan tiga resi dan ringkasan | Lulus |
| M06-02 | Tab `Diterima` menyaring data; kartu membuka detail; tombol kembali membuka daftar | Lulus |
| M06-03 | Analisis statis proyek | Lulus: `No issues found!` |
| M06-04 | Seluruh regression test proyek | Lulus: 12 test |
| M06-05 | Build web release | Lulus: `build/web` terbentuk |

## 8. Hasil Eksekusi dan Analisis

Aplikasi berhasil menampilkan tiga kartu pengiriman dengan warna status: oranye untuk `Dalam Perjalanan`, abu-abu untuk `Menunggu Pickup`, dan hijau untuk `Diterima`. Tab filter menyederhanakan pencarian status tanpa menduplikasi layar. Saat kartu disentuh, `Navigator.push` mengirim objek `Pengiriman` ke halaman detail. Tombol `Kembali ke Daftar` menjalankan `Navigator.pop` sehingga pengguna kembali ke halaman sebelumnya.

Pada pemeriksaan visual desktop melalui Chrome, daftar, ringkasan, tiga kartu, dan tombol `Pengiriman Baru` tampil tanpa overflow. Pengujian widget juga memverifikasi alur filter dan navigasi secara otomatis.

## 9. Kesimpulan dan Kendala

Antarmuka SiLog Modul 06 berhasil dibangun dengan widget Flutter terpisah dan dapat digunakan ulang. Daftar dan detail pengiriman, navigasi kembali, tema global, filter tiga tab, serta ringkasan nilai barang telah berfungsi. Formatter, analisis statis, test otomatis, dan build web selesai tanpa error.

Kendala yang ditemukan saat menulis test adalah selector `find.text('Diterima')` bersifat ambigu karena teks yang sama muncul sebagai tab dan badge status. Solusinya memakai `.last` untuk memilih tab. Tombol kembali pada detail berada di luar viewport test, sehingga test memakai `ensureVisible` sebelum `tap`.

## 10. Repositori dan Bukti Visual

- Repositori: https://github.com/copetpasarsenin/silog-714240047
- Branch: `praktikum/modul-06`
- Bukti daftar desktop: `bukti_visual_modul06/01_daftar_pengiriman_desktop.png`

Bukti manual yang masih perlu dilengkapi sebelum unggah LMS:

1. Wireframe Figma layar daftar dan detail.
2. Screenshot daftar dan detail pada lebar penuh serta lebar sekitar 400 piksel, dengan nama dan NIM terlihat.
3. Screenshot berurutan daftar, detail, lalu kembali ke daftar.
4. Screenshot Flutter Widget Inspector.
5. Screenshot editor, terminal test, branch, dan riwayat commit.

Bukti tersebut tidak diklaim sudah dibuat dalam jurnal ini.
