import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/main.dart';

Future<void> bukaForm(WidgetTester tester) async {
  await tester.tap(find.text('Pengiriman Baru'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('form menolak field kosong dan resi duplikat', (tester) async {
    await tester.pumpWidget(const SiLogApp());
    await bukaForm(tester);

    await tester.tap(find.text('Simpan Pengiriman'));
    await tester.pumpAndSettle();
    expect(find.text('Nomor resi wajib diisi'), findsOneWidget);
    expect(find.text('Nama barang wajib diisi'), findsOneWidget);
    expect(find.text('Harga satuan wajib diisi'), findsOneWidget);
    expect(find.text('Jumlah wajib diisi'), findsOneWidget);
    expect(find.text('Berat barang wajib diisi'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('resi')), 'SLG-2026-0001');
    await tester.enterText(find.byKey(const Key('namaBarang')), 'Buku');
    await tester.enterText(find.byKey(const Key('harga')), '12000');
    await tester.enterText(find.byKey(const Key('jumlah')), '2');
    await tester.enterText(find.byKey(const Key('berat')), '0');
    final simpanDuplikat = find.text('Simpan Pengiriman');
    await tester.ensureVisible(simpanDuplikat);
    await tester.pumpAndSettle();
    await tester.tap(simpanDuplikat);
    await tester.pumpAndSettle();
    expect(find.text('Nomor resi sudah digunakan'), findsOneWidget);
    expect(
      find.text('Berat barang harus antara 0.1 dan 5000.0'),
      findsOneWidget,
    );
  });

  testWidgets('pengiriman valid ditambahkan lalu dapat dihapus', (
    tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());
    await bukaForm(tester);

    await tester.enterText(find.byKey(const Key('resi')), 'SLG-2026-0099');
    await tester.enterText(find.byKey(const Key('namaBarang')), 'Buku');
    await tester.enterText(find.byKey(const Key('harga')), '12000');
    await tester.enterText(find.byKey(const Key('jumlah')), '2');
    await tester.enterText(find.byKey(const Key('berat')), '1.5');
    await tester.tap(find.text('Simpan Pengiriman'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0099'), findsOneWidget);
    expect(
      find.text('Pengiriman SLG-2026-0099 berhasil ditambahkan'),
      findsOneWidget,
    );

    await tester.tap(find.text('SLG-2026-0099'));
    await tester.pumpAndSettle();
    final hapusPengiriman = find.text('Hapus Pengiriman');
    await tester.ensureVisible(hapusPengiriman);
    await tester.tap(hapusPengiriman);
    await tester.pumpAndSettle();
    expect(find.text('Hapus pengiriman?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0099'), findsNothing);
  });
}
