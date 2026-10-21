mixin Terlacak {
  final List<String> _riwayat = [];

  List<String> get riwayat => List.unmodifiable(_riwayat);

  void catatPosisi(String lokasi) {
    final waktu = DateTime.now().toIso8601String().substring(11, 16);
    _riwayat.add('[$waktu] $lokasi');
  }

  String posisiTerakhir() =>
      _riwayat.isEmpty ? 'Belum ada data posisi' : _riwayat.last;
}

mixin Terasuransi {
  double persentasePremi = 0.005;

  double hitungPremi(double nilaiBarang) {
    if (nilaiBarang < 0) {
      throw ArgumentError.value(
        nilaiBarang,
        'nilaiBarang',
        'harus tidak negatif',
      );
    }
    return nilaiBarang * persentasePremi;
  }
}

abstract class LayananPengiriman {
  final String kodeLayanan;
  final double jarakKm;
  final double beratKg;

  LayananPengiriman({
    required this.kodeLayanan,
    required this.jarakKm,
    required this.beratKg,
  });

  double hitungTarif();

  int estimasiHari();

  String ringkasan() {
    final tarif = hitungTarif().toStringAsFixed(0);
    return '$kodeLayanan | ${jarakKm.toStringAsFixed(0)} km | '
        '${beratKg.toStringAsFixed(1)} kg | Rp$tarif | ${estimasiHari()} hari';
  }
}
