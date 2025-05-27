import 'package:flutter/material.dart';
import 'package:pos_app/components/menu.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:pos_app/components/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset(
          'assets/images/splash-removebg-preview.png'
        ),
      ), 
      nextScreen: const WelcomeScreen(),
      duration: 5000,
      backgroundColor: Colors.white,
    );
  }
}