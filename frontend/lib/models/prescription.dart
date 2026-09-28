import 'medicine.dart';

class Prescription {
  final int id;
  final String source;
  final String? prescriptionFile;
  final String? extractedText;
  final String status;
  final String? patientToken;
  final String? patientName;
  final String? patientPhone;
  final List<Medicine> medicines;
  final String? createdAt;
  final String? updatedAt;

  Prescription({
    required this.id,
    required this.source,
    this.prescriptionFile,
    this.extractedText,
    required this.status,
    this.patientToken,
    this.patientName,
    this.patientPhone,
    required this.medicines,
    this.createdAt,
    this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as int,
      source: json['source'] as String? ?? '',
      prescriptionFile: json['prescription_file'] as String?,
      extractedText: json['extracted_text'] as String?,
      status: json['status'] as String? ?? 'uploaded',
      patientToken: json['patient_token'] as String?,
      patientName: json['patient_name'] as String?,
      patientPhone: json['patient_phone'] as String?,
      medicines: (json['medicines'] as List<dynamic>? ?? [])
          .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}