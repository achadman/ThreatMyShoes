import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key, required String orderId, required String status});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final supabase = Supabase.instance.client;

  // Stream untuk mengambil pesanan yang BELUM "arrived"
  Stream<List<Map<String, dynamic>>> _getActiveOrderStream() {
    final userId = supabase.auth.currentUser?.id;

    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId ?? '')
        // .neq tidak ada di sini, jadi kita ambil semua dulu
        // lalu kita filter di tingkat widget agar lebih aman.
        .map(
          (items) =>
              items.where((item) => item['status'] != 'arrived').toList(),
        );
  }

  int _getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return 0;
      case "processed":
        return 1;
      case "shipped":
        return 2;
      default:
        return 0;
    }
  }

  Future<void> _completeOrder(String orderId) async {
    await supabase
        .from('orders')
        .update({'status': 'arrived'})
        .eq('id', orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan Selesai! Terima kasih.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status Pesanan Aktif")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getActiveOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // JIKA TIDAK ADA PESANAN AKTIF (KOSONG)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada pesanan yang sedang diproses",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!.first;
          final String status = order['status'] ?? "pending";
          final currentStep = _getCurrentStep(status);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(order['id'], order['treatment_name']),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _stepItem(
                        "Menunggu Konfirmasi",
                        Icons.receipt_long,
                        0,
                        currentStep,
                      ),
                      _stepItem(
                        "Proses Cuci",
                        Icons.local_laundry_service,
                        1,
                        currentStep,
                      ),
                      _stepItem(
                        "Sedang Dikirim",
                        Icons.local_shipping,
                        2,
                        currentStep,
                      ),
                    ],
                  ),
                ),

                // TOMBOL SELESAI: Muncul hanya jika status sudah 'shipped'
                if (status == 'shipped')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _completeOrder(order['id']),
                        child: const Text(
                          "Selesaikan Pesanan & Terima Barang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String id, String? name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: ${id.substring(0, 8)}...",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                name ?? "Layanan Laundry",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepItem(String title, IconData icon, int index, int currentStep) {
    final isActive = index <= currentStep;
    final isLast = index == 2;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isActive ? Colors.green : Colors.grey[300],
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? Colors.green : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  isActive ? "Sudah diproses" : "Menunggu giliran",
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
