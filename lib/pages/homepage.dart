import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(String) onSelect; 
  const HomePage({super.key, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    // List Menu Produk
    final List<Map<String, dynamic>> services = [
      {'name': 'Sepatu', 'icon': Icons.directions_run, 'color': Colors.blue},
      {'name': 'Tas', 'icon': Icons.shopping_bag, 'color': Colors.orange},
      {'name': 'Jaket', 'icon': Icons.checkroom, 'color': Colors.red},
      {'name': 'Helm', 'icon': Icons.sports_motorsports, 'color': Colors.green},
    ];

    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Halo, mau laundry apa?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Pilih kategori produk di bawah ini"),
            const SizedBox(height: 25),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Kolom
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(context, service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    return InkWell(
      // 2. Panggil onSelect saat kartu diklik
      onTap: () => onSelect(service['name']),
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service['icon'], size: 45, color: service['color']),
            const SizedBox(height: 12),
            Text(
              service['name'], 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}