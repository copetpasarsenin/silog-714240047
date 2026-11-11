import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../data/preferensi.dart';
import '../main.dart' show modeGelap;
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';
import 'stok_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  late List<Pengiriman> _daftar;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _daftar = List<Pengiriman>.from(dataPengiriman);
  }

  List<Pengiriman> get _hasilSaring => _filterStatus == 'Semua'
      ? _daftar
      : _daftar.where((item) => item.status == _filterStatus).toList();

  bool _resiSudahAda(String resi) =>
      _daftar.any((item) => item.resi.toUpperCase() == resi.toUpperCase());

  Future<void> _bukaFormulir() async {
    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengirimanPage(resiSudahAda: _resiSudahAda),
      ),
    );
    if (hasil == null || !mounted) return;
    setState(() => _daftar.insert(0, hasil));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengiriman ${hasil.resi} berhasil ditambahkan')),
    );
  }

  Future<void> _bukaDetail(Pengiriman pengiriman) async {
    final dihapus = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPengirimanPage(pengiriman: pengiriman),
      ),
    );
    if (dihapus != true || !mounted) return;
    setState(() => _daftar.remove(pengiriman));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengiriman ${pengiriman.resi} dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const opsi = ['Semua', 'Menunggu Pickup', 'Dalam Perjalanan', 'Diterima'];
    final hasil = _hasilSaring;
    final totalNilai = _daftar.fold<double>(
      0,
      (total, item) => total + item.nilaiBarang,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengiriman'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: modeGelap,
            builder: (context, gelap, _) => IconButton(
              tooltip: gelap ? 'Mode terang' : 'Mode gelap',
              icon: Icon(gelap ? Icons.light_mode : Icons.dark_mode),
              onPressed: () async {
                modeGelap.value = !gelap;
                await Preferensi().setModeGelap(!gelap);
              },
            ),
          ),
          IconButton(
            tooltip: 'Stok Gudang',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StokPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
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
                  child: Text(
                    '${_daftar.length} Pengiriman\n'
                    'Total nilai barang Rp${totalNilai.toStringAsFixed(0)}\n'
                    'Richard Firmansyah • 714240047',
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: opsi.map((opsiStatus) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(opsiStatus),
                    selected: _filterStatus == opsiStatus,
                    onSelected: (_) =>
                        setState(() => _filterStatus = opsiStatus),
                  ),
                );
              }).toList(),
            ),
          ),
          Text('Menampilkan ${hasil.length} dari ${_daftar.length} data'),
          Expanded(
            child: hasil.isEmpty
                ? const Center(child: Text('Tidak ada data pengiriman'))
                : ListView.builder(
                    itemCount: hasil.length,
                    itemBuilder: (context, index) {
                      final item = hasil[index];
                      return KartuPengiriman(
                        pengiriman: item,
                        onTap: () => _bukaDetail(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
    );
  }
}
