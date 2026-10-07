// Modul 03 - Latihan 3: Future, async, await
// Latihan 4: Eksekusi Paralel dengan Future.wait
// Tugas Praktikum: pantauBanyakResi

// --- Data basis resi (Tugas: minimal 5 resi) ---
final Map<String, String> dataResi = {
  'SLG-001': 'Paket SLG-001 sedang dalam perjalanan menuju gudang transit.',
  'SLG-002': 'Paket SLG-002 telah tiba di gudang Surabaya.',
  'SLG-003': 'Paket SLG-003 sedang diantar oleh kurir.',
  'SLG-004': 'Paket SLG-004 menunggu penjemputan di gudang Bandung.',
  'SLG-005': 'Paket SLG-005 telah diterima oleh penerima.',
};

class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda jaringan selama dua detik
  await Future.delayed(const Duration(seconds: 2));

  if (!resi.startsWith('SLG-')) {
    throw FormatException('Format resi tidak sah: $resi');
  }

  final status = dataResi[resi];
  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }

  return status;
}

Future<double> ambilOngkir(String resi) async {
  await Future.delayed(const Duration(seconds: 1));
  return 105400;
}

// Latihan 4: Eksekusi Paralel dengan Future.wait
Future<void> bandingkanWaktu() async {
  final mulai = DateTime.now();
  final hasil = await Future.wait([
    ambilStatusKiriman('SLG-001'),
    ambilOngkir('SLG-001'),
  ]);
  final durasi = DateTime.now().difference(mulai);
  print('Status : ${hasil[0]}');
  print('Ongkir : ${hasil[1]}');
  print('Durasi total: ${durasi.inMilliseconds} ms');
}

// Tugas Praktikum: pantauBanyakResi
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  final futures = daftarResi.map((resi) async {
    try {
      final status = await ambilStatusKiriman(resi);
      return 'OK   | $resi -> $status';
    } on ResiTidakDitemukan catch (e) {
      return 'GAGAL| $resi -> $e';
    } on FormatException catch (e) {
      return 'GAGAL| $resi -> ${e.message}';
    } catch (e) {
      return 'GAGAL| $resi -> $e';
    }
  }).toList();

  final hasilSemua = await Future.wait(futures);
  for (final h in hasilSemua) {
    print(h);
  }
}

Future<void> main() async {
  // --- Latihan 3: Pemanggilan berurutan ---
  print('=== Latihan 3: Pemanggilan Berurutan ===');
  print('1. Permintaan data dikirim...');
  try {
    final status = await ambilStatusKiriman('SLG-002');
    print('2. $status');
    final ongkir = await ambilOngkir('SLG-002');
    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } catch (e) {
    print('Gagal mengambil data: $e');
  }
  print('4. Proses selesai.');

  print('');

  // --- Latihan 4: Eksekusi Paralel ---
  print('=== Latihan 4: Eksekusi Paralel (Future.wait) ===');
  await bandingkanWaktu();

  print('');

  // --- Tugas: Skenario seluruh resi sah ---
  print('=== Tugas: Skenario Seluruh Resi Sah ===');
  await pantauBanyakResi(['SLG-001', 'SLG-002', 'SLG-003', 'SLG-004', 'SLG-005']);

  print('');

  // --- Tugas: Skenario terdapat resi tidak sah ---
  print('=== Tugas: Skenario Terdapat Resi Tidak Sah ===');
  await pantauBanyakResi(['SLG-001', 'SLG-999', 'XYZ-002', 'SLG-003']);
}
