import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:silog_app/data/order_api.dart';
import 'package:silog_app/data/order_cache.dart';
import 'package:silog_app/model/order.dart';
import 'package:silog_app/tampilan/daftar_pengiriman_page.dart';
import 'package:silog_app/tampilan/order_page.dart';

Future<OrderCache> cacheBaru() async => OrderCache.denganDatabase(
  await newDatabaseFactoryMemory().openDatabase('uji_order.db'),
);

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

    final cache = (await tester.runAsync(cacheBaru))!;
    await tester.pumpWidget(MaterialApp(home: OrderPage(api: api, cache: cache)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
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
    final cacheKosong = (await tester.runAsync(cacheBaru))!;
    final apiKosong = OrderApi(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    await tester.pumpWidget(
      MaterialApp(home: OrderPage(api: apiKosong, cache: cacheKosong)),
    );
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada order yang tercatat'), findsOneWidget);

    var percobaanGet = 0;
    final cacheError = (await tester.runAsync(cacheBaru))!;
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
      MaterialApp(
        home: OrderPage(
          key: const ValueKey('error-retry'),
          api: apiErrorLaluSukses,
          cache: cacheError,
        ),
      ),
    );
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
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

  test('OrderCache: simpanSemua, ambilSemua, timpa data lama, dan hapusSemua', () async {
    final cache = await cacheBaru();
    expect(await cache.ambilSemua(), isEmpty);

    await cache.simpanSemua(const [
      Order(id: 1, idPelanggan: 2, judul: 'Order 1', keterangan: 'Ket 1'),
      Order(id: 2, idPelanggan: 3, judul: 'Order 2', keterangan: 'Ket 2'),
    ]);
    final tersimpan = await cache.ambilSemua();
    expect(tersimpan.map((o) => o.judul), ['Order 1', 'Order 2']);

    await cache.simpanSemua(const [
      Order(id: 9, idPelanggan: 4, judul: 'Order Baru', keterangan: 'Ket Baru'),
    ]);
    final ditimpa = await cache.ambilSemua();
    expect(ditimpa.single.judul, 'Order Baru');

    await cache.hapusSemua();
    expect(await cache.ambilSemua(), isEmpty);
  });

  testWidgets('OrderPage fallback ke cache Sembast saat offline, lalu tampil error setelah Hapus Cache', (tester) async {
    var percobaanGet = 0;
    final cache = (await tester.runAsync(cacheBaru))!;
    final api = OrderApi(
      client: MockClient((request) async {
        percobaanGet++;
        if (percobaanGet == 1) {
          return http.Response(
            jsonEncode([
              {
                'id': 11,
                'userId': 5,
                'title': 'Order Tersimpan',
                'body': 'Tersimpan di Sembast',
              },
            ]),
            200,
          );
        }
        throw http.ClientException('offline');
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OrderPage(
          key: const ValueKey('cache-fallback'),
          api: api,
          cache: cache,
        ),
      ),
    );
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Tersimpan'), findsOneWidget);
    expect(find.textContaining('Menampilkan data tersimpan.'), findsNothing);

    await tester.tap(find.byTooltip('Muat ulang'));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Tersimpan'), findsOneWidget);
    expect(find.textContaining('Menampilkan data tersimpan. '), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus Cache'));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cache order berhasil dihapus'), findsOneWidget);

    await tester.tap(find.byTooltip('Muat ulang'));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('DaftarPengirimanPage memiliki tombol navigasi ke OrderPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DaftarPengirimanPage()));
    expect(find.byTooltip('Order Layanan Web'), findsOneWidget);
  });

  test('perbaruiOrder mengirim PUT JSON dan menangani status serta error jaringan', () async {
    String? metode;
    String? path;
    String? contentType;
    Map<String, dynamic>? bodyTerkirim;

    final apiSukses = OrderApi(
      client: MockClient((request) async {
        metode = request.method;
        path = request.url.path;
        contentType = request.headers['content-type'];
        bodyTerkirim = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 12,
            'userId': 3,
            'title': 'Judul Diperbarui',
            'body': 'Keterangan Diperbarui',
          }),
          200,
        );
      }),
    );

    final hasil = await apiSukses.perbaruiOrder(
      const Order(
        id: 12,
        idPelanggan: 3,
        judul: 'Judul Diperbarui',
        keterangan: 'Keterangan Diperbarui',
      ),
    );
    expect(metode, 'PUT');
    expect(path, '/posts/12');
    expect(contentType, contains('application/json'));
    expect(bodyTerkirim, {
      'id': 12,
      'userId': 3,
      'title': 'Judul Diperbarui',
      'body': 'Keterangan Diperbarui',
    });
    expect(hasil.id, 12);
    expect(hasil.judul, 'Judul Diperbarui');
    apiSukses.tutup();

    await expectLater(
      apiSukses.perbaruiOrder(
        const Order(idPelanggan: 1, judul: 'Tanpa ID', keterangan: ''),
      ),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );

    for (final status in [404, 500, 400]) {
      final apiErr = OrderApi(
        client: MockClient((_) async => http.Response('err', status)),
      );
      await expectLater(
        apiErr.perbaruiOrder(
          const Order(id: 12, idPelanggan: 1, judul: 'Tes', keterangan: ''),
        ),
        throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', status)),
      );
      apiErr.tutup();
    }

    final apiTimeout = OrderApi(
      client: MockClient((_) async => throw TimeoutException('timeout')),
    );
    await expectLater(
      apiTimeout.perbaruiOrder(
        const Order(id: 12, idPelanggan: 1, judul: 'Tes', keterangan: ''),
      ),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );
    apiTimeout.tutup();

    final apiClientErr = OrderApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      apiClientErr.perbaruiOrder(
        const Order(id: 12, idPelanggan: 1, judul: 'Tes', keterangan: ''),
      ),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );
    apiClientErr.tutup();

    final apiBadJson = OrderApi(
      client: MockClient((_) async => http.Response('{rusak', 200)),
    );
    await expectLater(
      apiBadJson.perbaruiOrder(
        const Order(id: 12, idPelanggan: 1, judul: 'Tes', keterangan: ''),
      ),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );
    apiBadJson.tutup();
  });

  test('hapusOrder mengirim DELETE dan menangani status serta error jaringan', () async {
    for (final status in [200, 204]) {
      String? metode;
      String? path;
      final apiOk = OrderApi(
        client: MockClient((request) async {
          metode = request.method;
          path = request.url.path;
          return http.Response('', status);
        }),
      );
      await apiOk.hapusOrder(12);
      expect(metode, 'DELETE');
      expect(path, '/posts/12');
      apiOk.tutup();
    }

    for (final status in [404, 500, 403]) {
      final apiErr = OrderApi(
        client: MockClient((_) async => http.Response('err', status)),
      );
      await expectLater(
        apiErr.hapusOrder(12),
        throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', status)),
      );
      apiErr.tutup();
    }

    final apiTimeout = OrderApi(
      client: MockClient((_) async => throw TimeoutException('timeout')),
    );
    await expectLater(
      apiTimeout.hapusOrder(12),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );
    apiTimeout.tutup();

    final apiClientErr = OrderApi(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      apiClientErr.hapusOrder(12),
      throwsA(isA<GagalApi>().having((e) => e.kode, 'kode', isNull)),
    );
    apiClientErr.tutup();
  });

  testWidgets('OrderPage memfilter pencarian judul serta menjalankan aksi Edit dan Hapus', (tester) async {
    String? putPath;
    Map<String, dynamic>? putBody;
    String? deletePath;
    final cache = (await tester.runAsync(cacheBaru))!;

    final api = OrderApi(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'userId': 3,
                'title': 'Pengiriman Bandung',
                'body': 'Koli 1',
              },
              {
                'id': 2,
                'userId': 4,
                'title': 'Pengiriman Surabaya',
                'body': 'Koli 2',
              },
            ]),
            200,
          );
        }
        if (request.method == 'PUT') {
          putPath = request.url.path;
          putBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(request.body, 200);
        }
        if (request.method == 'DELETE') {
          deletePath = request.url.path;
          return http.Response('', 200);
        }
        return http.Response('Not Found', 404);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OrderPage(
          key: const ValueKey('search-edit-delete'),
          api: api,
          cache: cache,
        ),
      ),
    );
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengiriman Bandung'), findsOneWidget);
    expect(find.text('Pengiriman Surabaya'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('cariOrder')), 'bandung');
    await tester.pumpAndSettle();
    expect(find.text('Pengiriman Bandung'), findsOneWidget);
    expect(find.text('Pengiriman Surabaya'), findsNothing);

    await tester.enterText(find.byKey(const Key('cariOrder')), 'tidakada');
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada order yang cocok dengan pencarian'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Bersihkan pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('Pengiriman Bandung'), findsOneWidget);
    expect(find.text('Pengiriman Surabaya'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit order').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('editJudulOrder')),
      'Pengiriman Bandung Express',
    );
    await tester.enterText(
      find.byKey(const Key('editKeteranganOrder')),
      'Koli 1 Prioritas',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(putPath, '/posts/1');
    expect(putBody, {
      'id': 1,
      'userId': 3,
      'title': 'Pengiriman Bandung Express',
      'body': 'Koli 1 Prioritas',
    });
    expect(find.text('Order #1 berhasil diperbarui'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus order').first);
    await tester.pumpAndSettle();
    expect(deletePath, '/posts/1');
    expect(find.text('Order #1 berhasil dihapus'), findsOneWidget);
  });
}
