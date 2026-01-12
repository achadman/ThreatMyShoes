import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/treatment_model.dart';

class DurationAdjuster extends StatelessWidget {
  final Treatment selectedTreatment;
  final int activeDuration;
  final DateTime pickupDate;
  final int expressFee;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const DurationAdjuster({
    super.key,
    required this.selectedTreatment,
    required this.activeDuration,
    required this.pickupDate,
    required this.expressFee,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    DateTime deliveryDate = pickupDate.add(Duration(days: activeDuration));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Waktu Pengerjaan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Durasi Pengerjaan:"),
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: activeDuration > 1 ? onRemove : null,
                          icon: const Icon(Icons.remove),
                          iconSize: 24,
                        ),
                        Text(
                          "$activeDuration Hari",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton.outlined(
                          onPressed: activeDuration < selectedTreatment.baseDays
                              ? onAdd
                              : null,
                          icon: const Icon(Icons.add),
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Estimasi Selesai:"),
                    Text(
                      DateFormat('dd MMM yyyy').format(deliveryDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (activeDuration < selectedTreatment.baseDays)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "* Biaya Express: +Rp $expressFee",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
