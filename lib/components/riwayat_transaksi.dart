import 'package:flutter/material.dart';

class RiwayatTransaksiPage extends StatelessWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> transaksiList = [
      {'tanggal': '01-07-2025', 'total': 'Rp 150.000'},
      {'tanggal': '02-07-2025', 'total': 'Rp 230.000'},
      {'tanggal': '03-07-2025', 'total': 'Rp 190.000'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ListView.builder(
        itemCount: transaksiList.length,
        itemBuilder: (context, index) {
          final transaksi = transaksiList[index];
          return ListTile(
            leading: const Icon(Icons.receipt),
            title: Text('Tanggal: ${transaksi['tanggal']}'),
            subtitle: Text('Total: ${transaksi['total']}'),
            onTap: () {
              // Aksi jika ingin tampilkan detail
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Detail Transaksi'),
                  content: Text('Tanggal: ${transaksi['tanggal']}\nTotal: ${transaksi['total']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
