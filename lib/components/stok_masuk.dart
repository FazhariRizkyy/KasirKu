import 'package:flutter/material.dart';

class StokMasukPage extends StatelessWidget {
  const StokMasukPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data stok masuk
    final List<Map<String, dynamic>> stokList = [
      {'produk': 'Beras 5kg', 'jumlah': 20, 'tanggal': '27-07-2025'},
      {'produk': 'Minyak Goreng 1L', 'jumlah': 30, 'tanggal': '26-07-2025'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Masuk'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ListView.builder(
        itemCount: stokList.length,
        itemBuilder: (context, index) {
          final item = stokList[index];
          return ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: Text(item['produk']),
            subtitle: Text(
              'Jumlah: ${item['jumlah']} \nTanggal: ${item['tanggal']}',
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
