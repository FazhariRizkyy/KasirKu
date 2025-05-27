import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:pos_app/components/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6, // 60% dari lebar layar
          height: MediaQuery.of(context).size.height * 0.6, // 60% dari tinggi layar
          child: Image.asset(
            'assets/images/KasirKu-Rezize.png',
            fit: BoxFit.scaleDown, // Memperbesar gambar tapi tetap menjaga rasio
          ),
        ),
      ),
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: const WelcomeScreen(),
      duration: 3000, // Dikurangi ke 3 detik agar tidak terlalu lama
      backgroundColor: Colors.blue.shade800, // Warna lebih gelap untuk kontras
      splashIconSize: MediaQuery.of(context).size.width * 0.6, // Sesuaikan ukuran ikon splash
    );
  }
}