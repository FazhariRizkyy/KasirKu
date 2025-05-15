import 'package:flutter/material.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
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

  final List<Map<String, dynamic>> _keranjang = [];
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredProdukList = [];

  @override
  void initState() {
    super.initState();
    _filteredProdukList = _produkList; // Inisialisasi dengan semua produk
  }

  void _tambahKeKeranjang(Map<String, dynamic> produk) {
    setState(() {
      final index = _keranjang.indexWhere(
        (item) => item['nama'] == produk['nama'],
      );
      if (index != -1) {
        if (_keranjang[index]['jumlah'] < produk['stok']) {
          _keranjang[index]['jumlah']++;
        }
      } else {
        _keranjang.add({...produk, 'jumlah': 1});
      }
    });
  }

  void _kurangJumlah(int index) {
    setState(() {
      if (_keranjang[index]['jumlah'] > 1) {
        _keranjang[index]['jumlah']--;
      } else {
        _keranjang.removeAt(index);
      }
    });
  }

  void _tambahJumlah(int index) {
    setState(() {
      if (_keranjang[index]['jumlah'] < _keranjang[index]['stok']) {
        _keranjang[index]['jumlah']++;
      }
    });
  }

  void _hapusItem(int index) {
    setState(() {
      _keranjang.removeAt(index);
    });
  }

  num _hitungTotal() {
    return _keranjang.fold(
      0,
      (sum, item) => sum + (item['harga'] * item['jumlah']),
    );
  }

  void _filterProduk(String query) {
    setState(() {
      _searchQuery = query;
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
        title: const Text('Transaksi'),
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
          // Daftar Produk
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: _filteredProdukList.length,
              itemBuilder: (context, index) {
                final item = _filteredProdukList[index];
                return GestureDetector(
                  onTap: () => _tambahKeKeranjang(item),
                  child: Card(
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
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Form Keranjang
          if (_keranjang.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keranjang Belanja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _keranjang.length,
                      itemBuilder: (context, index) {
                        final item = _keranjang[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Rp ${item['harga']} x ${item['jumlah']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _kurangJumlah(index),
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text('${item['jumlah']}'),
                                  IconButton(
                                    onPressed: () => _tambahJumlah(index),
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _hapusItem(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_hitungTotal()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi berhasil!')),
                        );
                        setState(() {
                          _keranjang.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi Transaksi',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
