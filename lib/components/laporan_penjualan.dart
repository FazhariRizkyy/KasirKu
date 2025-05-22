import 'package:flutter/material.dart';
import 'package:pos_app/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // Tambahkan import ini
import 'package:printing/printing.dart';

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  _LaporanPenjualanPageState createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _laporanList = [];
  String _selectedPeriod = 'Harian'; // Default filter
  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  // Ambil data laporan dari tabel_laporan_penjualan
  Future<void> _fetchLaporan() async {
    final db = await _dbHelper.database;
    String query = 'SELECT * FROM tabel_laporan_penjualan';
    List<String> whereArgs = [];

    DateTime now = DateTime.now();
    DateTime startDate;

    if (_selectedPeriod == 'Harian') {
      startDate = DateTime(now.year, now.month, now.day);
      query += ' WHERE date(tanggal) = ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    } else if (_selectedPeriod == 'Mingguan') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      query += ' WHERE date(tanggal) >= ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    } else {
      startDate = DateTime(now.year, now.month, 1);
      query += ' WHERE date(tanggal) >= ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    }

    final result = await db.rawQuery(query, whereArgs);
    setState(() {
      _laporanList = result;
    });
  }

  // Hitung total pendapatan
  double _hitungTotalPendapatan() {
    return _laporanList.fold(
      0,
      (sum, item) => sum + item['subtotal'] as double,
    );
  }

  // Buat PDF untuk laporan
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat
                .a4, // Ubah dari pw.PdfPageFormat menjadi PdfPageFormat
        margin: const pw.EdgeInsets.all(32),
        build:
            (pw.Context context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Penjualan - $_selectedPeriod',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'ID Transaksi',
                  'Produk',
                  'Kategori',
                  'Harga',
                  'Jumlah',
                  'Subtotal',
                  'Tanggal',
                ],
                data:
                    _laporanList
                        .map(
                          (item) => [
                            item['id_transaksi'].toString(),
                            item['nama_produk'],
                            item['kategori'],
                            'Rp ${item['harga'].toStringAsFixed(0)}',
                            item['jumlah'].toString(),
                            'Rp ${item['subtotal'].toStringAsFixed(0)}',
                            dateFormat.format(DateTime.parse(item['tanggal'])),
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Pendapatan: Rp ${_hitungTotalPendapatan().toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'laporan_penjualan_$_selectedPeriod.pdf',
    );
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
          // Dropdown untuk filter periode
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              items:
                  _periods.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                  _fetchLaporan();
                });
              },
              style: const TextStyle(fontSize: 16, color: Colors.black),
              underline: Container(height: 2, color: Colors.blue.shade700),
            ),
          ),
          // Total Pendapatan
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pendapatan:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${_hitungTotalPendapatan().toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Daftar Laporan
          Expanded(
            child:
                _laporanList.isEmpty
                    ? const Center(
                      child: Text('Tidak ada data laporan untuk periode ini'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _laporanList.length,
                      itemBuilder: (context, index) {
                        final item = _laporanList[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaksi #${item['id_transaksi']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Produk: ${item['nama_produk']}'),
                                Text('Kategori: ${item['kategori']}'),
                                Text(
                                  'Harga: Rp ${item['harga'].toStringAsFixed(0)}',
                                ),
                                Text('Jumlah: ${item['jumlah']}'),
                                Text(
                                  'Subtotal: Rp ${item['subtotal'].toStringAsFixed(0)}',
                                ),
                                Text(
                                  'Tanggal: ${_dateFormat.format(DateTime.parse(item['tanggal']))}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _laporanList.isEmpty ? null : _generatePdf,
        backgroundColor:
            _laporanList.isEmpty ? Colors.grey : Colors.blue.shade700,
        child: const Icon(Icons.print),
        tooltip: 'Cetak Laporan PDF',
      ),
    );
  }
}
