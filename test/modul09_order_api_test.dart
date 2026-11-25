import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:silog_app/data/order_api.dart';
import 'package:silog_app/model/order.dart';
import 'package:silog_app/tampilan/daftar_pengiriman_page.dart';
import 'package:silog_app/tampilan/order_page.dart';

void main() {
  test('Order.fromJson, toJson, dan toString sesuai spesifikasi', () {
    final lengkap = Order.fromJson({
      'id': 12,
      'userId': 3,
      'title': 'Pengiriman Beras',
      'body': 'Kirim ke gudang Bandung',
    });
    expect(lengkap.id, 12);
    expect(lengkap.idPelanggan, 3);
    expect(lengkap.judul, 'Pengiriman Beras');
    expect(lengkap.keterangan, 'Kirim ke gudang Bandung');
    expect(lengkap.toJson(), {
      'id': 12,
      'userId': 3,
      'title': 'Pengiriman Beras',
      'body': 'Kirim ke gudang Bandung',
    });
    expect(
      lengkap.toString(),
      'Order(id: 12, idPelanggan: 3, judul: Pengiriman Beras)',
    );

    final tanpaId = Order(
      idPelanggan: 5,
      judul: 'Paket Baru',
      keterangan: 'Catatan',
    );
    expect(tanpaId.toJson(), {
      'userId': 5,
      'title': 'Paket Baru',
      'body': 'Catatan',
    });

    final defaultNilai = Order.fromJson({'userId': 7});
    expect(defaultNilai.id, isNull);
    expect(defaultNilai.idPelanggan, 7);
    expect(defaultNilai.judul, '(tanpa judul)');
    expect(defaultNilai.keterangan, '');
  });

  test('ambilDaftar mengirim query _limit dan memetakan daftar Order', () async {
    Uri? uriDiminta;
    final api = OrderApi(
      client: MockClient((request) async {
        uriDiminta = request.url;
        return http.Response(
          jsonEncode([
            {'id': 1, 'userId': 1, 'title': 'Order A', 'body': 'Isi A'},
            {'id': 2, 'userId': 2, 'title': null, 'body': null},
          ]),
          200,
        );
      }),
    );

    final daftar = await api.ambilDaftar(limit: 2);
    expect(uriDiminta?.queryParameters['_limit'], '2');
    expect(daftar, hasLength(2));
    expect(daftar[0].judul, 'Order A');
    expect(daftar[1].judul, '(tanpa judul)');
    expect(daftar[1].keterangan, '');
    api.tutup();
  });

  test('kirimOrder mengirim POST JSON dan mengembalikan Order dengan id', () async {
    String? metode;
    Map<String, dynamic>? bodyTerkirim;
    final api = OrderApi(
      client: MockClient((request) async {
        metode = request.method;
        bodyTerkirim = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 101,
            'userId': 4,
            'title': 'Kirim Mesin',
            'body': 'Segera proses',
          }),
          201,
        );
      }),
    );

    final hasil = await api.kirimOrder(
      const Order(
        idPelanggan: 4,
        judul: 'Kirim Mesin',
        keterangan: 'Segera proses',
      ),
    );
    expect(metode, 'POST');
    expect(bodyTerkirim, {
      'userId': 4,
      'title': 'Kirim Mesin',
      'body': 'Segera proses',
    });
    expect(hasil.id, 101);
    expect(hasil.judul, 'Kirim Mesin');
    api.tutup();
  });

  test('OrderApi menangani status 500, ClientException, TimeoutException, dan JSON rusak', () async {
    final api500 = OrderApi(
      client: MockClient((_) async => http.Response('Error', 500)),
    );
    await expectLater(
      api500.ambilDaftar(),
      throwsA(
        isA<GagalApi>().having((e) => e.kode, 'kode', 500),
      ),
    );
    api500.tutup();

    final apiClientErr = OrderApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      apiClientErr.ambilDaftar(),
      throwsA(
        isA<GagalApi>().having((e) => e.kode, 'kode', isNull),
      ),
    );
    apiClientErr.tutup();

    final apiTimeout = OrderApi(
      client: MockClient((_) async => throw TimeoutException('timeout')),
    );
    await expectLater(
      apiTimeout.kirimOrder(
        const Order(idPelanggan: 1, judul: 'Tes', keterangan: 'Tes'),
      ),
      throwsA(
        isA<GagalApi>().having((e) => e.kode, 'kode', isNull),
      ),
    );
    apiTimeout.tutup();

    final apiBadJson = OrderApi(
      client: MockClient((_) async => http.Response('{bukan-json', 200)),
    );
    await expectLater(
      apiBadJson.ambilDaftar(),
      throwsA(
        isA<GagalApi>().having((e) => e.kode, 'kode', isNull),
      ),
    );
    apiBadJson.tutup();

    final apiNotList = OrderApi(
      client: MockClient((_) async => http.Response('{"id": 1}', 200)),
    );
    await expectLater(
      apiNotList.ambilDaftar(),
      throwsA(
        isA<GagalApi>().having((e) => e.kode, 'kode', isNull),
      ),
    );
    apiNotList.tutup();
  });

  testWidgets('OrderPage menampilkan judul, subtitle, daftar order, dan kirim order sukses', (tester) async {
    Map<String, dynamic>? bodyTerkirim;
    final api = OrderApi(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'userId': 3,
                'title': 'Order Pertama',
                'body': 'Detail order pertama',
              },
            ]),
            200,
          );
        }
        bodyTerkirim = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 101,
            'userId': 7,
            'title': 'Order pengiriman Bandung Surabaya',
            'body': '3 koli, berat total 42 kg, layanan reguler',
          }),
          201,
        );
      }),
    );

    await tester.pumpWidget(MaterialApp(home: OrderPage(api: api)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Order dari Layanan Web'), findsOneWidget);
    expect(find.text('Richard Firmansyah - 714240047'), findsOneWidget);
    expect(find.text('Order Pertama'), findsOneWidget);
    expect(find.text('Detail order pertama'), findsOneWidget);
    expect(find.text('Plg 3'), findsOneWidget);

    await tester.tap(find.text('Kirim Order'));
    await tester.pumpAndSettle();

    expect(bodyTerkirim, {
      'userId': 7,
      'title': 'Order pengiriman Bandung Surabaya',
      'body': '3 koli, berat total 42 kg, layanan reguler',
    });
    expect(find.text('Order terkirim dengan id 101'), findsOneWidget);
  });

  testWidgets('OrderPage menampilkan state kosong, error dengan Coba Lagi, dan gagal kirim', (tester) async {
    final apiKosong = OrderApi(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    await tester.pumpWidget(MaterialApp(home: OrderPage(api: apiKosong)));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada order yang tercatat'), findsOneWidget);

    var percobaanGet = 0;
    final apiErrorLaluSukses = OrderApi(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          percobaanGet++;
          if (percobaanGet == 1) {
            throw http.ClientException('offline');
          }
          return http.Response(
            jsonEncode([
              {
                'id': 8,
                'userId': 2,
                'title': 'Order Pulih',
                'body': 'Sukses setelah coba lagi',
              },
            ]),
            200,
          );
        }
        return http.Response('Server Error', 500);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(home: OrderPage(key: const ValueKey('error-retry'), api: apiErrorLaluSukses)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Order Pulih'), findsOneWidget);
    expect(find.text('Plg 2'), findsOneWidget);

    await tester.tap(find.text('Kirim Order'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Gagal: '),
      findsOneWidget,
    );
  });

  testWidgets('DaftarPengirimanPage memiliki tombol navigasi ke OrderPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DaftarPengirimanPage()));
    expect(find.byTooltip('Order Layanan Web'), findsOneWidget);
  });
}
