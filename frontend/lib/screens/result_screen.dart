import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class ResultScreen extends StatefulWidget {
  final Prescription prescription;

  const ResultScreen({super.key, required this.prescription});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Prescription prescription;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    prescription = widget.prescription;
    _maybeStartPolling();
  }

  void _maybeStartPolling() {
    if (prescription.status == 'completed' || prescription.status == 'uploaded' || prescription.status == 'processing') {
      _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _checkStatus());
    }
  }

  Future<void> _checkStatus() async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    try {
      final updated = await ApiService.getLatestPrescription(token);

      if (!mounted) return;

      setState(() => prescription = updated);

      if (updated.status == 'verified' || updated.status == 'failed') {
        _pollTimer?.cancel();
      }
    } catch (_) {
      // transient network error - retry on next tick
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(),
              const SizedBox(height: 24),
              _buildStatusText(),
              const SizedBox(height: 16),
              if (prescription.patientToken != null && prescription.patientToken!.isNotEmpty)
                Text(
                  'Token: ${prescription.patientToken}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (prescription.status) {
      case 'verified':
        return Icon(Icons.check_circle, size: 90, color: Colors.green.shade600);
      case 'failed':
        return Icon(Icons.error_outline, size: 90, color: Colors.red.shade400);
      default:
        return const SizedBox(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(strokeWidth: 4),
        );
    }
  }

  Widget _buildStatusText() {
    switch (prescription.status) {
      case 'verified':
        return const Column(
          children: [
            Text(
              'Your medicines are ready!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please collect them from the pharmacy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        );
      case 'failed':
        return const Column(
          children: [
            Text(
              "We couldn't process your prescription.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please try uploading a clearer photo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        );
      default:
        return const Column(
          children: [
            Text(
              'Your prescription is being reviewed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We'll notify you here once it's ready.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        );
    }
  }
}