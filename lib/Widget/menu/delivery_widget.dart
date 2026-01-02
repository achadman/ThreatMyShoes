// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryWidget extends StatelessWidget {
  final String deliveryOption;
  final double distance;
  // Callback untuk mengirim data balik ke file utama
  final Function(String) onOptionChanged;
  final Function(double) onDistanceChanged;

  const DeliveryWidget({
    super.key,
    required this.deliveryOption,
    required this.distance,
    required this.onOptionChanged,
    required this.onDistanceChanged,
  });

  Future<void> _openMap() async {
    const String googleMapsUrl = "https://maps.google.com/?q=Lokasi+Toko+Sepatu";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: deliveryOption,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ["Antar Sendiri", "Jemput"]
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => onOptionChanged(val!),
        ),
        const SizedBox(height: 16),

        if (deliveryOption == "Antar Sendiri") ...[
          _buildInfoToko(),
        ] else ...[
          _buildInputJemput(),
        ],
      ],
    );
  }

  Widget _buildInfoToko() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text("Silakan datang ke toko kami di alamat berikut:"),
          const Text("Jl. Angin Topan No. 123, Bandung", 
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _openMap,
            icon: const Icon(Icons.location_on),
            label: const Text("Google Maps (TreatMyShoes)"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputJemput() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Alamat Lengkap Penjemputan",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Estimasi Jarak dari Toko (KM)",
            border: OutlineInputBorder(),
            suffixText: "KM",
            helperText: "Gratis ongkir < 2 KM. Lebih dari itu 5rb/KM",
          ),
          onChanged: (val) {
            double dist = double.tryParse(val) ?? 0;
            onDistanceChanged(dist);
          },
        ),
      ],
    );
  }
}