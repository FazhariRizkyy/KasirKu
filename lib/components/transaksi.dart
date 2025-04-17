import 'package:flutter/material.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: const Center(child: Text('Ini adalah halaman Transaksi')),
    );
  }
}