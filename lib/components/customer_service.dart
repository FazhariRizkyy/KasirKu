import 'package:flutter/material.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Service')),
      body: const Center(child: Text('Ini adalah halaman Customer Service')),
    );
  }
}