# Jurnal Praktikum Pemrograman IV - Modul 02

## 1. Identitas

| Keterangan | Isi |
| --- | --- |
| Nama | Richard Firmansyah |
| NIM | 714240047 |
| Kelas | 3C-D4-TI |
| Modul | Modul 02 - Dasar Pemrograman Bahasa Dart |
| Tanggal praktikum | 23 September 2026 |

## 2. Tujuan Praktikum

1. Menggunakan tipe data, variabel, operator, percabangan, dan perulangan Dart.
2. Mengolah data pengiriman menggunakan `List` dan `Map`.
3. Membuat fungsi modular untuk perhitungan berat dan ongkos kirim.

## 3. Alat dan Bahan

| Alat | Versi/Keterangan |
| --- | --- |
| macOS | 15.8 (Intel x64) |
| Flutter SDK | 3.47.4 stable |
| Dart SDK | 3.13.3 stable |
| Visual Studio Code | Editor kode dengan ekstensi Flutter dan Dart |
| GitHub | https://github.com/copetpasarsenin/silog-714240047 |

## 4. Langkah Kerja

1. Membuat cabang `praktikum/modul-02` dari proyek `silog_app`.
2. Membuat direktori `latihan` pada akar proyek.
3. Menulis dan menjalankan `modul02_dasar.dart` untuk menghitung berat volumetrik dan kategori kiriman.
4. Menulis dan menjalankan `modul02_koleksi.dart` untuk rekap ongkos kirim delapan data kiriman.
5. Menulis dan menjalankan `modul02_fungsi.dart` untuk fungsi ongkir, estimasi hari sampai, dan analisis delapan kiriman.
6. Memeriksa kode dengan `dart format latihan` dan `dart analyze latihan`.

## 5. Kode Program dan Penjelasan

| Berkas | Isi |
| --- | --- |
| `latihan/modul02_dasar.dart` | Menghitung berat volumetrik, memilih berat tertagih terbesar, lalu menentukan kategori dengan percabangan. |
| `latihan/modul02_koleksi.dart` | Menggunakan `List` dan `Map`, perulangan `for-in`, serta rekap pendapatan per kota. |
| `latihan/modul02_fungsi.dart` | Memisahkan perhitungan ke fungsi bernama: berat volumetrik, berat tertagih, ongkir, estimasi hari sampai, dan analisis kiriman. |

Kode lengkap tersedia pada tiga berkas di atas dalam repositori.

## 6. Hasil Eksekusi dan Analisis

Transkrip hasil perintah tersedia pada `bukti_output_modul02.txt`.

- Berat volumetrik paket 45 x 30 x 25 cm adalah 5.63 kg. Karena berat aktual 12.40 kg lebih besar, berat tertagih tetap 12.40 kg dan kategorinya Paket Sedang.
- Jika dimensi diubah menjadi 90 x 60 x 50 cm, berat volumetrik menjadi 45.00 kg. Berat tertagih berubah menjadi 45.00 kg karena nilainya lebih besar daripada berat aktual, sehingga kategorinya Kargo.
- Total pendapatan delapan kiriman pada latihan koleksi adalah Rp1047350.
- Ongkir dengan asuransi adalah Rp117900. Jika `asuransi` diubah menjadi `false`, ongkir menjadi Rp105400 karena biaya asuransi Rp12500 tidak ditambahkan.
- Analisis tugas memperoleh total 96.2 kg, rata-rata 12.03 kg, kiriman terberat SLG-103, dan kiriman teringan SLG-108.

## 7. Jawaban Tugas Praktikum

Program tugas berada pada `latihan/modul02_fungsi.dart` dan menggunakan delapan kiriman. Seluruh perhitungan ditempatkan pada fungsi terpisah, sedangkan `main()` hanya memanggil fungsi untuk menampilkan contoh ongkir dan analisis hasil.

| Kategori | Jumlah kiriman |
| --- | ---: |
| Paket Kecil | 3 |
| Paket Sedang | 3 |
| Kargo | 2 |

## 8. Tabel Skenario Uji

| ID | Input | Output yang diharapkan | Output yang diperoleh | Status |
| --- | --- | --- | --- | --- |
| S01 | Aktual 12.4 kg, dimensi 45 x 30 x 25 cm | Volumetrik 5.63 kg, tertagih 12.40 kg, Paket Sedang | Sesuai | Lulus |
| S02 | Aktual 12.4 kg, dimensi 90 x 60 x 50 cm | Volumetrik dan tertagih 45.00 kg, Kargo | Assertion lulus | Lulus |
| S03 | Delapan data kiriman dan tarif empat kota | Total pendapatan Rp1047350 | Rp1047350 | Lulus |
| S04 | Berat 12.4 kg, tarif Rp8500, asuransi aktif, nilai Rp2500000 | Rp117900 | Rp117900 | Lulus |
| S05 | Input S04 dengan asuransi tidak aktif | Rp105400 | Assertion lulus | Lulus |
| S06 | Delapan berat: 3.2, 12.4, 27.5, 4.8, 18.0, 6.7, 22.1, 1.5 | Total 96.2 kg; rata-rata 12.03 kg; kategori 3, 3, 2 | Sesuai | Lulus |

## 9. Kesimpulan dan Kendala

Dart dapat digunakan untuk memodelkan perhitungan logistik dengan tipe data, koleksi, percabangan, dan fungsi modular. Berat tertagih ditentukan oleh nilai terbesar antara berat aktual dan berat volumetrik. Tidak ada kesalahan analisis kode setelah `dart format` dan `dart analyze` dijalankan.

## 10. Repositori dan Riwayat Commit

- Repositori: https://github.com/copetpasarsenin/silog-714240047
- Cabang: `praktikum/modul-02`
- Commit: `1e01db1 feat: add modul 02 dart exercises`
- Commit: `2adfac7 chore: keep latihan analysis clean`

## 11. Screenshot yang Harus Ditambahkan Sebelum Mengumpulkan

1. Editor menampilkan setiap berkas kode, terminal menjalankan `dart run`, serta nama dan NIM terlihat.
2. Terminal menampilkan `dart format latihan` dan `dart analyze latihan` tanpa peringatan.
3. Browser GitHub menampilkan cabang `praktikum/modul-02` dan riwayat commit setelah cabang dipush.

Pemeriksaan tambahan dijalankan dengan `dart run test/modul02_asserts.dart`.
