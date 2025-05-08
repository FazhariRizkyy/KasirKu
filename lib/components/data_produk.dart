import 'package:flutter/material.dart';

class DataProdukPage extends StatelessWidget {
  const DataProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> produkList = [
      {'nama': 'Beras 5kg', 'harga': 65000, 'stok': 25},
      {'nama': 'Minyak 1L', 'harga': 15000, 'stok': 40},
      {'nama': 'Gula 1kg', 'harga': 13000, 'stok': 30},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke form tambah produk nanti
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final item = produkList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(item['nama']),
              subtitle: Text('Harga: Rp ${item['harga']}\nStok: ${item['stok']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
