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
  final TextEditingController _cariC = TextEditingController();
  String _kataKunci = '';
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
    _cariC.dispose();
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

  void _tampilPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _hapusCache() async {
    await _cache.hapusSemua();
    _tampilPesan('Cache order berhasil dihapus');
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
      _tampilPesan('Order terkirim dengan id ${hasil.id}');
    } catch (e) {
      _tampilPesan('Gagal: $e');
    } finally {
      if (mounted) {
        setState(() => _mengirim = false);
      }
    }
  }

  Future<void> _editOrder(Order order) async {
    final hasilForm = await showDialog<Order>(
      context: context,
      builder: (_) => _DialogEditOrder(order: order),
    );
    if (hasilForm == null || !mounted) return;
    try {
      final hasil = await _api.perbaruiOrder(hasilForm);
      _tampilPesan('Order #${hasil.id} berhasil diperbarui');
    } catch (e) {
      _tampilPesan('Gagal: $e');
    }
  }

  Future<void> _hapusOrder(Order order) async {
    if (order.id == null) return;
    try {
      await _api.hapusOrder(order.id!);
      _tampilPesan('Order #${order.id} berhasil dihapus');
    } catch (e) {
      _tampilPesan('Gagal: $e');
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              key: const Key('cariOrder'),
              controller: _cariC,
              decoration: InputDecoration(
                hintText: 'Cari judul order...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Bersihkan pencarian',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cariC.clear();
                          setState(() => _kataKunci = '');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (nilai) => setState(() => _kataKunci = nilai),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Order>>(
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
                          const Icon(
                            Icons.cloud_off,
                            size: 56,
                            color: Colors.grey,
                          ),
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

                final kueri = _kataKunci.trim().toLowerCase();
                final tersaring = kueri.isEmpty
                    ? daftar
                    : daftar
                        .where((o) => o.judul.toLowerCase().contains(kueri))
                        .toList();

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
                      child: tersaring.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada order yang cocok dengan pencarian',
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _muatUlang,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: tersaring.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final o = tersaring[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${o.id ?? '-'}'),
                                    ),
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Plg ${o.idPelanggan}'),
                                        IconButton(
                                          tooltip: 'Edit order',
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: o.id == null
                                              ? null
                                              : () => _editOrder(o),
                                        ),
                                        IconButton(
                                          tooltip: 'Hapus order',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: o.id == null
                                              ? null
                                              : () => _hapusOrder(o),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mengirim ? null : _kirimOrderContoh,
        icon: const Icon(Icons.send),
        label: const Text('Kirim Order'),
      ),
    );
  }
}

class _DialogEditOrder extends StatefulWidget {
  final Order order;

  const _DialogEditOrder({required this.order});

  @override
  State<_DialogEditOrder> createState() => _DialogEditOrderState();
}

class _DialogEditOrderState extends State<_DialogEditOrder> {
  late final TextEditingController _judulC;
  late final TextEditingController _ketC;

  @override
  void initState() {
    super.initState();
    _judulC = TextEditingController(text: widget.order.judul);
    _ketC = TextEditingController(text: widget.order.keterangan);
  }

  @override
  void dispose() {
    _judulC.dispose();
    _ketC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Order #${widget.order.id}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('editJudulOrder'),
            controller: _judulC,
            decoration: const InputDecoration(
              labelText: 'Judul',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('editKeteranganOrder'),
            controller: _ketC,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Keterangan',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final judulBaru = _judulC.text.trim();
            if (judulBaru.isEmpty) return;
            Navigator.pop(
              context,
              Order(
                id: widget.order.id,
                idPelanggan: widget.order.idPelanggan,
                judul: judulBaru,
                keterangan: _ketC.text.trim(),
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
