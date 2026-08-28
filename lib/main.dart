import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'models/scan_result.dart';

void main() {
  runApp(const WordScannerApp());
}

class WordScannerApp extends StatelessWidget {
  const WordScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Scanner',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ScanResult;
          return ResultScreen(result: args);
        }
      },
    );
  }
}
