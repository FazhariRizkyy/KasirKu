import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/components/data_produk.dart';
import 'package:pos_app/components/laporan_penjualan.dart';
import 'package:pos_app/components/transaksi.dart';
import 'package:pos_app/components/stok_masuk.dart';
import 'package:pos_app/components/about.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title});
  final String title;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<_MenuItem> menuItems = [
    _MenuItem(icon: Icons.inventory_2, label: 'Produk', route: const DataProdukPage()),
    _MenuItem(icon: Icons.add_box, label: 'Stok Masuk', route: const StokMasukPage()),
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan Penjualan', route: const LaporanPenjualanPage()),
    _MenuItem(icon: Icons.point_of_sale, label: 'Transaksi', route: const TransaksiPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 234, 255),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()), // Navigasi ke about.dart
              );
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Membuat card lebih persegi
          ),
          itemBuilder: (context, index) {
            return _buildMenuCard(menuItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.route),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(4, 4), // Neumorphism shadow
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              spreadRadius: -2,
              blurRadius: 8,
              offset: const Offset(-4, -4), // Neumorphism highlight
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 48,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                color: Colors.blue.shade900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
  final Widget route;

  _MenuItem({required this.icon, required this.label, required this.route});
}