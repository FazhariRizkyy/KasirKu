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

  Future<void> _deleteProduk(int id, String nama) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus Produk',
          style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk $nama ?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteProduk(id);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.red[600],
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Data Produk Berhasil Dihapus!',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.red.withOpacity(0.3),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        _loadProduk();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Produk',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
        ),
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
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
                    borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                ),
              ),
            ),
            Expanded(
              child: _filteredProdukList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada Makanan & Minuman',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _filteredProdukList.length,
                      itemBuilder: (context, index) {
                        final produk = _filteredProdukList[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
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
                                      height: 80,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: produk.foto != null && File(produk.foto!).existsSync()
                                            ? Image.file(
                                                File(produk.foto!),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    _buildImagePlaceholder(),
                                              )
                                            : _buildImagePlaceholder(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message: produk.namaProduk,
                                            child: Text(
                                              produk.namaProduk,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            'Harga Jual: Rp ${produk.hargaJual.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                          Text(
                                            'Stok: ${produk.stok} ${produk.satuan}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            produk.kategori,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[700],
                                            ),
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
                                                builder: (context) => TambahDataPage(produk: produk),
                                              ),
                                            ).then((_) => _loadProduk());
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue[700],
                                            size: 20,
                                          ),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          onPressed: () => _deleteProduk(produk.idProduk!, produk.namaProduk),
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red[600],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahDataPage()),
          ).then((_) => _loadProduk());
        },
        backgroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No Image',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }
}