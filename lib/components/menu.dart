import 'package:flutter/material.dart';
import 'package:pos_app/components/data_produk.dart';
import 'package:pos_app/components/laporan_penjualan.dart';
import 'package:pos_app/components/transaksi.dart';
import 'package:pos_app/components/about.dart';
import 'package:pos_app/components/riwayat_transaksi.dart';
import 'package:pos_app/components/stok_masuk.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title});
  final String title;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<_MenuItem> menuItems = [
    _MenuItem(icon: Icons.inventory_2, label: 'Produk'),
    _MenuItem(icon: Icons.add_box, label: 'Stok Masuk'),
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan Penjualan'),
    _MenuItem(icon: Icons.point_of_sale, label: 'Transaksi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return _buildMenuCard(menuItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return InkWell(
      onTap: () {
        switch (item.label) {
          case 'Produk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataProdukPage()),
            );
            break;
          case 'Stok Masuk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StokMasukPage()),
            );
            break;
          case 'Laporan Penjualan':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LaporanPenjualanPage(),
              ),
            );
            break;
          case 'Transaksi':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransaksiPage()),
            );
            break;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({required this.icon, required this.label});
}
