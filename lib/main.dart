import 'package:flutter/material.dart';

import 'app.dart';
import 'data/services/api_service.dart';

// loading the token on startup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // plugins like secure storage need Flutter running before runApp
  final loggedIn = await ApiService().loadToken();
  runApp(MyApp(loggedIn: loggedIn));
}