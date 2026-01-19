import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({
    super.key,
    required String orderId,
    required String status,
  });

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _getActiveOrderStream() {
    final userId = supabase.auth.currentUser?.id;

    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId ?? '')
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan Selesai! Terima kasih."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF18ADFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Status Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getActiveOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final order = snapshot.data!.first;
          final String status = order['status'] ?? "pending";
          final currentStep = _getCurrentStep(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildIllustrationHeader(status, primaryBlue),
                const SizedBox(height: 25),
                _buildOrderDetails(order),
                const SizedBox(height: 25),

                // TIMELINE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStepItem(
                        "Konfirmasi Pesanan",
                        "Admin sedang memproses pesanan",
                        Icons.fact_check,
                        0,
                        currentStep,
                      ),
                      _buildStepItem(
                        "Dalam Perawatan",
                        "Sepatu sedang dicuci oleh tim",
                        Icons.waves,
                        1,
                        currentStep,
                      ),
                      _buildStepItem(
                        "Siap Dikirim",
                        "Sepatu bersih menuju lokasimu",
                        Icons.local_shipping,
                        2,
                        currentStep,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (status == 'shipped') _buildCompleteButton(order['id']),
              ],
            ),
          );
        },
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Tidak Ada Pesanan Aktif",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const Text(
            "Semua sepatumu sudah kembali bersih!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // HEADER STATUS
  Widget _buildIllustrationHeader(String status, Color primary) {
    IconData icon = Icons.query_builder;
    String message = "Menunggu Konfirmasi";

    if (status == 'processed') {
      icon = Icons.opacity;
      message = "Sedang Dicuci";
    } else if (status == 'shipped') {
      icon = Icons.local_shipping_outlined;
      message = "Sedang Dikirim";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Icon(icon, size: 80, color: primary),
          const SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  // DETAIL PESANAN
  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2, color: Colors.white70, size: 40),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ORDER ID: #${order['id'].toString().substring(0, 8).toUpperCase()}",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                order['treatment_name'] ?? "Treatment Sepatu",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP ITEM
  Widget _buildStepItem(
    String title,
    String desc,
    IconData icon,
    int index,
    int currentStep,
  ) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;
    Color color = isCompleted || isActive
        ? const Color(0xFF18ADFF)
        : Colors.grey[300]!;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.white,
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  size: 16,
                  color: isCompleted ? Colors.white : color,
                ),
              ),
              if (index != 2)
                Expanded(child: VerticalDivider(color: color, thickness: 2)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive || isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive || isCompleted
                        ? Colors.black54
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON SELESAI
  Widget _buildCompleteButton(String orderId) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _completeOrder(orderId),
        child: const Text(
          "Pesanan Saya Terima",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
