import 'package:flutter/material.dart';
import 'upload_screen.dart';
import 'result_screen.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _checkStatus(BuildContext context) async {
    final token = await AuthStorage.getToken();

    if (token == null) return;

    try {
      final prescription = await ApiService.getLatestPrescription(token);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(prescription: prescription)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No prescriptions found yet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Pharmacy')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_pharmacy, size: 90),
            const SizedBox(height: 24),
            const Text(
              'Digital Prescription Processing',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan or upload your prescription to check medicines and availability.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _checkStatus(context),
                icon: const Icon(Icons.search),
                label: const Text('Check Prescription Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}