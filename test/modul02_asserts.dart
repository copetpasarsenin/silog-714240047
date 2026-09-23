import '../latihan/modul02_dasar.dart' as dasar;
import '../latihan/modul02_fungsi.dart' as fungsi;

void main() {
  final volumetrikBesar = fungsi.beratVolumetrik(90, 60, 50);
  final tertagihBesar = fungsi.beratTertagih(
    aktual: 12.4,
    volumetrik: volumetrikBesar,
  );
  assert(volumetrikBesar == 45);
  assert(tertagihBesar == 45);
  assert(dasar.kategoriKiriman(tertagihBesar) == 'Kargo');

  assert(
    fungsi.hitungOngkir(
          berat: 12.4,
          tarifPerKg: 8500,
          asuransi: false,
          nilaiBarang: 2500000,
        ) ==
        105400,
  );

  final kiriman = fungsi.daftarKiriman();
  assert(fungsi.totalBerat(kiriman) == 96.2);
  assert(fungsi.rataRataBerat(kiriman) == 12.025);
  assert(fungsi.kirimanTerberat(kiriman)['resi'] == 'SLG-103');
  assert(fungsi.kirimanTeringan(kiriman)['resi'] == 'SLG-108');
  assert(fungsi.jumlahPerKategori(kiriman)['Paket Kecil'] == 3);
  assert(fungsi.jumlahPerKategori(kiriman)['Paket Sedang'] == 3);
  assert(fungsi.jumlahPerKategori(kiriman)['Kargo'] == 2);
}
