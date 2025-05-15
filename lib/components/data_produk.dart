import 'package:flutter/material.dart';
import 'package:pos_app/components/tambah_data.dart';

class DataProdukPage extends StatefulWidget {
  const DataProdukPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DataProdukPageState createState() => _DataProdukPageState();
}

class _DataProdukPageState extends State<DataProdukPage> {
  final List<Map<String, dynamic>> _produkList = [
    {
      'nama': 'Nabati',
      'harga': 5000,
      'stok': 25,
      'foto': 'https://via.placeholder.com/150',
    },
    {
      'nama': 'Nutrisari Jeruk Nipis',
      'harga': 5000,
      'stok': 40,
      'foto': 'https://via.placeholder.com/150',
    },
    {
      'nama': 'Permen Kopiko',
      'harga': 500,
      'stok': 30,
      'foto': 'https://via.placeholder.com/150',
    },
  ];

  List<Map<String, dynamic>> _filteredProdukList = [];

  @override
  void initState() {
    super.initState();
    _filteredProdukList = _produkList;
  }

  void _filterProduk(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProdukList = _produkList;
      } else {
        _filteredProdukList =
            _produkList
                .where(
                  (produk) => produk['nama'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterProduk,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // List Produk
          Expanded(
            child:
                _filteredProdukList.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan'))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredProdukList.length,
                      itemBuilder: (context, index) {
                        final item = _filteredProdukList[index];
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
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Informasi Produk
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahDataPage()),
          );
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
