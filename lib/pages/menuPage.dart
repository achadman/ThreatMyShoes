// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter03/Widget/menu/delivery_widget.dart';
import 'package:flutter03/Widget/menu/duration_adjuster.dart';
import 'package:flutter03/Widget/menu/inline_calender.dart';
import 'package:flutter03/Widget/menu/treatment_grid.dart';
import 'package:flutter03/logic/booking_logic.dart';
import 'package:flutter03/models/profile_model.dart';
import 'package:flutter03/models/treatment_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback onBack;
  const MenuPage({super.key, required this.onBack});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // 1. STATE VARIABLES
  Treatment? selectedTreatment;
  DateTime pickupDate = DateTime.now();
  int activeDuration = 0;

  // Variabel penunjang integrasi Supabase
  List<Treatment> treatments = []; // Biarkan kosong dulu, nanti diisi fetch

  bool isLoading = true;
  String deliveryOption = "Antar Sendiri";
  double distance = 0.0;
  int deliveryFee = 0;
  int expressFee = 0;
  int totalPrice = 0;
  UserProfile? currentUserProfile;

  @override
  void initState() {
    super.initState();
    fetchTreatments();
    fetchUserProfile();
  }

  //simpan order
  Future<void> handleCheckout() async {
    if (selectedTreatment == null) return;
    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // 1. FORMAT DATA
      // Format tanggal untuk key database (YYYY-MM-DD)
      String dateKey = DateFormat('yyyy-MM-dd').format(pickupDate);

      // Logika alamat dinamis
      String displayAddress = (deliveryOption == "Antar Sendiri")
          ? "Pelanggan antar ke toko"
          : (currentUserProfile?.address ?? "Alamat belum diatur");

      // Format tanggal untuk pesan WhatsApp (Bahasa Indonesia)
      String formattedDate = DateFormat(
        'EEEE, dd MMMM yyyy',
        'id_ID',
      ).format(pickupDate);

      // 2. SIMPAN KE DATABASE (TABEL ORDERS)
      await supabase.from('orders').insert({
        'user_id': user?.id,
        'treatment_name': selectedTreatment!.name,
        'total_price': totalPrice,
        'pickup_date': pickupDate.toIso8601String(),
        'delivery_option': deliveryOption,
        'address': displayAddress,
        'status': 'pending',
      });

      // 3. UPDATE SLOT DI TABEL BOOKED_SLOTS (MENGGUNAKAN RPC)
      await supabase.rpc('increment_slot', params: {'target_date': dateKey});

      // 4. REFRESH DATA KALENDER
      await fetchBookedSlots();

      // 5. KIRIM KE WHATSAPP
      String waPhone = "6283121782648";
      String message =
          "*ORDER TREATMYSHOES*\n"
          "--------------------------\n"
          "👤 *Pelanggan:* ${currentUserProfile?.name ?? 'Anon'}\n"
          "📞 *No. HP:* ${currentUserProfile?.phone ?? '-'}\n"
          "🚚 *Metode:* $deliveryOption\n"
          "🏠 *Alamat/Ket:* $displayAddress\n"
          "--------------------------\n"
          "👟 *Layanan:* ${selectedTreatment?.name}\n"
          "🗓️ *Tanggal:* $formattedDate\n"
          "💰 *Total:* Rp $totalPrice\n"
          "--------------------------";

      // Menggunakan Uri.https jauh lebih aman daripada Uri.parse string manual
      final Uri waUri = Uri.https('wa.me', '/$waPhone', {'text': message});

      // Cek apakah perangkat bisa membuka URL tersebut
      if (await canLaunchUrl(waUri)) {
        await launchUrl(
          waUri,
          mode:
              LaunchMode.externalApplication, // Membuka langsung di aplikasi WA
        );
      } else {
        throw "Tidak dapat membuka WhatsApp. Pastikan aplikasi terinstall.";
      }

      // Opsi: Beri notifikasi sukses jika perlu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dibuat!")),
        );
      }
    } catch (e) {
      debugPrint("Error detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memproses pesanan: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 1. Logika Jasa
  Future<void> fetchTreatments() async {
    try {
      final data = await Supabase.instance.client.from('treatments').select();

      setState(() {
        if (data.isNotEmpty) {
          treatments = (data as List)
              .map((item) => Treatment.fromJson(item))
              .toList();
        } else {
          // Default data jika tabel di Supabase masih kosong
          treatments = [
            Treatment(name: "Fast Clean", price: 20000, baseDays: 1),
            Treatment(name: "Deep Clean", price: 25000, baseDays: 3),
            Treatment(name: "Un-yellowing", price: 30000, baseDays: 3),
            Treatment(name: "Repaint", price: 75000, baseDays: 5),
          ];
        }

        // Cari tanggal awal yang bukan hari libur
        pickupDate = BookingLogic.getFirstAvailableDate([]);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. LOGIKA PERHITUNGAN
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

  // 3. Di dalam _MenupageState:
  Map<String, dynamic> bookedData = {};
  // Variabel ini yang tadinya undefined
  bool isLoadingSlots = true;
  //4. simpan logic
  Future<void> saveOrder() async {
    // 5. Validasi: Pastikan user sudah memilih treatment
    if (selectedTreatment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih jenis treatment terlebih dahulu!"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    // Tampilkan loading saat proses simpan

    try {
      final supabase = Supabase.instance.client;

      // Ambil user ID yang sedang login (jika ada sistem login)
      final String? userId = supabase.auth.currentUser?.id;

      // Masukkan data ke tabel 'orders'
      await supabase.from('orders').insert({
        'user_id': userId, // Bisa null jika belum ada sistem login
        'treatment_id': selectedTreatment!.id,
        'treatment_name': selectedTreatment!.name,
        'pickup_date': pickupDate.toIso8601String(),
        'delivery_option': deliveryOption,
        'delivery_fee': deliveryFee,
        'total_price': totalPrice,
        'status': 'Pending', // Status awal pesanan
        'created_at': DateTime.now().toIso8601String(),
      });

      // Jika berhasil
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil!"),
            content: const Text(
              "Pesanan kamu telah diterima dan akan segera diproses.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman utama
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving order: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal membuat pesanan: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  //5. profle
  Future<void> fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          // Menggunakan model yang sudah kamu buat
          currentUserProfile = UserProfile.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch profile: $e");
    }
  }

  //6. book data
  Future<void> fetchBookedSlots() async {
    final data = await Supabase.instance.client
        .from('booked_slots')
        .select('date, total_orders, max_slot');

    setState(() {
      bookedData = {
        for (var item in data)
          item['date'].toString(): {
            'total': item['total_orders'] as int,
            'max': item['max_slot'] as int,
          },
      };
    });
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

              const SizedBox(height: 10),

              InlineCalendar(
                focusedDay: DateTime.now(),
                selectedDay: pickupDate,
                bookedData: bookedData,
                onDaySelected: (date) {
                  setState(() => pickupDate = date);
                  calculateTotal();
                },
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
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
                // Panggil handleCheckout, dan matikan tombol saat loading
                onPressed: (selectedTreatment == null || isLoading)
                    ? null
                    : () => handleCheckout(),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
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
