import 'package:flutter/material.dart';
import 'package:pos_app/components/data_produk.dart';
import 'package:pos_app/components/laporan_penjualan.dart';
import 'package:pos_app/components/transaksi.dart';
import 'package:pos_app/components/about.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.title});
  final String title;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const HomeContent(),
    const FavoritePage(),
    const SettingPage(),
  ];

  final List<_MenuItem> menuItems = [
    _MenuItem(icon: Icons.inventory_2, label: 'Data Produk'),
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan Penjualan'),
    _MenuItem(icon: Icons.point_of_sale, label: 'Transaksi'),
    _MenuItem(icon: Icons.info_outline, label: 'Tentang'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // ignore: library_private_types_in_public_api
  final List<_MenuItem> menuItems = const [
    _MenuItem(icon: Icons.inventory_2, label: 'Data Produk'),
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan Penjualan'),
    _MenuItem(icon: Icons.point_of_sale, label: 'Transaksi'),
    _MenuItem(icon: Icons.info_outline, label: 'Tentang'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        itemCount: menuItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          return _buildMenuCard(context, menuItems[index]);
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return InkWell(
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
              MaterialPageRoute(builder: (context) => const LaporanPenjualanPage()),
            );
            break;
          case 'Transaksi':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransaksiPage()),
            );
            break;
          case 'Tentang':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
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

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Favorite Page\n(Coming Soon)',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Setting Page\n(Coming Soon)',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}
