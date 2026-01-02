import 'package:flutter/material.dart';

class PriceBreakdown extends StatelessWidget {
  final int treatmentPrice;
  final int expressFee;
  final int deliveryFee;
  final int totalPrice;

  const PriceBreakdown({
    super.key,
    required this.treatmentPrice,
    required this.expressFee,
    required this.deliveryFee,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rincian Biaya", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          _buildRow("Harga Layanan", treatmentPrice),
          if (expressFee > 0) _buildRow("Biaya Express", expressFee, isRed: true),
          if (deliveryFee > 0) _buildRow("Ongkos Kirim", deliveryFee),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Rp $totalPrice", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0096C9))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, int amount, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text("Rp $amount", style: TextStyle(color: isRed ? Colors.red : Colors.black)),
        ],
      ),
    );
  }
}