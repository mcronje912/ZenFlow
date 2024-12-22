// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenFlow'),
      ),
      body: const Center(
        child: Text('Welcome to ZenFlow!'),
      ),
    );
  }
}