import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/model/barang.dart';
import 'package:silog_app/model/gudang.dart';
import 'package:silog_app/model/pelanggan.dart';
import 'package:silog_app/model/pengiriman.dart';

void main() {
  final sepatu = Barang(
    kode: 'B-1024',
    nama: 'Sepatu Lari Pria',
    hargaSatuan: 450000,
    beratKg: 0.9,
  );
  final pelanggan = Pelanggan(
    kode: 'PLG-001',
    nama: 'Richard Firmansyah',
    nomorTelepon: '081234567890',
    alamat: 'Jalan Raya Logistik Nomor 123 Kecamatan Sukasari Kota Bandung',
  );

  group('Barang', () {
    test('dibentuk dari pemindaian dan menghitung nilai total', () {
      final kaos = Barang.dariPemindaian('B-2048;Kaos Katun;85000');

      expect(kaos.kode, 'B-2048');
      expect(kaos.nama, 'Kaos Katun');
      expect(kaos.satuan, 'pcs');
      expect(kaos.beratKg, 0);
      expect(kaos.nilaiTotal(3), 255000);
    });

    test('menolak harga satuan negatif', () {
      expect(() => sepatu.hargaSatuan = -1, throwsA(isA<ArgumentError>()));
    });
  });

  group('Gudang', () {
    test('menerima, mengeluarkan, dan melindungi stok', () {
      final gudang = Gudang(
        kode: 'GD-BDG',
        nama: 'Gudang Utama Bandung',
        kota: 'Bandung',
        kapasitas: 500,
      );

      gudang.terimaBarang(sepatu, 120);
      gudang.keluarkanBarang(sepatu, 10);

      expect(gudang.totalStok, 110);
      expect(gudang.stok, {'B-1024': 110});
      expect(
        () => gudang.stok['B-1024'] = 999,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('menolak stok melebihi kapasitas dan pengeluaran berlebih', () {
      final gudang = Gudang(
        kode: 'GD-SBY',
        nama: 'Gudang Surabaya',
        kota: 'Surabaya',
        kapasitas: 5,
      );

      expect(() => gudang.terimaBarang(sepatu, 6), throwsA(isA<StateError>()));
      gudang.terimaBarang(sepatu, 5);
      expect(
        () => gudang.keluarkanBarang(sepatu, 6),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Pengiriman dan Pelanggan', () {
    test('mendaftarkan pengiriman baru dan mengubah status maju', () {
      final gudang = Gudang(
        kode: 'GD-BDG',
        nama: 'Gudang Utama Bandung',
        kota: 'Bandung',
      );
      final pengiriman = Pengiriman.baru(
        resi: 'SLG-2026-0007',
        asal: gudang,
        kotaTujuan: 'Surabaya',
        barang: sepatu,
        jumlah: 10,
        pelanggan: pelanggan,
      );

      expect(pengiriman.status, 'Menunggu Pickup');
      expect(pengiriman.nilaiBarang, 4500000);
      expect(pengiriman.pelanggan, pelanggan);

      pengiriman.ubahStatus('Dalam Perjalanan');
      expect(pengiriman.status, 'Dalam Perjalanan');
      expect(() => pengiriman.ubahStatus('Draft'), throwsA(isA<StateError>()));
      expect(
        () => pengiriman.ubahStatus('Dibatalkan'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('meringkas alamat pelanggan paling banyak 40 karakter', () {
      final alamatRingkas = pelanggan.alamatRingkas();

      expect(alamatRingkas.length, lessThanOrEqualTo(40));
      expect(alamatRingkas, endsWith('...'));
    });
  });
}
