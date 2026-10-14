class Pelanggan {
  final String kode;
  final String nama;
  final String nomorTelepon;
  final String alamat;

  Pelanggan({
    required this.kode,
    required this.nama,
    required this.nomorTelepon,
    required this.alamat,
  });

  String alamatRingkas() {
    const batas = 40;
    final nilai = alamat.trim();
    if (nilai.length <= batas) {
      return nilai;
    }
    return '${nilai.substring(0, batas - 3).trimRight()}...';
  }

  @override
  String toString() => '$kode | $nama | ${alamatRingkas()}';
}
