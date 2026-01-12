import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Future<void> contactAdmin(Map<String, dynamic> orderData) async {
      final String phoneNumber =
          "6283121782648"; // Gunakan format internasional tanpa '+'
      final String orderId = orderData['id'].toString().substring(0, 8);
      final String layanan = orderData['treatment_name'] ?? '-';
      final String status =
          orderData['status']?.toString().toUpperCase() ?? 'PENDING';

      // Susun template pesan
      final String message =
          "Halo Admin TreatMyShoes, saya ingin menanyakan tentang pesanan saya:\n\n"
          "🆔 ID Order: #$orderId\n"
          "✨ Layanan: $layanan\n"
          "📊 Status: $status\n\n"
          "Mohon bantuannya, terima kasih.";

      // Encode pesan agar aman dikirim melalui URL
      final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Berikan peringatan jika WhatsApp tidak terinstall
        debugPrint("Tidak dapat membuka WhatsApp");
      }
    }

    final supabase = Supabase.instance.client;

    // Stream untuk memantau perubahan pada satu order spesifik ini
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('id', order['id']), // Hanya dengarkan order ini saja
      builder: (context, snapshot) {
        // Ambil data terbaru dari stream, jika belum ada gunakan data awal dari constructor
        final currentOrder = (snapshot.hasData && snapshot.data!.isNotEmpty)
            ? snapshot.data!.first
            : order;

        DateTime pickupDate = DateTime.parse(currentOrder['pickup_date']);
        String formattedDate = DateFormat(
          'EEEE, dd MMMM yyyy',
          'id_ID',
        ).format(pickupDate);

        return Scaffold(
          backgroundColor: const Color(0xffF8F9FA),
          appBar: AppBar(
            title: const Text(
              "Detail Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Status Badge (Sekarang Real-time!)
                _buildStatusHeader(currentOrder['status'] ?? 'pending'),
                const SizedBox(height: 20),

                // 2. Nota Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "TREATMYSHOES",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0096C9),
                          ),
                        ),
                      ),
                      const Divider(height: 30),
                      _buildDetailRow(
                        "Layanan",
                        currentOrder['treatment_name'] ?? '-',
                      ),
                      _buildDetailRow("Tgl Jemput", formattedDate),
                      _buildDetailRow(
                        "Pengiriman",
                        currentOrder['delivery_option'] ?? '-',
                      ),
                      const Divider(height: 30),
                      const Text(
                        "Alamat Penjemputan/Ket:",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currentOrder['address'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Bayar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp ${currentOrder['total_price']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0096C9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Tombol Bantuan
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        contactAdmin(currentOrder), // Panggil fungsi di sini
                    icon: const Icon(Icons.chat_outlined), // Icon ganti ke chat
                    label: const Text("Tanyakan Pesanan ke Admin"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xff0096C9)),
                      foregroundColor: const Color(0xff0096C9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(String status) {
    String displayStatus = "PENDING";
    Color color = Colors.orange;

    // Samakan dengan logika Admin
    switch (status.toLowerCase()) {
      case 'pending':
        displayStatus = "MENUNGGU KONFIRMASI";
        color = Colors.orange;
        break;
      case 'processed':
        displayStatus = "SEDANG DICUCI";
        color = Colors.blue;
        break;
      case 'shipped':
        displayStatus = "SEDANG DIKIRIM";
        color = Colors.purple;
        break;
      case 'arrived':
        displayStatus = "PESANAN SELESAI";
        color = Colors.green;
        break;
      default:
        displayStatus = status.toUpperCase();
        color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
