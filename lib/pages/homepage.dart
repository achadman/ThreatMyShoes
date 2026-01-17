import 'package:flutter/material.dart';
import 'package:flutter03/models/order_model.dart';
import 'package:flutter03/models/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final Function(String) onSelect;

  const HomePage({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Future<void> contactAdmin() async {
      final String phoneNumber = "6283121782648";
      // Tidak ada orderData di HomePage, jadi pesan umum
      final String layanan = 'Layanan Umum';
      final String status = 'Pertanyaan Umum';

      final String message =
          "Halo Admin TreatMyShoes, saya ingin menanyakan tentang pesanan saya:\n\n"
          "Saya memiliki pertanyaan terkait:\n"
          "✨ $layanan\n"
          "📊 $status\n\n"
          "Mohon bantuannya, terima kasih.";

      final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Tidak dapat membuka WhatsApp");
      }
    }

    final List<String> promoImages = [
      'assets/gambar/images.jpeg',
      'assets/gambar/images.jpeg',
      'assets/gambar/images.jpeg',
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Removed orderData
        onPressed: () => contactAdmin(),
        backgroundColor: const Color(0xFF25D366), // Warna hijau WhatsApp
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text(
          "Konsultasi Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== SLIDER PROMO =====
            SizedBox(
              height: 140,
              width: double.infinity,
              child: PageView.builder(
                itemCount: promoImages.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(promoImages[index]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),

            // ===== TOMBOL SEPATU =====
            InkWell(
              onTap: () => onSelect("Sepatu"),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.directions_run, size: 70, color: Colors.white),
                    SizedBox(height: 14),
                    Text(
                      "Laundry Sepatu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Deep Clean • Express • Premium",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
