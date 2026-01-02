// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter03/Widget/menu/date_picker.dart';
import 'package:flutter03/Widget/menu/delivery_widget.dart';
import 'package:flutter03/Widget/menu/duration_adjuster.dart';
import 'package:flutter03/Widget/menu/price_breakdown.dart';
import 'package:flutter03/Widget/menu/treatment_grid.dart';
import 'package:flutter03/logic/booking_logic.dart';
import 'package:flutter03/models/treatment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  // 1. STATE VARIABLES
  Treatment? selectedTreatment;
  DateTime pickupDate = DateTime.now();
  int activeDuration =
      0; // Durasi yang dipilih user (bisa dikurangi untuk express)

  String deliveryOption = "Antar Sendiri";
  double distance = 0.0;
  int deliveryFee = 0;
  int expressFee = 0;
  int totalPrice = 0;

  final List<Treatment> treatments = [
    Treatment(name: "Fast Clean", price: 20000, baseDays: 1),
    Treatment(name: "Deep Clean", price: 25000, baseDays: 3),
    Treatment(name: "Un-yellowing", price: 30000, baseDays: 3),
    Treatment(name: "Repaint", price: 75000, baseDays: 5),
  ];

  // 2. LOGIKA PERHITUNGAN BARU
  void calculateTotal() {
    if (selectedTreatment == null) return;

    setState(() {
      // Panggil logika dari file terpisah
      expressFee = BookingLogic.calculateExpressFee(
        activeDuration,
        selectedTreatment!.baseDays,
      );
      deliveryFee = BookingLogic.calculateDeliveryFee(deliveryOption, distance);

      totalPrice = selectedTreatment!.price + expressFee + deliveryFee;
    });
  }

  // Di dalam _MenupageState:
  List<String> fullyBookedDates = [
    "2024-05-25",
  ]; // Contoh data dari database nanti

  // Update fungsi pilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      // Pakai aturan dari file logic
      selectableDayPredicate: (day) =>
          BookingLogic.isDateSelectable(day, fullyBookedDates),
    );
    if (picked != null) setState(() => pickupDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomSummary(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Treatment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Cari bagian "Pilih Treatment"
              const SizedBox(height: 10),
              TreatmentGrid(
                treatments: treatments,
                selectedTreatment: selectedTreatment,
                onSelect: (item) {
                  setState(() {
                    selectedTreatment = item;
                    activeDuration = item.baseDays; // Reset durasi ke standar
                  });
                  calculateTotal();
                },
              ),
              const SizedBox(height: 25),
              const Text(
                "Waktu Pengerjaan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DatePickerSection(
                pickupDate: pickupDate,
                onTap: () => _selectDate(context),
              ),

              if (selectedTreatment != null)
                DurationAdjuster(
                  selectedTreatment: selectedTreatment!,
                  activeDuration: activeDuration,
                  pickupDate: pickupDate,
                  expressFee: expressFee,
                  onAdd: () {
                    setState(() => activeDuration++);
                    calculateTotal();
                  },
                  onRemove: () {
                    setState(() => activeDuration--);
                    calculateTotal();
                  },
                ),

              const SizedBox(height: 25),
              const Text(
                "Opsi Pengiriman",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              DeliveryWidget(
                deliveryOption: deliveryOption,
                distance: distance,
                onOptionChanged: (val) {
                  setState(() {
                    deliveryOption = val;
                    if (val == "Antar Sendiri") {
                      distance = 0;
                      deliveryFee = 0;
                    }
                    calculateTotal();
                  });
                },
                onDistanceChanged: (val) {
                  setState(() {
                    distance = val;
                    calculateTotal();
                  });
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _sendToWhatsApp() async {
    String phone = "6283121782648"; // Ganti nomor toko kamu
    String message =
        "Halo TreatMyShoes, saya mau pesan layanan laundry:\n\n"
        "- Layanan: ${selectedTreatment?.name}\n"
        "- Jarak: $distance KM\n"
        "- Opsi: $deliveryOption\n"
        "- Total: Rp $totalPrice\n"
        "- Alamat: (Isi alamat disini)";

    var url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Agar container menyesuaikan tinggi konten
        children: [
          // 1. Tampilkan rincian tipis jika sudah pilih treatment
          if (selectedTreatment != null) ...[
            _buildSmallRow("Harga Layanan", "Rp ${selectedTreatment!.price}"),
            if (expressFee > 0)
              _buildSmallRow("Biaya Express", "Rp $expressFee"),
            if (deliveryFee > 0)
              _buildSmallRow("Ongkos Kirim", "Rp $deliveryFee"),
            const Divider(height: 20),
          ],

          // 2. Baris Utama (Total & Tombol)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Bayar", style: TextStyle(fontSize: 12)),
                  Text(
                    "Rp $totalPrice",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0096C9),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0096C9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: selectedTreatment == null
                    ? null
                    : () => _sendToWhatsApp(),
                child: const Text(
                  "Pesan Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk baris rincian di bottom sheet
  Widget _buildSmallRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
