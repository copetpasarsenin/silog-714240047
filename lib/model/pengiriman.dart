import 'barang.dart';
import 'gudang.dart';
import 'pelanggan.dart';

class Pengiriman {
  static const List<String> _urutanStatus = [
    'Draft',
    'Menunggu Pickup',
    'Dalam Perjalanan',
    'Tiba di Kota Tujuan',
    'Diterima',
  ];

  final String resi;
  final Gudang asal;
  final String kotaTujuan;
  final Barang barang;
  final int jumlah;
  final DateTime tanggalKirim;
  final Pelanggan pelanggan;
  String _status;

  Pengiriman({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    required this.tanggalKirim,
    required this.pelanggan,
    String status = 'Draft',
  }) : _status = _statusAwal(status) {
    if (jumlah <= 0) {
      throw ArgumentError('Jumlah barang harus lebih besar dari nol');
    }
  }

  Pengiriman.baru({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    required this.pelanggan,
  }) : tanggalKirim = DateTime.now(),
       _status = 'Menunggu Pickup' {
    if (jumlah <= 0) {
      throw ArgumentError('Jumlah barang harus lebih besar dari nol');
    }
  }

  String get status => _status;

  double get nilaiBarang => barang.nilaiTotal(jumlah);

  void ubahStatus(String statusBaru) {
    final indeksSaatIni = _urutanStatus.indexOf(_status);
    final indeksBaru = _urutanStatus.indexOf(statusBaru);
    if (indeksBaru == -1) {
      throw ArgumentError('Status $statusBaru tidak dikenal');
    }
    if (indeksBaru < indeksSaatIni) {
      throw StateError(
        'Status tidak dapat mundur dari $_status ke $statusBaru',
      );
    }
    _status = statusBaru;
  }

  static String _statusAwal(String status) {
    if (!_urutanStatus.contains(status)) {
      throw ArgumentError('Status $status tidak dikenal');
    }
    return status;
  }

  @override
  String toString() =>
      '$resi | ${barang.nama} x$jumlah | ${asal.kota} -> $kotaTujuan | '
      '${pelanggan.nama} | $_status';
}
