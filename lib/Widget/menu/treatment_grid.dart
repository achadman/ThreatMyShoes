import 'package:flutter/material.dart';
import 'package:flutter03/models/treatment_model.dart'; // Pastikan import modelnya benar

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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final item = treatments[index];
        bool isSelected = selectedTreatment?.name == item.name;
        
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff0096C9).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xff0096C9) : Colors.grey.shade300, 
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp ${item.price}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  "${item.baseDays} Hari", 
                  style: const TextStyle(
                    color: Colors.blue, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}