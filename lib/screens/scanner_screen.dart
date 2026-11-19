import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Opens the camera, returns the first code it reads, and closes
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

// this screen has no knowledge of the api or models so it can be reusable to anything needed
class _ScannerScreenState extends State<ScannerScreen> {
  bool _handled =
      false; // onDetect fires many times per second, only act on the first

  // called continuosly while a code is in view
  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (_handled || code == null) return;
    _handled = true;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan item QR')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
