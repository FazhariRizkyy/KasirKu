import 'package:flutter/material.dart';

class DataProdukPage extends StatelessWidget {
  const DataProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Produk')),
      body: const Center(child: Text('Ini adalah halaman Data Produk')),
    );
  }
}