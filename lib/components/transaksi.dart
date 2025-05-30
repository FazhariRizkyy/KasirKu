import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/database/database_helper.dart';
import 'package:pos_app/models/product.dart';
import 'dart:io';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Produk> _produkList = [];
  List<Produk> _filteredProdukList = [];
  final List<Map<String, dynamic>> _keranjang = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadProduk();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProduk() async {
    final produk = await _dbHelper.getAllProduk();
    setState(() {
      _produkList = produk;
      _filteredProdukList = produk;
    });
  }

  void _tambahKeKeranjang(Produk produk) {
    setState(() {
      final index = _keranjang.indexWhere(
        (item) => item['id_produk'] == produk.idProduk,
      );
      if (index != -1) {
        if (_keranjang[index]['jumlah'] < produk.stok) {
          _keranjang[index]['jumlah']++;
        }
      } else {
        _keranjang.add({
          'id_produk': produk.idProduk,
          'nama': produk.namaProduk,
          'harga': produk.hargaJual,
          'stok': produk.stok,
          'jumlah': 1,
        });
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
      if (query.isEmpty) {
        _filteredProdukList = _produkList;
      } else {
        _filteredProdukList = _produkList
            .where((produk) => produk.namaProduk.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _prosesTransaksi() async {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Keranjang kosong!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      final total = _hitungTotal();
      final transaksi = {
        'tanggal': DateTime.now().toIso8601String(),
        'total': total,
      };
      final idTransaksi = await db.insert('tabel_transaksi', transaksi);

      for (var item in _keranjang) {
        final subtotal = item['harga'] * item['jumlah'];
        batch.insert('tabel_detail_transaksi', {
          'id_transaksi': idTransaksi,
          'id_produk': item['id_produk'],
          'nama_produk': item['nama'],
          'harga': item['harga'],
          'jumlah': item['jumlah'],
          'satuan': 'Unit',
          'subtotal': subtotal,
        });

        final produk = await _dbHelper.getProdukById(item['id_produk']);
        if (produk != null) {
          final newStok = produk.stok - item['jumlah'];
          batch.update(
            'tabel_produk',
            {'stok': newStok},
            where: 'id_produk = ?',
            whereArgs: [item['id_produk']],
          );

          batch.insert('tabel_laporan_penjualan', {
            'id_transaksi': idTransaksi,
            'id_produk': item['id_produk'],
            'nama_produk': item['nama'],
            'harga': item['harga'],
            'jumlah': item['jumlah'],
            'kategori': produk.kategori,
            'satuan': 'Unit',
            'tanggal': DateTime.now().toIso8601String(),
            'subtotal': subtotal,
          });
        }
      }

      await batch.commit();

      _animationController.reset();
      _animationController.forward();

      showDialog(
        context: context,
        builder: (context) => ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Transaksi Berhasil!',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: Rp ${total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _keranjang.clear();
                          _loadProduk();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blue.withOpacity(0.3),
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
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Gagal menyimpan transaksi: $e',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaksi',
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _filterProduk,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            // Daftar Produk
            Expanded(
              child: _filteredProdukList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada produk ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _filteredProdukList.length,
                      itemBuilder: (context, index) {
                        final item = _filteredProdukList[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: ProdukCard(
                            item: item,
                            onTap: () => _tambahKeKeranjang(item),
                          ),
                        );
                      },
                    ),
            ),
            // Form Keranjang
            if (_keranjang.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Keranjang
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Keranjang Belanja',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _keranjang.length,
                        itemBuilder: (context, index) {
                          final item = _keranjang[index];
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: KeranjangItem(
                              item: item,
                              index: index,
                              onKurang: () => _kurangJumlah(index),
                              onTambah: () => _tambahJumlah(index),
                              onHapus: () => _hapusItem(index),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.blue[100],
                            thickness: 1,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Rp ${_hitungTotal().toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _prosesTransaksi,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              child: Text(
                                'Konfirmasi Transaksi',
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProdukCard extends StatelessWidget {
  final Produk item;
  final VoidCallback onTap;

  const ProdukCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gambar atau placeholder
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.foto != null && File(item.foto!).existsSync()
                      ? Image.file(
                          File(item.foto!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.blue[700],
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.blue[700],
                            size: 40,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaProduk,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Harga Jual: Rp ${item.hargaJual.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Stok: ${item.stok}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeranjangItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final VoidCallback onKurang;
  final VoidCallback onTambah;
  final VoidCallback onHapus;

  const KeranjangItem({
    super.key,
    required this.item,
    required this.index,
    required this.onKurang,
    required this.onTambah,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item['harga'].toStringAsFixed(0)} x ${item['jumlah']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onKurang,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.blue[700],
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item['jumlah']}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onTambah,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue[700],
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onHapus,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}