import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../model/order.dart';

class GagalApi implements Exception {
  final String pesan;
  final int? kode;

  const GagalApi(this.pesan, {this.kode});

  @override
  String toString() => kode == null ? pesan : '$pesan (kode $kode)';
}

class OrderApi {
  static const _basis = 'https://jsonplaceholder.typicode.com';
  static const _batasWaktu = Duration(seconds: 12);

  final http.Client _client;

  OrderApi({http.Client? client}) : _client = client ?? http.Client();

  Future<T> _jalankan<T>(Future<T> Function() aksi) async {
    try {
      return await aksi();
    } on GagalApi {
      rethrow;
    } on TimeoutException {
      throw const GagalApi(
        'Waktu koneksi ke server habis. Silakan periksa jaringan Anda dan coba lagi.',
      );
    } on http.ClientException {
      throw const GagalApi(
        'Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API.',
      );
    } on FormatException {
      throw const GagalApi('Format data dari server tidak valid.');
    }
  }

  Future<List<Order>> ambilDaftar({int limit = 10}) => _jalankan(() async {
    final uri = Uri.parse('$_basis/posts').replace(
      queryParameters: {'_limit': '$limit'},
    );
    final res = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(_batasWaktu);

    if (res.statusCode != 200) {
      throw GagalApi(
        'Gagal mengambil daftar order dari server.',
        kode: res.statusCode,
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw const FormatException(
        'Respons daftar order bukan berupa list JSON.',
      );
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Format item order tidak valid.');
      }
      return Order.fromJson(item);
    }).toList();
  });

  Future<Order> kirimOrder(Order order) => _jalankan(() async {
    final uri = Uri.parse('$_basis/posts');
    final res = await _client
        .post(
          uri,
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(order.toJson()),
        )
        .timeout(_batasWaktu);

    if (res.statusCode != 201 && res.statusCode != 200) {
      debugPrint('OrderApi.kirimOrder: statusCode=${res.statusCode}, id=null');
      throw GagalApi(
        'Gagal mengirim order ke server.',
        kode: res.statusCode,
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Respons kirim order bukan berupa objek JSON.',
      );
    }

    final hasil = Order.fromJson(decoded);
    debugPrint(
      'OrderApi.kirimOrder: statusCode=${res.statusCode}, id=${hasil.id}',
    );
    return hasil;
  });

  void tutup() => _client.close();
}
