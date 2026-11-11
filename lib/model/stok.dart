class Stok {
  final int? id;
  final String kodeBarang;
  final String namaBarang;
  final String kodeGudang;
  final int jumlah;
  final DateTime diperbaruiPada;

  Stok({
    this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kodeGudang,
    required this.jumlah,
    required this.diperbaruiPada,
  }) {
    if (jumlah < 0) throw ArgumentError('Jumlah stok tidak boleh negatif');
  }

  Map<String, Object?> toMap() => {
    'kodeBarang': kodeBarang,
    'namaBarang': namaBarang,
    'kodeGudang': kodeGudang,
    'jumlah': jumlah,
    'diperbaruiPada': diperbaruiPada.toIso8601String(),
  };

  factory Stok.fromMap(int id, Map<String, Object?> map) => Stok(
    id: id,
    kodeBarang: map['kodeBarang'] as String,
    namaBarang: map['namaBarang'] as String,
    kodeGudang: map['kodeGudang'] as String,
    jumlah: map['jumlah'] as int,
    diperbaruiPada: DateTime.parse(map['diperbaruiPada'] as String),
  );

  Stok salinDengan({int? jumlah}) => Stok(
    id: id,
    kodeBarang: kodeBarang,
    namaBarang: namaBarang,
    kodeGudang: kodeGudang,
    jumlah: jumlah ?? this.jumlah,
    diperbaruiPada: DateTime.now(),
  );

  @override
  String toString() => '[$kodeBarang] $namaBarang @ $kodeGudang = $jumlah';
}
