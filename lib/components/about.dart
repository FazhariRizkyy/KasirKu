import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0, // Flat modern look
      ),
      backgroundColor: Colors.white, // Tema warna putih untuk latar belakang
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto profil di bagian atas
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage(
                'assets/images/GW-TUH.jpg', // Ganti dengan URL atau AssetImage('assets/images/foto_kamu.jpg')
              ),
              backgroundColor: Colors.blue.shade100, // Warna cadangan jika gambar gagal dimuat
            ),
            const SizedBox(height: 20),
            // Kartu informasi pengembang
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Fazhari Rizky',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pengembang Aplikasi Kasir UMKM',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.blue.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saya adalah pengembang aplikasi mobile yang bersemangat untuk menciptakan solusi teknologi bagi UMKM. Aplikasi ini dibuat untuk membantu pengelolaan kasir dengan mudah dan efisien.',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Informasi tambahan (opsional)
            Text(
              'Versi Aplikasi: 1.0.0',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}