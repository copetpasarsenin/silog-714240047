// ignore_for_file: avoid_print

void main() {
  final tarifZona = <String, double>{
    'Bandung': 6000,
    'Surabaya': 8500,
    'Makassar': 14000,
    'Jayapura': 21000,
  };
  final kiriman = <Map<String, Object>>[
    {'resi': 'SLG-001', 'kota': 'Bandung', 'berat': 3.0},
    {'resi': 'SLG-002', 'kota': 'Surabaya', 'berat': 12.5},
    {'resi': 'SLG-003', 'kota': 'Makassar', 'berat': 7.2},
    {'resi': 'SLG-004', 'kota': 'Surabaya', 'berat': 4.8},
    {'resi': 'SLG-005', 'kota': 'Jayapura', 'berat': 18.0},
    {'resi': 'SLG-006', 'kota': 'Bandung', 'berat': 9.5},
    {'resi': 'SLG-007', 'kota': 'Makassar', 'berat': 21.0},
    {'resi': 'SLG-008', 'kota': 'Jayapura', 'berat': 2.5},
  ];
  final rekapPerKota = <String, double>{};
  var totalPendapatan = 0.0;

  for (final item in kiriman) {
    final kota = item['kota'] as String;
    final berat = item['berat'] as double;
    final biaya = berat * (tarifZona[kota] ?? 0);
    totalPendapatan += biaya;
    rekapPerKota[kota] = (rekapPerKota[kota] ?? 0) + biaya;
    print('${item['resi']}  $kota  ${berat}kg  Rp${biaya.toStringAsFixed(0)}');
  }

  print('\n--- Rekapitulasi per Kota ---');
  rekapPerKota.forEach(
    (kota, total) => print('$kota : Rp${total.toStringAsFixed(0)}'),
  );
  print('Total pendapatan : Rp${totalPendapatan.toStringAsFixed(0)}');
}
