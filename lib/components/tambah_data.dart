import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahDataPage extends StatefulWidget {
  final Produk? produk;

  const TambahDataPage({super.key, this.produk});

  @override
  _TambahDataPageState createState() => _TambahDataPageState();
}

class _TambahDataPageState extends State<TambahDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  String? _kategori = 'Makanan';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Formatter untuk Rupiah
  final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _namaController.text = widget.produk!.namaProduk;
      _hargaBeliController.text = _rupiahFormat.format(widget.produk!.hargaBeli);
      _hargaJualController.text = _rupiahFormat.format(widget.produk!.hargaJual);
      _stokController.text = widget.produk!.stok.toString();
      _satuanController.text = widget.produk!.satuan;
      _kategori = widget.produk!.kategori;
      if (widget.produk!.foto != null) {
        _image = File(widget.produk!.foto!);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(imagePath);
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _saveProduk() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text;
      final hargaBeli = double.tryParse(
              _hargaBeliController.text.replaceAll('.', '')) ??
          0.0;
      final hargaJual = double.tryParse(
              _hargaJualController.text.replaceAll('.', '')) ??
          0.0;
      final stok = int.tryParse(_stokController.text) ?? 0;

      final produk = Produk(
        idProduk: widget.produk?.idProduk,
        namaProduk: nama,
        hargaBeli: hargaBeli,
        hargaJual: hargaJual,
        stok: stok,
        kategori: _kategori!,
        satuan: _satuanController.text,
        foto: _image?.path,
      );

      if (widget.produk == null) {
        await _dbHelper.createProduk(produk);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue[700],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Data Produk Berhasil Ditambahkan!',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (mounted) Navigator.pop(context);
        }
      } else {
        await _dbHelper.updateProduk(produk);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.update,
                      color: Colors.blue[700],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Data Produk Berhasil Diubah!',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (mounted) Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk == null ? 'Tambah Produk' : 'Edit Produk'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.grey[100],
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.center,
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada gambar dipilih',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '(Tap untuk memilih gambar)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaBeliController,
                  decoration: InputDecoration(
                    labelText: 'Harga Beli',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RupiahInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga beli tidak boleh kosong';
                    }
                    final cleanValue = value.replaceAll('.', '');
                    if (double.tryParse(cleanValue) == null ||
                        double.parse(cleanValue) <= 0) {
                      return 'Harga beli harus berupa angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaJualController,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RupiahInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga jual tidak boleh kosong';
                    }
                    final cleanValue = value.replaceAll('.', '');
                    if (double.tryParse(cleanValue) == null ||
                        double.parse(cleanValue) <= 0) {
                      return 'Harga jual harus berupa angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stokController,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Stok harus berupa angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _satuanController,
                  decoration: InputDecoration(
                    labelText: 'Satuan',
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: pcs, dus, pak, porsi, dll',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Satuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _kategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Makanan', 'Minuman'].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _kategori = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(widget.produk == null ? 'Simpan' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _satuanController.dispose();
    super.dispose();
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format as Rupiah
    final number = int.parse(newText);
    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(number);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}