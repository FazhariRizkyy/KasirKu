import 'package:flutter/material.dart';
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
    // Inisialisasi animasi untuk pop-up
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

  // Load produk dari database
  Future<void> _loadProduk() async {
    final produk = await _dbHelper.getAllProduk();
    setState(() {
      _produkList = produk;
      _filteredProdukList = produk;
    });
  }

  // Tambah produk ke keranjang
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

  // Kurangi jumlah item di keranjang
  void _kurangJumlah(int index) {
    setState(() {
      if (_keranjang[index]['jumlah'] > 1) {
        _keranjang[index]['jumlah']--;
      } else {
        _keranjang.removeAt(index);
      }
    });
  }

  // Tambah jumlah item di keranjang
  void _tambahJumlah(int index) {
    setState(() {
      if (_keranjang[index]['jumlah'] < _keranjang[index]['stok']) {
        _keranjang[index]['jumlah']++;
      }
    });
  }

  // Hapus item dari keranjang
  void _hapusItem(int index) {
    setState(() {
      _keranjang.removeAt(index);
    });
  }

  // Hitung total belanja
  num _hitungTotal() {
    return _keranjang.fold(
      0,
      (sum, item) => sum + (item['harga'] * item['jumlah']),
    );
  }

  // Filter produk berdasarkan pencarian
  void _filterProduk(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProdukList = _produkList;
      } else {
        _filteredProdukList = _produkList
            .where((produk) =>
                produk.namaProduk.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Proses transaksi
  Future<void> _prosesTransaksi() async {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    final db = await _dbHelper.database;
    final batch = db.batch();

    // Simpan transaksi
    final total = _hitungTotal();
    final transaksi = {
      'tanggal': DateTime.now().toIso8601String(),
      'total': total,
    };
    final idTransaksi = await db.insert('tabel_transaksi', transaksi);

    // Simpan detail transaksi dan update stok
    for (var item in _keranjang) {
      final subtotal = item['harga'] * item['jumlah'];
      // Simpan ke tabel_detail_transaksi
      batch.insert('tabel_detail_transaksi', {
        'id_transaksi': idTransaksi,
        'id_produk': item['id_produk'],
        'nama_produk': item['nama'],
        'harga': item['harga'],
        'jumlah': item['jumlah'],
        'subtotal': subtotal,
      });

      // Update stok di tabel_produk
      final produk = await _dbHelper.getProdukById(item['id_produk']);
      if (produk != null) {
        final newStok = produk.stok - item['jumlah'];
        batch.update(
          'tabel_produk',
          {'stok': newStok},
          where: 'id_produk = ?',
          whereArgs: [item['id_produk']],
        );

        // Simpan ke tabel_laporan_penjualan
        batch.insert('tabel_laporan_penjualan', {
          'id_transaksi': idTransaksi,
          'id_produk': item['id_produk'],
          'nama_produk': item['nama'],
          'harga': item['harga'],
          'jumlah': item['jumlah'],
          'kategori': produk.kategori,
          'tanggal': DateTime.now().toIso8601String(),
          'subtotal': subtotal,
        });
      }
    }

    await batch.commit();

    // Reset dan jalankan animasi untuk pop-up
    _animationController.reset();
    _animationController.forward();

    // Tampilkan pop-up transaksi berhasil dengan desain kustom
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Sukses
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16),
                // Judul
                Text(
                  'Transaksi Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                // Total
                Text(
                  'Total: Rp ${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol OK
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
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            child: item.foto != null && File(item.foto!).existsSync()
                                ? Image.file(
                                    File(item.foto!),
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
                                  item.namaProduk,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Harga Jual: Rp ${item.hargaJual.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  'Stok: ${item.stok}',
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
                                      'Rp ${item['harga'].toStringAsFixed(0)} x ${item['jumlah']}',
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
                        'Rp ${_hitungTotal().toStringAsFixed(0)}',
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
                      onPressed: _prosesTransaksi,
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