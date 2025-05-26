import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pos_app/components/tambah_data.dart';
import '../database/database_helper.dart';
import 'package:pos_app/models/product.dart';

class DataProdukPage extends StatefulWidget {
  const DataProdukPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
            .where(
              (produk) => produk.namaProduk.toLowerCase().contains(
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
        title: Text(
          'Data Makanan & Minuman',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterProduk,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                // ignore: deprecated_member_use
                fillColor: Colors.white.withOpacity(0.9),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
              ),
            ),
          ),
          Expanded(
            child: _filteredProdukList.isEmpty
                ? Center(
                    child: Text(
                      'Produk tidak ditemukan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: _filteredProdukList.length,
                    itemBuilder: (context, index) {
                      final produk = _filteredProdukList[index];
                      final keuntungan = produk.hargaJual - produk.hargaBeli;
                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          elevation: 0,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  // ignore: deprecated_member_use
                                  Colors.white.withOpacity(0.9),
                                  // ignore: deprecated_member_use
                                  Colors.blue.shade50.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: produk.foto != null &&
                                                  File(produk.foto!).existsSync()
                                              ? Image.file(
                                                  File(produk.foto!),
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      _buildImagePlaceholder(),
                                                )
                                              : _buildImagePlaceholder(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Tooltip(
                                          message: produk.namaProduk,
                                          child: Text(
                                            produk.namaProduk,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          label: 'Harga Beli',
                                          value:
                                              'Rp ${produk.hargaBeli.toStringAsFixed(0)}',
                                          color: Colors.blue.shade700,
                                        ),
                                        _buildInfoRow(
                                          label: 'Harga Jual',
                                          value:
                                              'Rp ${produk.hargaJual.toStringAsFixed(0)}',
                                          color: Colors.blue.shade700,
                                        ),
                                        _buildInfoRow(
                                          label: 'Keuntungan',
                                          value:
                                              'Rp ${keuntungan.toStringAsFixed(0)}',
                                          color: Colors.green.shade600,
                                        ),
                                        _buildInfoRow(
                                          label: 'Stok',
                                          value: '${produk.stok}',
                                          color: Colors.grey.shade700,
                                        ),
                                        _buildInfoRow(
                                          label: 'Kategori',
                                          value: produk.kategori,
                                          color: Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TambahDataPage(
                                                produk: produk,
                                              ),
                                            ),
                                          ).then((_) => _loadProduk());
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await _dbHelper.deleteProduk(
                                            produk.idProduk!,
                                          );
                                          _loadProduk();
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade600,
                                          size: 20,
                                        ),
                                        tooltip: 'Hapus',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
        backgroundColor: Colors.blue.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No Image',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}