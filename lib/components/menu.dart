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
    _MenuItem(icon: Icons.bar_chart, label: 'Laporan', route: const LaporanPenjualanPage()),
    _MenuItem(icon: Icons.point_of_sale, label: 'Kasir', route: const TransaksiPage()),
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
                MaterialPageRoute(builder: (context) => const AboutPage()),
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
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return _buildMenuCard(menuItems[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item, int index) {
    return _AnimatedCard(
      item: item,
      index: index,
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final _MenuItem item;
  final int index;

  const _AnimatedCard({required this.item, required this.index});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isTapped = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    // Start fade-in animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.95; // Scale down slightly when tapped
          _isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0; // Return to original size
          _isTapped = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.item.route),
        );
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0; // Return to original size if tap is canceled
          _isTapped = false;
        });
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.scale(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: _isTapped
                  ? Border.all(color: Colors.blue.shade800, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  spreadRadius: -2,
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _isTapped ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    widget.item.icon,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.item.label,
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