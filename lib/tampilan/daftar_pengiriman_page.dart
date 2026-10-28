import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatelessWidget {
  const DaftarPengirimanPage({super.key});

  List<Pengiriman> _filter(String? status) {
    if (status == null) {
      return dataPengiriman;
    }
    return dataPengiriman.where((item) => item.status == status).toList();
  }

  Widget _ringkasan(BuildContext context) {
    final totalNilai = dataPengiriman.fold<double>(
      0,
      (total, item) => total + item.nilaiBarang,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dataPengiriman.length} Pengiriman',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Total nilai barang Rp${totalNilai.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Richard Firmansyah • 714240047',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _daftar(BuildContext context, String? status) {
    final pengiriman = _filter(status);
    if (pengiriman.isEmpty) {
      return const Center(child: Text('Tidak ada pengiriman'));
    }

    return ListView.builder(
      itemCount: pengiriman.length,
      itemBuilder: (context, index) {
        final item = pengiriman[index];
        return KartuPengiriman(
          pengiriman: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPengirimanPage(pengiriman: item),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Cari resi',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Perjalanan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ringkasan(context),
            Expanded(
              child: TabBarView(
                children: [
                  _daftar(context, null),
                  _daftar(context, 'Dalam Perjalanan'),
                  _daftar(context, 'Diterima'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }
}
