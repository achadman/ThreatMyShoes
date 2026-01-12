import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter03/models/treatment_model.dart';

class TreatmentGrid extends StatelessWidget {
  final List<Treatment> treatments;
  final Treatment? selectedTreatment;
  final Function(Treatment) onSelect;

  const TreatmentGrid({
    super.key,
    required this.treatments,
    required this.selectedTreatment,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
                "Pilih Treatment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        SizedBox(height: 12,),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: treatments.length,
          itemBuilder: (context, index) {
            final item = treatments[index];
            
            // Logika agar tidak semua ter-select di awal
            bool isSelected = false;
            if (selectedTreatment != null) {
              if (item.id != null) {
                isSelected = selectedTreatment?.id == item.id;
              } else {
                isSelected = selectedTreatment?.name == item.name;
              }
            }
            
            return GestureDetector(
              onTap: () => onSelect(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xff0096C9).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xff0096C9) : Colors.grey.shade300, 
                    width: isSelected ? 2.5 : 1, // Tebal hanya jika terpilih
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xff0096C9) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(item.price),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.baseDays} Hari", 
                      style: TextStyle(
                        color: isSelected ? const Color(0xff0096C9) : Colors.blue, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}