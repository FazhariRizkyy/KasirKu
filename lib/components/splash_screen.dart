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
          width: MediaQuery.of(context).size.width * 5.5, // Adjust size
          height: MediaQuery.of(context).size.height * 5.5,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset('assets/images/KasirKu-Icon.png'),
          ),
        ),
      ),
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: const WelcomeScreen(),
      duration: 5000,
      backgroundColor: Colors.blue,
    );
  }
}
