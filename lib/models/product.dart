class Produk {
  int? idProduk;
  String namaProduk;
  double harga;
  int stok;
  String kategori;
  String? foto;

  Produk({
    this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.kategori,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produk': idProduk,
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
      'foto': foto,
    };
  }

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      idProduk: map['id_produk'],
      namaProduk: map['nama_produk'],
      harga: map['harga'],
      stok: map['stok'],
      kategori: map['kategori'],
      foto: map['foto'],
    );
  }
}