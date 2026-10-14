import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/main.dart';

void main() {
  testWidgets('menampilkan beranda SiLog', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SiLog - Modul 1'), findsOneWidget);
    expect(find.text('Sistem Informasi Logistik'), findsOneWidget);
    expect(find.text('Nama: Richard Firmansyah'), findsOneWidget);
  });
}
