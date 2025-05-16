import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_app/models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter untuk database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasirku.db');
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Membuat tabel saat database dibuat
  Future _createDB(Database db, int version) async {
    // Tabel Produk
    await db.execute('''
    CREATE TABLE tabel_produk (
      id_produk INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_produk TEXT NOT NULL,
      harga REAL NOT NULL,
      stok INTEGER NOT NULL,
      kategori TEXT NOT NULL,
      tanggal_masuk DATE,
      foto TEXT
      )
    ''');

    //Tabel Stok Masuk
    await db.execute('''
      CREATE TABLE tabel_stok_masuk (
        id_stok INTEGER PRIMARY KEY,
        id_produk INTEGER NOT NULL,
        nama_produk TEXT NOT NULL,
        harga REAL NOT NULL,
        stok INTEGER NOT NULL,
        tanggal_masuk TEXT NOT NULL,
        FOREIGN KEY (id_produk) REFERENCES tabel_produk(id_produk)
      )
    ''');

    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE tabel_transaksi (
        id_transaksi INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produk INTEGER NOT NULL,
        nama_produk TEXT NOT NULL,
        harga REAL NOT NULL,
        stok INTEGER NOT NULL,
        kategori TEXT NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (id_produk) REFERENCES tabel_produk(id_produk)
      )
    ''');

    // Tabel Laporan Penjualan
    await db.execute('''
      CREATE TABLE tabel_laporan_penjualan (
        id_laporan INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER NOT NULL,
        id_produk INTEGER NOT NULL,
        nama_produk TEXT NOT NULL,
        harga REAL NOT NULL,
        stok INTEGER NOT NULL,
        kategori TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (id_transaksi) REFERENCES tabel_transaksi(id_transaksi),
        FOREIGN KEY (id_produk) REFERENCES tabel_produk(id_produk)
      )
    ''');
  }

  // CRUD Operations untuk tabel_produk
  Future<int> createProduk(Produk produk) async {
    final db = await database;
    final productId = await db.insert('tabel_produk', produk.toMap());

    // Insert ke tabel_stok_masuk untuk mencatat riwayat stok masuk
    await db.insert('tabel_stok_masuk', {
      'id_produk': productId,
      'nama_produk': produk.namaProduk,
      'harga': produk.harga,
      'stok': produk.stok,
      'tanggal_masuk': DateTime.now().toIso8601String(), // Format tanggal
    });

    return productId;
  }

  Future<List<Produk>> getAllProduk() async {
    final db = await database;
    final result = await db.query('tabel_produk');
    return result.map((map) => Produk.fromMap(map)).toList();
  }

  Future<Produk?> getProdukById(int id) async {
    final db = await database;
    final result = await db.query(
      'tabel_produk',
      where: 'id_produk = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Produk.fromMap(result.first) : null;
  }

  Future<int> updateProduk(Produk produk) async {
    final db = await database;
    return await db.update(
      'tabel_produk',
      produk.toMap(),
      where: 'id_produk = ?',
      whereArgs: [produk.idProduk],
    );
  }

  Future<int> deleteProduk(int id) async {
    final db = await database;
    return await db.delete(
      'tabel_produk',
      where: 'id_produk = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllStokMasuk() async {
    final db = await database;
    return await db.query('tabel_stok_masuk', orderBy: 'tanggal_masuk DESC');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
