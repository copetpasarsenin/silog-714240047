import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BerandaPage(),
    );
  }
}

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SiLog - Modul 1')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_shipping, size: 72),
            SizedBox(height: 16),
            Text(
              'Sistem Informasi Logistik',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Lingkungan pengembangan siap digunakan'),
            SizedBox(height: 16),
            Text('Nama: Richard Firmansyah', style: TextStyle(fontSize: 16)),
            Text('NIM: 714240047', style: TextStyle(fontSize: 16)),
            Text('Kelas: 3C-D4-TI', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
