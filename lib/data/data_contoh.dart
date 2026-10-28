import '../model/barang.dart';
import '../model/gudang.dart';
import '../model/pelanggan.dart';
import '../model/pengiriman.dart';

final gudangBandung = Gudang(
  kode: 'GD-BDG',
  nama: 'Gudang Utama Bandung',
  kota: 'Bandung',
);

final pelangganContoh = Pelanggan(
  kode: 'PLG-001',
  nama: 'Toko Nusantara',
  nomorTelepon: '081234567890',
  alamat: 'Jl. Asia Afrika No. 12, Bandung',
);

final List<Pengiriman> dataPengiriman = [
  Pengiriman(
    resi: 'SLG-2026-0001',
    asal: gudangBandung,
    kotaTujuan: 'Surabaya',
    barang: Barang(
      kode: 'B-1024',
      nama: 'Sepatu Lari Pria',
      hargaSatuan: 450000,
    ),
    jumlah: 10,
    tanggalKirim: DateTime(2026, 9, 8),
    pelanggan: pelangganContoh,
    status: 'Dalam Perjalanan',
  ),
  Pengiriman(
    resi: 'SLG-2026-0002',
    asal: gudangBandung,
    kotaTujuan: 'Makassar',
    barang: Barang(kode: 'B-2048', nama: 'Kaos Katun', hargaSatuan: 85000),
    jumlah: 120,
    tanggalKirim: DateTime(2026, 9, 9),
    pelanggan: pelangganContoh,
    status: 'Menunggu Pickup',
  ),
  Pengiriman(
    resi: 'SLG-2026-0003',
    asal: gudangBandung,
    kotaTujuan: 'Medan',
    barang: Barang(kode: 'B-3072', nama: 'Tas Ransel', hargaSatuan: 275000),
    jumlah: 35,
    tanggalKirim: DateTime(2026, 9, 10),
    pelanggan: pelangganContoh,
    status: 'Diterima',
  ),
];
