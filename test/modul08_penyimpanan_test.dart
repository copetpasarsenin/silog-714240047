import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silog_app/data/preferensi.dart';
import 'package:silog_app/data/stok_repository.dart';
import 'package:silog_app/model/stok.dart';
import 'package:silog_app/tampilan/stok_page.dart';

Stok stok(String kode, String nama, int jumlah, {String gudang = 'GD-BDG'}) =>
    Stok(
      kodeBarang: kode,
      namaBarang: nama,
      kodeGudang: gudang,
      jumlah: jumlah,
      diperbaruiPada: DateTime(2026, 11, 11),
    );

Future<StokRepository> repoBaru() async => StokRepository.denganDatabase(
  await newDatabaseFactoryMemory().openDatabase('uji.db'),
);

void main() {
  test('serialisasi toMap/fromMap dan jumlah negatif ditolak', () {
    final asli = stok('B-1024', 'Sepatu', 10);
    final balik = Stok.fromMap(7, asli.toMap());
    expect(balik.id, 7);
    expect(balik.toString(), asli.toString());
    expect(balik.diperbaruiPada, asli.diperbaruiPada);
    expect(() => stok('B-1', 'X', -1), throwsArgumentError);
  });

  test('repositori: simpan, baca, ubah, hapus, cari', () async {
    final repo = await repoBaru();
    final id = await repo.simpan(stok('B-0001', 'Kaos Katun', 20));
    await repo.simpan(stok('B-0002', 'Air Mineral', 5));
    await repo.simpan(stok('B-0003', 'Kaos Polo', 7, gudang: 'GD-JKT'));

    final bdg = await repo.ambilSemua(kodeGudang: 'GD-BDG');
    expect(bdg.map((s) => s.namaBarang), ['Air Mineral', 'Kaos Katun']);
    expect(await repo.totalStokGudang('GD-BDG'), 25);

    final satu = (await repo.ambilSatu(id))!;
    await repo.perbarui(satu.salinDengan(jumlah: 30));
    expect((await repo.ambilSatu(id))!.jumlah, 30);
    expect(
      () => repo.perbarui(stok('B-9', 'Tanpa Id', 1)),
      throwsArgumentError,
    );

    expect((await repo.cari('kaos')).length, 2);
    expect(
      (await repo.cari('KAOS', kodeGudang: 'GD-JKT')).single.kodeBarang,
      'B-0003',
    );
    expect(await repo.cari('(('), isEmpty, reason: 'regex di-escape');

    await repo.hapus(id);
    expect(await repo.ambilSatu(id), isNull);
    await repo.kosongkan();
    expect(await repo.ambilSemua(), isEmpty);
  });

  test('preferensi gudang terakhir dan mode gelap tersimpan', () async {
    SharedPreferences.setMockInitialValues({});
    final pref = Preferensi();
    expect(await pref.ambilGudangTerakhir(), 'GD-BDG');
    expect(await pref.modeGelap(), isFalse);
    await pref.simpanGudangTerakhir('GD-JKT');
    await pref.setModeGelap(true);
    expect(await pref.ambilGudangTerakhir(), 'GD-JKT');
    expect(await pref.modeGelap(), isTrue);
  });

  testWidgets('StokPage: form validasi lalu stok tampil', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = await tester.runAsync(repoBaru);
    await tester.runAsync(() => repo!.simpan(stok('B-0001', 'Kaos Katun', 4)));
    await tester.pumpWidget(MaterialApp(home: StokPage(repository: repo)));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kaos Katun'), findsOneWidget);

    await tester.tap(find.text('Tambah Stok'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Stok'));
    await tester.pumpAndSettle();
    expect(find.text('Kode barang wajib diisi'), findsOneWidget);
    expect(find.text('Nama barang wajib diisi'), findsOneWidget);
    expect(find.text('Jumlah wajib diisi'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('kodeBarang')), 'B-0001');
    await tester.enterText(find.byKey(const Key('namaStok')), 'Ab');
    await tester.pumpAndSettle();
    expect(find.text('Kode barang sudah ada di gudang ini'), findsOneWidget);
    expect(find.text('Nama barang minimal 3 karakter'), findsOneWidget);
  });
}
