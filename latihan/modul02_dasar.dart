// ignore_for_file: avoid_print

void main() {
  const faktorVolumetrik = 6000.0;
  const beratAktual = 12.4;
  const panjang = 45.0;
  const lebar = 30.0;
  const tinggi = 25.0;

  final beratVolumetrik = (panjang * lebar * tinggi) / faktorVolumetrik;
  final beratTertagih = beratAktual > beratVolumetrik
      ? beratAktual
      : beratVolumetrik;
  final kategori = kategoriKiriman(beratTertagih);

  print('Berat aktual     : ${beratAktual.toStringAsFixed(2)} kg');
  print('Berat volumetrik : ${beratVolumetrik.toStringAsFixed(2)} kg');
  print('Berat tertagih   : ${beratTertagih.toStringAsFixed(2)} kg');
  print('Kategori kiriman : $kategori');
}

String kategoriKiriman(double berat) {
  if (berat <= 5) return 'Paket Kecil';
  if (berat <= 20) return 'Paket Sedang';
  return 'Kargo';
}
