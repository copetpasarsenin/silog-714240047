import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/stok.dart';

class FormStokPage extends StatefulWidget {
  final String kodeGudang;
  final bool Function(String kodeBarang) kodeSudahAda;

  const FormStokPage({
    super.key,
    required this.kodeGudang,
    required this.kodeSudahAda,
  });

  @override
  State<FormStokPage> createState() => _FormStokPageState();
}

class _FormStokPageState extends State<FormStokPage> {
  final _formKey = GlobalKey<FormState>();
  final _kodeC = TextEditingController();
  final _namaC = TextEditingController();
  final _jumlahC = TextEditingController();

  @override
  void dispose() {
    _kodeC.dispose();
    _namaC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  String? _validasiKode(String? nilai) {
    final kode = (nilai ?? '').trim().toUpperCase();
    if (kode.isEmpty) return 'Kode barang wajib diisi';
    if (!RegExp(r'^B-\d{4}$').hasMatch(kode)) {
      return 'Format kode harus B-NNNN';
    }
    if (widget.kodeSudahAda(kode)) return 'Kode barang sudah ada di gudang ini';
    return null;
  }

  String? _validasiNama(String? nilai) {
    final nama = (nilai ?? '').trim();
    if (nama.isEmpty) return 'Nama barang wajib diisi';
    if (nama.length < 3) return 'Nama barang minimal 3 karakter';
    return null;
  }

  String? _validasiJumlah(String? nilai) {
    if ((nilai ?? '').trim().isEmpty) return 'Jumlah wajib diisi';
    final jumlah = int.tryParse(nilai!.trim());
    if (jumlah == null) return 'Jumlah harus berupa bilangan bulat';
    if (jumlah < 0 || jumlah > 100000) {
      return 'Jumlah harus antara 0 dan 100000';
    }
    return null;
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Stok(
        kodeBarang: _kodeC.text.trim().toUpperCase(),
        namaBarang: _namaC.text.trim(),
        kodeGudang: widget.kodeGudang,
        jumlah: int.parse(_jumlahC.text.trim()),
        diperbaruiPada: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Stok ${widget.kodeGudang}')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('kodeBarang'),
              controller: _kodeC,
              decoration: const InputDecoration(
                labelText: 'Kode Barang',
                hintText: 'B-1024',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: _validasiKode,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('namaStok'),
              controller: _namaC,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              validator: _validasiNama,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('jumlahStok'),
              controller: _jumlahC,
              decoration: const InputDecoration(
                labelText: 'Jumlah (unit)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validasiJumlah,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _simpan, child: const Text('Simpan Stok')),
          ],
        ),
      ),
    );
  }
}
