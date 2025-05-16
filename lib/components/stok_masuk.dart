// File: stok_masuk_page.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StokMasukPage extends StatefulWidget {
  const StokMasukPage({super.key});

  @override
  _StokMasukPageState createState() => _StokMasukPageState();
}

class _StokMasukPageState extends State<StokMasukPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _stokMasukList = [];

  @override
  void initState() {
    super.initState();
    _loadStokMasuk();
  }

  Future<void> _loadStokMasuk() async {
    final stokMasuk = await _dbHelper.getAllStokMasuk();
    setState(() {
      _stokMasukList = stokMasuk;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Stok Masuk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _stokMasukList.isEmpty
          ? const Center(child: Text('Belum ada riwayat stok masuk'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _stokMasukList.length,
              itemBuilder: (context, index) {
                final stok = _stokMasukList[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stok['nama_produk'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Harga: Rp ${stok['harga'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Stok: ${stok['stok']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Tanggal Masuk: ${stok['tanggal_masuk'].substring(0, 10)}', // Format tanggal
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}