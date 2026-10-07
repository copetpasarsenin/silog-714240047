// Modul 03 - Latihan 1: Null Safety & Latihan 2: Penanganan Error

class DataKiriman {
  final String resi; // wajib
  final String kotaTujuan; // wajib
  final String? catatan; // opsional
  final DateTime? waktuTerima; // opsional

  DataKiriman({
    required this.resi,
    required this.kotaTujuan,
    this.catatan,
    this.waktuTerima,
  });
}

String ringkasan(DataKiriman k) {
  final catatan = k.catatan ?? '(tanpa catatan)';
  final status = k.waktuTerima == null
      ? 'Dalam perjalanan'
      : 'Diterima pada ${k.waktuTerima!.toIso8601String()}';
  return '${k.resi} | ${k.kotaTujuan} | $status | $catatan';
}

// Latihan 2: Penanganan Error
class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

final Map<String, String> basisResi = {
  'SLG-001': 'Bandung',
  'SLG-002': 'Surabaya',
};

String cariKota(String resi) {
  final kota = basisResi[resi];
  if (kota == null) {
    throw ResiTidakDitemukan(resi);
  }
  return kota;
}

void ujiPenanganan() {
  for (final resi in ['SLG-001', 'SLG-999']) {
    try {
      print('$resi -> ${cariKota(resi)}');
    } on ResiTidakDitemukan catch (e) {
      print('Peringatan: $e');
    } catch (e, s) {
      print('Kesalahan tidak terduga: $e');
      print(s);
    } finally {
      print('Pencarian $resi selesai.');
    }
  }
}

void main() {
  // Latihan 1: Null Safety
  final daftar = <DataKiriman>[
    DataKiriman(resi: 'SLG-001', kotaTujuan: 'Bandung'),
    DataKiriman(
      resi: 'SLG-002',
      kotaTujuan: 'Surabaya',
      catatan: 'Titipkan ke satpam',
      waktuTerima: DateTime(2026, 9, 12, 10, 30),
    ),
  ];

  for (final k in daftar) {
    print(ringkasan(k));
  }

  print('');

  // Latihan 2: Penanganan Error
  ujiPenanganan();
}
