class Produk {
  int? idProduk;
  String namaProduk;
  double hargaBeli; // Baru
  double hargaJual; // Baru
  int stok;
  String kategori;
  String? foto;

  Produk({
    this.idProduk,
    required this.namaProduk,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.kategori,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produk': idProduk,
      'nama_produk': namaProduk,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'kategori': kategori,
      'foto': foto,
    };
  }

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      idProduk: map['id_produk'],
      namaProduk: map['nama_produk'],
      hargaBeli: map['harga_beli']?.toDouble() ?? 0.0,
      hargaJual: map['harga_jual']?.toDouble() ?? map['harga']?.toDouble() ?? 0.0, // Kompatibilitas dengan data lama
      stok: map['stok'],
      kategori: map['kategori'],
      foto: map['foto'],
    );
  }
}