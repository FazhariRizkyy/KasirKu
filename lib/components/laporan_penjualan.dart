import 'package:flutter/material.dart';
class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  _LaporanPenjualanPageState createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  // Dummy data untuk riwayat transaksi
  final List<Map<String, dynamic>> _transactionList = [
    {
      'id': 'T001',
      'date': '2025-05-15',
      'total': 150000,
      'items': ['Nabati', 'Nutrisari'],
    },
    {
      'id': 'T002',
      'date': '2025-05-14',
      'total': 200000,
      'items': ['Permen Kopiko'],
    },
    {
      'id': 'T003',
      'date': '2025-05-13',
      'total': 100000,
      'items': ['Nabati'],
    },
  ];

  List<Map<String, dynamic>> _filteredTransactionList = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactionList = _transactionList;
  }

  void _filterTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTransactionList = _transactionList;
      } else {
        _filteredTransactionList = _transactionList
            .where((transaction) =>
                transaction['id'].toLowerCase().contains(query.toLowerCase()) ||
                transaction['date'].contains(query))
            .toList();
      }
    });
  }

  void _generatePdf() {
    // Placeholder untuk logika cetak PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mencetak laporan ke PDF...')),
    );
    // Gunakan package seperti `pdf` dan `printing` untuk generate PDF
    // Contoh: Buat dokumen PDF dengan tabel transaksi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterTransactions,
              decoration: InputDecoration(
                hintText: 'Cari transaksi (ID atau tanggal)...',
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
          // List Transaksi
          Expanded(
            child: _filteredTransactionList.isEmpty
                ? const Center(child: Text('Transaksi tidak ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredTransactionList.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactionList[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.receipt, color: Colors.blue),
                            title: Text(
                              'Transaksi ${transaction['id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Tanggal: ${transaction['date']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  'Total: Rp ${transaction['total']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigasi ke halaman detail transaksi
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Menampilkan detail ${transaction['id']}')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePdf,
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.print, color: Colors.white),
        tooltip: 'Cetak Laporan',
      ),
    );
  }
}