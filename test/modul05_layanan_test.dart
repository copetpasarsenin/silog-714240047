import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/layanan/layanan_pengiriman.dart';
import 'package:silog_app/layanan/moda.dart';

void main() {
  group('LayananPengiriman', () {
    test('menghitung tarif dan estimasi sesuai moda', () {
      final truk = PengirimanTruk(
        kodeLayanan: 'TRK-REG',
        jarakKm: 780,
        beratKg: 1200,
      );
      final kereta = PengirimanKeretaApi(
        kodeLayanan: 'KA-CARGO',
        jarakKm: 780,
        beratKg: 1200,
        stasiunAsal: 'Kiaracondong',
        stasiunTujuan: 'Pasar Turi',
      );
      final kapal = PengirimanKapal(
        kodeLayanan: 'KPL-PETI',
        jarakKm: 1450,
        beratKg: 1200,
        volumeM3: 8.5,
      );

      expect(truk.hitungTarif(), 4950000);
      expect(truk.estimasiHari(), 2);
      expect(kereta.hitungTarif(), 1139200);
      expect(kereta.estimasiHari(), 3);
      expect(kapal.hitungTarif(), 8975000);
      expect(kapal.estimasiHari(), 8);
      expect(kereta.ringkasan(), contains('Kiaracondong-Pasar Turi'));
    });

    test('menentukan berat tertagih udara dari berat volumetrik', () {
      final udara = PengirimanUdara(
        kodeLayanan: 'UDR-001',
        jarakKm: 950,
        beratKg: 12.4,
        panjangCm: 90,
        lebarCm: 60,
        tinggiCm: 50,
      );

      expect(udara.beratVolumetrik, 45);
      expect(udara.beratTertagih, 45);
      expect(udara.hitungTarif(), 3675000);
      expect(udara.estimasiHari(), 2);
    });

    test('mixin asuransi hanya tersedia pada kapal dan udara', () {
      final kapal = PengirimanKapal(
        kodeLayanan: 'KPL-001',
        jarakKm: 100,
        beratKg: 10,
        volumeM3: 2,
      );
      final udara = PengirimanUdara(
        kodeLayanan: 'UDR-002',
        jarakKm: 100,
        beratKg: 10,
        panjangCm: 10,
        lebarCm: 10,
        tinggiCm: 10,
      );
      final truk = PengirimanTruk(
        kodeLayanan: 'TRK-001',
        jarakKm: 100,
        beratKg: 10,
      );

      expect(kapal, isA<Terasuransi>());
      expect(udara, isA<Terasuransi>());
      expect(truk, isNot(isA<Terasuransi>()));
      expect(kapal.hitungPremi(2000000), 10000);
      expect(udara.hitungPremi(2000000), 15000);
    });

    test('mencatat posisi tanpa membuka riwayat internal', () {
      final truk = PengirimanTruk(
        kodeLayanan: 'TRK-001',
        jarakKm: 100,
        beratKg: 10,
      );

      truk.catatPosisi('Gudang Bandung');

      expect(truk.riwayat, hasLength(1));
      expect(truk.posisiTerakhir(), contains('Gudang Bandung'));
      expect(() => truk.riwayat.add('ubah'), throwsUnsupportedError);
    });
  });
}
