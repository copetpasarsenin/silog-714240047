// ignore_for_file: avoid_print

import 'package:silog_app/layanan/layanan_pengiriman.dart';
import 'package:silog_app/layanan/moda.dart';

void main() {
  final List<LayananPengiriman> daftarLayanan = [
    PengirimanTruk(kodeLayanan: 'TRK-REG', jarakKm: 780, beratKg: 1200),
    PengirimanTruk(
      kodeLayanan: 'TRK-EXP',
      jarakKm: 780,
      beratKg: 1200,
      ekspres: true,
    ),
    PengirimanKeretaApi(
      kodeLayanan: 'KA-CARGO',
      jarakKm: 780,
      beratKg: 1200,
      stasiunAsal: 'Kiaracondong',
      stasiunTujuan: 'Pasar Turi',
    ),
    PengirimanKapal(
      kodeLayanan: 'KPL-PETI',
      jarakKm: 1450,
      beratKg: 1200,
      volumeM3: 8.5,
    ),
    PengirimanUdara(
      kodeLayanan: 'UDR-CARGO',
      jarakKm: 950,
      beratKg: 12.4,
      panjangCm: 90,
      lebarCm: 60,
      tinggiCm: 50,
    ),
  ];

  print('=== Perbandingan Layanan Pengiriman ===');
  for (final layanan in daftarLayanan) {
    print(layanan.ringkasan());
  }

  daftarLayanan.sort((a, b) => a.hitungTarif().compareTo(b.hitungTarif()));
  print('\nLayanan termurah: ${daftarLayanan.first.kodeLayanan}');
  print(
    'Layanan tercepat: '
    '${daftarLayanan.reduce((a, b) => a.estimasiHari() <= b.estimasiHari() ? a : b).kodeLayanan}',
  );

  final truk = daftarLayanan.whereType<PengirimanTruk>().first;
  truk.catatPosisi('Gudang Utama Bandung');
  truk.catatPosisi('Rest Area KM 207');
  truk.catatPosisi('Gudang Transit Semarang');
  print('\nRiwayat posisi ${truk.kodeLayanan}:');
  for (final riwayat in truk.riwayat) {
    print(' $riwayat');
  }
  print('Posisi terakhir: ${truk.posisiTerakhir()}');

  final kapal = daftarLayanan.whereType<PengirimanKapal>().first;
  final udara = daftarLayanan.whereType<PengirimanUdara>().first;
  print('\nPremi kapal: Rp${kapal.hitungPremi(2000000).toStringAsFixed(0)}');
  print('Premi udara: Rp${udara.hitungPremi(2000000).toStringAsFixed(0)}');
  print(
    truk is Terasuransi
        ? 'PengirimanTruk memiliki asuransi.'
        : 'PengirimanTruk tidak memiliki metode hitungPremi.',
  );
}
