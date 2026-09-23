double beratVolumetrik(double p, double l, double t, {double faktor = 6000}) =>
    (p * l * t) / faktor;

double beratTertagih({required double aktual, required double volumetrik}) =>
    aktual > volumetrik ? aktual : volumetrik;

double hitungOngkir({
  required double berat,
  required double tarifPerKg,
  bool asuransi = false,
  double persenAsuransi = 0.005,
  double nilaiBarang = 0,
}) {
  var biaya = berat * tarifPerKg;
  if (asuransi) biaya += nilaiBarang * persenAsuransi;
  return biaya;
}

String rupiah(double nilai) => 'Rp${nilai.toStringAsFixed(0)}';

int estimasiHariSampai(String kota) {
  switch (kota) {
    case 'Bandung':
      return 1;
    case 'Surabaya':
      return 2;
    case 'Makassar':
      return 4;
    case 'Jayapura':
      return 7;
    default:
      return 5;
  }
}

String kategoriKiriman(double berat) {
  if (berat <= 5) return 'Paket Kecil';
  if (berat <= 20) return 'Paket Sedang';
  return 'Kargo';
}

List<Map<String, Object>> daftarKiriman() => [
  {'resi': 'SLG-101', 'berat': 3.2},
  {'resi': 'SLG-102', 'berat': 12.4},
  {'resi': 'SLG-103', 'berat': 27.5},
  {'resi': 'SLG-104', 'berat': 4.8},
  {'resi': 'SLG-105', 'berat': 18.0},
  {'resi': 'SLG-106', 'berat': 6.7},
  {'resi': 'SLG-107', 'berat': 22.1},
  {'resi': 'SLG-108', 'berat': 1.5},
];

double beratDari(Map<String, Object> kiriman) => kiriman['berat'] as double;

double totalBerat(List<Map<String, Object>> kiriman) =>
    kiriman.fold<double>(0, (total, item) => total + beratDari(item));

double rataRataBerat(List<Map<String, Object>> kiriman) =>
    totalBerat(kiriman) / kiriman.length;

Map<String, Object> kirimanTerberat(List<Map<String, Object>> kiriman) =>
    kiriman.reduce((a, b) => beratDari(a) > beratDari(b) ? a : b);

Map<String, Object> kirimanTeringan(List<Map<String, Object>> kiriman) =>
    kiriman.reduce((a, b) => beratDari(a) < beratDari(b) ? a : b);

Map<String, int> jumlahPerKategori(List<Map<String, Object>> kiriman) {
  final jumlah = {'Paket Kecil': 0, 'Paket Sedang': 0, 'Kargo': 0};
  for (final item in kiriman) {
    final kategori = kategoriKiriman(beratDari(item));
    jumlah[kategori] = jumlah[kategori]! + 1;
  }
  return jumlah;
}

void tampilkanContohOngkir() {
  final volumetrik = beratVolumetrik(45, 30, 25);
  final tertagih = beratTertagih(aktual: 12.4, volumetrik: volumetrik);
  final ongkir = hitungOngkir(
    berat: tertagih,
    tarifPerKg: 8500,
    asuransi: true,
    nilaiBarang: 2500000,
  );
  print('Berat tertagih : ${tertagih.toStringAsFixed(2)} kg');
  print('Ongkos kirim   : ${rupiah(ongkir)}');
  print('Estimasi tiba Surabaya: ${estimasiHariSampai('Surabaya')} hari');
}

void tampilkanAnalisis(List<Map<String, Object>> kiriman) {
  final terberat = kirimanTerberat(kiriman);
  final teringan = kirimanTeringan(kiriman);
  final kategori = jumlahPerKategori(kiriman);

  print('\n--- Analisis Kiriman ---');
  print('Total berat      : ${totalBerat(kiriman).toStringAsFixed(1)} kg');
  print('Rata-rata berat  : ${rataRataBerat(kiriman).toStringAsFixed(2)} kg');
  print('Kiriman terberat : ${terberat['resi']} (${beratDari(terberat)} kg)');
  print('Kiriman teringan : ${teringan['resi']} (${beratDari(teringan)} kg)');
  kategori.forEach((nama, jumlah) => print('$nama : $jumlah kiriman'));
}

void main() {
  tampilkanContohOngkir();
  tampilkanAnalisis(daftarKiriman());
}
