import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/prescription.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<String> login(String phone) async {
    final uri = Uri.parse('$baseUrl/api/patients/login/');
    final response = await http.post(uri, body: {'phone': phone});

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['token_number'] as String;
  }

  static Future<Prescription> uploadPrescription({
    required Uint8List imageBytes,
    required String fileName,
    required String tokenNumber,
  }) async {
    final uri = Uri.parse('$baseUrl/api/prescriptions/process/');
    final request = http.MultipartRequest('POST', uri);

    request.fields['token_number'] = tokenNumber;

    request.files.add(
      http.MultipartFile.fromBytes('prescription_file', imageBytes, filename: fileName),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Prescription.fromJson(jsonDecode(responseBody) as Map<String, dynamic>);
    } else {
      throw Exception('Upload failed (${response.statusCode}): $responseBody');
    }
  }

  static Future<Prescription> getLatestPrescription(String tokenNumber) async {
    final uri = Uri.parse('$baseUrl/api/patients/$tokenNumber/latest/');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Prescription.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch status (${response.statusCode}): ${response.body}');
    }
  }
}