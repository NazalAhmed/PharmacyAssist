import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';

import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'result_screen.dart';
import 'login_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  bool isProcessing = false;

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = image);
  }

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => selectedImage = image);
  }

  Future<void> processPrescription() async {
    if (selectedImage == null || isProcessing) return;

    final token = await AuthStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in again')));
      return;
    }

    setState(() => isProcessing = true);

    try {
      final Uint8List imageBytes = await selectedImage!.readAsBytes();

      final prescription = await ApiService.uploadPrescription(
        imageBytes: imageBytes,
        fileName: selectedImage!.name,
        tokenNumber: token,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(prescription: prescription),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('Invalid token')) {
        await AuthStorage.clearSession();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Select a prescription image',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : Image.network(
                        selectedImage!.path,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('Unable to preview image'),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : pickFromGallery,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choose Prescription'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : pickFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedImage != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : processPrescription,
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Process Prescription'),
                ),
              ),
            if (isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Reading prescription, this can take a moment...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
