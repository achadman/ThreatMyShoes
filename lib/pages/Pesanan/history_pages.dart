import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter03/pages/Pesanan/order_detail.dart';

class HistoryPages extends StatefulWidget {
  const HistoryPages({super.key});

  @override
  State<HistoryPages> createState() => _HistoryPagesState();
}

class _HistoryPagesState extends State<HistoryPages> {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getHistoryStream() {
    final userId = supabase.auth.currentUser?.id;
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId ?? '')
        .order('pickup_date', ascending: false);
  }

  // FUNGSI HELPER: Menentukan warna berdasarkan status dari database
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'arrived':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // FUNGSI HELPER: Mengubah id status menjadi teks yang enak dibaca
  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return "Menunggu";
      case 'processed':
        return "Proses Cuci";
      case 'shipped':
        return "Sedang Dikirim";
      case 'arrived':
        return "Selesai";
      default:
        return status?.toUpperCase() ?? "UNKNOWN";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada riwayat pesanan"));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildHistoryCard(order);
            },
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'processed':
        return Icons.wash;
      case 'shipped':
        return Icons.local_shipping;
      case 'arrived':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> order) {
    DateTime pickupDate = DateTime.parse(order['pickup_date']);
    String formattedDate = DateFormat('dd MMM yyyy').format(pickupDate);

    String rawStatus = order['status']?.toString() ?? "pending";

    Color statusColor = _getStatusColor(rawStatus);
    String statusLabel = _getStatusLabel(rawStatus);
    IconData statusIcon = _getStatusIcon(rawStatus); // Ambil ikon

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
        // Tambahkan ikon kecil di depan judul (opsional tapi bagus)
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          order['treatment_name'] ?? "Layanan",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text("Jadwal: $formattedDate"),
            Text(
              "Total: Rp ${order['total_price']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        // Bagian Status dengan Ikon + Teks
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Agar container tidak melebar
            children: [
              Icon(statusIcon, color: statusColor, size: 14), // Ikon kecil
              const SizedBox(width: 5),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
