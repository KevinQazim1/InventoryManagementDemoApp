import 'package:flutter/material.dart';
import 'package:inventory_management_app/screens/inventory_list_screen.dart';
import 'package:inventory_management_app/screens/item_form_screen.dart';
import 'package:inventory_management_app/screens/scanner_screen.dart';
import 'package:inventory_management_app/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: loggedIn ? const ItemListScreen() : const LoginScreen(), // first screen depends on the token check
      routes: {
        '/items': (context) => const ItemListScreen(),
        '/login': (context) => const LoginScreen(),
        '/item': (context) => const ItemFormScreen(),
        '/scan': (context) => const ScannerScreen(),
      },
    );
  }
}