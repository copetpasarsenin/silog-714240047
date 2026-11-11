import 'package:flutter/material.dart';

import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../model/stok.dart';
import 'form_stok_page.dart';

class StokPage extends StatefulWidget {
  final StokRepository? repository;

  const StokPage({super.key, this.repository});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  static const _opsiGudang = ['GD-BDG', 'GD-JKT', 'GD-SBY'];

  late final StokRepository _repo =
      widget.repository ?? StokRepository.instance;
  final _pref = Preferensi();
  final _cariC = TextEditingController();

  List<Stok> _daftar = [];
  String _gudang = 'GD-BDG';
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cariC.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    setState(() => _memuat = true);
    _gudang = await _pref.ambilGudangTerakhir();
    final kata = _cariC.text.trim();
    final data = kata.isEmpty
        ? await _repo.ambilSemua(kodeGudang: _gudang)
        : await _repo.cari(kata, kodeGudang: _gudang);
    if (!mounted) return;
    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  Future<void> _gantiGudang(String kode) async {
    await _pref.simpanGudangTerakhir(kode);
    await _muat();
  }

  Future<void> _bukaFormulir() async {
    final semua = await _repo.ambilSemua(kodeGudang: _gudang);
    if (!mounted) return;
    final stok = await Navigator.push<Stok>(
      context,
      MaterialPageRoute(
        builder: (_) => FormStokPage(
          kodeGudang: _gudang,
          kodeSudahAda: (kode) => semua.any((s) => s.kodeBarang == kode),
        ),
      ),
    );
    if (stok == null) return;
    await _repo.simpan(stok);
    await _muat();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${stok.namaBarang} disimpan ke $_gudang')),
    );
  }

  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;
    if (baru < 0) return;
    await _repo.perbarui(stok.salinDengan(jumlah: baru));
    await _muat();
  }

  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus data stok'),
        content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya == true && stok.id != null) {
      await _repo.hapus(stok.id!);
      await _muat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stok.namaBarang} dihapus dari $_gudang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(0, (a, s) => a + s.jumlah);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Gudang $_gudang'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Pilih gudang',
            icon: const Icon(Icons.warehouse_outlined),
            onSelected: _gantiGudang,
            itemBuilder: (_) => _opsiGudang
                .map((g) => PopupMenuItem(value: g, child: Text(g)))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              key: const Key('cariStok'),
              controller: _cariC,
              decoration: const InputDecoration(
                labelText: 'Cari nama barang',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _muat(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Total stok: $total unit dari ${_daftar.length} jenis barang\n'
              'Richard Firmansyah • 714240047',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
                ? const Center(child: Text('Belum ada data stok'))
                : ListView.builder(
                    itemCount: _daftar.length,
                    itemBuilder: (context, i) {
                      final s = _daftar[i];
                      return ListTile(
                        title: Text(s.namaBarang),
                        subtitle: Text('${s.kodeBarang} - ${s.jumlah} unit'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Kurangi',
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _ubahJumlah(s, -1),
                            ),
                            IconButton(
                              tooltip: 'Tambah',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _ubahJumlah(s, 1),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _hapus(s),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Stok'),
      ),
    );
  }
}
