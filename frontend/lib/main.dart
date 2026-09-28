import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_storage.dart';

void main() {
  runApp(const SmartPharmacyApp());
}

class SmartPharmacyApp extends StatelessWidget {
  const SmartPharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pharmacy',
      theme: ThemeData(useMaterial3: true),
      home: const _SessionGate(),
    );
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final hasToken = snapshot.data != null && snapshot.data!.isNotEmpty;
        return hasToken ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}