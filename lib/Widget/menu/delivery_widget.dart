// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryWidget extends StatelessWidget {
  final String deliveryOption;
  final double distance;
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
    const String googleMapsUrl =
        "https://maps.app.goo.gl/nhcBpkfCXbv9rw2N8?g_st=aw";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Opsi Pengiriman",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // 1. CARDS SELECTION ROW
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                title: "Antar Sendiri",
                icon: Icons.storefront_outlined,
                isSelected: deliveryOption == "Antar Sendiri",
                onTap: () => onOptionChanged("Antar Sendiri"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                title: "Jemput",
                icon: Icons.moped_outlined,
                isSelected: deliveryOption == "Jemput",
                onTap: () => onOptionChanged("Jemput"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. DYNAMIC CONTENT
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: deliveryOption == "Antar Sendiri"
              ? _buildInfoToko()
              : _buildInputJemput(),
        ),
      ],
    );
  }

  // WIDGET KARTU PILIHAN
  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff0096C9).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xff0096C9) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xff0096C9) : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xff0096C9) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoToko() {
    return Container(
      key: const ValueKey("InfoToko"),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "Silakan datang ke toko kami di alamat berikut:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 5),
          const Text(
            "Jl. Terusan pasir koja, Gg.Rahayu 2 No.93/91, Cibadak, Kec. Astanaanyar, Kota Bandung, Jawa Barat",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _openMap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              elevation: 0,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.location_on, size: 18),
            label: const Text(
              "Google Maps (TreatMyShoes)",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputJemput() {
    return Column(
      key: const ValueKey("InputJemput"),
      children: [
        const Text(
          "Detail Penjemputan",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        // Alamat sudah otomatis dari profile di file utama,
        // widget ini hanya menangani jarak untuk ongkir
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Estimasi Jarak dari Toko",
            prefixIcon: const Icon(Icons.map_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixText: "KM",
            helperText: "Gratis ongkir < 2 KM. Selanjutnya 5rb/KM",
            helperStyle: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
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
