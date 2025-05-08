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
        title: const Text('Riwayat Stok Masuk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor:Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: stokList.length,
          itemBuilder: (context, index) {
            final item = stokList[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  item['produk'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Jumlah: ${item['jumlah']}\nTanggal: ${item['tanggal']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
