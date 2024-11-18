import 'package:flutter/material.dart';
import 'package:trusir/loginpage.dart';
import 'package:trusir/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const TrusirLoginPage(), 
        '/menu': (context) => const MenuPage(), 
      },
    );
  }
}
