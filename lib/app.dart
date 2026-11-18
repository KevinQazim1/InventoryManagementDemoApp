import 'package:flutter/material.dart';
import 'package:inventory_management_app/screens/inventory_list_screen.dart';
import 'package:inventory_management_app/screens/item_form_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routes: { // setting up the routes for app navigation
        '/': (context) => const ItemListScreen(),
        '/item': (context) => const ItemFormScreen(),
      },
    );
  }
}