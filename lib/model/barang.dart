class Barang {
  final String kode;
  final String nama;
  final String satuan;
  final double beratKg;
  double _hargaSatuan;

  Barang({
    required this.kode,
    required this.nama,
    required double hargaSatuan,
    this.satuan = 'pcs',
    this.beratKg = 0,
  }) : _hargaSatuan = _hargaTidakNegatif(hargaSatuan);

  Barang.dariPemindaian(String baris)
    : this(
        kode: _kolomPemindaian(baris, 0),
        nama: _kolomPemindaian(baris, 1),
        hargaSatuan: double.parse(_kolomPemindaian(baris, 2)),
      );

  double get hargaSatuan => _hargaSatuan;

  set hargaSatuan(double nilai) {
    _hargaSatuan = _hargaTidakNegatif(nilai);
  }

  double nilaiTotal(int jumlah) => _hargaSatuan * jumlah;

  static double _hargaTidakNegatif(double nilai) {
    if (nilai < 0) {
      throw ArgumentError('Harga satuan tidak boleh negatif');
    }
    return nilai;
  }

  static String _kolomPemindaian(String baris, int indeks) {
    final kolom = baris.split(';');
    if (kolom.length != 3 || kolom.any((nilai) => nilai.trim().isEmpty)) {
      throw FormatException('Data pemindaian harus berupa kode;nama;harga');
    }
    return kolom[indeks].trim();
  }

  @override
  String toString() =>
      '[$kode] $nama ($satuan) - Rp${_hargaSatuan.toStringAsFixed(0)}';
}
