import 'package:flutter/material.dart';

import '../data/order_api.dart';
import '../data/order_cache.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  final OrderApi? api;
  final OrderCache? cache;

  const OrderPage({super.key, this.api, this.cache});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final OrderApi _api;
  late final OrderCache _cache;
  late Future<List<Order>> _future;
  bool _mengirim = false;
  String? _peringatan;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? OrderApi();
    _cache = widget.cache ?? OrderCache.instance;
    _future = _ambilDenganCadangan();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<List<Order>> _ambilDenganCadangan() async {
    try {
      final segar = await _api.ambilDaftar();
      await _cache.simpanSemua(segar);
      _peringatan = null;
      return segar;
    } on GagalApi catch (e) {
      final lokal = await _cache.ambilSemua();
      if (lokal.isNotEmpty) {
        _peringatan = 'Menampilkan data tersimpan. $e';
        return lokal;
      }
      _peringatan = null;
      rethrow;
    }
  }

  Future<void> _muatUlang() async {
    final baru = _ambilDenganCadangan();
    setState(() {
      _future = baru;
    });
    try {
      await baru;
    } catch (_) {}
  }

  Future<void> _hapusCache() async {
    await _cache.hapusSemua();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache order berhasil dihapus')),
    );
  }

  Future<void> _kirimOrderContoh() async {
    if (_mengirim) return;
    setState(() => _mengirim = true);
    try {
      final hasil = await _api.kirimOrder(
        const Order(
          idPelanggan: 7,
          judul: 'Order pengiriman Bandung Surabaya',
          keterangan: '3 koli, berat total 42 kg, layanan reguler',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order terkirim dengan id ${hasil.id}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _mengirim = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order dari Layanan Web'),
            Text(
              'Richard Firmansyah - 714240047',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus Cache',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _hapusCache,
          ),
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(
              child: Text('Belum ada order yang tercatat'),
            );
          }

          return Column(
            children: [
              if (_peringatan != null)
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _peringatan!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _muatUlang,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: daftar.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final o = daftar[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${o.id ?? '-'}')),
                        title: Text(
                          o.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          o.keterangan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text('Plg ${o.idPelanggan}'),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mengirim ? null : _kirimOrderContoh,
        icon: const Icon(Icons.send),
        label: const Text('Kirim Order'),
      ),
    );
  }
}
