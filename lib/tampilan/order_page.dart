import 'package:flutter/material.dart';

import '../data/order_api.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  final OrderApi? api;

  const OrderPage({super.key, this.api});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final OrderApi _api;
  late Future<List<Order>> _future;
  bool _mengirim = false;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? OrderApi();
    _future = _api.ambilDaftar();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final baru = _api.ambilDaftar();
    setState(() {
      _future = baru;
    });
    try {
      await baru;
    } catch (_) {}
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

          return RefreshIndicator(
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
