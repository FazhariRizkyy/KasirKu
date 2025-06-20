import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_app/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  _LaporanPenjualanPageState createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _laporanList = [];
  String _selectedPeriod = 'Harian';
  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  final DateFormat _reportDateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    final db = await _dbHelper.database;
    String query = '''
      SELECT 
        lp.id_transaksi,
        lp.nama_produk,
        lp.harga_beli,
        lp.harga_jual,
        lp.jumlah,
        (lp.harga_jual - lp.harga_beli) * lp.jumlah AS keuntungan,
        t.metode_pembayaran
      FROM tabel_laporan_penjualan lp
      JOIN tabel_transaksi t ON lp.id_transaksi = t.id_transaksi
    ''';
    List<String> whereArgs = [];

    DateTime now = DateTime.now();
    DateTime startDate;

    if (_selectedPeriod == 'Harian') {
      startDate = DateTime(now.year, now.month, now.day);
      query += ' WHERE date(t.tanggal) = ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    } else if (_selectedPeriod == 'Mingguan') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      query += ' WHERE date(t.tanggal) >= ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    } else {
      startDate = DateTime(now.year, now.month, 1);
      query += ' WHERE date(t.tanggal) >= ?';
      whereArgs.add(startDate.toIso8601String().substring(0, 10));
    }

    final result = await db.rawQuery(query, whereArgs);
    setState(() {
      _laporanList = result;
    });
  }

  double _hitungTotalPendapatan() {
    return _laporanList.fold(
      0,
      (sum, item) => sum + (item['harga_jual'] * item['jumlah']).toDouble(),
    );
  }

  double _hitungTotalKeuntungan() {
    return _laporanList.fold(
      0,
      (sum, item) => sum + (item['keuntungan'] as num).toDouble(),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    DateTime now = DateTime.now();
    String dateText;

    if (_selectedPeriod == 'Harian') {
      dateText = _reportDateFormat.format(now);
    } else if (_selectedPeriod == 'Mingguan') {
      DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
      DateTime endDate = startDate.add(Duration(days: 6));
      dateText = '${_reportDateFormat.format(startDate)} - ${_reportDateFormat.format(endDate)}';
    } else {
      dateText = 'Bulan ${_reportDateFormat.format(DateTime(now.year, now.month, 1)).split(' ').sublist(1).join(' ')}';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Laporan Penjualan - $_selectedPeriod',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Tanggal: $dateText',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: [
              'Transaksi',
              'Produk',
              'Harga Beli',
              'Harga Jual',
              'Terjual',
              'Keuntungan',
              'Metode Pembayaran',
            ],
            data: _laporanList.map((item) => [
                  item['id_transaksi'].toString(),
                  item['nama_produk'],
                  'Rp ${item['harga_beli'].toStringAsFixed(0)}',
                  'Rp ${item['harga_jual'].toStringAsFixed(0)}',
                  item['jumlah'].toString(),
                  'Rp ${item['keuntungan'].toStringAsFixed(0)}',
                  item['metode_pembayaran'] ?? 'Tidak Diketahui',
                ]).toList(),
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
          pw.Text(
            'Total Keuntungan: Rp ${_hitungTotalKeuntungan().toStringAsFixed(0)}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Penjualan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isExpanded: true,
                  items: _periods.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(
                        period,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                      _fetchLaporan();
                    });
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pendapatan:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Rp ${_hitungTotalPendapatan().toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Keuntungan:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Rp ${_hitungTotalKeuntungan().toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _laporanList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data laporan untuk periode ini',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _laporanList.length,
                      itemBuilder: (context, index) {
                        final item = _laporanList[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: StrukCard(
                            item: item,
                            dateFormat: _dateFormat,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _laporanList.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(
                      laporanList: _laporanList,
                      selectedPeriod: _selectedPeriod,
                      generatePdf: _generatePdf,
                    ),
                  ),
                );
              },
        backgroundColor: _laporanList.isEmpty ? Colors.grey[400] : Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        tooltip: 'Lihat Preview & Cetak PDF',
        child: Icon(
          Icons.print,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class StrukCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final DateFormat dateFormat;

  const StrukCard({super.key, required this.item, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Bisa ditambahkan navigasi ke detail transaksi
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transaksi #${item['id_transaksi']}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produk: ${item['nama_produk']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harga Beli: Rp ${item['harga_beli'].toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Harga Jual: Rp ${item['harga_jual'].toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Terjual: ${item['jumlah']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Keuntungan: Rp ${item['keuntungan'].toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      'Metode Pembayaran: ${item['metode_pembayaran'] ?? 'Tidak Diketahui'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
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
  }
}

class PreviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> laporanList;
  final String selectedPeriod;
  final Future<Uint8List> Function(PdfPageFormat) generatePdf;

  const PreviewScreen({
    super.key,
    required this.laporanList,
    required this.selectedPeriod,
    required this.generatePdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
        title: Text(
          'Laporan Penjualan - $selectedPeriod',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => generatePdf(format),
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'laporan_penjualan_$selectedPeriod.pdf',
      ),
    );
  }
}