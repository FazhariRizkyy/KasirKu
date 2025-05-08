import 'package:flutter/material.dart';
import 'package:pos_app/components/tambah_data.dart';

class DataProdukPage extends StatelessWidget {
  const DataProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> produkList = [
      {
        'nama': 'Beras 5kg',
        'harga': 65000,
        'stok': 25,
        'foto': 'https://via.placeholder.com/150',
      },
      {
        'nama': 'Minyak 1L',
        'harga': 15000,
        'stok': 40,
        'foto': 'https://via.placeholder.com/150',
      },
      {
        'nama': 'Gula 1kg',
        'harga': 13000,
        'stok': 30,
        'foto': 'https://via.placeholder.com/150',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor:Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final item = produkList[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['foto'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informasi Produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Harga: Rp ${item['harga'].toString()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Stok: ${item['stok']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Aksi (Edit/Hapus - Opsional)
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahDataPage()),
          );
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
}
