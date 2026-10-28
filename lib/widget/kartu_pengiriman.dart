import 'package:flutter/material.dart';

import '../model/pengiriman.dart';

class KartuPengiriman extends StatelessWidget {
  final Pengiriman pengiriman;
  final VoidCallback onTap;

  const KartuPengiriman({
    super.key,
    required this.pengiriman,
    required this.onTap,
  });

  Color _warnaStatus(BuildContext context) {
    switch (pengiriman.status) {
      case 'Diterima':
        return Colors.green;
      case 'Dalam Perjalanan':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = _warnaStatus(context);
    final teks = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: warna.withValues(alpha: .15),
                child: Icon(Icons.inventory_2, color: warna),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pengiriman.resi, style: teks.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${pengiriman.barang.nama} x ${pengiriman.jumlah}',
                      style: teks.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pengiriman.asal.kota} → ${pengiriman.kotaTujuan}',
                      style: teks.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pengiriman.status,
                  style: teks.labelSmall?.copyWith(color: warna),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
