import 'package:ar_shopping_app/class/product.dart';
import 'package:ar_shopping_app/home.dart';
import 'package:flutter/material.dart';

// Main entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start at the mock shopping app's home screen.
      home: ShoppingAppHomeScreen(products: products),
    );
  }
}

