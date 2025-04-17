import 'package:flutter/material.dart';
import 'package:pos_app/components/customer_service.dart';
import 'package:pos_app/components/data_produk.dart';
import 'package:pos_app/components/laporan_penjualan.dart';
import 'package:pos_app/components/transaksi.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title});
  final String title;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<_MenuItem> menuItems = [
    _MenuItem(icon: Icons.inventory_2, label: 'Data Produk'),
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan Penjualan'),
    _MenuItem(icon: Icons.point_of_sale, label: 'Transaksi'),
    _MenuItem(icon: Icons.support_agent, label: 'Customer Service'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Spacer(), // Untuk mendorong ke tengah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: GridView.count(
                shrinkWrap:
                    true, // Penting agar GridView tidak mengambil seluruh tinggi layar
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children:
                    menuItems.map((item) {
                      return _buildMenuCard(item);
                    }).toList(),
              ),
            ),
          ),
          const Spacer(), // Untuk menjaga tetap di tengah
        ],
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return GestureDetector(
      onTap: () {
        switch (item.label) {
          case 'Data Produk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DataProdukPage()),
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
          case 'Customer Service':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerServicePage(),
              ),
            );
            break;
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
