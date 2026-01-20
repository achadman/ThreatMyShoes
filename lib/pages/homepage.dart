import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final Function(String) onSelect;

  const HomePage({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Future<void> contactAdmin() async {
      final String phoneNumber = "6283121782648";
      final String message =
          "Halo Admin TreatMyShoes, saya ingin menanyakan tentang layanan laundry sepatu.\n\nTerima kasih.";

      final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    }

    final List<String> promoImages = [
      'assets/gambar/1.png',
      'assets/gambar/2.png',
      'assets/gambar/3.png',
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: contactAdmin,
        backgroundColor: const Color(0xFF25D366),
        icon: const Icon(Icons.message, color: Colors.white),
        label: const Text(
          "Konsultasi Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== SLIDER PROMO =====
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: promoImages.length,
                itemBuilder: (context, index) {
                  return Container(
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

            const SizedBox(height: 16),

            // ===== TOMBOL LAUNDRY SEPATU =====
            InkWell(
              onTap: () => onSelect("Sepatu"),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 180,
                width: double.infinity,
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

            const SizedBox(height: 24),

            // ===== KENAPA PILIH =====
            const Text(
              "Kenapa Pilih TreatMyShoes?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _FeatureItem(icon: Icons.verified, label: "Profesional"),
                SizedBox(width: 20),
                _FeatureItem(icon: Icons.cleaning_services, label: "Aman"),
                SizedBox(width: 20),
                _FeatureItem(icon: Icons.timer, label: "Cepat"),
              ],
            ),

            const SizedBox(height: 28),

            // ===== CARA PEMESANAN (DIPERCANTIK) =====
            const Text(
              "Cara Pemesanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            _OrderStep(
              step: "1",
              icon: Icons.touch_app,
              title: "Pilih Layanan",
              subtitle: "Pilih jenis laundry sepatu sesuai kebutuhan",
            ),
            _OrderStep(
              step: "2",
              icon: Icons.delivery_dining,
              title: "Penjemputan",
              subtitle: "Admin menjemput sepatu ke lokasi kamu",
            ),
            _OrderStep(
              step: "3",
              icon: Icons.cleaning_services,
              title: "Proses Perawatan",
              subtitle: "Sepatu dicuci dan dirawat secara profesional",
            ),
            _OrderStep(
              step: "4",
              icon: Icons.home,
              title: "Sepatu Diantar",
              subtitle: "Sepatu bersih kembali ke tangan kamu",
              isLast: true,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ===== FEATURE ITEM =====
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue.withOpacity(0.12),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ===== ORDER STEP CARD =====
class _OrderStep extends StatelessWidget {
  final String step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _OrderStep({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.blue.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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
