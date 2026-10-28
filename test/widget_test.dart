import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/main.dart';

void main() {
  testWidgets('menampilkan daftar seluruh pengiriman', (tester) async {
    await tester.pumpWidget(const SiLogApp());

    expect(find.text('Daftar Pengiriman'), findsOneWidget);
    expect(find.text('SLG-2026-0001'), findsOneWidget);
    expect(find.text('SLG-2026-0002'), findsOneWidget);
    expect(find.text('SLG-2026-0003'), findsOneWidget);
    expect(find.text('3 Pengiriman'), findsOneWidget);
  });

  testWidgets('filter tab dan navigasi detail berfungsi', (tester) async {
    await tester.pumpWidget(const SiLogApp());

    await tester.tap(find.text('Diterima').last);
    await tester.pumpAndSettle();
    expect(find.text('SLG-2026-0003'), findsOneWidget);
    expect(find.text('SLG-2026-0001'), findsNothing);

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SLG-2026-0001'));
    await tester.pumpAndSettle();
    expect(find.text('Informasi Pengiriman'), findsOneWidget);
    expect(find.text('Kembali ke Daftar'), findsOneWidget);

    final kembali = find.text('Kembali ke Daftar');
    await tester.ensureVisible(kembali);
    await tester.tap(kembali);
    await tester.pumpAndSettle();
    expect(find.text('Daftar Pengiriman'), findsOneWidget);
  });
}
