import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final matched = medicine.isMatched;
    final available = medicine.available;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    medicine.medicineName ?? medicine.extractedName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(matched: matched, available: available),
              ],
            ),

            if (matched &&
                medicine.genericName != null &&
                medicine.genericName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  medicine.genericName!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),

            if (!matched)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'OCR read: "${medicine.extractedName}"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (medicine.dosage.isNotEmpty)
                  _detail(Icons.medication, medicine.dosage),
                if (medicine.frequency.isNotEmpty)
                  _detail(Icons.schedule, medicine.frequency),
                if (medicine.duration.isNotEmpty)
                  _detail(Icons.date_range, medicine.duration),
              ],
            ),

            if (medicine.confidenceScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Match confidence: ${medicine.confidenceScore!.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool matched;
  final bool? available;

  const _StatusChip({required this.matched, required this.available});

  @override
  Widget build(BuildContext context) {
    if (!matched) {
      return _chip('Not matched', Colors.grey.shade200, Colors.grey.shade700);
    }

    final isAvailable = available == true;

    return _chip(
      isAvailable ? 'Available' : 'Out of stock',
      isAvailable ? Colors.green.shade100 : Colors.red.shade100,
      isAvailable ? Colors.green.shade800 : Colors.red.shade800,
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: fg)),
    );
  }
} 