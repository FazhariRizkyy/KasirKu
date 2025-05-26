class Produk {
  final int? idProduk;
  final String namaProduk;
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final String kategori;
  final DateTime? tanggalMasuk;
  final String? foto;

  Produk({
    this.idProduk,
    required this.namaProduk,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.kategori,
    this.tanggalMasuk,
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
      'tanggal_masuk': tanggalMasuk?.toIso8601String(),
      'foto': foto,
    };
  }

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      idProduk: map['id_produk'],
      namaProduk: map['nama_produk'],
      hargaBeli: map['harga_beli'],
      hargaJual: map['harga_jual'],
      stok: map['stok'],
      kategori: map['kategori'],
      tanggalMasuk: map['tanggal_masuk'] != null
          ? DateTime.parse(map['tanggal_masuk'])
          : null,
      foto: map['foto'],
    );
  }
}