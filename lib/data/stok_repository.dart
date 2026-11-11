import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import '../model/stok.dart';

class StokRepository {
  static final StokRepository instance = StokRepository._();
  StokRepository._();

  /// Dipakai pengujian dengan basis data memori agar repositori diuji mandiri.
  @visibleForTesting
  StokRepository.denganDatabase(Database db) : _db = db;

  Database? _db;
  final _store = intMapStoreFactory.store('stok');

  Future<Database> get _database async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('silog.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await databaseFactoryIo.openDatabase('${dir.path}/silog.db');
    }
    return _db!;
  }

  List<Stok> _keStok(List<RecordSnapshot<int, Map<String, Object?>>> rekaman) =>
      rekaman.map((r) => Stok.fromMap(r.key, r.value)).toList();

  /// CREATE
  Future<int> simpan(Stok stok) async {
    final db = await _database;
    return _store.add(db, stok.toMap());
  }

  /// READ - seluruh data, diurutkan berdasarkan nama barang
  Future<List<Stok>> ambilSemua({String? kodeGudang}) async {
    final db = await _database;
    final finder = Finder(
      filter: kodeGudang == null
          ? null
          : Filter.equals('kodeGudang', kodeGudang),
      sortOrders: [SortOrder('namaBarang')],
    );
    return _keStok(await _store.find(db, finder: finder));
  }

  /// READ - pencarian nama barang (tidak peka huruf besar/kecil)
  Future<List<Stok>> cari(String kata, {String? kodeGudang}) async {
    final db = await _database;
    final filterNama = Filter.matchesRegExp(
      'namaBarang',
      RegExp(RegExp.escape(kata.trim()), caseSensitive: false),
    );
    final finder = Finder(
      filter: kodeGudang == null
          ? filterNama
          : Filter.and([Filter.equals('kodeGudang', kodeGudang), filterNama]),
      sortOrders: [SortOrder('namaBarang')],
    );
    return _keStok(await _store.find(db, finder: finder));
  }

  /// READ - satu data
  Future<Stok?> ambilSatu(int id) async {
    final db = await _database;
    final nilai = await _store.record(id).get(db);
    return nilai == null ? null : Stok.fromMap(id, nilai);
  }

  /// UPDATE
  Future<void> perbarui(Stok stok) async {
    if (stok.id == null) {
      throw ArgumentError('Data tanpa id tidak dapat diperbarui');
    }
    final db = await _database;
    await _store.record(stok.id!).update(db, stok.toMap());
  }

  /// DELETE
  Future<void> hapus(int id) async {
    final db = await _database;
    await _store.record(id).delete(db);
  }

  Future<int> totalStokGudang(String kodeGudang) async {
    final daftar = await ambilSemua(kodeGudang: kodeGudang);
    return daftar.fold<int>(0, (a, s) => a + s.jumlah);
  }

  Future<void> kosongkan() async {
    final db = await _database;
    await _store.delete(db);
  }
}
