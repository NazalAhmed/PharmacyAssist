class Medicine {
  final int id;
  final String extractedName;
  final int? medicine; // id of matched Medicine, null if unmatched
  final String? medicineName;
  final String? genericName;
  final String dosage;
  final String frequency;
  final String duration;
  final double? confidenceScore;
  final bool? available;
  final bool pharmacistVerified;

  Medicine({
    required this.id,
    required this.extractedName,
    this.medicine,
    this.medicineName,
    this.genericName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.confidenceScore,
    this.available,
    required this.pharmacistVerified,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int,
      extractedName: json['extracted_name'] as String? ?? '',
      medicine: json['medicine'] as int?,
      medicineName: json['medicine_name'] as String?,
      genericName: json['generic_name'] as String?,
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      available: json['available'] as bool?,
      pharmacistVerified: json['pharmacist_verified'] as bool? ?? false,
    );
  }

  bool get isMatched => medicine != null;
}