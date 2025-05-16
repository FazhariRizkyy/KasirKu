import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pos_app/components/tambah_data.dart';
import '../database/database_helper.dart';
import 'package:pos_app/models/product.dart';

class DataProdukPage extends StatefulWidget {
  const DataProdukPage({super.key});

  @override
  _DataProdukPageState createState() => _DataProdukPageState();
}

class _DataProdukPageState extends State<DataProdukPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Produk> _produkList = [];
  List<Produk> _filteredProdukList = [];

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    final produk = await _dbHelper.getAllProduk();
    setState(() {
      _produkList = produk;
      _filteredProdukList = produk;
    });
  }

  void _filterProduk(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProdukList = _produkList;
      } else {
        _filteredProdukList = _produkList
            .where((produk) => produk.namaProduk.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Makanan & Minuman'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _filteredProdukList.isEmpty
                ? const Center(child: Text('Produk tidak ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredProdukList.length,
                    itemBuilder: (context, index) {
                      final produk = _filteredProdukList[index];
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: produk.foto != null && File(produk.foto!).existsSync()
                                    ? Image.file(
                                        File(produk.foto!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produk.namaProduk,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Harga: Rp ${produk.harga.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Stok: ${produk.stok}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Kategori: ${produk.kategori}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TambahDataPage(produk: produk),
                                        ),
                                      ).then((_) => _loadProduk());
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _dbHelper.deleteProduk(produk.idProduk!);
                                      _loadProduk();
                                    },
                                  ),
                                ],
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
          ).then((_) => _loadProduk());
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}