import 'package:flutter/material.dart';
import 'package:pos_app/components/onboarding_screen.dart';
import 'components/splash_screen.dart';
import 'components/menu.dart'; // Impor MenuPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/menu': (context) => const MenuPage(title: 'KasirKu'),
      },
    );
  }
}