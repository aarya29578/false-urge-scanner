import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
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
        '/': (context) => const WordScannerNavigation(),
        '/result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ScanResult;
          return ResultScreen(result: args);
        },
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class WordScannerNavigation extends StatefulWidget {
  const WordScannerNavigation({super.key});

  @override
  State<WordScannerNavigation> createState() => _WordScannerNavigationState();
}

class _WordScannerNavigationState extends State<WordScannerNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Protection',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
