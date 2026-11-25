import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import '../model/order.dart';

class OrderCache {
  static final OrderCache instance = OrderCache._();
  OrderCache._();

  @visibleForTesting
  OrderCache.denganDatabase(Database db) : _db = db;

  Database? _db;
  final _store = intMapStoreFactory.store('order_cache');

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

  Future<void> simpanSemua(List<Order> daftar) async {
    final db = await _database;
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (final order in daftar) {
        await _store.add(txn, order.toJson());
      }
    });
  }

  Future<List<Order>> ambilSemua() async {
    final db = await _database;
    final rekaman = await _store.find(db);
    return rekaman
        .map((r) => Order.fromJson(Map<String, dynamic>.from(r.value)))
        .toList();
  }

  Future<void> hapusSemua() async {
    final db = await _database;
    await _store.delete(db);
  }
}
